page 70829575 "PPHRDS_ReqDocSysSetup"
{
    Caption = 'Request Document System Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report,License,Setup';
    SourceTable = PPHRDS_ReqDocSysSetup;
    ApplicationArea = All;
    AboutTitle = 'About Request Document System Setup';
    AboutText = 'Register license to use the Request Document System.';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Visible = false;
            }
            group(Budget)
            {
                Caption = 'Budget';
                group("G/L Account")
                {
                    Caption = 'G/L Account';
                    field("G/L Budget Name"; Rec."G/L Budget Name")
                    {
                        Tooltip = 'Specifies the G/L Budget Name.';
                        ApplicationArea = All;
                        Caption = 'Budget Name';
                    }
                }
                group(Item)
                {
                    Caption = 'Item';
                    field("Item Budget Name"; Rec."Item Budget Name")
                    {
                        Tooltip = 'Specifies the Item Budget Name.';
                        ApplicationArea = All;
                        Caption = 'Budget Name';
                    }
                    field("Item Budget Type"; Rec."Item Budget Type")
                    {
                        Tooltip = 'Specifies the Item Budget Type.';
                        ApplicationArea = All;
                        Caption = 'Budget Type';
                    }
                }
            }
            group("Number Series")
            {
                group(Control21)
                {
                    ShowCaption = false;
                    group(Control17)
                    {
                        ShowCaption = false;
                        field("Request Nos."; Rec."Request Nos.")
                        {
                            Tooltip = 'Specifies the Request Nos..';
                            ApplicationArea = All;
                        }
                        field("Processed Request Nos."; Rec."Processed Request Nos.")
                        {
                            Tooltip = 'Specifies the Processed Request Nos..';
                            ApplicationArea = All;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RegisterApp)
            {
                Caption = 'Register';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Register the license of the Request Document System.';
                Image = Register;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                AboutTitle = 'Register the license.';
                AboutText = 'Register the license key provided to your company.';

                trigger OnAction();
                var
                    InstalledApp: Record "PHLLMT_PASIInstallApp";
                    LicenseMgmt: Codeunit PPHRDS_LicenseMgmt;
                begin
                    LicenseMgmt.RegisterApp(InstalledApp);
                    Page.RunModal(Page::PHLLMT_PASIInstalledAppCard, InstalledApp)
                end;
            }
            action(CreateSetupData)
            {
                ApplicationArea = All;
                Caption = 'C&reate Setup Data';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ToolTip = 'Runs a routine which creates the default setup.';
                PromotedOnly = true;
                AboutTitle = 'Create Setup Data.';
                AboutText = 'Creates default request document system data.';

                trigger OnAction();
                var
                    RequestManagement: Codeunit PPHRDS_RequestManagement;
                begin
                    RequestManagement.InitializeDefaultSetup();
                end;
            }
            action(RequestUserSetup)
            {
                ApplicationArea = All;
                Caption = 'User Setup';
                Image = Users;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ToolTip = 'Setup users to for additional features.';
                PromotedOnly = true;
                RunObject = Page PPHRDS_ReqDocSysUserSetup;
            }
        }
    }

    trigger OnOpenPage();
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
