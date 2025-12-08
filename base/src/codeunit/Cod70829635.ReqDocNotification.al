codeunit 70829635 PPHRDS_ReqDocNotification
{
    trigger OnRun()
    begin
    end;

    var
        MyNotifications: Record "My Notifications";
        RequestType: Enum PPHRDS_RequestType;
        RequestPurchDocType: Enum PPHRDS_RequestPurchDocType;
        TotalRequest: Integer;
        TheNotification: Notification;
        PendingRequestTxt: Label 'There are %1 available request document.', Comment = '%1 = Total available request';
        ShowReqMsg: Label 'Get request lines.';
        PendingRequestDocumentDescriptionTxt: Label 'Show warning when a request document is available.';
        AvailReqDocForPurchQuoteTxt: Label 'Available request document for purchase quote.';
        AvailReqDocForPurchOrderTxt: Label 'Available request document for purchase order.';
        AvailReqDocForPurchInvoiceTxt: Label 'Available request document for purchase invoice.';
        AvailReqDocForTransOrderTxt: Label 'Available request document for transfer order.';
        AvailReqDocForItemJnlTxt: Label 'Available request document for item journal.';
        AvailReqDocForReqWhstTxt: Label 'Available request document for requisition worksheet.';
        AvailReqDocForGenJnlTxt: Label 'Available request document for general journal.';
        DontShowAgainTxt: Label 'Don''t show again';

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quotes", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseQuotesOnOpenPageEvent(var Rec: Record "Purchase Header")
    begin
        if not MyNotifications.IsEnabled(GetPurchQuoteNotifID()) then
            exit;

        TotalRequest := CountPendingRequest(RequestType::Purchase, RequestPurchDocType::Quote);
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForPurchDocCode());
        TheNotification.SetData('RequestPurchDocType', Format(RequestPurchDocType::Quote));
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetPurchQuoteNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseOrderListOnOpenPageEvent(var Rec: Record "Purchase Header")
    begin
        if not MyNotifications.IsEnabled(GetPurchOrderNotifID()) then
            exit;

        TotalRequest := CountPendingRequest(RequestType::Purchase, RequestPurchDocType::Order);
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForPurchDocCode());
        TheNotification.SetData('RequestPurchDocType', Format(RequestPurchDocType::Order));
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetPurchOrderNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoices", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseInvoicesOnOpenPageEvent(var Rec: Record "Purchase Header")
    begin
        if not MyNotifications.IsEnabled(GetPurchInvoiceNotifID()) then
            exit;

        TotalRequest := CountPendingRequest(RequestType::Purchase, RequestPurchDocType::Invoice);
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForPurchDocCode());
        TheNotification.SetData('RequestPurchDocType', Format(RequestPurchDocType::Invoice));
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetPurchInvoiceNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Orders", 'OnOpenPageEvent', '', false, false)]
    local procedure TransferOrdersOnOpenPageEvent(var Rec: Record "Transfer Header")
    begin
        if not MyNotifications.IsEnabled(GetTransOrderNotifID()) then
            exit;

        TotalRequest := CountPendingRequest(RequestType::"Transfer Order", RequestPurchDocType::" ");
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForTransDocCode());
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetTransOrderNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Journal", 'OnOpenPageEvent', '', false, false)]
    local procedure ItemJournalOnOpenPageEvent(var Rec: Record "Item Journal Line")
    begin
        if not MyNotifications.IsEnabled(GetItemJnlNotifID()) then
            exit;

        TotalRequest := CountPendingRequest(RequestType::"Item Journal", RequestPurchDocType::" ");
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForItemJnlCode());
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetItemJnlNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Req. Worksheet", 'OnOpenPageEvent', '', false, false)]
    local procedure ReqWorksheetOnOpenPageEvent(var Rec: Record "Requisition Line")
    begin
        if not MyNotifications.IsEnabled(GetReqWhstNotifID()) then
            exit;

        TotalRequest := CountPendingRequest(RequestType::"Req. Worksheet", RequestPurchDocType::" ");
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForReqWhstCode());
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetReqWhstNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnAfterTemplateSelection', '', false, false)]
    local procedure GenJnlManagementOnAfterTemplateSelection(var GenJnlTemplate: Record "Gen. Journal Template"; var GenJnlLine: Record "Gen. Journal Line"; var JnlSelected: Boolean; var OpenFromBatch: Boolean; RecurringJnl: Boolean)
    begin
        if not (GenJnlTemplate."Page ID" in [39, 256]) then
            exit;

        if not MyNotifications.IsEnabled(GetGenJnlNotifID()) then
            exit;

        TotalRequest := CountPendingRequestGenJnl(GenJnlTemplate.Name);
        if TotalRequest = 0 then
            exit;

        TheNotification.Id := Format(CreateGuid(), 0, 9);
        TheNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        TheNotification.Message := StrSubstNo(PendingRequestTxt, TotalRequest);
        TheNotification.AddAction(ShowReqMsg, Codeunit::"PPHRDS_ReqDocNotification", OpenGetRequestLinesForGenJnlCode());
        TheNotification.AddAction(DontShowAgainTxt, Codeunit::"PPHRDS_ReqDocNotification", TurnOffReminderCode());
        TheNotification.SetData('NotifID', GetGenJnlNotifID());
        TheNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        PASIInstallApp: Record PHLLMT_PASIInstallApp;
        LicenseMgmt: Codeunit PPHRDS_LicenseMgmt;
    begin
        if not PASIInstallApp.Get(LicenseMgmt.GetRegisteredAppID()) then
            exit;

        MyNotifications.InsertDefaultWithTableNum(GetPurchQuoteNotifID(),
          AvailReqDocForPurchQuoteTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);

        MyNotifications.InsertDefaultWithTableNum(GetPurchOrderNotifID(),
          AvailReqDocForPurchOrderTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);

        MyNotifications.InsertDefaultWithTableNum(GetPurchInvoiceNotifID(),
          AvailReqDocForPurchInvoiceTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);

        MyNotifications.InsertDefaultWithTableNum(GetTransOrderNotifID(),
          AvailReqDocForTransOrderTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);

        MyNotifications.InsertDefaultWithTableNum(GetItemJnlNotifID(),
          AvailReqDocForItemJnlTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);

        MyNotifications.InsertDefaultWithTableNum(GetReqWhstNotifID(),
          AvailReqDocForReqWhstTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);

        MyNotifications.InsertDefaultWithTableNum(GetGenJnlNotifID(),
          AvailReqDocForGenJnlTxt,
          PendingRequestDocumentDescriptionTxt,
          DATABASE::PPHRDS_ReqHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::PHLLMT_PASIInstallApp, 'OnAfterDeleteEvent', '', false, false)]
    local procedure PASIInstallAppOnAfterDeleteEvent(var Rec: Record PHLLMT_PASIInstallApp; RunTrigger: Boolean)
    begin
        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetPurchDocNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetPurchQuoteNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetPurchOrderNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetPurchInvoiceNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetTransOrderNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetItemJnlNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetReqWhstNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);

        MyNotifications.Reset();
        MyNotifications.SetRange("Notification Id", GetGenJnlNotifID());
        if not MyNotifications.IsEmpty then
            MyNotifications.DeleteAll(true);
    end;

    procedure TurnOffReminderCode(): Code[128];
    begin
        exit(UpperCase('TurnOffReminder'));
    end;

    procedure TurnOffReminder(LicenseNotification: Notification)
    begin
        MyNotifications.Disable(LicenseNotification.GetData('NotifID'));
    end;

    procedure OpenGetRequestLinesForPurchDocCode(): Code[128];
    begin
        exit(UpperCase('OpenGetRequestLinesForPurchDoc'));
    end;

    procedure OpenGetRequestLinesForPurchDoc(LicenseNotification: Notification)
    var
        GetRequestLines: Page PPHRDS_GetRequestLines;
        locPurchaseHeader: Record "Purchase Header";
    begin
        Clear(GetRequestLines);
        case LicenseNotification.GetData('RequestPurchDocType') of
            'Quote':
                begin
                    GetRequestLines.CreatePurchaseDocument(locPurchaseHeader);
                    GetRequestLines.SetRecords(locPurchaseHeader, RequestPurchDocType::Quote);
                    GetRequestLines.RunModal();
                end;
            'Order':
                begin
                    GetRequestLines.CreatePurchaseDocument(locPurchaseHeader);
                    GetRequestLines.SetRecords(locPurchaseHeader, RequestPurchDocType::Order);
                    GetRequestLines.RunModal();
                end;
            'Invoice':
                begin
                    GetRequestLines.CreatePurchaseDocument(locPurchaseHeader);
                    GetRequestLines.SetRecords(locPurchaseHeader, RequestPurchDocType::Invoice);
                    GetRequestLines.RunModal();
                end;
        end;
    end;

    local procedure OpenGetRequestLinesForTransDocCode(): Code[128];
    begin
        exit(UpperCase('OpenGetRequestLinesForTransDoc'));
    end;

    procedure OpenGetRequestLinesForTransDoc(LicenseNotification: Notification)
    var
        GetRequestLines: Page PPHRDS_GetRequestLines;
        locTransferHeader: Record "Transfer Header";
    begin
        Clear(GetRequestLines);
        GetRequestLines.CreateTransferDocument(locTransferHeader);
        GetRequestLines.SetRecords(locTransferHeader);
        GetRequestLines.RunModal();
    end;

    local procedure OpenGetRequestLinesForItemJnlCode(): Code[128];
    begin
        exit(UpperCase('OpenGetRequestLinesForItemJnl'));
    end;

    procedure OpenGetRequestLinesForItemJnl(LicenseNotification: Notification)
    var
        GetRequestLines: Page PPHRDS_GetRequestLines;
        locItemJournalLine: Record "Item Journal Line";
        ReqDocSysTempStorage: Codeunit PPHRDS_ReqDocSysTempStorage;
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
    begin
        Clear(GetRequestLines);
        ReqDocSysTempStorage.GetJnlTemplateAndBatchName(JournalTemplateName, JournalBatchName);
        locItemJournalLine."Journal Template Name" := JournalTemplateName;
        locItemJournalLine."Journal Batch Name" := JournalBatchName;
        GetRequestLines.CreateItemJournalLine(locItemJournalLine);
        GetRequestLines.SetRecords(locItemJournalLine);
        GetRequestLines.RunModal();
    end;

    local procedure OpenGetRequestLinesForReqWhstCode(): Code[128];
    begin
        exit(UpperCase('OpenGetRequestLinesForReqWhst'));
    end;

    procedure OpenGetRequestLinesForReqWhst(LicenseNotification: Notification)
    var
        GetRequestLines: Page PPHRDS_GetRequestLines;
        locRequisitionLine: Record "Requisition Line";
        ReqDocSysTempStorage: Codeunit PPHRDS_ReqDocSysTempStorage;
        WorksheetTemplateName: Code[10];
        JournalBatchName: Code[10];
    begin
        ReqDocSysTempStorage.GetJnlTemplateAndBatchName(WorksheetTemplateName, JournalBatchName);
        locRequisitionLine."Worksheet Template Name" := WorksheetTemplateName;
        locRequisitionLine."Journal Batch Name" := JournalBatchName;
        Clear(GetRequestLines);
        GetRequestLines.CreateRequisitionLine(locRequisitionLine);
        GetRequestLines.SetRecords(locRequisitionLine);
        GetRequestLines.RunModal();
    end;

    local procedure OpenGetRequestLinesForGenJnlCode(): Code[128];
    begin
        exit(UpperCase('OpenGetRequestLinesForGenJnl'));
    end;

    procedure OpenGetRequestLinesForGenJnl(LicenseNotification: Notification)
    var
        GetRequestLines: Page PPHRDS_GetRequestLines;
        locGenJournalLine: Record "Gen. Journal Line";
        ReqDocSysTempStorage: Codeunit PPHRDS_ReqDocSysTempStorage;
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
    begin

        Clear(GetRequestLines);
        ReqDocSysTempStorage.GetJnlTemplateAndBatchName(JournalTemplateName, JournalBatchName);
        locGenJournalLine."Journal Template Name" := JournalTemplateName;
        locGenJournalLine."Journal Batch Name" := JournalBatchName;
        GetRequestLines.CreateGenJournalLine(locGenJournalLine);
        GetRequestLines.SetRecords(locGenJournalLine);
        GetRequestLines.RunModal();
    end;

    procedure CountPendingRequest(locRequestType: Enum PPHRDS_RequestType; locRequestPurchDocType: Enum PPHRDS_RequestPurchDocType): Integer;
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
        ReqDocSysTempStorage: Codeunit PPHRDS_ReqDocSysTempStorage;
        locTotalRequest: Integer;
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
    begin

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                case locRequestType of
                    locRequestType::Purchase:
                        begin
                            ReqLine.SetRange("Request Type", ReqLine."Request Type"::Purchase);
                            ReqLine.SetRange("Request Purch. Document Type", locRequestPurchDocType);
                        end;
                    locRequestType::"Transfer Order":
                        ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Transfer Order");
                    locRequestType::"Item Journal":
                        ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Item Journal");
                    locRequestType::"Req. Worksheet":
                        ReqLine.SetRange("Request Type", ReqLine."Request Type"::"Req. Worksheet");
                    locRequestType::"General Journal":
                        begin
                            ReqDocSysTempStorage.GetJnlTemplateAndBatchName(JournalTemplateName, JournalBatchName);
                            Message(JournalTemplateName);
                            ReqLine.SetRange("Request Type", ReqLine."Request Type"::"General Journal");
                            ReqLine.SetRange("Journal Template Name", JournalTemplateName);
                        end;
                    else
                        OnCountPendingRequestOnTypeCaseElse(locRequestType, ReqLine, locRequestPurchDocType);
                end;
                ReqLine.SetRange("Completely Processed", false);
                if not ReqLine.IsEmpty then
                    locTotalRequest += 1;

            until ReqHeader.Next() = 0;

        exit(locTotalRequest);

    end;

    procedure CountPendingRequestGenJnl(JournalTemplateName: Code[10]): Integer;
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqLine: Record PPHRDS_ReqLine;
        locTotalRequest: Integer;
    begin

        ReqHeader.Reset();
        ReqHeader.SetRange(Status, ReqHeader.Status::Released);
        if ReqHeader.FindSet() then
            repeat

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", ReqHeader."No.");
                ReqLine.SetRange("Request Type", ReqLine."Request Type"::"General Journal");
                ReqLine.SetRange("Journal Template Name", JournalTemplateName);
                ReqLine.SetRange("Completely Processed", false);
                if not ReqLine.IsEmpty then
                    locTotalRequest += 1;

            until ReqHeader.Next() = 0;

        exit(locTotalRequest);

    end;

    procedure GetPurchDocNotifID(): Guid
    begin
        exit('a7c0e78c-3e59-4d12-aa56-28d53da666fc')
    end;

    procedure GetPurchQuoteNotifID(): Guid
    begin
        exit('fe9a6d3d-a841-467d-8947-3eb1b3280553')
    end;

    procedure GetPurchOrderNotifID(): Guid
    begin
        exit('bec9373e-ec06-4dca-abf6-8796a38110e4')
    end;

    procedure GetPurchInvoiceNotifID(): Guid
    begin
        exit('1fb9f392-c4c1-4929-86ac-ecac6571fe32')
    end;

    procedure GetTransOrderNotifID(): Guid
    begin
        exit('d2650395-c271-44c4-9fae-9622d1eb2c1a')
    end;

    procedure GetItemJnlNotifID(): Guid
    begin
        exit('6a7e966c-2294-4d97-b32e-7d446deef791')
    end;

    procedure GetReqWhstNotifID(): Guid
    begin
        exit('3107ec8c-264d-49c1-b88c-f3f587f37085')
    end;

    procedure GetGenJnlNotifID(): Guid
    begin
        exit('2fd76b88-b8f7-4280-9a13-2855c89c1825')
    end;

    [IntegrationEvent(false, false)]
    procedure OnCountPendingRequestOnTypeCaseElse(var RequestType: Enum PPHRDS_RequestType; var ReqLine: Record PPHRDS_ReqLine; var RequestPurchDocType: Enum PPHRDS_RequestPurchDocType)
    begin
    end;
}