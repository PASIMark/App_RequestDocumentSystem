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
            group(Restrictions)
            {
                Caption = 'Restrictions';
                group("Request Document")
                {
                    Caption = 'Request Document';
                    field("Allow Edit Released Req. Hdr"; Rec."Allow Edit Released Req. Hdr")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit key header fields (Requestor ID, Request Date, Document Date, Location Code, Request Code) on a Request after it has been released. Turn on to bypass the restriction.';
                    }
                    field("Allow Edit Released Req. Line"; Rec."Allow Edit Released Req. Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit fields, insert new lines, or delete lines on a Request that has been released. Data-integrity checks (for example, reducing a quantity below what has already been processed) still apply. Turn on to bypass the released-status restriction.';
                    }
                    field("Allow Edit Purch. Code w/ Appr"; Rec."Allow Edit Purch. Code w/ Appr")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to change the Purchaser Code on a Request Header while an approval process is still open. Turn on to bypass the restriction.';
                    }
                    field("Allow Inactive Request Code"; Rec."Allow Inactive Request Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to use a Request Code that is marked as inactive on a Request Line. Turn on to bypass the active-code check.';
                    }
                }
                group(Purchase)
                {
                    Caption = 'Purchase';
                    field("Allow Edit Purchase Line"; Rec."Allow Edit Purchase Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit key fields (Vendor, Type, No., Location, Unit of Measure, Quantity) on a Purchase Line that has already been processed from a Request. Turn on to bypass the restriction.';
                    }
                }
                group(Transfer)
                {
                    Caption = 'Transfer';
                    field("Allow Edit Transfer Header"; Rec."Allow Edit Transfer Header")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to change the Transfer-to Code on a Transfer Header that has already been processed from a Request. Turn on to bypass the restriction.';
                    }
                    field("Allow Edit Transfer Line"; Rec."Allow Edit Transfer Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit key fields (Transfer-from Code, Transfer-to Code, Item No., Quantity, Unit of Measure) on a Transfer Line that has already been processed from a Request. Turn on to bypass the restriction.';
                    }
                }
                group("Item Journal")
                {
                    Caption = 'Item Journal';
                    field("Allow Edit Item Journal Line"; Rec."Allow Edit Item Journal Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit key fields (Document No., Item No., Location Code, Quantity, Unit of Measure, Gen. Prod. Posting Group) on an Item Journal Line that has already been processed from a Request. Turn on to bypass the restriction.';
                    }
                }
                group("Requisition Worksheet")
                {
                    Caption = 'Requisition Worksheet';
                    field("Allow Edit Req. Wksh. Line"; Rec."Allow Edit Req. Wksh. Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit key fields (Type, No., Location Code, Quantity, Unit of Measure) on a Requisition Line that has already been processed from a Request. Turn on to bypass the restriction.';
                    }
                    field("Allow Insert Restr. Req. Line"; Rec."Allow Insert Restr. Req. Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to insert new lines into a Requisition Worksheet that currently has usage restrictions (for example, when the worksheet is pending approval). Turn on to bypass the restriction.';
                    }
                }
                group("General Journal")
                {
                    Caption = 'General Journal';
                    field("Allow Edit Gen. Journal Line"; Rec."Allow Edit Gen. Journal Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether users are allowed to edit key fields (Document No., Account Type, Account No., Quantity) on a General or Payment Journal Line that has already been processed from a Request. Turn on to bypass the restriction.';
                    }
                }
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
