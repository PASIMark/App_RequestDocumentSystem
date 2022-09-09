pageextension 70829588 PPHRDS_ReqWorksheet extends "Req. Worksheet"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_ReqWorksheetFactBox; PPHRDS_ProcessedRequestFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "Journal Template Name" = field("Worksheet Template Name"), "Journal Batch Name" = field("Journal Batch Name"), "Journal Line No." = field("Line No."), "Request No." = field("Demand Order No.");
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
                    GetRequestLines.CreateRequisitionLine(Rec);
                    GetRequestLines.SetRecords(Rec);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}