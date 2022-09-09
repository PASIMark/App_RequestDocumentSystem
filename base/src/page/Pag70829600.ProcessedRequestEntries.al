page 70829600 PPHRDS_ProcessedRequestEntries
{
    Caption = 'Processed Request Entries';
    Editable = false;
    PageType = List;
    UsageCategory = History;
    SourceTable = PPHRDS_ProcessedRequestEntry;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Tooltip = 'Specifies the Entry No..';
                    ApplicationArea = All;
                }
                field("Request No."; Rec."Request No.")
                {
                    Tooltip = 'Specifies the Request No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Request Line No."; Rec."Request Line No.")
                {
                    Tooltip = 'Specifies the Request Line No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Processed Request No."; Rec."Processed Request No.")
                {
                    Tooltip = 'Specifies the Processed Request No..';
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
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    Tooltip = 'Specifies the Approval ID.';
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Approval ID';
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
                    Visible = false;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    Tooltip = 'Specifies the Expected Receipt Date.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Request Code"; Rec."Request Code")
                {
                    Tooltip = 'Specifies the Request Code.';
                    ApplicationArea = All;
                }
                field("Request Description"; Rec."Request Description")
                {
                    Tooltip = 'Specifies the Request Description.';
                    ApplicationArea = All;
                }
                field("Purchase Document Type"; Rec."Purchase Document Type")
                {
                    Tooltip = 'Specifies the Purchase Document Type.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Purchase Document No."; Rec."Purchase Document No.")
                {
                    Tooltip = 'Specifies the Purchase Document No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Transfer Order No."; Rec."Transfer Order No.")
                {
                    Tooltip = 'Specifies the Transfer Order No..';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    Tooltip = 'Specifies the Journal Template Name.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    Tooltip = 'Specifies the Journal Batch Name.';
                    ApplicationArea = All;
                    Visible = false;
                }
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
                field("Location Code"; Rec."Location Code")
                {
                    Tooltip = 'Specifies the Location Code.';
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Tooltip = 'Specifies the Unit of Measure Code.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    Tooltip = 'Specifies the Quantity.';
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
                field(Status; Rec.Status)
                {
                    Tooltip = 'Specifies the Status.';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(ProcReqEntriesFactBox; PPHRDS_ProcReqEntriesFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
            systempart(Control30; Links)
            {
                ApplicationArea = All;
            }
            systempart(Control26; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Show Target Document")
                {
                    ApplicationArea = All;
                    Caption = 'Show Target Document';
                    Enabled = (Rec.Status <> Rec.Status::Cancelled) and TargetDocExist;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F7';
                    PromotedOnly = true;
                    ToolTip = 'Opens the target document.';

                    trigger OnAction();
                    begin
                        RequestManagement.ProcessedReqShowDoc(Rec);
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

    trigger OnAfterGetCurrRecord()
    begin
        TargetDocExist := RequestManagement.ProcessedReqDocExist(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        TargetDocExist := RequestManagement.ProcessedReqDocExist(Rec);
    end;

    var
        RequestManagement: Codeunit PPHRDS_RequestManagement;
        TargetDocExist: Boolean;
}

