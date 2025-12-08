page 70829637 PPHRDS_ProcessedRequestList
{
    Caption = 'Processed Request List';
    CardPageID = PPHRDS_ProcessedRequest;
    Editable = false;
    PageType = List;
    UsageCategory = History;
    PromotedActionCategories = 'New,Process,Report,Correct,Request,Print,Print/Send,Navigate';
    SourceTable = PPHRDS_ProcessedReqHeader;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    Tooltip = 'Specifies the Posting Date.';
                    ApplicationArea = All;
                }
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
                field("Request Code"; Rec."Request Code")
                {
                    Tooltip = 'Specifies the Request Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Request Description"; Rec."Request Description")
                {
                    Tooltip = 'Specifies the Request Description.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Tooltip = 'Specifies the Location Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Tooltip = 'Specifies the Shortcut Dimension 1 Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Tooltip = 'Specifies the Shortcut Dimension 2 Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Doc. Attachment List Factbox")
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
            systempart(Control3; Notes)
            {
                ApplicationArea = All;
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

    trigger OnOpenPage()
    begin
        if RequestManagement.RequestorIDFilter(UserId) then begin
            Rec.FilterGroup(100);
            Rec.SetRange("Requestor ID", UserId);
            Rec.FilterGroup(0);
        end;
    end;

    var
        RequestManagement: Codeunit PPHRDS_RequestManagement;
}

