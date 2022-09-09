page 70829635 PPHRDS_ProcessedRequest
{
    Caption = 'Processed Request';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Correct,Request,Print,Print/Send,Navigate';
    SourceTable = PPHRDS_ProcessedReqHeader;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                }
                field("Requestor ID"; Rec."Requestor ID")
                {
                    Tooltip = 'Specifies the Requestor ID.';
                    ApplicationArea = All;
                }
                field("Requestor Name"; Rec."Requestor Name")
                {
                    Tooltip = 'Specifies the Requestor Name.';
                    ApplicationArea = All;
                }
                group(Control20)
                {
                    Caption = '';
                    field("Purchaser Code"; Rec."Purchaser Code")
                    {
                        Tooltip = 'Specifies the Approval ID.';
                        ApplicationArea = All;
                        Caption = 'Approval ID';
                    }
                    field("Currency Code"; Rec."Currency Code")
                    {
                        Tooltip = 'Specifies the Currency Code.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Request Code"; Rec."Request Code")
                    {
                        Tooltip = 'Specifies the Request Code.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Request Description"; Rec."Request Description")
                    {
                        Tooltip = 'Specifies the Request Description.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        Tooltip = 'Specifies the Location Code.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Control5)
                {
                    Caption = '';
                    field("Request No."; Rec."Request No.")
                    {
                        Tooltip = 'Specifies the Request No..';
                        ApplicationArea = All;
                    }
                    field("Request Date"; Rec."Request Date")
                    {
                        Tooltip = 'Specifies the Request Date.';
                        ApplicationArea = All;
                    }
                    field("Document Date"; Rec."Document Date")
                    {
                        Tooltip = 'Specifies the Document Date.';
                        ApplicationArea = All;
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
                }
            }
            part(Control12; PPHRDS_ProcessedRequestSubform)
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = filter('70829615|70829635'),
                              "No." = FIELD("Request No."),
                              "Document Type" = const(PPHRDS_Request);
            }
            systempart(Control7; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control13; Notes)
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Request)
            {
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction();
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
        }
    }
}

