page 70829610 PPHRDS_ProcessedRequestFactBox
{
    Caption = 'Request Details';
    PageType = CardPart;
    SourceTable = PPHRDS_ProcessedRequestEntry;
    SourceTableView = WHERE(Status = CONST(Processed));

    layout
    {
        area(content)
        {
            field("Request No."; Rec."Request No.")
            {
                Tooltip = 'Specifies the Request No..';
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    ProcessedReqHeader: Record PPHRDS_ProcessedReqHeader;
                begin
                    ProcessedReqHeader.SetRange("No.", Rec."Processed Request No.");
                    Page.Run(Page::"PPHRDS_ProcessedRequest", ProcessedReqHeader);
                end;
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
            field("Request Date"; Rec."Request Date")
            {
                Tooltip = 'Specifies the Request Date.';
                ApplicationArea = All;
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
            field(ReqRequestedQty; ReqRequestedQty)
            {
                Tooltip = 'Specifies the ReqRequestedQty.';
                ApplicationArea = All;
                Caption = 'Requested Quantity';
            }
            field(ReqOutstandingQty; ReqOutstandingQty)
            {
                Tooltip = 'Specifies the ReqOutstandingQty.';
                ApplicationArea = All;
                Caption = 'Remaining Quantity';
            }
            field("Unit of Measure Code"; Rec."Unit of Measure Code")
            {
                Tooltip = 'Specifies the Unit of Measure Code.';
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
        if ReqLine.Get(Rec."Request No.", Rec."Request Line No.") then begin
            ReqRequestedQty := ReqLine.Quantity;
            ReqOutstandingQty := ReqLine."Outstanding Quantity";
            ReqNotes := ReqLine.Notes;
        end else begin
            ReqRequestedQty := Rec."Original Quantity";
            ReqOutstandingQty := 0;
            ReqNotes := Rec.Notes;
        end;
    end;

    var
        ReqLine: Record PPHRDS_ReqLine;
        ReqOutstandingQty: Decimal;
        ReqRequestedQty: Decimal;
        ReqNotes: Text[250];
}

