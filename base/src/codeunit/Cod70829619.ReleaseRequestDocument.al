codeunit 70829619 PPHRDS_ReleaseRequestDocument
{
    TableNo = PPHRDS_ReqHeader;

    trigger OnRun();
    begin
        RequestHeader.Copy(Rec);
        Code();
        Rec := RequestHeader;
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        RequestApprovalMgt: Codeunit PPHRDS_RequestApprovalMgt;
        NothingToReleaseErr: Label 'There is nothing to release for the document of number %1.', Comment = '%1 = Request No.';
        RequestHeader: Record PPHRDS_ReqHeader;
        DocReleaseCompleteErr: Label 'This document can only be released when the approval process is complete.';
        ApprovalProcessCancelErr: Label 'The approval process must be cancelled or completed to reopen this document.';

    local procedure Code();
    var
        ReqLine: Record PPHRDS_ReqLine;
        RequestCode: Record PPHRDS_RequestCode;
        IsHandled: Boolean;
    begin
        OnBeforeReleaseReqDoc(RequestHeader, IsHandled);
        if IsHandled then
            exit;

        if RequestHeader.Status = RequestHeader.Status::Released then
            exit;

        RequestHeader.CheckRequestReleaseRestrictions();

        RequestHeader.TestField("Requestor ID");
        RequestHeader.TestField("Request Date");
        RequestHeader.TestField("Document Date");

        ReqLine.SetRange("Document No.", RequestHeader."No.");
        ReqLine.SetFilter(Type, '>0');
        ReqLine.SetFilter(Quantity, '<>0');
        if not ReqLine.Find('-') then
            Error(NothingToReleaseErr, RequestHeader."No.");

        ReqLine.Reset();
        ReqLine.SetRange("Document No.", RequestHeader."No.");
        ReqLine.SetFilter(Type, '>0');
        // ReqLine.SetFilter(Quantity, '<>0');
        // ReqLine.SetFilter("Qty. to Process", '<>0');
        if ReqLine.Find('-') then
            repeat

                if ReqLine."Request Type" = ReqLine."Request Type"::"Transfer Order" then
                    ReqLine.TestField("Line Amount", 0);

                RequestCode.Get(ReqLine."Request Code");
                if ReqLine.Quantity <= 0 then
                    ReqLine.FieldError(Quantity);
                ReqLine.CheckLocation();

                case RequestCode.Type of
                    RequestCode.Type::Purchase,
                    RequestCode.Type::"Req. Worksheet":
                        begin
                            ReqLine.TestField("Expected Receipt Date");
                            if ReqLine."Applies-to Purch. Doc. No." <> '' then begin
                                if ReqLine."Request Purch. Document Type" = ReqLine."Request Purch. Document Type"::Order then
                                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, ReqLine."Applies-to Purch. Doc. No.")
                                else
                                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, ReqLine."Applies-to Purch. Doc. No.");
                                PurchaseHeader.TestField(Status, RequestHeader.Status::Open);
                            end;
                        end;
                end;

                if ReqLine."Job No." <> '' then
                    ReqLine.TestField("Job Task No.");

            until ReqLine.Next() = 0;

        ReqLine.Reset();
        ReqLine.SetRange("Document No.", RequestHeader."No.");
        if ReqLine.Find('-') then
            repeat
                ReqLine.Status := ReqLine.Status::Released;
                ReqLine.Modify();
            until ReqLine.Next() = 0;

        RequestHeader.Status := RequestHeader.Status::Released;
        RequestHeader.Modify();
    end;

    procedure Reopen(var ReqHeader: Record PPHRDS_ReqHeader);
    var
        ReqLine: Record PPHRDS_ReqLine;
        IsHandled: Boolean;
    begin
        OnBeforeReopenReqDoc(ReqHeader, IsHandled);
        if IsHandled then
            exit;

        if ReqHeader.Status = ReqHeader.Status::Open then
            exit;

        ReqLine.Reset();
        ReqLine.SetRange("Document No.", ReqHeader."No.");
        if ReqLine.Find('-') then
            repeat
                ReqLine.Status := ReqLine.Status::Open;
                ReqLine.Modify();
            until ReqLine.Next() = 0;

        ReqHeader.Status := ReqHeader.Status::Open;
        ReqHeader.Modify();
    end;

    procedure PerformManualRelease(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
        PerformManualCheckAndRelease(ReqHeader);
    end;

    procedure PerformManualCheckAndRelease(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
        if RequestApprovalMgt.IsRequestHeaderPendingApproval(ReqHeader) then
            Error(DocReleaseCompleteErr);

        Codeunit.Run(Codeunit::PPHRDS_ReleaseRequestDocument, ReqHeader);
    end;

    procedure PerformManualReopen(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
        if ReqHeader.Status = ReqHeader.Status::"Pending Approval" then
            Error(ApprovalProcessCancelErr);

        Reopen(ReqHeader);
    end;

    procedure ReleaseRequestHeader(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
        RequestHeader.Copy(ReqHeader);
        Code();
        ReqHeader := RequestHeader;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseReqDoc(var ReqHeader: Record PPHRDS_ReqHeader; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenReqDoc(var ReqHeader: Record PPHRDS_ReqHeader; var IsHandled: Boolean)
    begin
    end;
}

