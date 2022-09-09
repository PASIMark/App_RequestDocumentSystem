page 70829636 PPHRDS_ProcessedRequestSubform
{
    AutoSplitKey = true;
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = PPHRDS_ProcessedReqLine;

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
                }
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
                field("Description 2"; Rec."Description 2")
                {
                    Tooltip = 'Specifies the Description 2.';
                    ApplicationArea = All;
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
                }
                field(Quantity; Rec.Quantity)
                {
                    Tooltip = 'Specifies the Quantity.';
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Tooltip = 'Specifies the Unit of Measure Code.';
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    Tooltip = 'Specifies the Direct Unit Cost.';
                    ApplicationArea = All;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    Tooltip = 'Specifies the Line Amount.';
                    ApplicationArea = All;
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
                        //ValidateShortcutDimCode(3,ShortcutDimCode[3]);
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
                        //ValidateShortcutDimCode(4,ShortcutDimCode[4]);
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
                        //ValidateShortcutDimCode(5,ShortcutDimCode[5]);
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
                        //ValidateShortcutDimCode(6,ShortcutDimCode[6]);
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
                        //ValidateShortcutDimCode(7,ShortcutDimCode[7]);
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
                        //ValidateShortcutDimCode(8,ShortcutDimCode[8]);
                    end;
                }
                field("Processed Request Entry Status"; Rec."Processed Request Entry Status")
                {
                    Tooltip = 'Specifies the Processed Request Entry Status.';
                    ApplicationArea = All;
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
                    RunPageLink = "Processed Request No." = FIELD("Document No."),
                                  "Processed Request Line No." = FIELD("Line No.");
                    ToolTip = 'Opens the processed requistion entries.';
                }
            }
        }
    }

    trigger OnAfterGetRecord();
    begin
        //ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        //CLEAR(ShortcutDimCode);
    end;

    var
        ShortcutDimCode: array[8] of Code[20];
}

