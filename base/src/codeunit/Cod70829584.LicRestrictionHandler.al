codeunit 70829584 "PPHRDS_LicRestrictionHandler"
{
    trigger OnRun()
    begin

    end;

    var
        LicenseMgmt: Codeunit PPHRDS_LicenseMgmt;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqHeader, 'OnBeforeInsertEvent', '', false, false)]
    local procedure ReqHeaderOnBeforeInsertEvent(var Rec: Record PPHRDS_ReqHeader; RunTrigger: Boolean)
    begin
        if RunTrigger then
            LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqHeader, 'OnBeforeModifyEvent', '', false, false)]
    local procedure ReqHeaderOnBeforeModifyEvent(var xRec: Record PPHRDS_ReqHeader; var Rec: Record PPHRDS_ReqHeader; RunTrigger: Boolean)
    begin
        if RunTrigger then
            LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqHeader, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure ReqHeaderOnBeforeDeleteEvent(var Rec: Record PPHRDS_ReqHeader; RunTrigger: Boolean)
    begin
        if RunTrigger then
            LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqLine, 'OnBeforeInsertEvent', '', false, false)]
    local procedure ReqLineOnBeforeInsertEvent(var Rec: Record PPHRDS_ReqLine; RunTrigger: Boolean)
    begin
        if RunTrigger then
            LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqLine, 'OnBeforeModifyEvent', '', false, false)]
    local procedure ReqLineOnBeforeModifyEvent(var xRec: Record PPHRDS_ReqLine; var Rec: Record PPHRDS_ReqLine; RunTrigger: Boolean)
    begin
        if RunTrigger then
            LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Table, Database::PPHRDS_ReqLine, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure ReqLineOnBeforeDeleteEvent(var Rec: Record PPHRDS_ReqLine; RunTrigger: Boolean)
    begin
        if RunTrigger then
            LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_RequestManagement, 'OnBeforeInitializeDefaultSetup', '', false, false)]
    local procedure RequestManagementOnBeforeInitializeDefaultSetup(var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_ProcessRequestDocument, 'OnBeforeProcessPurchaseHeader', '', false, false)]
    local procedure ProcessRequestDocumentOnBeforeProcessPurchaseHeader(PurchaseHeader: Record "Purchase Header"; var TempReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_ProcessRequestDocument, 'OnBeforeProcessTransferHeader', '', false, false)]
    local procedure ProcessRequestDocumentOnBeforeProcessTransferHeader(TransferHeader: Record "Transfer Header"; var TempReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_ProcessRequestDocument, 'OnBeforeProcessItemJournalLine', '', false, false)]
    local procedure ProcessRequestDocumentOnBeforeProcessItemJournalLine(ItemJournalLine: Record "Item Journal Line"; var TempReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_ProcessRequestDocument, 'OnBeforeProcessRequisitionLine', '', false, false)]
    local procedure ProcessRequestDocumentOnBeforeProcessRequisitionLine(RequisitionLine: Record "Requisition Line"; var TempReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_ProcessRequestDocument, 'OnBeforeNewPurchaseDocument', '', false, false)]
    local procedure ProcessRequestDocumentOnBeforeNewPurchaseDocument(var TempReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_ProcessRequestDocument, 'OnBeforeNewTransferDocument', '', false, false)]
    local procedure ProcessRequestDocumentOnBeforeNewTransferDocument(var TempReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean)
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;

    [EventSubscriber(ObjectType::Report, Report::PPHRDS_Request, 'OnBeforeInitReport', '', false, false)]
    local procedure RequestOnBeforeInitReport()
    begin
        LicenseMgmt.PromptErrorIfLicenseInvalid();
    end;
}