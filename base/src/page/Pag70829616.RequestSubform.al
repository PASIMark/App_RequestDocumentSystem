page 70829616 PPHRDS_RequestSubform
{
    AutoSplitKey = true;
    Caption = 'Lines';
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = PPHRDS_ReqLine;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    Tooltip = 'Specifies the Type.';
                    ApplicationArea = All;
                    ShowMandatory = TypeChosen;
                    StyleExpr = BudgetStyleExpression;

                    trigger OnValidate();
                    begin
                        TypeChosen := Rec.HasTypeToFillMandatotyFields();
                    end;
                }
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;

                    trigger OnValidate();
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the Variant Code.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                    Visible = false;
                }
                field("Item Reference No."; Rec."Item Reference No.")
                {
                    Tooltip = 'Specifies the Item Reference No..';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                    Visible = false;
                }
                field("IC Partner Code"; Rec."IC Partner Code")
                {
                    Tooltip = 'Specifies the IC Partner Code.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                    Visible = false;
                }
                field("IC Partner Reference"; Rec."IC Partner Reference")
                {
                    Tooltip = 'Specifies the IC Partner Reference.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                    Visible = false;
                }
                field("IC Partner Ref. Type"; Rec."IC Partner Ref. Type")
                {
                    Tooltip = 'Specifies the IC Partner Ref. Type.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    Tooltip = 'Specifies the Description.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                }
                field("Description 2"; Rec."Description 2")
                {
                    Tooltip = 'Specifies the Description 2.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                    Visible = false;
                }
                field(Notes; Rec.Notes)
                {
                    Tooltip = 'Specifies the Notes.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Tooltip = 'Specifies the Location Code.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                }
                field(Quantity; Rec.Quantity)
                {
                    Tooltip = 'Specifies the Quantity.';
                    ApplicationArea = All;
                    ShowMandatory = TypeChosen;
                    StyleExpr = BudgetStyleExpression;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Tooltip = 'Specifies the Unit of Measure Code.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    Tooltip = 'Specifies the Direct Unit Cost.';
                    ApplicationArea = All;
                    ShowMandatory = TypeChosen;
                    StyleExpr = BudgetStyleExpression;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    Tooltip = 'Specifies the Line Amount.';
                    ApplicationArea = All;
                    StyleExpr = BudgetStyleExpression;
                }
                field("Qty. to Process"; Rec."Qty. to Process")
                {
                    Tooltip = 'Specifies the Qty. to Process.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quantity Processed"; Rec."Quantity Processed")
                {
                    Tooltip = 'Specifies the Quantity Processed.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    Tooltip = 'Specifies the Outstanding Quantity.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    Tooltip = 'Specifies the Expected Receipt Date.';
                    ApplicationArea = All;
                }
                field("Request Code"; Rec."Request Code")
                {
                    Tooltip = 'Specifies the Request Code.';
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Tooltip = 'Specifies the Currency Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Tooltip = 'Specifies the Vendor No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Tooltip = 'Specifies the Vendor Name.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Job No."; Rec."Job No.")
                {
                    Tooltip = 'Specifies the Job No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    Tooltip = 'Specifies the Job Task No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Applies-to Purch. Doc. No."; Rec."Applies-to Purch. Doc. No.")
                {
                    Tooltip = 'Specifies the Applies-to Purch. Doc. No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Tooltip = 'Specifies the Shortcut Dimension 1 Code.';
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Tooltip = 'Specifies the Shortcut Dimension 2 Code.';
                    ApplicationArea = All;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    Tooltip = 'Specifies the Shortcut Dimension 3 Code.';
                    ApplicationArea = All;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    Tooltip = 'Specifies the Shortcut Dimension 4 Code.';
                    ApplicationArea = All;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    Tooltip = 'Specifies the Shortcut Dimension 5 Code.';
                    ApplicationArea = All;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    Tooltip = 'Specifies the Shortcut Dimension 6 Code.';
                    ApplicationArea = All;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    Tooltip = 'Specifies the Shortcut Dimension 7 Code.';
                    ApplicationArea = All;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    Tooltip = 'Specifies the Shortcut Dimension 8 Code.';
                    ApplicationArea = All;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Line No."; Rec."Line No.")
                {
                    Tooltip = 'Specifies the Line No..';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction();
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Processed Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Processed Entries';
                    Image = Entries;
                    RunObject = Page PPHRDS_ProcessedRequestEntries;
                    RunPageLink = "Request No." = FIELD("Document No."),
                                  "Request Line No." = FIELD("Line No.");
                    ToolTip = 'Opens the processed requistion entries.';
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        TotalBudgetValue := 0;
        TotalActualValue := 0;
        TotalReleasedValue := 0;
        TotalPurchaseValue := 0;
        TotalAvailableValue := 0;
        RequestBudgetManagement.GetBudgetDetails(Rec, TotalBudgetValue, TotalActualValue, TotalReleasedValue, TotalPurchaseValue, TotalAvailableValue, BudgetExist, IsOverBudget);

        ControlAppearance();
    end;

    trigger OnAfterGetRecord();
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        TypeChosen := Rec.HasTypeToFillMandatotyFields();

        TotalBudgetValue := 0;
        TotalActualValue := 0;
        TotalReleasedValue := 0;
        TotalPurchaseValue := 0;
        TotalAvailableValue := 0;
        RequestBudgetManagement.GetBudgetDetails(Rec, TotalBudgetValue, TotalActualValue, TotalReleasedValue, TotalPurchaseValue, TotalAvailableValue, BudgetExist, IsOverBudget);

        ControlAppearance();
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        Rec.InitReqLineType();

        Clear(ShortcutDimCode);
        ControlAppearance();
    end;

    var
        RequestBudgetManagement: Codeunit PPHRDS_RequestBudgetManagement;
        ShortcutDimCode: array[8] of Code[20];
        BudgetStyleExpression: Text;
        TypeChosen: Boolean;
        TotalBudgetValue: Decimal;
        TotalActualValue: Decimal;
        TotalReleasedValue: Decimal;
        TotalPurchaseValue: Decimal;
        TotalAvailableValue: Decimal;
        BudgetExist: Boolean;
        IsOverBudget: Boolean;

    local procedure ControlAppearance();
    begin
        if not BudgetExist then begin
            BudgetStyleExpression := 'Standard';
            exit;
        end;

        if IsOverBudget then
            BudgetStyleExpression := 'Unfavorable'
        else
            BudgetStyleExpression := 'Standard';
    end;
}

