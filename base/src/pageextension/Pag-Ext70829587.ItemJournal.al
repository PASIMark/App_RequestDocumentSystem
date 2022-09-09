pageextension 70829587 PPHRDS_ItemJournal extends "Item Journal"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_ItemJournalReqFactBox; PPHRDS_ProcessedRequestFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field("Journal Batch Name"), "Journal Line No." = field("Line No."), "Journal Document No." = field("Document No.");
            }
        }
    }

    actions
    {
        addfirst("F&unctions")
        {
            action(PPHRDS_GetRequestLines)
            {
                ToolTip = 'Get Request Lines';
                ApplicationArea = All;
                Caption = 'Get Request Lines';
                Image = GetLines;

                trigger OnAction()
                var
                    GetRequestLines: Page PPHRDS_GetRequestLines;
                begin
                    Clear(GetRequestLines);
                    GetRequestLines.CreateItemJournalLine(Rec);
                    GetRequestLines.SetRecords(Rec);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}