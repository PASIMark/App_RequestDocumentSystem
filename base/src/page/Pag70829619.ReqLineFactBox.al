page 70829619 PPHRDS_ReqLineFactBox
{
    Caption = 'Request Line Details';
    PageType = CardPart;
    SourceTable = PPHRDS_ReqLine;

    layout
    {
        area(content)
        {
            group("G/L Account")
            {
                Caption = 'G/L Account';
                Visible = GLVisibility;
                field(GLAccountNo; Rec."No.")
                {
                    Tooltip = 'Specifies the GLAccountNo.';
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(GLOutstandingQuantity; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the GLOutstandingQuantity.';
                    ApplicationArea = All;
                    Caption = 'Outstanding Quantity';
                }
                field(GLQuantityProcessed; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the GLQuantityProcessed.';
                    ApplicationArea = All;
                    Caption = 'Quantity Processed';
                }
            }
            group(Item)
            {
                Caption = 'Item';
                Visible = ItemVisibility;
                field(ItemNo; Rec."No.")
                {
                    Tooltip = 'Specifies the Item No.';
                    ApplicationArea = All;
                    Caption = 'No.';
                    Lookup = false;

                    trigger OnDrillDown();
                    begin
                        ShowDetails();
                    end;
                }
                field(Availability; StrSubstNo(AvailabilityLbl, ReqInfoPaneMgt.CalcAvailability(Rec)))
                {
                    ApplicationArea = All;
                    Caption = 'Availability';
                    //DecimalPlaces = 2:0;
                    DrillDown = true;
                    Editable = true;
                    ToolTip = 'Specifies how many units of the item on the line are available.';

                    trigger OnDrillDown();
                    begin
                        Rec.ShowItemByLocation(Rec."No.");
                    end;
                }
                field(ItemOutstandingQuantity; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the ItemOutstandingQuantity.';
                    ApplicationArea = All;
                    Caption = 'Outstanding Quantity';
                }
                field(ItemQuantityProcessed; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the ItemQuantityProcessed.';
                    ApplicationArea = All;
                    Caption = 'Quantity Processed';
                }
            }
            group("Fixed Asset")
            {
                Caption = 'Fixed Asset';
                Visible = FixedAssetVisibility;
                field(FixedAssetNo; Rec."No.")
                {
                    Tooltip = 'Specifies the FixedAssetNo.';
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(FixedAssetOutstandingQuantity; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the FixedAssetOutstandingQuantity.';
                    ApplicationArea = All;
                    Caption = 'Outstanding Quantity';
                }
                field(FixedAssetQuantityProcessed; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the FixedAssetQuantityProcessed.';
                    ApplicationArea = All;
                    Caption = 'Quantity Processed';
                }
            }
            group(Expense)
            {
                Caption = 'Expense';
                Visible = ExpVisibility;
                field(ExpenseNo; Rec."No.")
                {
                    Tooltip = 'Specifies the ExpenseNo.';
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(ExpenseAssetOutstandingQuantity; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the ExpenseAssetOutstandingQuantity.';
                    ApplicationArea = All;
                    Caption = 'Outstanding Quantity';
                }
                field(ExpenseAssetQuantityProcessed; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the ExpenseAssetQuantityProcessed.';
                    ApplicationArea = All;
                    Caption = 'Quantity Processed';
                }
            }
            group(Vendor)
            {
                Caption = 'Vendor';
                Visible = VendVisibility;
                field(VendNo; Rec."No.")
                {
                    Tooltip = 'Specifies the GLAccountNo.';
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(VendQuantity; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the GLOutstandingQuantity.';
                    ApplicationArea = All;
                    Caption = 'Outstanding Quantity';
                }
                field(VendProcessed; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the GLQuantityProcessed.';
                    ApplicationArea = All;
                    Caption = 'Quantity Processed';
                }
            }
            group(Employee)
            {
                Caption = 'Employee';
                Visible = EmplVisibility;
                field(EmplNo; Rec."No.")
                {
                    Tooltip = 'Specifies the GLAccountNo.';
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(EmplQuantity; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the GLOutstandingQuantity.';
                    ApplicationArea = All;
                    Caption = 'Outstanding Quantity';
                }
                field(EmplProcessed; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the GLQuantityProcessed.';
                    ApplicationArea = All;
                    Caption = 'Quantity Processed';
                }
            }
            group(Budget)
            {
                Caption = 'Budget';
                Visible = BudgetExist;
                field(Current; TotalBudgetValue)
                {
                    Tooltip = 'Specifies the Current.';
                    ApplicationArea = All;
                    Caption = 'Current';
                }
                field(Actual; TotalActualValue)
                {
                    Tooltip = 'Specifies the Actual.';
                    ApplicationArea = All;
                    Caption = 'Actual';
                }
                field(Released; TotalReleasedValue)
                {
                    Tooltip = 'Specifies the Released.';
                    ApplicationArea = All;
                    Caption = 'Released';
                }
                field(Purchase; TotalPurchaseValue)
                {
                    Tooltip = 'Specifies the Purchase.';
                    ApplicationArea = All;
                    Caption = 'Purchase';
                }
                field(Available; TotalAvailableValue)
                {
                    Tooltip = 'Specifies the Available.';
                    ApplicationArea = All;
                    Caption = 'Available';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord();
    begin
        Rec.ClearReqHeader();

        FactboxVisibility();
        RequestBudgetManagement.GetBudgetDetails(Rec, TotalBudgetValue, TotalActualValue, TotalReleasedValue, TotalPurchaseValue, TotalAvailableValue, BudgetExist, IsOverBudget);
    end;

    trigger OnAfterGetRecord();
    begin
        FactboxVisibility();
        RequestBudgetManagement.GetBudgetDetails(Rec, TotalBudgetValue, TotalActualValue, TotalReleasedValue, TotalPurchaseValue, TotalAvailableValue, BudgetExist, IsOverBudget);
    end;

    trigger OnOpenPage();
    begin
        FactboxVisibility();
    end;

    var
        ReqInfoPaneMgt: Codeunit PPHRDS_RequestInfoPaneMgt;
        RequestBudgetManagement: Codeunit PPHRDS_RequestBudgetManagement;
        GLVisibility: Boolean;
        ItemVisibility: Boolean;
        FixedAssetVisibility: Boolean;
        VendVisibility: Boolean;
        EmplVisibility: Boolean;
        ExpVisibility: Boolean;
        TotalBudgetValue: Decimal;
        TotalActualValue: Decimal;
        TotalReleasedValue: Decimal;
        TotalPurchaseValue: Decimal;
        TotalAvailableValue: Decimal;
        BudgetExist: Boolean;
        IsOverBudget: Boolean;
        AvailabilityLbl: Label '%1', Comment = '%1 = Availability';

    local procedure ShowDetails();
    var
        locItem: Record Item;
    begin
        if Rec.Type = Rec.Type::Item then begin
            locItem.Get(Rec."No.");
            PAGE.Run(PAGE::"Item Card", locItem);
        end;
    end;

    local procedure FactboxVisibility();
    begin
        ItemVisibility := false;
        GLVisibility := false;
        FixedAssetVisibility := false;
        VendVisibility := false;
        EmplVisibility := false;
        ExpVisibility := false;

        case Rec.Type of
            Rec.Type::Item:
                ItemVisibility := true;
            Rec.Type::"G/L Account":
                GLVisibility := true;
            Rec.Type::"Fixed Asset":
                FixedAssetVisibility := true;
            Rec.Type::Vendor:
                VendVisibility := true;
            Rec.Type::Employee:
                EmplVisibility := true;
        end;
    end;
}

