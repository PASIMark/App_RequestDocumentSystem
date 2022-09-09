codeunit 70830055 "PPHRDS_TestLibrary"
{
    trigger OnRun()
    begin

    end;

    var
        InstalledApp: Record PHLLMT_PASIInstallApp;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DecryptLicenseMgmt: Codeunit PHLLMT_DecryptLicenseMgmt;
        REQNoSeriesCodeTxt: Label 'REQ';
        ReqDocSysAppIDTxt: Label '25a9851d-b839-4163-8fd2-f7e922d0339d';
        LicenseKeyTxt: Label 'RDhDPiRZLVZSMCAzKRRFFFZSMCBFOSZWJGxjQDJDOyVVKWljQTAzKRRFFFZSMCAzKRRFFFZSMCBHKRRFFFZSMCAzKRRFFFZSMCAzKUZqRcKLd2NUM01DaEnCg3deVDNcTXhIe38=';

    procedure GetRegisteredAppID(): Guid
    begin
        GetInstalledAppRecord();
        exit(InstalledApp."App ID");
    end;

    procedure PromptErrorIfLicenseInvalid()
    begin
        if not DecryptLicenseMgmt.ValidLicensedUser(GetRegisteredAppName()) then
            Error(GetLastErrorText());
    end;

    procedure RegisterApp();
    begin
        if not GetInstalledAppRecord() then begin
            InstalledApp.Init();
            InstalledApp.Validate("App ID", ReqDocSysAppIDTxt);
            InstalledApp.Insert(true);
            DecryptLicenseMgmt.ImportLicenseKey(InstalledApp, LicenseKeyTxt);
        end;
    end;

    local procedure GetInstalledAppRecord(): Boolean
    begin
        exit(InstalledApp.Get(ReqDocSysAppIDTxt))
    end;

    local procedure GetRegisteredAppName(): Text[2048]
    begin
        GetInstalledAppRecord();
        exit(InstalledApp."App Name");
    end;

    procedure InsertRequestHeader(var ReqHeader: Record PPHRDS_ReqHeader)
    begin
        ReqHeader.Init();
        ReqHeader.Insert(true);
    end;

    procedure GetRequestAssignedNoSeries(): Code[20]
    begin
        exit(NoSeriesManagement.TryGetNextNo(REQNoSeriesCodeTxt, WorkDate()));
    end;
}