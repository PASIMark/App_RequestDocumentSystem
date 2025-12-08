page 70829620 "PPHRDS_GetRequestLines"
{
    Caption = 'Get Request Lines';
    PageType = List;
    UsageCategory = None;
    SourceTable = PPHRDS_ReqLine;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the Document No..';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    Tooltip = 'Specifies the Line No..';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    Tooltip = 'Specifies the Type.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    Tooltip = 'Specifies the Description.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Description 2"; Rec."Description 2")
                {
                    Tooltip = 'Specifies the Description 2.';
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Tooltip = 'Specifies the Location Code.';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Tooltip = 'Specifies the Unit of Measure Code.';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Tooltip = 'Specifies the Vendor No..';
                    ApplicationArea = All;
                    Visible = ShowVendorNo;

                    trigger OnValidate()
                    begin
                        CheckSelection()
                    end;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    Tooltip = 'Specifies the Transfer-from Code.';
                    ApplicationArea = All;
                    Visible = ShowTransferCode;

                    trigger OnValidate()
                    begin
                        CheckSelection()
                    end;
                }
                field("Transfer-to Code"; Rec."Location Code")
                {
                    Caption = 'Transfer-to Code';
                    Tooltip = 'Specifies the Transfer-to Code.';
                    ApplicationArea = All;
                    Visible = ShowTransferCode;
                    Editable = false;
                }
                field("Qty. to Process"; Rec."Qty. to Process")
                {
                    Tooltip = 'Specifies the Qty. to Process.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckSelection();
                    end;
                }
                field("Quantity Processed"; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the Quantity Processed.';
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the Outstanding Quantity.';
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field(Select; Rec.Select)
                {
                    Tooltip = 'The selected line is carried over to the document line.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckSelection();
                    end;
                }
            }
        }

        area(factboxes)
        {
            part(Control46; PPHRDS_GetRequestLinesFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
            }
            systempart(Control7; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control3; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {

        area(Processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(ProcessRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Process Request';
                    Image = Process;
                    ToolTip = 'Process the selected request lines to the active document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction();
                    var
                        ProcessRequestDocument: Codeunit PPHRDS_ProcessRequestDocument;
                    begin
                        if isCreatePurchaseDocument then begin
                            ProcessRequestDocument.NewPurchaseDocument(Rec);
                            exit;
                        end;

                        if isCreatePurchaseLine then begin
                            ProcessRequestDocument.ProcessRequest(PurchaseHeader, Rec);
                            exit;
                        end;

                        if isCreateTransferDocument then begin
                            ProcessRequestDocument.NewTransferDocument(Rec);
                            exit;
                        end;

                        if isCreateTransferLine then begin
                            ProcessRequestDocument.ProcessRequest(TransferHeader, Rec);
                            exit;
                        end;

                        IF isCreateItemJournalLine then begin
                            ProcessRequestDocument.ProcessRequest(ItemJournalLine, Rec);
                            exit;
                        end;

                        IF isCreateRequisitionLine then begin
                            ProcessRequestDocument.ProcessRequest(RequisitionLine, Rec);
                            exit;
                        end;

                        if isCreateGenJournalLine then begin
                            ProcessRequestDocument.ProcessRequest(GenJournalLine, Rec);
                            exit;
                        end;
                    end;
                }
            }
        }
    }

    var
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ItemJournalLine: Record "Item Journal Line";
        RequisitionLine: Record "Requisition Line";
        GenJournalLine: Record "Gen. Journal Line";
        TransferRoute: Record "Transfer Route";
        RequestCode: Record PPHRDS_RequestCode;
        isCreatePurchaseDocument: Boolean;
        isCreatePurchaseLine: Boolean;
        isCreateTransferDocument: Boolean;
        isCreateTransferLine: Boolean;
        isCreateItemJournalLine: Boolean;
        isCreateRequisitionLine: Boolean;
        isCreateGenJournalLine: Boolean;
        ShowVendorNo: Boolean;
        ShowTransferCode: Boolean;

    procedure CreatePurchaseDocument(locPurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader := locPurchaseHeader;
        isCreatePurchaseDocument := true;
        ShowVendorNo := true;
    end;

    procedure CreatePurchaseLine(locPurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader := locPurchaseHeader;
        isCreatePurchaseLine := true;
    end;

    procedure CreateTransferDocument(locTransferHeader: Record "Transfer Header")
    begin
        TransferHeader := locTransferHeader;
        isCreateTransferDocument := true;
        ShowTransferCode := true;
    end;

    procedure CreateTransferLine(locTransferHeader: Record "Transfer Header")
    begin
        TransferHeader := locTransferHeader;
        isCreateTransferLine := true;
    end;

    procedure CreateItemJournalLine(locItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine := locItemJournalLine;
        isCreateItemJournalLine := true;
    end;

    procedure CreateRequisitionLine(locRequisitionLine: Record "Requisition Line")
    begin
        RequisitionLine := locRequisitionLine;
        isCreateRequisitionLine := true;
    end;

    procedure CreateGenJournalLine(locGenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine := locGenJournalLine;
        isCreateGenJournalLine := true;
    end;

    procedure SetRecords()
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    procedure SetRecords(locPurchaseHeader: Record "Purchase Header"; RequestPurchDocType: Enum PPHRDS_RequestPurchDocType)
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", Rec."Request Type"::Purchase);
                ReqLine.SetRange("Request Purch. Document Type", RequestPurchDocType);
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    procedure SetRecords(locTransferHeader: Record "Transfer Header")
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Transfer Order");
                if isCreateTransferLine then begin
                    ReqLine.SetRange("Transfer-from Code", '');
                    ReqLine.SetRange("Location Code", TransferHeader."Transfer-to Code");
                end;
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    procedure SetRecords(locTransferLine: Record "Transfer Line")
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Transfer Order");
                if isCreateTransferLine then begin
                    ReqLine.SetFilter("Transfer-from Code", '%1|%2', TransferHeader."Transfer-from Code", '');
                    ReqLine.SetRange("Location Code", TransferHeader."Transfer-to Code");
                end;
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    procedure SetRecords(locItemJournalLine: Record "Item Journal Line")
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Item Journal");
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    procedure SetRecords(locRequisitionLine: Record "Requisition Line")
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Req. Worksheet");
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    procedure SetRecords(locGenJournalLine: Record "Gen. Journal Line")
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", ReqLine."Request Type"::"General Journal");
                ReqLine.SetRange("Journal Template Name", locGenJournalLine."Journal Template Name");
                ReqLine.SetRange("Completely Processed", false);
                OnSetRecordsOnAfterFilterReqLine(ReqLine);
                if ReqLine.FindSet() then
                    repeat
                        If Not Rec.Get(ReqLine."Document No.", ReqLine."Line No.") then begin
                            Rec.Copy(ReqLine);
                            Rec.Insert();
                        end;
                    until ReqLine.Next() = 0;

            until ReqHeader.Next() = 0;

        Rec.Reset();
    end;

    local procedure CheckSelection()
    begin
        if Rec.Select then begin

            if isCreatePurchaseDocument then
                if Rec."Vendor No." = '' then
                    Rec.FieldError("Vendor No.");

            if isCreateTransferDocument then begin
                if Rec."Transfer-from Code" = '' then
                    Rec.FieldError("Transfer-from Code");
                if Rec."Transfer-from Code" <> '' then
                    if RequestCode.Get(rec."Request Code") and (RequestCode."In-Transit Code" = '') then begin
                        TransferRoute.Get(Rec."Transfer-from Code", Rec."Location Code");
                        TransferRoute.TestField("In-Transit Code");
                    end;
            end;

            if Rec."Qty. to Process" = 0 then
                Rec.FieldError("Qty. to Process");

        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetRecordsOnAfterFilterReqLine(var ReqLine: Record PPHRDS_ReqLine)
    begin
    end;
}
