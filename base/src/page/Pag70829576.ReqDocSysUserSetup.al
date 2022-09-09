page 70829576 "PPHRDS_ReqDocSysUserSetup"
{
    Caption = 'Request Document System User Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = PPHRDS_ReqDocSysUserSetup;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Requestor ID"; Rec."Requestor ID")
                {
                    Tooltip = 'Specifies the User ID.';
                    ApplicationArea = All;
                }
                field("Requestor Name"; Rec."Requestor Name")
                {
                    Tooltip = 'Specifies the User Name.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requestor ID Filter"; Rec."Requestor ID Filter")
                {
                    Tooltip = 'Specifies the Requestor ID Filter.';
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control8; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control7; Notes)
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Users")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update Users';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Users;
                ToolTip = 'Update the users for the request document system.';

                trigger OnAction()
                var
                    RequestManagement: Codeunit PPHRDS_RequestManagement;
                begin
                    RequestManagement.CreateReqDocUsers();
                end;
            }
        }
    }
}

