codeunit 70829620 PPHRDS_ProcessRequestDocument
{
    TableNo = PPHRDS_ReqHeader;

    trigger OnRun();
    begin
    end;

    var
        RequestSetup: Record PPHRDS_ReqDocSysSetup;
        RequestCode: Record PPHRDS_RequestCode;
        ReqHeader: Record PPHRDS_ReqHeader;
        RequestManagement: Codeunit PPHRDS_RequestManagement;
        NoSeries: Codeunit "No. Series";
        RequestApprovalMgt: Codeunit PPHRDS_RequestApprovalMgt;
        DimensionManagement: Codeunit DimensionManagement;
        ReqDoc: List of [Text];
        ReqNo: Code[20];
        LineNo: Integer;
        ReqLineCtr: Integer;
        ShortcutDimension1Code: Code[20];
        ShortcutDimension2Code: Code[20];
        DimSetID: Integer;
        ReqDocDimConflict: List of [Text];
        DimConfictExist: Boolean;
        HeaderRecSysId: Guid;
        LineRecSysId: Guid;
        DimensionSetIDArr: array[10] of Integer;
        NothingToProcessErr: Label 'There is nothing to process.';
        ReqLinesProcessMsg: Label 'There are a total of %1 request lines processed.', Comment = '%1 = Total request document processed.';

    procedure ProcessRequest(PurchaseHeader: Record "Purchase Header"; var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locPurchaseLine: Record "Purchase Line";
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        IsHandled: Boolean;
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeProcessPurchaseHeader(PurchaseHeader, TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;

        Clear(ReqDoc);
        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                if not ReqDoc.Contains(TempReqLine."Document No.") then
                    ReqDoc.Add(TempReqLine."Document No.")
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        foreach ReqNo in ReqDoc do begin

            // Header
            ReqHeader.Get(ReqNo);
            if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                ReqHeader.TestField(Status, ReqHeader.Status::Released);
            if not ReqHeader.Find() then
                Error(NothingToProcessErr);

            CheckAndUpdate(ReqHeader);
            InsertProcessedHeader(ReqHeader, locProcessedReqHeader);

            // Line
            TempReqLine.Reset();
            TempReqLine.SetRange("Document No.", ReqHeader."No.");
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindSet() then
                repeat

                    locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                    locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                    InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);
                    CreatePurchaseLine(locReqLine, PurchaseHeader, locPurchaseLine, LineRecSysId);
                    InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                    locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                    locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                    locProcessedRequestEntry."Purchase Document Type" := LocPurchaseLine."Document Type";
                    locProcessedRequestEntry."Purchase Document No." := LocPurchaseLine."Document No.";
                    locProcessedRequestEntry."Purchase Document Line No." := LocPurchaseLine."Line No.";
                    locProcessedRequestEntry."Processed SystemId" := LineRecSysId;
                    locProcessedRequestEntry.Modify(true);

                    IsHandledApplyDim := false;
                    ProcessRequestPurchaseLineOnBeforeApplyDim(locReqLine, PurchaseHeader, locPurchaseLine, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locPurchaseLine);

                    locReqLine.InitOutstanding();
                    locReqLine.InitQtyToReceive();
                    locReqLine.Modify();

                    TempReqLine.Delete();

                    ReqLineCtr += 1;
                until TempReqLine.Next() = 0;

            DeleteAfterPosting(ReqHeader);

        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    procedure ProcessRequest(TransferHeader: Record "Transfer Header"; var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locTransferLine: Record "Transfer Line";
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        IsHandled: Boolean;
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeProcessTransferHeader(TransferHeader, TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;

        Clear(ReqDoc);
        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                if not ReqDoc.Contains(TempReqLine."Document No.") then
                    ReqDoc.Add(TempReqLine."Document No.")
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        foreach ReqNo in ReqDoc do begin

            // Header
            ReqHeader.Get(ReqNo);
            if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                ReqHeader.TestField(Status, ReqHeader.Status::Released);
            if not ReqHeader.Find() then
                Error(NothingToProcessErr);

            CheckAndUpdate(ReqHeader);
            InsertProcessedHeader(ReqHeader, locProcessedReqHeader);

            // Line
            TempReqLine.Reset();
            TempReqLine.SetRange("Document No.", ReqHeader."No.");
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindSet() then
                repeat

                    locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                    locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                    InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);
                    CreateTransferLine(locReqLine, TransferHeader, locTransferLine, LineRecSysId);
                    InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                    locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                    locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                    locProcessedRequestEntry."Transfer Order No." := locTransferLine."Document No.";
                    locProcessedRequestEntry."Transfer Order Line No." := locTransferLine."Line No.";
                    locProcessedRequestEntry."Processed SystemId" := locTransferLine.SystemId;
                    locProcessedRequestEntry.Modify(true);
                    IsHandledApplyDim := false;
                    ProcessRequestTransferLineOnBeforeApplyDim(locReqLine, TransferHeader, locTransferLine, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locTransferLine);

                    locReqLine.InitOutstanding();
                    locReqLine.InitQtyToReceive();
                    locReqLine.Modify();

                    TempReqLine.Delete();

                    ReqLineCtr += 1;
                until TempReqLine.Next() = 0;

            DeleteAfterPosting(ReqHeader);

        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    procedure ProcessRequest(ItemJournalLine: Record "Item Journal Line"; var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locItemJournalLine: Record "Item Journal Line";
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        IsHandled: Boolean;
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeProcessItemJournalLine(ItemJournalLine, TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;

        Clear(ReqDoc);
        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                if not ReqDoc.Contains(TempReqLine."Document No.") then
                    ReqDoc.Add(TempReqLine."Document No.")
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        foreach ReqNo in ReqDoc do begin

            // Header
            ReqHeader.Get(ReqNo);
            if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                ReqHeader.TestField(Status, ReqHeader.Status::Released);
            if not ReqHeader.Find() then
                Error(NothingToProcessErr);

            CheckAndUpdate(ReqHeader);
            InsertProcessedHeader(ReqHeader, locProcessedReqHeader);

            // Line
            TempReqLine.Reset();
            TempReqLine.SetRange("Document No.", ReqHeader."No.");
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindSet() then
                repeat

                    locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                    locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                    InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);
                    CreateItemJournalLine(locReqLine, ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name", locItemJournalLine, LineRecSysId);
                    InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                    locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                    locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                    locProcessedRequestEntry."Journal Template Name" := locItemJournalLine."Journal Template Name";
                    locProcessedRequestEntry."Journal Batch Name" := locItemJournalLine."Journal Batch Name";
                    locProcessedRequestEntry."Journal Line No." := locItemJournalLine."Line No.";
                    locProcessedRequestEntry."Journal Document No." := locItemJournalLine."Document No.";
                    locProcessedRequestEntry."Processed SystemId" := LineRecSysId;
                    locProcessedRequestEntry.Modify(true);

                    IsHandledApplyDim := false;
                    ProcessRequestItemJournalLineOnBeforeApplyDim(locReqLine, locItemJournalLine, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locItemJournalLine);

                    locReqLine.InitOutstanding();
                    locReqLine.InitQtyToReceive();
                    locReqLine.Modify();

                    TempReqLine.Delete();

                    ReqLineCtr += 1;
                until TempReqLine.Next() = 0;

            DeleteAfterPosting(ReqHeader);

        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    procedure ProcessRequest(RequisitionLine: Record "Requisition Line"; var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locRequisitionLine: Record "Requisition Line";
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        IsHandled: Boolean;
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeProcessRequisitionLine(RequisitionLine, TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;

        Clear(ReqDoc);
        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                if not ReqDoc.Contains(TempReqLine."Document No.") then
                    ReqDoc.Add(TempReqLine."Document No.")
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        foreach ReqNo in ReqDoc do begin

            // Header
            ReqHeader.Get(ReqNo);
            if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                ReqHeader.TestField(Status, ReqHeader.Status::Released);
            if not ReqHeader.Find() then
                Error(NothingToProcessErr);

            CheckAndUpdate(ReqHeader);
            InsertProcessedHeader(ReqHeader, locProcessedReqHeader);

            // Line
            TempReqLine.Reset();
            TempReqLine.SetRange("Document No.", ReqHeader."No.");
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindSet() then
                repeat

                    locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                    locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                    InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);
                    CreateRequisitionLine(locReqLine, RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name", locRequisitionLine, LineRecSysId);
                    InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                    locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                    locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                    locProcessedRequestEntry."Journal Template Name" := locRequisitionLine."Worksheet Template Name";
                    locProcessedRequestEntry."Journal Batch Name" := locRequisitionLine."Journal Batch Name";
                    locProcessedRequestEntry."Journal Line No." := locRequisitionLine."Line No.";
                    locProcessedRequestEntry."Processed SystemId" := LineRecSysId;
                    LocProcessedRequestEntry.Modify(true);

                    IsHandledApplyDim := false;
                    ProcessRequestRequisitionLineOnBeforeApplyDim(locReqLine, locRequisitionLine, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locRequisitionLine);

                    locReqLine.InitOutstanding();
                    locReqLine.InitQtyToReceive();
                    locReqLine.Modify();

                    TempReqLine.Delete();

                    ReqLineCtr += 1;
                until TempReqLine.Next() = 0;

            DeleteAfterPosting(ReqHeader);

        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    procedure ProcessRequest(GenJournalLine: Record "Gen. Journal Line"; var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locGenJournalLine: Record "Gen. Journal Line";
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        IsHandled: Boolean;
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeProcessGenJournalLine(GenJournalLine, TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;

        Clear(ReqDoc);
        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                if not ReqDoc.Contains(TempReqLine."Document No.") then
                    ReqDoc.Add(TempReqLine."Document No.")
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        foreach ReqNo in ReqDoc do begin

            // Header
            ReqHeader.Get(ReqNo);
            if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                ReqHeader.TestField(Status, ReqHeader.Status::Released);
            if not ReqHeader.Find() then
                Error(NothingToProcessErr);

            CheckAndUpdate(ReqHeader);
            InsertProcessedHeader(ReqHeader, locProcessedReqHeader);

            // Line
            TempReqLine.Reset();
            TempReqLine.SetRange("Document No.", ReqHeader."No.");
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindSet() then
                repeat

                    locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                    locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                    InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);
                    CreateGenJournalLine(locReqLine, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", locGenJournalLine, LineRecSysId);
                    InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                    locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                    locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                    locProcessedRequestEntry."Journal Template Name" := locGenJournalLine."Journal Template Name";
                    locProcessedRequestEntry."Journal Batch Name" := locGenJournalLine."Journal Batch Name";
                    locProcessedRequestEntry."Journal Line No." := locGenJournalLine."Line No.";
                    locProcessedRequestEntry."Journal Document No." := locGenJournalLine."Document No.";
                    locProcessedRequestEntry."Processed SystemId" := LineRecSysId;
                    locProcessedRequestEntry.Modify(true);

                    IsHandledApplyDim := false;
                    ProcessRequestGenJournalLineOnBeforeApplyDim(locReqLine, locGenJournalLine, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locGenJournalLine);

                    locReqLine.InitOutstanding();
                    locReqLine.InitQtyToReceive();
                    locReqLine.Modify();

                    TempReqLine.Delete();

                    ReqLineCtr += 1;
                until TempReqLine.Next() = 0;

            DeleteAfterPosting(ReqHeader);

        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    procedure NewPurchaseDocument(var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locPurchaseHeader: Record "Purchase Header";
        locPurchaseLine: Record "Purchase Line";
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        IsHandled: Boolean;
        ProcReqDocNo: Code[20];
        ReqDocNo: Code[20];
        Vendors: List of [Text];
        VendorNo: Code[20];
        ProcessedReqDic: Dictionary of [Code[20], Code[20]];
        ReqDocDic: Dictionary of [Code[20], Code[20]];
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeNewPurchaseDocument(TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;
        Clear(ProcessedReqDic);

        Clear(ReqDoc);
        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                if not ReqDoc.Contains(TempReqLine."Document No.") then
                    ReqDoc.Add(TempReqLine."Document No.");
                if not Vendors.Contains(TempReqLine."Vendor No.") then
                    Vendors.Add(TempReqLine."Vendor No.");
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        foreach ReqNo in ReqDoc do begin
            ReqHeader.Get(ReqNo);
            if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                ReqHeader.TestField(Status, ReqHeader.Status::Released);

            CheckAndUpdate(ReqHeader);
        end;

        Clear(ReqDocDimConflict);
        foreach VendorNo in Vendors do begin
            TempReqLine.Reset();
            TempReqLine.SetRange("Vendor No.", VendorNo);
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindFirst() then begin
                ReqHeader.Get(TempReqLine."Document No.");
                DimSetID := ReqHeader."Dimension Set ID";
                repeat
                    ReqHeader.Get(TempReqLine."Document No.");
                    if DimSetID <> ReqHeader."Dimension Set ID" then
                        ReqDocDimConflict.Add(ReqHeader."No.");
                until TempReqLine.Next() = 0;
            end;
        end;


        foreach VendorNo in Vendors do begin
            TempReqLine.Reset();
            TempReqLine.SetRange("Vendor No.", VendorNo);
            TempReqLine.SetRange(Select, true);
            if TempReqLine.FindSet() then begin

                CreatePurchaseHeader(TempReqLine, locPurchaseHeader, HeaderRecSysId);
                DimConfictExist := false;

                repeat
                    locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                    locReqLine.Validate("Vendor No.", TempReqLine."Vendor No.");
                    locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                    if not ProcessedReqDic.ContainsKey(locReqLine."Document No.") then begin
                        ReqHeader.Get(locReqLine."Document No.");
                        InsertProcessedHeader(ReqHeader, locProcessedReqHeader);
                        ProcessedReqDic.Add(ReqHeader."No.", locProcessedReqHeader."No.")
                    end;
                    ProcessedReqDic.Get(locReqLine."Document No.", ProcReqDocNo);
                    locProcessedReqHeader.Get(ProcReqDocNo);
                    InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);

                    CreatePurchaseLine(locReqLine, locPurchaseHeader, locPurchaseLine, LineRecSysId);

                    ReqHeader.Get(locReqLine."Document No.");

                    if not ReqDocDic.Get(TempReqLine."Document No.", ReqDocNo) then begin
                        ReqDocDic.Add(TempReqLine."Document No.", TempReqLine."Document No.");
                        TransferAttachmentOnPurchaseHeaderInsert(locPurchaseHeader, TempReqLine."Document No.");
                    end;

                    InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                    locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                    locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                    locProcessedRequestEntry."Purchase Document Type" := locPurchaseLine."Document Type";
                    locProcessedRequestEntry."Purchase Document No." := locPurchaseLine."Document No.";
                    locProcessedRequestEntry."Purchase Document Line No." := locPurchaseLine."Line No.";
                    locProcessedRequestEntry."Processed SystemId" := LineRecSysId;
                    locProcessedRequestEntry."Processed SystemId (Header)" := HeaderRecSysId;
                    locProcessedRequestEntry.Modify(true);

                    IsHandledApplyDim := false;
                    NewPurchaseDocumenLineOnBeforeApplyDim(TempReqLine, locReqLine, locPurchaseHeader, locPurchaseLine, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locPurchaseLine);

                    locReqLine.InitOutstanding();
                    locReqLine.InitQtyToReceive();
                    locReqLine.Modify();

                    if ReqDocDimConflict.Contains(TempReqLine."Document No.") then
                        DimConfictExist := true;

                    TempReqLine.Delete();
                    ReqLineCtr += 1;

                until TempReqLine.Next() = 0;

                if not DimConfictExist then begin
                    IsHandledApplyDim := false;
                    NewPurchaseDocumentHeaderOnBeforeApplyDim(TempReqLine, locPurchaseHeader, IsHandledApplyDim);
                    if not IsHandledApplyDim then
                        ApplyReqDocDimension(locProcessedRequestEntry, locPurchaseHeader);
                end;

            end;
        end;

        foreach ReqNo in ReqDoc do begin
            ReqHeader.Get(ReqNo);
            DeleteAfterPosting(ReqHeader);
        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    procedure NewTransferDocument(var TempReqLine: Record PPHRDS_ReqLine temporary)
    var
        locReqLine: Record PPHRDS_ReqLine;
        locTransferHeader: Record "Transfer Header";
        locTransferLine: Record "Transfer Line";
        locProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
        locProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        tempTransferHeader: Record "Transfer Header" temporary;
        IsHandled: Boolean;
        KeyCtr: Integer;
        ProcReqDocNo: Code[20];
        ProcessedReqDic: Dictionary of [Code[20], Code[20]];
        IsHandledApplyDim: Boolean;
    begin
        OnBeforeNewTransferDocument(TempReqLine, IsHandled);
        if IsHandled then
            exit;

        RequestSetup.Get();
        ReqLineCtr := 0;
        Clear(ProcessedReqDic);
        if tempTransferHeader.IsTemporary then
            tempTransferHeader.DeleteAll();
        KeyCtr := 1;

        TempReqLine.Reset();
        TempReqLine.SetRange(Select, true);
        if TempReqLine.FindSet() then
            repeat
                tempTransferHeader.Reset();
                tempTransferHeader.SetRange("Transfer-from Code", TempReqLine."Transfer-from Code");
                tempTransferHeader.SetRange("Transfer-to Code", TempReqLine."Location Code");
                if tempTransferHeader.IsEmpty then begin

                    ReqHeader.Get(TempReqLine."Document No.");

                    if RequestApprovalMgt.IsRequestApprovalsWorkflowEnabled(ReqHeader) then
                        ReqHeader.TestField(Status, ReqHeader.Status::Released);

                    CheckAndUpdate(ReqHeader);

                    Clear(tempTransferHeader);
                    tempTransferHeader.Init();
                    tempTransferHeader."No." := Format(KeyCtr);
                    tempTransferHeader."Transfer-from Code" := TempReqLine."Transfer-from Code";
                    tempTransferHeader."Transfer-to Code" := TempReqLine."Location Code";
                    tempTransferHeader.Insert();
                    KeyCtr += 1;

                end;
            until TempReqLine.Next() = 0
        else
            Error(NothingToProcessErr);

        Clear(ReqDocDimConflict);
        tempTransferHeader.Reset();
        if tempTransferHeader.FindSet() then
            repeat
                TempReqLine.Reset();
                TempReqLine.SetRange("Transfer-from Code", tempTransferHeader."Transfer-from Code");
                TempReqLine.SetRange("Location Code", tempTransferHeader."Transfer-to Code");
                TempReqLine.SetRange(Select, true);
                if TempReqLine.FindFirst() then begin
                    ReqHeader.Get(TempReqLine."Document No.");
                    DimSetID := ReqHeader."Dimension Set ID";
                    repeat
                        ReqHeader.Get(TempReqLine."Document No.");
                        if DimSetID <> ReqHeader."Dimension Set ID" then
                            ReqDocDimConflict.Add(ReqHeader."No.");
                    until TempReqLine.Next() = 0;
                end;
            until tempTransferHeader.Next() = 0;

        tempTransferHeader.Reset();
        if tempTransferHeader.FindSet() then
            repeat

                TempReqLine.Reset();
                TempReqLine.SetRange("Transfer-from Code", tempTransferHeader."Transfer-from Code");
                TempReqLine.SetRange("Location Code", tempTransferHeader."Transfer-to Code");
                TempReqLine.SetRange(Select, true);
                if TempReqLine.FindSet() then begin

                    CreateTransferHeader(TempReqLine, LocTransferHeader, HeaderRecSysId);
                    DimConfictExist := false;

                    repeat
                        locReqLine.Get(TempReqLine."Document No.", TempReqLine."Line No.");
                        locReqLine.Validate("Qty. to Process", TempReqLine."Qty. to Process");

                        if not ProcessedReqDic.ContainsKey(locReqLine."Document No.") then begin
                            ReqHeader.Get(locReqLine."Document No.");
                            InsertProcessedHeader(ReqHeader, locProcessedReqHeader);
                            ProcessedReqDic.Add(ReqHeader."No.", locProcessedReqHeader."No.")
                        end;
                        ProcessedReqDic.Get(locReqLine."Document No.", ProcReqDocNo);
                        locProcessedReqHeader.Get(ProcReqDocNo);
                        InsertProcessedLine(locProcessedReqHeader."No.", locReqLine, locProcessedReqLine);

                        CreateTransferLine(locReqLine, locTransferHeader, locTransferLine, LineRecSysId);
                        ReqHeader.Get(locReqLine."Document No.");
                        InsertRequestLedgerEntry(ReqHeader, locReqLine, locProcessedRequestEntry);
                        locProcessedRequestEntry."Processed Request No." := locProcessedReqLine."Document No.";
                        locProcessedRequestEntry."Processed Request Line No." := locProcessedReqLine."Line No.";
                        locProcessedRequestEntry."Transfer Order No." := locTransferLine."Document No.";
                        locProcessedRequestEntry."Transfer Order Line No." := locTransferLine."Line No.";
                        locProcessedRequestEntry."Processed SystemId" := LineRecSysId;
                        locProcessedRequestEntry."Processed SystemId (Header)" := HeaderRecSysId;
                        locProcessedRequestEntry.Modify(true);

                        IsHandledApplyDim := false;
                        NewTransferDocumentLineOnBeforeApplyDim(TempReqLine, locReqLine, locTransferHeader, locTransferLine, IsHandledApplyDim);
                        if not IsHandledApplyDim then
                            ApplyReqDocDimension(locProcessedRequestEntry, locTransferLine);

                        locReqLine.InitOutstanding();
                        locReqLine.InitQtyToReceive();
                        locReqLine.Modify();

                        if ReqDocDimConflict.Contains(TempReqLine."Document No.") then
                            DimConfictExist := true;

                        TempReqLine.Delete();
                        ReqLineCtr += 1;

                    until TempReqLine.Next() = 0;

                    if not DimConfictExist then begin
                        IsHandledApplyDim := false;
                        NewTransferDocumentHeaderOnBeforeApplyDim(TempReqLine, locTransferHeader, IsHandledApplyDim);
                        if not IsHandledApplyDim then
                            ApplyReqDocDimension(locProcessedRequestEntry, locTransferHeader);
                    end;

                end;

            until tempTransferHeader.Next() = 0;

        foreach ReqNo in ProcessedReqDic.Keys() do begin
            ReqHeader.Get(ReqNo);
            DeleteAfterPosting(ReqHeader);
        end;

        TempReqLine.Reset();
        Message(ReqLinesProcessMsg, ReqLineCtr);
    end;

    local procedure CheckAndUpdate(var parReqHeader: Record PPHRDS_ReqHeader);
    begin
        ReleaseReqDocument(parReqHeader);
    end;

    local procedure CreatePurchaseHeader(TempReqLine: Record PPHRDS_ReqLine temporary; var parPurchaseHeader: Record "Purchase Header"; var SysId: Guid)
    begin
        Clear(parPurchaseHeader);

        RequestCode.Get(TempReqLine."Request Code");

        parPurchaseHeader.Init();
        case TempReqLine."Request Purch. Document Type" of
            TempReqLine."Request Purch. Document Type"::Quote:
                begin
                    if RequestCode."Purch. Quote Nos." <> '' then
                        parPurchaseHeader."No. Series" := RequestCode."Purch. Quote Nos.";
                    parPurchaseHeader.Validate("Document Type", parPurchaseHeader."Document Type"::Quote);
                end;
            TempReqLine."Request Purch. Document Type"::Order:
                begin
                    if RequestCode."Purch. Order Nos." <> '' then
                        parPurchaseHeader."No. Series" := RequestCode."Purch. Order Nos.";
                    parPurchaseHeader.Validate("Document Type", parPurchaseHeader."Document Type"::Order);
                end;
            TempReqLine."Request Purch. Document Type"::Invoice:
                begin
                    if RequestCode."Purch. Invoice Nos." <> '' then
                        parPurchaseHeader."No. Series" := RequestCode."Purch. Invoice Nos.";
                    parPurchaseHeader.Validate("Document Type", parPurchaseHeader."Document Type"::Invoice);
                end;
        end;
        parPurchaseHeader.Validate("Buy-from Vendor No.", TempReqLine."Vendor No.");
        CreatePurchaseHeaderOnBeforeInsert(TempReqLine, parPurchaseHeader);
        parPurchaseHeader.Insert(true);
        SysId := parPurchaseHeader.SystemId;
        parPurchaseHeader.Validate("Posting Date", WorkDate());
        CreatePurchaseHeaderOnBeforeModify(TempReqLine, parPurchaseHeader);
        parPurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLine(ReqLine: Record PPHRDS_ReqLine; parPurchaseHeader: Record "Purchase Header"; var parPurchaseLine: Record "Purchase Line"; var SysId: Guid)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        if ReqLine."Applies-to Purch. Doc. No." = '' then begin
            PurchaseLine.SetRange("Document Type", parPurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", parPurchaseHeader."No.")
        end else begin
            case ReqLine."Request Purch. Document Type" of
                ReqLine."Request Purch. Document Type"::Quote:
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Quote);
                ReqLine."Request Purch. Document Type"::Order:
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                ReqLine."Request Purch. Document Type"::Invoice:
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Invoice);
            end;
            PurchaseLine.SetRange("Document No.", ReqLine."Applies-to Purch. Doc. No.");
        end;
        if PurchaseLine.FindLast() then
            LineNo := PurchaseLine."Line No." + 10000
        else
            LineNo := 10000;

        RequestCode.Get(ReqLine."Request Code");

        parPurchaseLine.Init();
        if ReqLine."Applies-to Purch. Doc. No." = '' then begin
            parPurchaseLine.Validate("Document Type", parPurchaseHeader."Document Type");
            parPurchaseLine.Validate("Document No.", parPurchaseHeader."No.")
        end else begin
            case ReqLine."Request Purch. Document Type" of
                ReqLine."Request Purch. Document Type"::Quote:
                    parPurchaseLine.Validate("Document Type", PurchaseLine."Document Type"::Quote);
                ReqLine."Request Purch. Document Type"::Order:
                    parPurchaseLine.Validate("Document Type", PurchaseLine."Document Type"::Order);
                ReqLine."Request Purch. Document Type"::Invoice:
                    parPurchaseLine.Validate("Document Type", PurchaseLine."Document Type"::Invoice);
            end;
            parPurchaseLine.Validate("Document No.", ReqLine."Applies-to Purch. Doc. No.");
        end;
        parPurchaseLine."Line No." := LineNo;
        CreatePurchaseLineOnBeforeInsert(ReqLine, parPurchaseHeader, parPurchaseLine);
        parPurchaseLine.Insert(true);
        SysId := parPurchaseLine.SystemId;
        parPurchaseLine.Validate(Type, RequestManagement.LineReqTypeToPurchType(ReqLine.Type));
        parPurchaseLine.Validate("No.", ReqLine."No.");
        parPurchaseLine.Validate("Location Code", ReqLine."Location Code");
        parPurchaseLine.Validate(Quantity, ReqLine."Qty. to Process");
        parPurchaseLine.Validate("Unit of Measure Code", ReqLine."Unit of Measure Code");
        parPurchaseLine.Validate("Direct Unit Cost", ReqLine."Direct Unit Cost");
        parPurchaseLine.Validate("Expected Receipt Date", ReqLine."Expected Receipt Date");
        parPurchaseLine.Description := ReqLine.Description;
        parPurchaseLine."Description 2" := ReqLine."Description 2";
        if ReqLine."Job No." <> '' then begin
            parPurchaseLine.Validate("Job No.", ReqLine."Job No.");
            parPurchaseLine.Validate("Job Task No.", ReqLine."Job Task No.");
        end;
        CreatePurchaseLineOnBeforeModify(ReqLine, parPurchaseHeader, parPurchaseLine);
        parPurchaseLine.Modify(true);
    end;

    local procedure CreateTransferHeader(TempReqLine: Record PPHRDS_ReqLine temporary; var parTransferHeader: Record "Transfer Header"; var SysId: Guid)
    begin
        Clear(parTransferHeader);

        RequestCode.Get(TempReqLine."Request Code");

        parTransferHeader.Init();
        parTransferHeader."No." := '';
        CreateTransferHeaderOnBeforeInsert(TempReqLine, parTransferHeader);
        parTransferHeader.Insert(true);
        SysId := parTransferHeader.SystemId;
        parTransferHeader.Validate("Transfer-from Code", TempReqLine."Transfer-from Code");
        parTransferHeader.Validate("Transfer-to Code", TempReqLine."Location Code");
        if RequestCode."In-Transit Code" <> '' then
            parTransferHeader.Validate("In-Transit Code", RequestCode."In-Transit Code");
        parTransferHeader.CopyLinks(ReqHeader);
        CreateTransferHeaderOnBeforeModify(TempReqLine, parTransferHeader);
        parTransferHeader.Modify(true);
    end;

    local procedure CreateTransferLine(ReqLine: Record PPHRDS_ReqLine; parTransferHeader: Record "Transfer Header"; var parTransferLine: Record "Transfer Line"; var SysId: Guid)
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", parTransferHeader."No.");
        if TransferLine.FindLast() then
            LineNo := TransferLine."Line No." + 10000
        else
            LineNo := 10000;

        parTransferLine.Init();
        parTransferLine.Validate("Document No.", parTransferHeader."No.");
        parTransferLine.Validate("Line No.", LineNo);
        CreateTransferLineOnBeforeInsert(ReqLine, parTransferHeader, parTransferLine);
        parTransferLine.Insert(true);
        SysId := parTransferLine.SystemId;
        parTransferLine.Validate("Item No.", ReqLine."No.");
        parTransferLine.Validate(Quantity, ReqLine."Qty. to Process");
        parTransferLine.Validate("Unit of Measure Code", ReqLine."Unit of Measure Code");
        parTransferLine.Description := ReqLine.Description;
        parTransferLine."Description 2" := ReqLine."Description 2";
        CreateTransferLineOnBeforeModify(ReqLine, parTransferHeader, parTransferLine);
        parTransferLine.Modify(true);
    end;

    local procedure CreateItemJournalLine(ReqLine: Record PPHRDS_ReqLine; TemplateName: Code[10]; BatchName: Code[10]; var parItemJournalLine: Record "Item Journal Line"; var SysId: Guid);
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        RequestCode.Get(ReqLine."Request Code");

        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindLast() then
            LineNo := ItemJournalLine."Line No." + 10000
        else
            LineNo := 10000;

        parItemJournalLine.Init();
        parItemJournalLine.Validate("Journal Template Name", TemplateName);
        parItemJournalLine.Validate("Journal Batch Name", BatchName);
        parItemJournalLine.Validate("Line No.", LineNo);
        Commit();
        parItemJournalLine.SetUpNewLine(ItemJournalLine);
        CreateItemJournalLineOnBeforeInsert(ReqLine, parItemJournalLine);
        parItemJournalLine.Insert(true);
        SysId := parItemJournalLine.SystemId;
        if parItemJournalLine."Document No." = '' then
            parItemJournalLine.Validate("Document No.", ReqLine."Document No.");
        parItemJournalLine.Validate("Posting Date", WorkDate());
        parItemJournalLine.Validate("Entry Type", RequestCode."Entry Type");
        parItemJournalLine.Validate("Item No.", ReqLine."No.");
        parItemJournalLine.Description := ReqLine.Description;
        parItemJournalLine.Validate(Quantity, ReqLine."Qty. to Process");
        parItemJournalLine.Validate("Unit of Measure Code", ReqLine."Unit of Measure Code");
        parItemJournalLine.Validate("Location Code", ReqLine."Location Code");
        parItemJournalLine.Validate("Unit Cost", ReqLine."Direct Unit Cost");
        if RequestCode."Gen. Prod. Posting Group" <> '' then
            parItemJournalLine.Validate("Gen. Prod. Posting Group", RequestCode."Gen. Prod. Posting Group");
        parItemJournalLine.Description := ReqLine.Description;
        ReqHeader.Get(ReqLine."Document No.");
        parItemJournalLine.CopyLinks(ReqHeader);
        CreateItemJournalLineOnBeforeModify(ReqLine, parItemJournalLine);
        parItemJournalLine.Modify(true);
    end;

    local procedure CreateRequisitionLine(ReqLine: Record PPHRDS_ReqLine; TemplateName: Code[10]; BatchName: Code[10]; var parRequisitionLine: Record "Requisition Line"; var SysId: Guid);
    var
        RequisitionLine: Record "Requisition Line";
    begin
        RequestCode.Get(ReqLine."Request Code");

        RequisitionLine.Reset();
        RequisitionLine.SetRange("Worksheet Template Name", TemplateName);
        RequisitionLine.SetRange("Journal Batch Name", BatchName);
        if RequisitionLine.FindLast() then
            LineNo := RequisitionLine."Line No." + 10000
        else
            LineNo := 10000;

        parRequisitionLine.Init();
        parRequisitionLine.Validate("Worksheet Template Name", TemplateName);
        parRequisitionLine.Validate("Journal Batch Name", BatchName);
        parRequisitionLine.Validate("Line No.", LineNo);
        CreateRequisitionLineOnBeforeInsert(ReqLine, parRequisitionLine);
        parRequisitionLine.Insert(true);
        SysId := parRequisitionLine.SystemId;
        parRequisitionLine.Validate("Order Date", WorkDate());
        case ReqLine.Type of
            ReqLine.Type::Item:
                parRequisitionLine.Validate(Type, ReqLine.Type::Item);
            ReqLine.Type::"G/L Account":
                parRequisitionLine.Validate(Type, ReqLine.Type::"G/L Account");
        end;
        parRequisitionLine.Validate("Action Message", parRequisitionLine."Action Message"::New);
        parRequisitionLine.Validate("No.", ReqLine."No.");
        parRequisitionLine.Validate(Quantity, ReqLine."Qty. to Process");
        parRequisitionLine.Validate("Unit of Measure Code", ReqLine."Unit of Measure Code");
        parRequisitionLine.Validate("Location Code", ReqLine."Location Code");
        parRequisitionLine.Validate("Vendor No.", ReqLine."Vendor No.");
        parRequisitionLine.Validate("Direct Unit Cost", ReqLine."Direct Unit Cost");
        parRequisitionLine.Description := ReqLine.Description;
        parRequisitionLine."Description 2" := ReqLine."Description 2";
        parRequisitionLine."Demand Type" := DATABASE::PPHRDS_ReqHeader;
        parRequisitionLine."Demand Order No." := ReqLine."Document No.";
        ReqHeader.Get(ReqLine."Document No.");
        parRequisitionLine.CopyLinks(ReqHeader);
        CreateRequisitionLineOnBeforeModify(ReqLine, parRequisitionLine);
        parRequisitionLine.Modify(true);
    end;

    local procedure CreateGenJournalLine(ReqLine: Record PPHRDS_ReqLine; TemplateName: Code[10]; BatchName: Code[10]; var parGenJournalLine: Record "Gen. Journal Line"; var SysId: Guid);
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        RequestCode.Get(ReqLine."Request Code");

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No." + 10000
        else
            LineNo := 10000;

        parGenJournalLine.Init();
        parGenJournalLine.Validate("Journal Template Name", TemplateName);
        parGenJournalLine.Validate("Journal Batch Name", BatchName);
        parGenJournalLine.Validate("Line No.", LineNo);
        Commit();
        parGenJournalLine.SetUpNewLine(GenJournalLine, GenJournalLine.Amount, true);
        CreateGenJournalLineOnBeforeInsert(ReqLine, parGenJournalLine);
        parGenJournalLine.Insert(true);
        SysId := parGenJournalLine.SystemId;
        if parGenJournalLine."Document No." = '' then
            parGenJournalLine.Validate("Document No.", ReqLine."Document No.");
        case ReqLine.Type of
            ReqLine.Type::Vendor:
                parGenJournalLine.Validate("Account Type", parGenJournalLine."Account Type"::Vendor);
            ReqLine.Type::Employee:
                parGenJournalLine.Validate("Account Type", parGenJournalLine."Account Type"::Employee);
        end;
        parGenJournalLine.Validate("Account No.", ReqLine."No.");
        parGenJournalLine.Description := ReqLine.Description;
        parGenJournalLine.Validate(Quantity, ReqLine."Qty. to Process");
        parGenJournalLine.Validate(Amount, ReqLine."Direct Unit Cost" * ReqLine."Qty. to Process");
        if ReqLine."Currency Code" <> '' then
            parGenJournalLine.Validate("Currency Code", ReqLine."Currency Code");
        parGenJournalLine.Description := ReqLine.Description;
        ReqHeader.Get(ReqLine."Document No.");
        parGenJournalLine.CopyLinks(ReqHeader);
        CreateGenJournalLineOnBeforeModify(ReqLine, parGenJournalLine);
        parGenJournalLine.Modify(true);
    end;

    local procedure ReleaseReqDocument(var parReqHeader: Record PPHRDS_ReqHeader);
    var
        ReleaseRequestDocument: Codeunit PPHRDS_ReleaseRequestDocument;
    begin
        if not (parReqHeader.Status = parReqHeader.Status::Open) then
            exit;

        ReleaseRequestDocument.ReleaseRequestHeader(parReqHeader);
        parReqHeader.TestField(Status, parReqHeader.Status::Released);
        parReqHeader.Status := parReqHeader.Status::Released;
    end;

    local procedure InsertRequestLedgerEntry(locReqHeader: Record PPHRDS_ReqHeader; ReqLine: Record PPHRDS_ReqLine; var parProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry);
    var
        ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        EntryNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertRequestLedgerEntry(ReqLine, parProcessedRequestEntry, IsHandled);
        if IsHandled then
            exit;

        ProcessedRequestEntry.Reset();
        if ProcessedRequestEntry.FindLast() then
            EntryNo := ProcessedRequestEntry."Entry No." + 1
        else
            EntryNo := 1;

        parProcessedRequestEntry.Init();
        parProcessedRequestEntry."Entry No." := EntryNo;
        parProcessedRequestEntry."Request No." := ReqLine."Document No.";
        parProcessedRequestEntry."Request Line No." := ReqLine."Line No.";
        parProcessedRequestEntry."Processed Request No." := '';
        parProcessedRequestEntry."Processed Request Line No." := 0;
        parProcessedRequestEntry."Requestor ID" := locReqHeader."Requestor ID";
        parProcessedRequestEntry."Requestor Name" := locReqHeader."Requestor Name";
        parProcessedRequestEntry."Purchaser Code" := locReqHeader."Purchaser Code";
        parProcessedRequestEntry."Request Date" := locReqHeader."Request Date";
        parProcessedRequestEntry."Document Date" := locReqHeader."Document Date";
        parProcessedRequestEntry."Expected Receipt Date" := ReqLine."Expected Receipt Date";
        parProcessedRequestEntry."Request Code" := ReqLine."Request Code";
        parProcessedRequestEntry."Request Description" := ReqLine."Request Description";
        parProcessedRequestEntry."Request Type" := ReqLine."Request Type";
        parProcessedRequestEntry.Type := ReqLine.Type;
        parProcessedRequestEntry."No." := ReqLine."No.";
        parProcessedRequestEntry.Description := ReqLine.Description;
        parProcessedRequestEntry."Description 2" := ReqLine."Description 2";
        parProcessedRequestEntry."Location Code" := ReqLine."Location Code";
        parProcessedRequestEntry."Unit of Measure" := ReqLine."Unit of Measure";
        parProcessedRequestEntry."Unit of Measure Code" := ReqLine."Unit of Measure Code";
        parProcessedRequestEntry.Quantity := ReqLine."Qty. to Process";
        parProcessedRequestEntry."Quantity (Base)" := ReqLine."Qty. to Process (Base)";
        parProcessedRequestEntry."Direct Unit Cost" := ReqLine."Direct Unit Cost";
        parProcessedRequestEntry."Unit Cost" := ReqLine."Unit Cost";
        parProcessedRequestEntry."Line Amount" := ReqLine."Line Amount";
        parProcessedRequestEntry."Currency Code" := ReqLine."Currency Code";
        parProcessedRequestEntry."Job No." := ReqLine."Job No.";
        parProcessedRequestEntry."Job Task No." := ReqLine."Job Task No.";
        parProcessedRequestEntry."Vendor No." := ReqLine."Vendor No.";
        parProcessedRequestEntry."Vendor Name" := ReqLine."Vendor Name";
        parProcessedRequestEntry.Notes := ReqLine.Notes;
        parProcessedRequestEntry."Original Quantity" := ReqLine.Quantity;
        parProcessedRequestEntry."Dimension Set ID (Header)" := locReqHeader."Dimension Set ID";
        parProcessedRequestEntry."Dimension Set ID" := ReqLine."Dimension Set ID";
        parProcessedRequestEntry."Processor User ID" := CopyStr(UserId(), 1, MaxStrLen(parProcessedRequestEntry."Processor User ID"));
        parProcessedRequestEntry.Insert(true);

        OnAfterInsertRequestLedgerEntry(ReqLine, parProcessedRequestEntry);
    end;

    local procedure InsertProcessedHeader(var paReqHeader: Record PPHRDS_ReqHeader; var ProcessedReqHeader: Record PPHRDS_ProcessedReqHeader);
    var
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        ProcessedReqHeader.Init();
        ProcessedReqHeader.TransferFields(paReqHeader);
        if RequestSetup."Processed Request Nos." <> '' then
            ProcessedReqHeader."No." := NoSeries.GetNextNo(RequestSetup."Processed Request Nos.", WorkDate())
        else
            ProcessedReqHeader."No." := paReqHeader."No.";
        ProcessedReqHeader."Request No." := paReqHeader."No.";
        ProcessedReqHeader.Insert(true);
        RecordLinkManagement.CopyLinks(paReqHeader, ProcessedReqHeader);
    end;

    local procedure InsertProcessedLine(parDocumentNo: Code[20]; parReqLine: Record PPHRDS_ReqLine; var parProcessedReqLine: Record PPHRDS_ProcessedReqLine);
    begin
        parProcessedReqLine.Init();
        parProcessedReqLine.TransferFields(parReqLine);
        parProcessedReqLine."Document No." := parDocumentNo;
        parProcessedReqLine.Quantity := parReqLine."Qty. to Process";
        parProcessedReqLine."Quantity (Base)" := parReqLine."Qty. to Process (Base)";
        parProcessedReqLine.Insert(true);
    end;

    local procedure DeleteAfterPosting(var parReqHeader: Record PPHRDS_ReqHeader);
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentCopy: Record "Document Attachment";
    begin
        parReqHeader.CalcFields("Completely Processed");

        if parReqHeader."Completely Processed" then begin

            DocumentAttachment.Reset();
            DocumentAttachment.SetRange("Table ID", Database::PPHRDS_ReqHeader);
            DocumentAttachment.SetRange("No.", parReqHeader."No.");
            DocumentAttachment.SetRange("Document Type", DocumentAttachment."Document Type"::PPHRDS_Request);
            if DocumentAttachment.FindSet() then
                repeat
                    DocumentAttachmentCopy.TransferFields(DocumentAttachment);
                    DocumentAttachmentCopy.Validate("Table ID", Database::PPHRDS_ProcessedReqHeader);
                    DocumentAttachmentCopy.Insert();
                    DocumentAttachment.Delete();
                until DocumentAttachment.Next() = 0;

            DeleteRequistion(parReqHeader);

        end;
    end;

    local procedure DeleteRequistion(var parReqHeader: Record PPHRDS_ReqHeader);
    var
        LocReqLine: Record PPHRDS_ReqLine;
    begin
        if parReqHeader.HasLinks then
            parReqHeader.DeleteLinks();
        parReqHeader.Delete();

        LocReqLine.Reset();
        LocReqLine.SetRange("Document No.", parReqHeader."No.");
        LocReqLine.DeleteAll();
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var PurchaseHeader: Record "Purchase Header")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := PurchaseHeader."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID (Header)";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> PurchaseHeader."Dimension Set ID") then begin
            PurchaseHeader.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(PurchaseHeader."Dimension Set ID", PurchaseHeader."Shortcut Dimension 1 Code", PurchaseHeader."Shortcut Dimension 2 Code");
            PurchaseHeader.Modify(true);
        end;
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var PurchaseLine: Record "Purchase Line")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := PurchaseLine."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> PurchaseLine."Dimension Set ID") then begin
            PurchaseLine.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(PurchaseLine."Dimension Set ID", PurchaseLine."Shortcut Dimension 1 Code", PurchaseLine."Shortcut Dimension 2 Code");
            PurchaseLine.Modify(true);
        end;
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var TransferHeader: Record "Transfer Header")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := TransferHeader."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID (Header)";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> TransferHeader."Dimension Set ID") then begin
            TransferHeader.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(TransferHeader."Dimension Set ID", TransferHeader."Shortcut Dimension 1 Code", TransferHeader."Shortcut Dimension 2 Code");
            TransferHeader.Modify(true);
        end;
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var TransferLine: Record "Transfer Line")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := TransferLine."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> TransferLine."Dimension Set ID") then begin
            TransferLine.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(TransferLine."Dimension Set ID", TransferLine."Shortcut Dimension 1 Code", TransferLine."Shortcut Dimension 2 Code");
            TransferLine.Modify(true);
        end;
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var ItemJournalLine: Record "Item Journal Line")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := ItemJournalLine."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> ItemJournalLine."Dimension Set ID") then begin
            ItemJournalLine.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(ItemJournalLine."Dimension Set ID", ItemJournalLine."Shortcut Dimension 1 Code", ItemJournalLine."Shortcut Dimension 2 Code");
            ItemJournalLine.Modify(true);
        end;
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var RequisitionLine: Record "Requisition Line")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := RequisitionLine."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> RequisitionLine."Dimension Set ID") then begin
            RequisitionLine.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(RequisitionLine."Dimension Set ID", RequisitionLine."Shortcut Dimension 1 Code", RequisitionLine."Shortcut Dimension 2 Code");
            RequisitionLine.Modify(true);
        end;
    end;

    local procedure ApplyReqDocDimension(ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var GenJournalLine: Record "Gen. Journal Line")
    begin
        Clear(DimensionSetIDArr);
        DimensionSetIDArr[1] := GenJournalLine."Dimension Set ID";
        DimensionSetIDArr[2] := ProcessedRequestEntry."Dimension Set ID";
        DimSetID := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimension1Code, ShortcutDimension2Code);
        if (DimSetID <> 0) and (DimSetID <> GenJournalLine."Dimension Set ID") then begin
            GenJournalLine.Validate("Dimension Set ID", DimSetID);
            DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
            GenJournalLine.Modify(true);
        end;
    end;

    local procedure TransferAttachmentOnPurchaseHeaderInsert(pPurchHeader: Record "Purchase Header"; pReqHeaderNo: Code[20])
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentCopy: Record "Document Attachment";
        LastLineNo: Integer;
    begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::PPHRDS_ReqHeader);
        DocumentAttachment.SetRange("No.", pReqHeaderNo);
        DocumentAttachment.SetRange("Document Type", DocumentAttachment."Document Type"::PPHRDS_Request);
        if DocumentAttachment.FindSet() then
            repeat
                DocumentAttachmentCopy.Validate("Table ID", Database::"Purchase Header");
                DocumentAttachmentCopy.Validate("No.", pPurchHeader."No.");
                DocumentAttachmentCopy."Attached Date" := DocumentAttachment."Attached Date";
                DocumentAttachmentCopy."File Name" := DocumentAttachment."File Name";
                DocumentAttachmentCopy."File Extension" := DocumentAttachment."File Extension";
                DocumentAttachmentCopy."Document Reference ID" := DocumentAttachment."Document Reference ID";
                DocumentAttachmentCopy."Attached By" := DocumentAttachment."Attached By";
                DocumentAttachmentCopy.User := DocumentAttachment.User;
                DocumentAttachmentCopy."Document Flow Sales" := DocumentAttachment."Document Flow Sales";
                DocumentAttachmentCopy.Validate("Document Type", pPurchHeader."Document Type");
                DocumentAttachmentCopy."Line No." := DocumentAttachment."Line No.";
                DocumentAttachmentCopy."VAT Report Config. Code" := DocumentAttachment."VAT Report Config. Code";
                DocumentAttachmentCopy."Document Flow Service" := DocumentAttachment."Document Flow Service";
                DocumentAttachmentCopy."Document Flow Production" := DocumentAttachment."Document Flow Production";
                DocumentAttachmentCopy.Insert(true);
            until DocumentAttachment.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessPurchaseHeader(PurchaseHeader: Record "Purchase Header"; var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessTransferHeader(TransferHeader: Record "Transfer Header"; var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessItemJournalLine(ItemJournalLine: Record "Item Journal Line"; var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessRequisitionLine(RequisitionLine: Record "Requisition Line"; var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessGenJournalLine(GenJournalLine: Record "Gen. Journal Line"; var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNewPurchaseDocument(var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNewTransferDocument(var TempReqLine: Record PPHRDS_ReqLine temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreatePurchaseHeaderOnBeforeInsert(TempReqLine: Record PPHRDS_ReqLine temporary; var PurchaseHeader: Record "Purchase Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreatePurchaseHeaderOnBeforeModify(TempReqLine: Record PPHRDS_ReqLine temporary; var PurchaseHeader: Record "Purchase Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure NewPurchaseDocumentHeaderOnBeforeApplyDim(TempReqLine: Record PPHRDS_ReqLine temporary; var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure NewPurchaseDocumenLineOnBeforeApplyDim(TempReqLine: Record PPHRDS_ReqLine temporary; ReqLine: record PPHRDS_ReqLine; PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreatePurchaseLineOnBeforeInsert(ReqLine: record PPHRDS_ReqLine; PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreatePurchaseLineOnBeforeModify(ReqLine: record PPHRDS_ReqLine; PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure ProcessRequestPurchaseLineOnBeforeApplyDim(ReqLine: record PPHRDS_ReqLine; PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateTransferHeaderOnBeforeInsert(TempReqLine: Record PPHRDS_ReqLine temporary; var parTransferHeader: Record "Transfer Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateTransferHeaderOnBeforeModify(TempReqLine: Record PPHRDS_ReqLine temporary; var parTransferHeader: Record "Transfer Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure NewTransferDocumentHeaderOnBeforeApplyDim(TempReqLine: Record PPHRDS_ReqLine temporary; var parTransferHeader: Record "Transfer Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure NewTransferDocumentLineOnBeforeApplyDim(TempReqLine: Record PPHRDS_ReqLine temporary; ReqLine: record PPHRDS_ReqLine; TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateTransferLineOnBeforeInsert(ReqLine: record PPHRDS_ReqLine; TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateTransferLineOnBeforeModify(ReqLine: record PPHRDS_ReqLine; TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure ProcessRequestTransferLineOnBeforeApplyDim(ReqLine: record PPHRDS_ReqLine; TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateItemJournalLineOnBeforeInsert(ReqLine: record PPHRDS_ReqLine; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateItemJournalLineOnBeforeModify(ReqLine: record PPHRDS_ReqLine; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure ProcessRequestItemJournalLineOnBeforeApplyDim(ReqLine: record PPHRDS_ReqLine; var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateRequisitionLineOnBeforeInsert(ReqLine: Record PPHRDS_ReqLine; var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateRequisitionLineOnBeforeModify(ReqLine: Record PPHRDS_ReqLine; var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure ProcessRequestRequisitionLineOnBeforeApplyDim(ReqLine: Record PPHRDS_ReqLine; var RequisitionLine: Record "Requisition Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateGenJournalLineOnBeforeInsert(ReqLine: record PPHRDS_ReqLine; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CreateGenJournalLineOnBeforeModify(ReqLine: record PPHRDS_ReqLine; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure ProcessRequestGenJournalLineOnBeforeApplyDim(ReqLine: record PPHRDS_ReqLine; var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRequestLedgerEntry(ReqLine: Record PPHRDS_ReqLine; var parProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRequestLedgerEntry(ReqLine: Record PPHRDS_ReqLine; var parProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry);
    begin
    end;
}

