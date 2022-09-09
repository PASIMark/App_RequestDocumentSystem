page 70829601 "PPHRDS_ProcReqEntriesFactBox"
{
    Caption = 'Processing Details';
    PageType = CardPart;
    SourceTable = PPHRDS_ProcessedRequestEntry;

    layout
    {
        area(content)
        {
            group(Purchase)
            {
                Caption = 'Purchase';
                Visible = PurchaseVisible;
                field("Purchase Document Type"; Rec."Purchase Document Type")
                {
                    Caption = 'Document Type';
                    Tooltip = 'Specifies the Document Type.';
                    ApplicationArea = All;
                }
                field("Purchase Document No."; Rec."Purchase Document No.")
                {
                    Caption = 'No.';
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                }
                field("Purchase Document Line."; Rec."Purchase Document Line No.")
                {
                    Caption = 'Line No.';
                    Tooltip = 'Specifies the Line No..';
                    ApplicationArea = All;
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                Visible = TransferVisible;
                field("Transfer Order No."; Rec."Transfer Order No.")
                {
                    Caption = 'No.';
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                }
                field("Transfer Order Line No."; Rec."Transfer Order Line No.")
                {
                    Caption = 'Line No.';
                    Tooltip = 'Specifies the Line No..';
                    ApplicationArea = All;
                }
            }
            group(Journal)
            {
                Caption = 'Journal';
                Visible = JournalVisible;
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    Caption = 'Journal Template Name';
                    Tooltip = 'Specifies the Journal Template Name.';
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    Caption = 'Journal Batch Name';
                    Tooltip = 'Specifies the Journal Batch Name.';
                    ApplicationArea = All;
                }
                field("Journal Document No."; Rec."Journal Document No.")
                {
                    Caption = 'Document No.';
                    Tooltip = 'Specifies the Document No..';
                    ApplicationArea = All;
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    Caption = 'Line No.';
                    Tooltip = 'Specifies the Line No..';
                    ApplicationArea = All;
                }
            }
            group(Requisition)
            {
                Caption = 'Requisition Worksheets';
                Visible = ReqWkshtVisible;
                field("Req Worksheet Template Name"; Rec."Journal Template Name")
                {
                    Caption = 'No.';
                    Tooltip = 'Specifies the Journal Template Name.';
                    ApplicationArea = All;
                }
                field("Req Journal Batch Name"; Rec."Journal Batch Name")
                {
                    Caption = 'Journal Batch Name';
                    Tooltip = 'Specifies the Journal Batch Name.';
                    ApplicationArea = All;
                }
                field("Demand Order No."; Rec."Request No.")
                {
                    Caption = 'Demand Order No.';
                    Tooltip = 'Specifies the Demand Order No..';
                    ApplicationArea = All;
                }
                field("Req Journal Line No."; Rec."Journal Line No.")
                {
                    Caption = 'Line No.';
                    Tooltip = 'Specifies the Line No..';
                    ApplicationArea = All;
                }

            }
            field("Processor User ID"; Rec."Processor User ID")
            {
                Caption = 'Processor User ID';
                Tooltip = 'Specifies the Processor User ID.';
                ApplicationArea = All;
            }
            field("Status"; Rec.Status)
            {
                Caption = 'Status';
                Tooltip = 'Specifies the Status.';
                ApplicationArea = All;
            }

            group(ReqLineNotes)
            {
                Caption = 'Notes';
                field(Notes; Rec.Notes)
                {
                    Tooltip = 'Specifies the Notes.';
                    ApplicationArea = All;
                    ShowCaption = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord();
    begin
        FactboxVisibility();
    end;

    trigger OnAfterGetRecord();
    begin
        FactboxVisibility();
    end;

    trigger OnOpenPage();
    begin
        FactboxVisibility();
    end;

    local procedure FactboxVisibility();
    begin
        PurchaseVisible := false;
        TransferVisible := false;
        JournalVisible := false;
        ReqWkshtVisible := false;

        case Rec."Request Type" of
            Rec."Request Type"::Purchase:
                PurchaseVisible := true;
            Rec."Request Type"::"Transfer Order":
                TransferVisible := true;
            Rec."Request Type"::"Item Journal", Rec."Request Type"::"General Journal":
                JournalVisible := true;
            Rec."Request Type"::"Req. Worksheet":
                ReqWkshtVisible := true;
        end;
    end;

    var
        PurchaseVisible: Boolean;
        TransferVisible: Boolean;
        JournalVisible: Boolean;
        ReqWkshtVisible: Boolean;
}

