codeunit 70829575 "PPHRDS_RequestManagement"
{
    trigger OnRun();
    begin
    end;

    var
        User: Record User;
        ReqDocSysUserSetup: Record PPHRDS_ReqDocSysUserSetup;
        ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
        ProcessedReqEntryExist: Boolean;
        REQNoSeriesCodeTxt: Label 'REQ';
        ProcREQNoSeriesCodeTxt: Label 'REQ+';

    procedure InitializeDefaultSetup();
    var
        DefaultSetupInitMsg: Label 'The default setup has been initialized.';
        IsHandled: Boolean;
    begin
        OnBeforeInitializeDefaultSetup(IsHandled);
        if IsHandled then
            exit;

        InitializeReqDocSysSetup();
        CreateRequestCode();
        CreateReqDocUsers();

        if not GuiAllowed then
            Message(DefaultSetupInitMsg);
    end;

    local procedure CreateRequestCode()
    var
        RequestCode: Record PPHRDS_RequestCode;
        GenJournalTemplate: Record "Gen. Journal Template";
        DefPaymentJournalTemplateTxt: Label 'PAYMENT';
    begin
        // Create Request Code
        RequestCode.Init();
        RequestCode.Validate(Code, 'QUOTE');
        RequestCode.Validate(Description, 'Purchase Quote');
        RequestCode.Validate(Type, RequestCode.Type::Purchase);
        RequestCode.Validate("Purchase Document Type", RequestCode."Purchase Document Type"::Quote);
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'ORDER');
        RequestCode.Validate(Description, 'Purchase Order');
        RequestCode.Validate(Type, RequestCode.Type::Purchase);
        RequestCode.Validate("Purchase Document Type", RequestCode."Purchase Document Type"::Order);
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'INVOICE');
        RequestCode.Validate(Description, 'Purchase Invoice');
        RequestCode.Validate(Type, RequestCode.Type::Purchase);
        RequestCode.Validate("Purchase Document Type", RequestCode."Purchase Document Type"::Invoice);
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'TRANSFER');
        RequestCode.Validate(Description, 'Transfer Order');
        RequestCode.Validate(Type, RequestCode.Type::"Transfer Order");
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'POSADJ');
        RequestCode.Validate(Description, 'Positive Adjustment');
        RequestCode.Validate(Type, RequestCode.Type::"Item Journal");
        RequestCode.Validate("Entry Type", RequestCode."Entry Type"::"Positive Adjmt.");
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'NEGADJ');
        RequestCode.Validate(Description, 'Negative Adjustment');
        RequestCode.Validate(Type, RequestCode.Type::"Item Journal");
        RequestCode.Validate("Entry Type", RequestCode."Entry Type"::"Negative Adjmt.");
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'REQWHST');
        RequestCode.Validate(Description, 'Requisition Worksheet');
        RequestCode.Validate(Type, RequestCode.Type::"Req. Worksheet");
        RequestCode.Validate(Active, true);
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'CASHADVANCE');
        RequestCode.Validate(Description, 'Cash Advance');
        RequestCode.Validate(Type, RequestCode.Type::"General Journal");
        if GenJournalTemplate.Get(DefPaymentJournalTemplateTxt) then begin
            RequestCode.Validate("Journal Template Name", GenJournalTemplate.Name);
            RequestCode.Validate(Active, true);
        end;
        if RequestCode.Insert(true) then;

        RequestCode.Init();
        RequestCode.Validate(Code, 'PAYMENT');
        RequestCode.Validate(Description, 'Payment');
        RequestCode.Validate(Type, RequestCode.Type::"General Journal");
        if GenJournalTemplate.Get(DefPaymentJournalTemplateTxt) then begin
            RequestCode.Validate("Journal Template Name", GenJournalTemplate.Name);
            RequestCode.Validate(Active, true);
        end;
        if RequestCode.Insert(true) then;
    end;

    local procedure InitializeReqDocSysSetup()
    var
        ReqDocSysSetup: Record PPHRDS_ReqDocSysSetup;
    begin
        if not ReqDocSysSetup.Insert() then
            ReqDocSysSetup.Get();

        CreateReqNoSeries();

        if ReqDocSysSetup."Request Nos." = '' then
            ReqDocSysSetup.Validate("Request Nos.", REQNoSeriesCodeTxt);
        if ReqDocSysSetup."Processed Request Nos." = '' then
            ReqDocSysSetup.Validate("Processed Request Nos.", ProcREQNoSeriesCodeTxt);
        ReqDocSysSetup.Modify();
    end;

    local procedure CreateReqNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        StartNo: Code[20];
        EndNo: Code[20];
        REQNoSeriesDescTxt: Label 'Request Document';
        REQStartNoTxt: Label 'REQ000001';
        REQEndNoTxt: Label 'REQ999999';
        ProcREQNoSeriesDescTxt: Label 'Processed Request Document';
        ProcREQStartNoTxt: Label 'PREQ000001';
        ProcREQSEndNoTxt: Label 'PREQ999999';
    begin
        if not NoSeries.Get(REQNoSeriesCodeTxt) then begin
            NoSeries.Init();
            NoSeries.Code := REQNoSeriesCodeTxt;
            NoSeries.Description := REQNoSeriesDescTxt;
            NoSeries.Validate("Default Nos.", true);
            NoSeries.Insert();

            if not NoSeriesLine.Get(REQNoSeriesCodeTxt, 10000) then begin
                StartNo := REQStartNoTxt;
                EndNo := REQEndNoTxt;
                NoSeriesLine.Init();
                NoSeriesLine.Validate("Series Code", REQNoSeriesCodeTxt);
                NoSeriesLine.Validate("Line No.", 10000);
                NoSeriesLine."Starting Date" := WorkDate();
                NoSeriesLine.Validate("Starting No.", StartNo);
                NoSeriesLine.Validate("Ending No.", EndNo);
                NoSeriesLine.Insert(true);
            end;
        end;

        if not NoSeries.Get(ProcREQNoSeriesCodeTxt) then begin
            NoSeries.Init();
            NoSeries.Code := ProcREQNoSeriesCodeTxt;
            NoSeries.Description := ProcREQNoSeriesDescTxt;
            NoSeries.Validate("Default Nos.", true);
            NoSeries.Insert();

            if not NoSeriesLine.Get(ProcREQNoSeriesCodeTxt, 10000) then begin
                StartNo := ProcREQStartNoTxt;
                EndNo := ProcREQSEndNoTxt;
                NoSeriesLine.Init();
                NoSeriesLine."Series Code" := ProcREQNoSeriesCodeTxt;
                NoSeriesLine.Validate("Line No.", 10000);
                NoSeriesLine."Starting Date" := WorkDate();
                NoSeriesLine.Validate("Starting No.", StartNo);
                NoSeriesLine.Validate("Ending No.", EndNo);
                NoSeriesLine.Insert(true);
            end;
        end;
    end;

    procedure CreateReqDocUsers()
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        User.Reset();
        if EnvironmentInfo.IsSaaS() then
            User.SetFilter("License Type", '<>%1&<>%2', User."License Type"::"External User", User."License Type"::Application);
        User.SetRange(State, User.State::Enabled);
        if User.FindSet() then
            repeat
                if not ReqDocSysUserSetup.Get(User."User Name") then begin
                    ReqDocSysUserSetup.Init();
                    ReqDocSysUserSetup.Validate("Requestor ID", User."User Name");
                    ReqDocSysUserSetup.Insert();
                end;
            until User.Next() = 0;
    end;

    procedure RequestorIDFilter(parUserID: Text): Boolean
    begin
        if not ReqDocSysUserSetup.Get(parUserId) then
            exit(false);

        if ReqDocSysUserSetup."Requestor ID Filter" then
            exit(true)
        else
            exit(false);
    end;

    procedure GetFiscalYear(parCurrDate: Date; var varStartDate: Date; var varEndDate: Date): Text[250];
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.Reset();
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod."Starting Date" := parCurrDate;
        AccountingPeriod.Find('=<');
        varStartDate := AccountingPeriod."Starting Date";
        if AccountingPeriod.Next() = 0 then
            varEndDate := 99991231D
        else
            varEndDate := AccountingPeriod."Starting Date" - 1;
    end;

    procedure LookUpUserName(): Code[50];
    var
        Users: Page Users;
    begin
        Clear(Users);
        Users.LookupMode := true;
        if (Users.RunModal() = ACTION::LookupOK) then begin
            Users.GetRecord(User);
            exit(User."User Name");
        end;
    end;

    procedure GetUserFullName(Username: code[50]): Text[80]
    begin
        User.Reset();
        User.SetRange("User Name", Username);
        if User.FIND('=><') then
            exit(User."Full Name");
    end;

    procedure LineReqTypeToPurchType(ReqLineType: Enum PPHRDS_ReqLineType): Enum "Purchase Line Type";
    var
        PurchLineType: Enum "Purchase Line Type";
    begin
        case ReqLineType of
            ReqLineType::"G/L Account":
                exit(PurchLineType::"G/L Account");
            ReqLineType::Item:
                exit(PurchLineType::Item);
            ReqLineType::"Fixed Asset":
                exit(PurchLineType::"Fixed Asset");
        end;
    end;

    procedure ProcessedReqShowDoc(parProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry);
    var
        locPurchaseHeader: Record "Purchase Header";
        locTransferHeader: Record "Transfer Header";
        locItemJournalLine: Record "Item Journal Line";
        locRequisitionLine: Record "Requisition Line";
        locGenJournalLine: Record "Gen. Journal Line";
        PurchaseQuoteDoc: Page "Purchase Quote";
        PurchaseOrderDoc: Page "Purchase Order";
        PurchaseInvoiceDoc: Page "Purchase Invoice";
        PurchaseCreditMemoDoc: Page "Purchase Credit Memo";
        BlanketPurchaseOrderDoc: Page "Blanket Purchase Order";
        PurchaseReturnOrderDoc: Page "Purchase Return Order";
        TransferOrderDoc: Page "Transfer Order";
        ItemJournal: Page "Item Journal";
        ReqWorksheet: Page "Req. Worksheet";
        GeneralJournal: Page "General Journal";
        PaymentJournal: Page "Payment Journal";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        case parProcessedRequestEntry."Request Type" of
            parProcessedRequestEntry."Request Type"::Purchase:
                begin
                    locPurchaseHeader.Get(parProcessedRequestEntry."Purchase Document Type", parProcessedRequestEntry."Purchase Document No.");
                    case parProcessedRequestEntry."Purchase Document Type" of
                        parProcessedRequestEntry."Purchase Document Type"::Quote:
                            begin
                                Clear(PurchaseQuoteDoc);
                                PurchaseQuoteDoc.SetRecord(locPurchaseHeader);
                                PurchaseQuoteDoc.Editable(false);
                                PurchaseQuoteDoc.RunModal();
                            end;
                        parProcessedRequestEntry."Purchase Document Type"::Order:
                            begin
                                Clear(PurchaseOrderDoc);
                                PurchaseOrderDoc.SetRecord(locPurchaseHeader);
                                PurchaseOrderDoc.Editable(false);
                                PurchaseOrderDoc.RunModal();
                            end;
                        parProcessedRequestEntry."Purchase Document Type"::Invoice:
                            begin
                                Clear(PurchaseInvoiceDoc);
                                PurchaseInvoiceDoc.SetRecord(locPurchaseHeader);
                                PurchaseInvoiceDoc.Editable(false);
                                PurchaseInvoiceDoc.RunModal();
                            end;
                        parProcessedRequestEntry."Purchase Document Type"::"Credit Memo":
                            begin
                                Clear(PurchaseCreditMemoDoc);
                                PurchaseCreditMemoDoc.SetRecord(locPurchaseHeader);
                                PurchaseCreditMemoDoc.Editable(false);
                                PurchaseCreditMemoDoc.RunModal();
                            end;
                        parProcessedRequestEntry."Purchase Document Type"::"Blanket Order":
                            begin
                                Clear(BlanketPurchaseOrderDoc);
                                BlanketPurchaseOrderDoc.SetRecord(locPurchaseHeader);
                                BlanketPurchaseOrderDoc.Editable(false);
                                BlanketPurchaseOrderDoc.RunModal();
                            end;
                        parProcessedRequestEntry."Purchase Document Type"::"Return Order":
                            begin
                                Clear(PurchaseReturnOrderDoc);
                                PurchaseReturnOrderDoc.SetRecord(locPurchaseHeader);
                                PurchaseReturnOrderDoc.Editable(false);
                                PurchaseReturnOrderDoc.RunModal();
                            end;
                    end;
                end;
            parProcessedRequestEntry."Request Type"::"Transfer Order":
                begin
                    locTransferHeader.Get(parProcessedRequestEntry."Transfer Order No.");
                    Clear(TransferOrderDoc);
                    TransferOrderDoc.SetRecord(locTransferHeader);
                    TransferOrderDoc.Editable(false);
                    TransferOrderDoc.RunModal();
                end;
            parProcessedRequestEntry."Request Type"::"Item Journal":
                begin
                    locItemJournalLine.Reset();
                    locItemJournalLine.SetRange("Journal Template Name", parProcessedRequestEntry."Journal Template Name");
                    locItemJournalLine.SetRange("Journal Batch Name", parProcessedRequestEntry."Journal Batch Name");
                    if locItemJournalLine.FindFirst() then;
                    Clear(ItemJournal);
                    ItemJournal.SetRecord(locItemJournalLine);
                    ItemJournal.Editable(false);
                    ItemJournal.RunModal();
                end;
            parProcessedRequestEntry."Request Type"::"Req. Worksheet":
                begin
                    locRequisitionLine.Reset();
                    locRequisitionLine.SetRange("Worksheet Template Name", parProcessedRequestEntry."Journal Template Name");
                    locRequisitionLine.SetRange("Journal Batch Name", parProcessedRequestEntry."Journal Batch Name");
                    if locRequisitionLine.FindFirst() then;
                    Clear(ReqWorksheet);
                    ReqWorksheet.SetRecord(locRequisitionLine);
                    ReqWorksheet.Editable(false);
                    ReqWorksheet.RunModal();
                end;
            parProcessedRequestEntry."Request Type"::"General Journal":
                begin
                    locGenJournalLine.Reset();
                    locGenJournalLine.SetRange("Journal Template Name", parProcessedRequestEntry."Journal Template Name");
                    locGenJournalLine.SetRange("Journal Batch Name", parProcessedRequestEntry."Journal Batch Name");
                    if locGenJournalLine.FindFirst() then;
                    Clear(GeneralJournal);
                    GenJournalTemplate.Get(parProcessedRequestEntry."Journal Template Name");
                    case GenJournalTemplate."Page ID" of
                        39:
                            begin
                                GeneralJournal.SetRecord(locGenJournalLine);
                                GeneralJournal.Editable(false);
                                GeneralJournal.RunModal();
                            end;
                        256:
                            begin
                                PaymentJournal.SetRecord(locGenJournalLine);
                                PaymentJournal.Editable(false);
                                PaymentJournal.RunModal();
                            end;
                    end;
                end;
        end;
    end;

    procedure ProcessedReqDocExist(parProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry): Boolean;
    var
        locPurchaseHeader: Record "Purchase Header";
        locTransferHeader: Record "Transfer Header";
        locItemJournalLine: Record "Item Journal Line";
        locRequisitionLine: Record "Requisition Line";
        locGenJournalLine: Record "Gen. Journal Line";
    begin
        case parProcessedRequestEntry."Request Type" of
            parProcessedRequestEntry."Request Type"::Purchase:
                exit(locPurchaseHeader.Get(parProcessedRequestEntry."Purchase Document Type", parProcessedRequestEntry."Purchase Document No."));
            parProcessedRequestEntry."Request Type"::"Transfer Order":
                exit(locTransferHeader.Get(parProcessedRequestEntry."Transfer Order No."));
            parProcessedRequestEntry."Request Type"::"Item Journal":
                begin
                    locItemJournalLine.Reset();
                    locItemJournalLine.SetRange("Journal Template Name", parProcessedRequestEntry."Journal Template Name");
                    locItemJournalLine.SetRange("Journal Batch Name", parProcessedRequestEntry."Journal Batch Name");
                    exit(not locItemJournalLine.IsEmpty());
                end;
            parProcessedRequestEntry."Request Type"::"Req. Worksheet":
                begin
                    locRequisitionLine.Reset();
                    locRequisitionLine.SetRange("Worksheet Template Name", parProcessedRequestEntry."Journal Template Name");
                    locRequisitionLine.SetRange("Journal Batch Name", parProcessedRequestEntry."Journal Batch Name");
                    exit(not locRequisitionLine.IsEmpty());
                end;
            parProcessedRequestEntry."Request Type"::"General Journal":
                begin
                    locGenJournalLine.Reset();
                    locGenJournalLine.SetRange("Journal Template Name", parProcessedRequestEntry."Journal Template Name");
                    locGenJournalLine.SetRange("Journal Batch Name", parProcessedRequestEntry."Journal Batch Name");
                    exit(not locGenJournalLine.IsEmpty());
                end;
        end;
    end;

    procedure UpdateReqLineQty(parDocumentNo: Code[20]; parLineNo: Integer);
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        LocReqLine: Record PPHRDS_ReqLine;
    begin
        if ReqHeader.Get(parDocumentNo) then
            ReqHeader.TestField(Status, ReqHeader.Status::Released);

        if locReqLine.Get(parDocumentNo, parLineNo) then begin
            LocReqLine.InitOutstanding();
            LocReqLine.InitQtyToReceive();
            UpdateReqLineQtyOnBeforeModify(locReqLine);
            LocReqLine.Modify();
        end;
    end;

    procedure GetRecurringRequestLines(ReqHeader: Record PPHRDS_ReqHeader)
    var
        StandardPurchaseCode: Record "Standard Purchase Code";
        StandardPurchaseCodes: Page "Standard Purchase Codes";
    begin
        ReqHeader.TestField("No.");

        StandardPurchaseCodes.SetTableView(StandardPurchaseCode);
        StandardPurchaseCodes.LookupMode(true);
        if StandardPurchaseCodes.RunModal() = ACTION::LookupOK then begin
            StandardPurchaseCodes.PPHRDS_GetSelected(StandardPurchaseCode);
            if StandardPurchaseCode.FindSet() then
                repeat
                    ApplyStdCodesToRequestLines(ReqHeader, StandardPurchaseCode);
                until StandardPurchaseCode.Next() = 0;
        end;
    end;

    procedure IsProcessedRequestEntryExist(SystemID: Guid; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsProcessedRequestEntryExist(SystemID, ProcessedReqEntry, IsHandled, Result);
        if IsHandled then
            exit(Result);

        ProcessedReqEntryExist := IsProcessedRequestEntryExist(SystemID);
        ProcessedReqEntry := ProcessedRequestEntry;
        exit(ProcessedReqEntryExist);
    end;

    procedure IsProcessedRequestEntryHeaderExist(SystemID: Guid; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsProcessedRequestEntryHeaderExist(SystemID, ProcessedReqEntry, IsHandled, Result);
        if IsHandled then
            exit(Result);

        ProcessedReqEntryExist := IsProcessedRequestEntryHeaderExist(SystemID);
        ProcessedReqEntry := ProcessedRequestEntry;
        exit(ProcessedReqEntryExist);
    end;

    procedure IsProcessedRequestEntryExist(SystemId: Guid): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        ProcessedRequestEntry.SetRange("Processed SystemId", SystemId);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    procedure IsProcessedRequestEntryHeaderExist(SystemId: Guid): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        ProcessedRequestEntry.SetRange("Processed SystemId (Header)", SystemId);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    procedure IsProcessedRequestEntryExist(TransferOrderNo: Code[20]): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Transfer Order");
        ProcessedRequestEntry.SetRange("Transfer Order No.", TransferOrderNo);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    procedure IsProcessedRequestEntryExist(TransferOrderNo: Code[20]; TransferOrderLineNo: Integer): Boolean
    begin
        ProcessedRequestEntry.Reset();
        ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Transfer Order");
        ProcessedRequestEntry.SetRange("Transfer Order No.", TransferOrderNo);
        ProcessedRequestEntry.SetRange("Transfer Order Line No.", TransferOrderLineNo);
        ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        exit(ProcessedRequestEntry.FindFirst());
    end;

    local procedure ApplyStdCodesToRequestLines(ReqHeader: Record PPHRDS_ReqHeader; StdPurchCode: Record "Standard Purchase Code")
    var
        StdPurchLine: Record "Standard Purchase Line";
        locReqLine: Record PPHRDS_ReqLine;
    begin
        StdPurchLine.SetRange("Standard Purchase Code", StdPurchCode.Code);
        StdPurchLine.SetFilter(Type, '<>%1', StdPurchLine.Type::"Charge (Item)");

        StdPurchLine.LockTable();
        if StdPurchLine.Find('-') then
            repeat

                locReqLine.Init();
                locReqLine.Validate("Document No.", ReqHeader."No.");
                if StdPurchLine.Type = StdPurchLine.Type::" " then begin
                    locReqLine.Validate("No.", StdPurchLine."No.");
                    locReqLine.Description := StdPurchLine.Description;
                end else
                    if not StdPurchLine.EmptyLine() then begin
                        case StdPurchLine.Type of
                            StdPurchLine.Type::"G/L Account":
                                locReqLine.Validate(Type, locReqLine.Type::"G/L Account");
                            StdPurchLine.Type::Item:
                                locReqLine.Validate(Type, locReqLine.Type::Item);
                            StdPurchLine.Type::"Fixed Asset":
                                locReqLine.Validate(Type, locReqLine.Type::"Fixed Asset");
                        end;

                        locReqLine.Validate("No.", StdPurchLine."No.");
                        locReqLine.Validate(Quantity, StdPurchLine.Quantity);
                        if StdPurchLine."Unit of Measure Code" <> '' then
                            locReqLine.Validate("Unit of Measure Code", StdPurchLine."Unit of Measure Code");
                        if StdPurchLine.Description <> '' then
                            locReqLine.Validate(Description, StdPurchLine.Description);
                        if StdPurchLine."Amount Excl. VAT" <> 0 then
                            locReqLine.Validate("Direct Unit Cost", StdPurchLine."Amount Excl. VAT");
                    end;

                locReqLine."Shortcut Dimension 1 Code" := StdPurchLine."Shortcut Dimension 1 Code";
                locReqLine."Shortcut Dimension 2 Code" := StdPurchLine."Shortcut Dimension 2 Code";

                // CombineReqDimensions(locReqLine, StdPurchLine);
                Clear(DimensionSetIDArr);
                DimensionSetIDArr[1] := locReqLine."Dimension Set ID";
                DimensionSetIDArr[2] := StdPurchLine."Dimension Set ID";

                locReqLine."Dimension Set ID" :=
                  DimensionManagement.GetCombinedDimensionSetID(
                    DimensionSetIDArr, locReqLine."Shortcut Dimension 1 Code", locReqLine."Shortcut Dimension 2 Code");

                if StdPurchLine.InsertLine() then begin
                    locReqLine."Line No." := GetNextReqLineNo(locReqLine);
                    locReqLine.Insert(true);
                end;

            until StdPurchLine.Next() = 0;
    end;

    procedure CombineReqDimensions(RecID: RecordId; TargetDimensionSetID: Integer; var ShortcutDimension1Code: Code[20]; var ShortcutDimension2Code: Code[20]): Integer;
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemJournalLine: Record "Item Journal Line";
        RequisitionLine: Record "Requisition Line";
        GenJournalLine: Record "Gen. Journal Line";
        ReqDocExist: Boolean;
        SourceDimensionSetID: Integer;
    begin
        case RecID.TableNo of
            38:
                begin
                    if not PurchaseHeader.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(PurchaseHeader.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID (Header)";
                end;
            39:
                begin
                    if not PurchaseLine.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(PurchaseLine.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID";
                end;
            83:
                begin
                    if not ItemJournalLine.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(ItemJournalLine.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID";
                end;
            81:
                begin
                    if not GenJournalLine.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(GenJournalLine.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID";
                end;
            246:
                begin
                    if not RequisitionLine.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(RequisitionLine.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID";
                end;
            5740:
                begin
                    if not TransferHeader.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(TransferHeader.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID (Header)";
                end;
            5741:
                begin
                    if not TransferLine.Get(RecID) then
                        exit(0);

                    ReqDocExist := IsProcessedRequestEntryExist(TransferLine.SystemId, ProcessedRequestEntry);
                    SourceDimensionSetID := ProcessedRequestEntry."Dimension Set ID";
                end;
        end;

        if not ReqDocExist then
            exit(0);

        if SourceDimensionSetID = 0 then
            exit(0);

        if TargetDimensionSetID = SourceDimensionSetID then
            exit(0);

        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := TargetDimensionSetID;
        DimensionSetIDArr[2] := SourceDimensionSetID;
        exit(DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code));
    end;

    local procedure GetNextReqLineNo(ReqLine: Record PPHRDS_ReqLine): Integer
    begin
        ReqLine.SetRange("Document No.", ReqLine."Document No.");
        if ReqLine.FindLast() then
            exit(ReqLine."Line No." + 10000);

        exit(10000);
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(PurchaseDocumentType: enum "Purchase Document Type"; PurchaseDocumentNo: Code[20]; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    begin
        // ProcessedReqEntryExist := IsProcessedRequestEntryExist(PurchaseDocumentType, PurchaseDocumentNo);
        // ProcessedReqEntry := ProcessedRequestEntry;
        // exit(ProcessedReqEntryExist);
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(PurchaseDocumentType: enum "Purchase Document Type"; PurchaseDocumentNo: Code[20]; PurchaseDocumentLineNo: Integer; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    begin
        // ProcessedReqEntryExist := IsProcessedRequestEntryExist(PurchaseDocumentType, PurchaseDocumentNo, PurchaseDocumentLineNo);
        // ProcessedReqEntry := ProcessedRequestEntry;
        // exit(ProcessedReqEntryExist);
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; JournalLineNo: Integer; RequestNo: Code[20]; TableID: Integer; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    begin
        // ProcessedReqEntryExist := IsProcessedRequestEntryExist(JournalTemplateName, JournalBatchName, JournalLineNo, RequestNo, TableID);
        // ProcessedReqEntry := ProcessedRequestEntry;
        // exit(ProcessedReqEntryExist);
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(TransferOrderNo: Code[20]; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    begin
        // ProcessedReqEntryExist := IsProcessedRequestEntryExist(TransferOrderNo);
        // ProcessedReqEntry := ProcessedRequestEntry;
        // exit(ProcessedReqEntryExist);
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(TransferOrderNo: Code[20]; TransferOrderLineNo: Integer; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry): Boolean
    begin
        // ProcessedReqEntryExist := IsProcessedRequestEntryExist(TransferOrderNo, TransferOrderLineNo);
        // ProcessedReqEntry := ProcessedRequestEntry;
        // exit(ProcessedReqEntryExist);
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(PurchaseDocumentType: enum "Purchase Document Type"; PurchaseDocumentNo: Code[20]): Boolean
    begin
        // ProcessedRequestEntry.Reset();
        // ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::Purchase);
        // ProcessedRequestEntry.SetRange("Purchase Document Type", PurchaseDocumentType);
        // ProcessedRequestEntry.SetRange("Purchase Document No.", PurchaseDocumentNo);
        // ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        // exit(ProcessedRequestEntry.FindFirst());
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(PurchaseDocumentType: enum "Purchase Document Type"; PurchaseDocumentNo: Code[20]; PurchaseDocumentLineNo: Integer): Boolean
    begin
        // ProcessedRequestEntry.Reset();
        // ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::Purchase);
        // ProcessedRequestEntry.SetRange("Purchase Document Type", PurchaseDocumentType);
        // ProcessedRequestEntry.SetRange("Purchase Document No.", PurchaseDocumentNo);
        // ProcessedRequestEntry.SetRange("Purchase Document Line No.", PurchaseDocumentLineNo);
        // ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        // exit(ProcessedRequestEntry.FindFirst());
    end;

    [Obsolete('Implemented SystemId in IsProcessedRequestEntryHeaderExist procedure. New procedure added in ver. 1.0.0.1')]
    procedure IsProcessedRequestEntryExist(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; JournalLineNo: Integer; RequestNo: Code[20]; TableID: Integer): Boolean
    begin
        // ProcessedRequestEntry.Reset();
        // ProcessedRequestEntry.SetRange("Journal Template Name", JournalTemplateName);
        // ProcessedRequestEntry.SetRange("Journal Batch Name", JournalBatchName);
        // ProcessedRequestEntry.SetRange("Journal Line No.", JournalLineNo);
        // ProcessedRequestEntry.SetRange(Status, ProcessedRequestEntry.Status::Processed);
        // case TableID of
        //     81:
        //         begin
        //             ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"General Journal");
        //             ProcessedRequestEntry.SetRange("Journal Document No.", RequestNo);
        //         end;
        //     83:
        //         begin
        //             ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Item Journal");
        //             ProcessedRequestEntry.SetRange("Journal Document No.", RequestNo);
        //         end;
        //     246:
        //         begin
        //             ProcessedRequestEntry.SetRange("Request Type", ProcessedRequestEntry."Request Type"::"Req. Worksheet");
        //             ProcessedRequestEntry.SetRange("Request No.", RequestNo);
        //         end;
        // end;
        // exit(ProcessedRequestEntry.FindFirst());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsProcessedRequestEntryExist(SystemID: Guid; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry; var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsProcessedRequestEntryHeaderExist(SystemID: Guid; var ProcessedReqEntry: Record PPHRDS_ProcessedRequestEntry; var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure UpdateReqLineQtyOnBeforeModify(var ReqLine: Record PPHRDS_ReqLine);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitializeDefaultSetup(var IsHandled: Boolean);
    begin
    end;
}
