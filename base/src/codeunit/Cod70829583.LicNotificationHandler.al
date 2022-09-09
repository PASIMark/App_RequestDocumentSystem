codeunit 70829583 "PPHRDS_LicNotificationHandler"
{
    trigger OnRun()
    begin

    end;

    local procedure SendNotification()
    begin
        LicenseNoficationMgmt.SendLicenseExpiringNotification(LicenseMgmt.GetRegisteredAppID(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_ReqDocSysSetup, 'OnOpenPageEvent', '', false, false)]
    local procedure RequestSetupOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"G/L Budget Names", 'OnOpenPageEvent', '', false, false)]
    local procedure GLBudgetNamesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Budget Names Purchase", 'OnOpenPageEvent', '', false, false)]
    local procedure BudgetNamesPurchaseOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_FixedAssetBudgets, 'OnOpenPageEvent', '', false, false)]
    local procedure FixedAssetBudgetsOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_RequestCodes, 'OnOpenPageEvent', '', false, false)]
    local procedure RequestCodesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_RequestCodeCard, 'OnOpenPageEvent', '', false, false)]
    local procedure RequestCodeCardOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Standard Purchase Codes", 'OnOpenPageEvent', '', false, false)]
    local procedure StandardPurchaseCodesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_RequestList, 'OnOpenPageEvent', '', false, false)]
    local procedure RequestListOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_Request, 'OnOpenPageEvent', '', false, false)]
    local procedure RequestOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_ProcessedRequestList, 'OnOpenPageEvent', '', false, false)]
    local procedure ProcessedRequestListOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_ProcessedRequest, 'OnOpenPageEvent', '', false, false)]
    local procedure ProcessedRequestOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::PPHRDS_ProcessedRequest, 'OnOpenPageEvent', '', false, false)]
    local procedure ProcessedRequestEntriesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"PPHRDS_GetRequestLines", 'OnOpenPageEvent', '', false, false)]
    local procedure GetRequestLinesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quotes", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseQuotesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quote", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseQuoteOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseOrderListOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseOrderOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoices", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseInvoicesOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnOpenPageEvent', '', false, false)]
    local procedure PurchaseInvoiceOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Orders", 'OnOpenPageEvent', '', false, false)]
    local procedure TransferOrdersOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnOpenPageEvent', '', false, false)]
    local procedure TransferOrderOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Journal", 'OnOpenPageEvent', '', false, false)]
    local procedure ItemJournalOnOpenPageEvent()
    begin
        SendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Req. Worksheet", 'OnOpenPageEvent', '', false, false)]
    local procedure ReqWorksheetOnOpenPageEvent()
    begin
        SendNotification();
    end;

    var
        LicenseMgmt: Codeunit PPHRDS_LicenseMgmt;
        LicenseNoficationMgmt: Codeunit PHLLMT_LicNoficationMgmt;
}