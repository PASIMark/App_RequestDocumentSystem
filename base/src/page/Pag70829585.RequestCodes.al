page 70829585 PPHRDS_RequestCodes
{
    Caption = 'Request Codes';
    CardPageID = PPHRDS_RequestCodeCard;
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = PPHRDS_RequestCode;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    Tooltip = 'Specifies the Code.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Tooltip = 'Specifies the Description.';
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    Tooltip = 'Specifies the Type.';
                    ApplicationArea = All;
                }
                field(Active; Rec.Active)
                {
                    Tooltip = 'Specifies the Active.';
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
    }
}

