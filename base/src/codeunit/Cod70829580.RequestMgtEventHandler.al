codeunit 70829580 "PPHRDS_RequestMgtEventHandler"
{
    trigger OnRun()
    begin
    end;

    var
        RequisitionWkshName: Record "Requisition Wksh. Name";
        ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        MyNotifications: Record "My Notifications";
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
        RequestManagement: Codeunit PPHRDS_RequestManagement;
        ReqDocSysTempStorage: Codeunit PPHRDS_ReqDocSysTempStorage;
        ReqDocNotification: Codeunit PPHRDS_ReqDocNotification;
        DimensionManagement: Codeunit DimensionManagement;
        NewDimSetID: Integer;
        ShortcutDimension1Code: Code[20];
        ShortcutDimension2Code: Code[20];
        LineNoAssignedToReqErr: Label 'The Line No. %1. is assigned to Request No. %2.', Comment = '%1 = Line No. field, %2 = Request No.';
        TransOrderNoAssignedToReqErr: Label 'The Transfer Order No. %1. is assigned to Request No. %2.', Comment = '%1 = Transfer Order No. field, %2 = Request No.';

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure OnBeforeValidateEventQuantity(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer);
    begin
        if CurrFieldNo = 0 then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if (xRec.Quantity = Rec.Quantity) then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnModifyPurchaseLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; RunTrigger: Boolean);
    begin
        if IsNullGuid(Rec.SystemId) then
            exit;

        if (xRec."Buy-from Vendor No." = Rec."Buy-from Vendor No.") and
        (xRec.Type = Rec.Type) and
        (xRec."No." = Rec."No.") and
        (xRec."Location Code" = Rec."Location Code") and
        (xRec."Unit of Measure Code" = Rec."Unit of Measure Code") then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeValidateTransferFromCode', '', false, false)]
    // local procedure TransferHeaderOnBeforeValidateTransferFromCode(var TransferHeader: Record "Transfer Header"; var xTransferHeader: Record "Transfer Header"; var IsHandled: Boolean; var HideValidationDialog: Boolean)
    // begin
    //     // if RequestManagement.IsProcessedRequestEntryExist(TransferHeader."No.", ProcessedRequestEntry) then
    //     if RequestManagement.IsProcessedRequestEntryHeaderExist(TransferHeader.SystemId, ProcessedRequestEntry) then
    //         Error(TransOrderNoAssignedToReqErr, TransferHeader."No.", ProcessedRequestEntry."Request No.");
    // end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeValidateTransferToCode', '', false, false)]
    local procedure TransferHeaderOnBeforeValidateTransferToCode(var TransferHeader: Record "Transfer Header"; var xTransferHeader: Record "Transfer Header"; var IsHandled: Boolean; var HideValidationDialog: Boolean)
    begin
        if IsNullGuid(TransferHeader.SystemId) then
            exit;

        if RequestManagement.IsProcessedRequestEntryHeaderExist(TransferHeader.SystemId, ProcessedRequestEntry) then
            Error(TransOrderNoAssignedToReqErr, TransferHeader."No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnModifyTransferLine(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; RunTrigger: Boolean);
    begin
        if IsNullGuid(Rec.SystemId) then
            exit;

        if (xRec."Transfer-from Code" = Rec."Transfer-from Code") and
            (xRec."Transfer-to Code" = Rec."Transfer-to Code") and
            (xRec."Item No." = Rec."Item No.") and
            (xRec.Quantity = Rec.Quantity) and
            (xRec."Unit of Measure Code" = Rec."Unit of Measure Code")
        then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnModifyItemJournalLine(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; RunTrigger: Boolean);
    begin
        if not RunTrigger then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if (xRec."Document No." = Rec."Document No.") and
            (xRec."Item No." = Rec."Item No.") and
            (xRec."Location Code" = Rec."Location Code") and
            (xRec.Quantity = Rec.Quantity) and
            (xRec."Unit of Measure Code" = Rec."Unit of Measure Code") and
            (xRec."Gen. Prod. Posting Group" = Rec."Gen. Prod. Posting Group")
        then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure RequisitionLineOnAfterValidateEventType(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer);
    begin
        if CurrFieldNo = 0 then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if xRec.Type = Rec.Type then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure RequisitionLineOnAfterValidateEventNo(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer);
    begin
        if CurrFieldNo = 0 then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if xRec."No." = Rec."No." then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure RequisitionLineOnAfterValidateEventLocationCode(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer);
    begin
        if CurrFieldNo = 0 then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if xRec."Location Code" = Rec."Location Code" then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure RequisitionLineOnAfterValidateEventQuantity(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer);
    begin
        if CurrFieldNo = 0 then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if xRec.Quantity = Rec.Quantity then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'Unit of Measure Code', false, false)]
    local procedure RequisitionLineOnAfterValidateEventUnitofMeasureCode(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer);
    begin
        if CurrFieldNo = 0 then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if xRec."Unit of Measure Code" = Rec."Unit of Measure Code" then
            exit;

        if RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnModifyGenJournalLine(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; RunTrigger: Boolean);
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        RequestCode: Record PPHRDS_RequestCode;
    begin
        if not RunTrigger then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if not RequestManagement.IsProcessedRequestEntryExist(Rec.SystemId, ProcessedRequestEntry) then
            exit;

        RequestCode.Get(ProcessedRequestEntry."Request Code");
        GenJournalTemplate.Get(RequestCode."Journal Template Name");

        // if (xRec.Amount = Rec.Amount) and
        //     (xRec."Amount (LCY)" = Rec."Amount (LCY)")
        // then
        //     AllowGenJnlAmtChange := true
        // else
        //     AllowGenJnlAmtChange := RequestCode."Allow Editing Amount";

        case GenJournalTemplate.Type of
            GenJournalTemplate.Type::General:
                if RequestCode."Gen. Jnl. Account No." = '' then begin
                    if (xRec."Document No." = Rec."Document No.") and
                        (xRec."Bal. Account Type" = Rec."Bal. Account Type") and
                        (xRec."Bal. Account No." = Rec."Bal. Account No.") and
                        (xRec.Quantity = Rec.Quantity)
                    then
                        exit;
                end else
                    if (xRec."Document No." = Rec."Document No.") and
                        (xRec."Account Type" = Rec."Account Type") and
                        (xRec."Account No." = Rec."Account No.") and
                        (xRec."Bal. Account Type" = Rec."Bal. Account Type") and
                        (xRec."Bal. Account No." = Rec."Bal. Account No.") and
                        (xRec.Quantity = Rec.Quantity)
                    then
                        exit;
            GenJournalTemplate.Type::Payments:
                if (xRec."Document No." = Rec."Document No.") and
                    (xRec."Account Type" = Rec."Account Type") and
                    (xRec."Account No." = Rec."Account No.") and
                    (xRec.Quantity = Rec.Quantity)
                then
                    exit;
        end;

        Error(LineNoAssignedToReqErr, Rec."Line No.", ProcessedRequestEntry."Request No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeletePurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean);
    begin
        if not RunTrigger then
            exit;

        DeletePurchaseLine(Rec);
    end;

    local procedure DeletePurchaseLine(var Rec: Record "Purchase Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeDeletePurchaseLine(Rec, IsHandled);
        if IsHandled then
            exit;

        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Processed SystemId", Rec.SystemId);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        if ProcessedRequestEntry.FindFirst() then begin
            ProcessedRequestEntry.Status := ProcessedRequestEntry.Status::Cancelled;
            ProcessedRequestEntry."Processor User ID" := CopyStr(UserId(), 1, MaxStrLen(ProcessedRequestEntry."Processor User ID"));
            ProcessedRequestEntry.Modify(true);
            RequestManagement.UpdateReqLineQty(ProcessedRequestEntry."Request No.", ProcessedRequestEntry."Request Line No.");
        end;

        OnAfterDeletePurchaseLine(Rec, ProcessedRequestEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteTransferLine(var Rec: Record "Transfer Line"; RunTrigger: Boolean);
    begin
        if not RunTrigger then
            exit;

        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Processed SystemId", Rec.SystemId);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        if ProcessedRequestEntry.FindFirst() then begin
            ProcessedRequestEntry.Status := ProcessedRequestEntry.Status::Cancelled;
            ProcessedRequestEntry."Processor User ID" := CopyStr(UserId(), 1, MaxStrLen(ProcessedRequestEntry."Processor User ID"));
            ProcessedRequestEntry.Modify(true);
            RequestManagement.UpdateReqLineQty(ProcessedRequestEntry."Request No.", ProcessedRequestEntry."Request Line No.");
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteItemJournalLine(var Rec: Record "Item Journal Line"; RunTrigger: Boolean);
    begin
        if not RunTrigger then
            exit;

        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Processed SystemId", Rec.SystemId);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        if ProcessedRequestEntry.FindFirst() then begin
            ProcessedRequestEntry.Status := ProcessedRequestEntry.Status::Cancelled;
            ProcessedRequestEntry."Processor User ID" := CopyStr(UserId(), 1, MaxStrLen(ProcessedRequestEntry."Processor User ID"));
            ProcessedRequestEntry.Modify(true);
            RequestManagement.UpdateReqLineQty(ProcessedRequestEntry."Request No.", ProcessedRequestEntry."Request Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Req. Worksheet", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeletePageReqWorksheet(var Rec: Record "Requisition Line"; var AllowDelete: Boolean);
    begin
        if not AllowDelete then
            exit;

        if Rec."Demand Type" <> DATABASE::PPHRDS_ReqHeader then
            exit;

        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Processed SystemId", Rec.SystemId);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        if ProcessedRequestEntry.FindFirst() then begin
            ProcessedRequestEntry.Status := ProcessedRequestEntry.Status::Cancelled;
            ProcessedRequestEntry."Processor User ID" := CopyStr(UserId(), 1, MaxStrLen(ProcessedRequestEntry."Processor User ID"));
            ProcessedRequestEntry.Modify(true);
            RequestManagement.UpdateReqLineQty(ProcessedRequestEntry."Request No.", ProcessedRequestEntry."Request Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteGenJournalLine(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean);
    begin
        if not RunTrigger then
            exit;

        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Processed SystemId", Rec.SystemId);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        if ProcessedRequestEntry.FindFirst() then begin
            ProcessedRequestEntry.Status := ProcessedRequestEntry.Status::Cancelled;
            ProcessedRequestEntry."Processor User ID" := CopyStr(UserId(), 1, MaxStrLen(ProcessedRequestEntry."Processor User ID"));
            ProcessedRequestEntry.Modify(true);
            RequestManagement.UpdateReqLineQty(ProcessedRequestEntry."Request No.", ProcessedRequestEntry."Request Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure RequisitionLineOnBeforeInsertEvent(var Rec: Record "Requisition Line"; RunTrigger: Boolean);
    begin
        if not RunTrigger then
            exit;

        CheckReqWkshHasUsageRestrictions(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqHeader, 'OnCheckRequestReleaseRestrictions', '', false, false)]
    local procedure ReqHeaderOnCheckRequestReleaseRestrictions(sender: Record PPHRDS_ReqHeader)
    begin
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Doc. Attachment List Factbox", 'OnAfterGetRecRefFail', '', false, false)]
    local procedure DocumentAttachmentFactboxOnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
    begin
        case DocumentAttachment."Table ID" of
            Database::PPHRDS_ReqHeader:
                begin
                    RecRef.Open(DATABASE::PPHRDS_ReqHeader);
                    if ReqHeader.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(ReqHeader);
                end;
            Database::PPHRDS_ProcessedReqHeader:
                begin
                    RecRef.Open(DATABASE::PPHRDS_ProcessedReqHeader);
                    ProcessedReqHeader.SetRange("Request No.", DocumentAttachment."No.");
                    if ProcessedReqHeader.FindFirst() then
                        RecRef.GetTable(ProcessedReqHeader);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure DocumentAttachmentDetailsOnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean)
    var
        FieldRef: FieldRef;
    begin
        if RecRef.Number = Database::PPHRDS_ProcessedReqHeader then begin
            FieldRef := RecRef.Field(20);
            DocumentAttachment.SetRange("No.", FieldRef.Value);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertAttachment', '', false, false)]
    local procedure DocumentAttachmentOnBeforeInsertAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        case DocumentAttachment."Table ID" of
            Database::PPHRDS_ReqHeader:
                begin
                    DocumentAttachment."Document Type" := DocumentAttachment."Document Type"::PPHRDS_Request;
                    FieldRef := RecRef.Field(1);
                    DocumentAttachment."No." := FieldRef.Value;
                end;
            Database::PPHRDS_ProcessedReqHeader:
                begin
                    DocumentAttachment."Document Type" := DocumentAttachment."Document Type"::PPHRDS_Request;
                    FieldRef := RecRef.Field(20);
                    DocumentAttachment."No." := FieldRef.Value;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterCreateDim', '', false, false)]
    local procedure RequisitionLineOnAfterCreateDim(var ReqLine: Record "Requisition Line"; xReqLine: Record "Requisition Line")
    begin
        if ReqDocSysTempStorage.GetRequsitionLineCurrFieldNo() = 0 then
            exit;

        ShortcutDimension1Code := ReqLine."Shortcut Dimension 1 Code";
        ShortcutDimension2Code := ReqLine."Shortcut Dimension 2 Code";
        NewDimSetID := RequestManagement.CombineReqDimensions(ReqLine.RecordId, ReqLine."Dimension Set ID", ShortcutDimension1Code, ShortcutDimension2Code);
        if NewDimSetID = 0 then
            exit;

        if NewDimSetID <> ReqLine."Dimension Set ID" then begin
            ReqLine."Shortcut Dimension 1 Code" := ShortcutDimension1Code;
            ReqLine."Shortcut Dimension 2 Code" := ShortcutDimension2Code;
            ReqLine.Validate("Dimension Set ID", NewDimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(ReqLine."Dimension Set ID", ReqLine."Shortcut Dimension 1 Code", ReqLine."Shortcut Dimension 2 Code");
            ReqLine.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCreateDim', '', false, false)]
    local procedure GenJournalLineOnAfterCreateDim(CurrFieldNo: Integer; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if CurrFieldNo = 0 then
            exit;

        NewDimSetID := RequestManagement.CombineReqDimensions(GenJournalLine.RecordId, GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
        if NewDimSetID = 0 then
            exit;

        ShortcutDimension1Code := GenJournalLine."Shortcut Dimension 1 Code";
        ShortcutDimension2Code := GenJournalLine."Shortcut Dimension 2 Code";
        if NewDimSetID <> GenJournalLine."Dimension Set ID" then begin
            GenJournalLine.Validate("Dimension Set ID", NewDimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID", ShortcutDimension1Code, ShortcutDimension2Code);
            GenJournalLine.Modify(true);
        end;
    end;

    // Replaced by DimensionManagementOnAfterGetRecDefaultDimIDProcedure
    // [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterCreateDimTableIDs', '', false, false)]
    // local procedure RequisitionLineOnAfterCreateDimTableIDs(var RequisitionLine: Record "Requisition Line"; var FieldNo: Integer; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    // begin
    //     ReqDocSysTempStorage.ClearRequsitionLineCurrFieldNo();
    //     ReqDocSysTempStorage.SetRequsitionLineCurrFieldNo(FieldNo);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnAfterGetRecDefaultDimIDProcedure', '', false, false)]
    local procedure DimensionManagementOnAfterGetRecDefaultDimIDProcedure(RecVariant: Variant; CurrFieldNo: Integer)
    var
        locRecordRef: RecordRef;
    begin
        ReqDocSysTempStorage.ClearRequsitionLineCurrFieldNo();
        if RecVariant.IsRecord then
            locRecordRef.GetTable(RecVariant);
        if locRecordRef.Number = Database::"Requisition Line" then
            ReqDocSysTempStorage.SetRequsitionLineCurrFieldNo(CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure ItemJournalLineOnAfterSetupNewLine(var ItemJournalLine: Record "Item Journal Line"; var LastItemJournalLine: Record "Item Journal Line"; ItemJournalTemplate: Record "Item Journal Template")
    begin
        if not MyNotifications.IsEnabled(ReqDocNotification.GetItemJnlNotifID()) then
            exit;

        ReqDocSysTempStorage.ClearJnlTemplateAndBatchName();
        ReqDocSysTempStorage.SetJnlTemplateAndBatchName(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReqJnlManagement, 'OnAfterSetUpNewLine', '', false, false)]
    local procedure RequisitionLineOnAfterSetupNewLine(var ReqLine: Record "Requisition Line"; var LastReqLine: Record "Requisition Line")
    begin
        if not MyNotifications.IsEnabled(ReqDocNotification.GetReqWhstNotifID()) then
            exit;

        ReqDocSysTempStorage.ClearJnlTemplateAndBatchName();
        ReqDocSysTempStorage.SetJnlTemplateAndBatchName(ReqLine."Worksheet Template Name", ReqLine."Journal Batch Name");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnAfterGetAccounts', '', false, false)]
    local procedure GenJnlManagementOnAfterGetAccounts(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100]; var BalAccName: Text[100])
    begin
        if not MyNotifications.IsEnabled(ReqDocNotification.GetGenJnlNotifID()) then
            exit;

        ReqDocSysTempStorage.ClearJnlTemplateAndBatchName();
        ReqDocSysTempStorage.SetJnlTemplateAndBatchName(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure NotificationManagementOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        FieldRef: FieldRef;
    begin
        if RecRef.Number = Database::PPHRDS_ReqHeader then begin
            DocumentType := RecRef.Caption;
            FieldRef := RecRef.Field(1);
            DocumentNo := Format(FieldRef.Value);
            IsHandled := true;
        end;
    end;

    local procedure CheckReqWkshHasUsageRestrictions(RequisitionLine: Record "Requisition Line");
    var
        locRequisitionLine: Record "Requisition Line";
    begin
        RequisitionWkshName.Get(RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name");
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(RequisitionWkshName);

        locRequisitionLine.SetRange("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
        locRequisitionLine.SetRange("Journal Batch Name", RequisitionLine."Journal Batch Name");
        if locRequisitionLine.FindSet() then
            repeat
                RecordRestrictionMgt.CheckRecordHasUsageRestrictions(locRequisitionLine);
            until locRequisitionLine.Next() = 0;
    end;

    [Obsolete('Moved to PPHRDS_RequestMgtEventHandler codeunit. New procedure added in ver. 1.0.0.1')]
    local procedure IsProcessedRequestEntryExist(PurchaseDocumentType: enum "Purchase Document Type"; PurchaseDocumentNo: Code[20]; PurchaseDocumentLineNo: Integer): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::Purchase);
        ProcessedRequestEntry.SetRange("Purchase Document Type", PurchaseDocumentType);
        ProcessedRequestEntry.SetRange("Purchase Document No.", PurchaseDocumentNo);
        ProcessedRequestEntry.SetRange("Purchase Document Line No.", PurchaseDocumentLineNo);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    [Obsolete('Moved to PPHRDS_RequestMgtEventHandler codeunit. New procedure added in ver. 1.0.0.1')]
    local procedure IsProcessedRequestEntryExist(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; JournalLineNo: Integer; RequestNo: Code[20]; TableID: Integer): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Journal Template Name", JournalTemplateName);
        ProcessedRequestEntry.SetRange("Journal Batch Name", JournalBatchName);
        ProcessedRequestEntry.SetRange("Journal Line No.", JournalLineNo);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        case TableID of
            81:
                begin
                    ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"General Journal");
                    ProcessedRequestEntry.SetRange("Journal Document No.", RequestNo);
                end;
            83:
                begin
                    ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Item Journal");
                    ProcessedRequestEntry.SetRange("Journal Document No.", RequestNo);
                end;
            246:
                begin
                    ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Req. Worksheet");
                    ProcessedRequestEntry.SetRange("Request No.", RequestNo);
                end;
        end;
        exit(ProcessedRequestEntry.FindFirst());
    end;

    [Obsolete('Moved to PPHRDS_RequestMgtEventHandler codeunit. New procedure added in ver. 1.0.0.1')]
    local procedure IsProcessedRequestEntryExist(TransferOrderNo: Code[20]): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Transfer Order");
        ProcessedRequestEntry.SetRange("Transfer Order No.", TransferOrderNo);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    [Obsolete('Moved to PPHRDS_RequestMgtEventHandler codeunit. New procedure added in ver. 1.0.0.1')]
    local procedure IsProcessedRequestEntryExist(TransferOrderNo: Code[20]; TransferOrderLineNo: Integer): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Transfer Order");
        ProcessedRequestEntry.SetRange("Transfer Order No.", TransferOrderNo);
        ProcessedRequestEntry.SetRange("Transfer Order Line No.", TransferOrderLineNo);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterTableHasNumberFieldPrimaryKey, '', false, false)]
    local procedure OnAfterSetDocumentAttachmentFiltersForRecRefInternal(var FieldNo: Integer; TableNo: Integer; var Result: Boolean)
    begin
        if TableNo <> Database::PPHRDS_ReqHeader then
            exit;

        FieldNo := 1;
        Result := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeletePurchaseLine(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeletePurchaseLine(var PurchaseLine: Record "Purchase Line"; ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry)
    begin
    end;
}
