page 70829595 PPHRDS_FixedAssetBudgets
{
    Caption = 'Fixed Asset Budgets';
    PageType = List;
    UsageCategory = Lists;
    SourceTable = PPHRDS_FixedAssetBudget;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Tooltip = 'Specifies the Description.';
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    Tooltip = 'Specifies the Amount.';
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    Tooltip = 'Specifies the Blocked.';
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control7; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control6; Notes)
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Suggest Fixed Assets")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Fixed Assets';
                    Image = Suggest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Suggest Fixed Assets.';

                    trigger OnAction();
                    begin
                        RequestBudgetManagement.AddBudgetedAsset();
                    end;
                }
            }
        }
    }

    var
        RequestBudgetManagement: Codeunit PPHRDS_RequestBudgetManagement;
}

