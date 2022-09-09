codeunit 70829585 "PPHRDS_LicMgmtHandler"
{
    trigger OnRun()
    begin

    end;

    var
        LicenseMgmt: Codeunit PPHRDS_LicenseMgmt;


    [EventSubscriber(ObjectType::Table, DATABASE::PHLLMT_PASIInstallApp, 'OnAfterInsertEvent', '', false, false)]
    local procedure PASIInstallAppOnAfterInsertEvent(var Rec: Record PHLLMT_PASIInstallApp; RunTrigger: Boolean)
    begin
        LicenseMgmt.AssignUserLicenseType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::PHLLMT_PASIInstallApp, 'OnAfterRenameEvent', '', false, false)]
    local procedure PASIInstallAppOnAfterRenameEvent(var Rec: Record PHLLMT_PASIInstallApp; RunTrigger: Boolean)
    begin
        LicenseMgmt.AssignUserLicenseType(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::PHLLMT_PASIInstalledAppCard, 'OnAfterDefaultSetLicenseRequirements', '', false, false)]
    local procedure PASIInstalledAppCardOnAfterDefaultSetLicenseRequirements(PASIInstallApp: Record PHLLMT_PASIInstallApp; var UserType: Integer)
    begin
        LicenseMgmt.GetUserLicenseType(PASIInstallApp, UserType);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PHLLMT_DecryptLicenseMgmt, 'OnBeforeGetLicenseUrl', '', false, false)]
    local procedure DecryptLicenseMgmtOnBeforeGetLicenseUrl(AppID: Guid; AppName: Text; var url: Text; var IsHandled: Boolean)
    var
        urlTxt: Label 'https://pasilicenseportal.azurewebsites.net/Licenses/ByVoiceId/%1/%2', Comment = '%1 = Voice No., %2 = App Name';
    begin
        if not (LicenseMgmt.GetRegisteredAppID() = AppID) then
            exit;

        url := StrSubstNo(urlTxt, SerialNumber().Trim(), LicenseMgmt.GetRegisteredAppName());
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PHLLMT_DecryptLicenseMgmt, 'OnBeforeGetRegistrationUrl', '', false, false)]
    local procedure DecryptLicenseMgmtOnBeforeGetRegistrationUrl(AppID: Guid; AppName: Text; var url: Text; var IsHandled: Boolean)
    var
        urlTxt: Label 'https://pasilicenseportal.azurewebsites.net/Identity/Account/Register?returnUrl=/authentication/login';
    begin
        if not (LicenseMgmt.GetRegisteredAppID() = AppID) then
            exit;

        url := urlTxt;
        IsHandled := true;
    end;
}