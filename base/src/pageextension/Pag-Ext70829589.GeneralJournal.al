pageextension 70829589 "PPHRDS_GeneralJournal" extends "General Journal"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_ProcReqGenJnlFactBox; PPHRDS_ProcReqGenJnlFactBox)
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
                    GetRequestLines.CreateGenJournalLine(Rec);
                    GetRequestLines.SetRecords(Rec);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}