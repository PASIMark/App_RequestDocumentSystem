codeunit 70829582 "PPHRDS_LicenseMgmt"
{
    trigger OnRun()
    begin

    end;

    var
        InstalledApp: Record PHLLMT_PASIInstallApp;
        DecryptLicenseMgmt: Codeunit PHLLMT_DecryptLicenseMgmt;
        PlanIds: Codeunit "Plan Ids";
        TeamMemberLicenseInvalidTxt: Label 'Your license is not valid for a team member user.';

    procedure GetRegisteredAppID(): Guid
    begin
        GetInstalledAppRecord();
        exit(InstalledApp."App ID");
    end;

    procedure RegisterApp(var parInstalledApp: Record "PHLLMT_PASIInstallApp")
    begin
        if not GetInstalledAppRecord() then begin
            InstalledApp.Init();
            InstalledApp.Validate("App ID", ReqDocSysAppID());
            InstalledApp.Insert(true);
            Commit();
        end;
        parInstalledApp := InstalledApp;
    end;

    procedure GetRegisteredAppName(): Text[2048]
    begin
        GetInstalledAppRecord();
        exit(InstalledApp."App Name");
    end;

    procedure PromptErrorIfLicenseInvalid()
    var
        LicensedUsers: Integer;
        UserLicenseType: List of [Text];
    begin
        if not DecryptLicenseMgmt.ValidLicensedUser(GetRegisteredAppName()) then
            Error(GetLastErrorText());

        Clear(UserLicenseType);
        Clear(LicensedUsers);
        DecryptLicenseMgmt.GetLicenseDetails(UserLicenseType, LicensedUsers);

        if (not UserLicenseType.Contains(PlanIds.GetPremiumPlanId())) and
            (not UserLicenseType.Contains(PlanIds.GetEssentialPlanId())) and
            (not UserLicenseType.Contains(PlanIds.GetTeamMemberPlanId())) and
            (LicensedUsers = 0)
        then
            exit;

        if (not UserLicenseType.Contains(PlanIds.GetTeamMemberPlanId())) and isTeamMemberPlan() then
            Error(TeamMemberLicenseInvalidTxt);
    end;

    procedure AssignUserLicenseType(var Rec: Record PHLLMT_PASIInstallApp)
    var
        UserLicenseMgmt: Codeunit PHLLMT_UserLicenseMgmt;
        UserLicenseType: List of [Text];
    begin
        Clear(UserLicenseType);

        if Rec."App ID" = ReqDocSysAppID() then begin

            if UserLicenseMgmt.GetUserCount(PlanIds.GetPremiumPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetPremiumPlanId());

            if UserLicenseMgmt.GetUserCount(PlanIds.GetEssentialPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetEssentialPlanId());

            if UserLicenseMgmt.GetUserCount(PlanIds.GetTeamMemberPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetTeamMemberPlanId());

            Rec."User Type Requirement" := UserLicenseMgmt.GetUserRequirmentType(UserLicenseType);
            Rec.Modify();

        end;
    end;

    procedure GetUserLicenseType(Rec: Record PHLLMT_PASIInstallApp; var UserType: Integer)
    var
        UserLicenseMgmt: Codeunit PHLLMT_UserLicenseMgmt;
        UserLicenseType: List of [Text];
    begin
        Clear(UserLicenseType);

        if Rec."App ID" = ReqDocSysAppID() then begin

            if UserLicenseMgmt.GetUserCount(PlanIds.GetPremiumPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetPremiumPlanId());

            if UserLicenseMgmt.GetUserCount(PlanIds.GetEssentialPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetEssentialPlanId());

            if UserLicenseMgmt.GetUserCount(PlanIds.GetTeamMemberPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetTeamMemberPlanId());

            UserType := UserLicenseMgmt.GetUserRequirmentType(UserLicenseType);

        end;
    end;

    [Obsolete('Obsolete in version 1.0.0.4')]
    procedure GetUserLicenseType(Rec: Record PHLLMT_PASIInstallApp): Integer
    var
        UserLicenseMgmt: Codeunit PHLLMT_UserLicenseMgmt;
        UserLicenseType: List of [Text];
    begin
        Clear(UserLicenseType);

        if Rec."App ID" = ReqDocSysAppID() then begin

            if UserLicenseMgmt.GetUserCount(PlanIds.GetPremiumPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetPremiumPlanId());

            if UserLicenseMgmt.GetUserCount(PlanIds.GetEssentialPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetEssentialPlanId());

            if UserLicenseMgmt.GetUserCount(PlanIds.GetTeamMemberPlanId()) > 0 then
                UserLicenseType.Add(PlanIds.GetTeamMemberPlanId());

            exit(UserLicenseMgmt.GetUserRequirmentType(UserLicenseType));

        end;
    end;

    local procedure GetInstalledAppRecord(): Boolean
    begin
        exit(InstalledApp.Get(ReqDocSysAppID()))
    end;

    local procedure ReqDocSysAppID(): Guid
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        exit(ModuleInfo.Id)
    end;

    local procedure isTeamMemberPlan(): Boolean
    var
        UsersInPlans: Query "Users in Plans";
    begin
        UsersInPlans.SetRange(User_Security_ID, UserSecurityId());
        UsersInPlans.SetRange(Plan_ID, PlanIds.GetTeamMemberPlanId());
        UsersInPlans.Open();
        if UsersInPlans.Read() then
            exit(true);
        exit(false);
    end;
}