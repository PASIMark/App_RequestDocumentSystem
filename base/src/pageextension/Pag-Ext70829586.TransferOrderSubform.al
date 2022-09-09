pageextension 70829586 "PPHRDS_TransferOrderSubform" extends "Transfer Order Subform"
{
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
                    TransferHeader: Record "Transfer Header";
                    GetRequestLines: Page PPHRDS_GetRequestLines;
                begin
                    TransferHeader.Get(Rec."Document No.");
                    TransferHeader.TestField("Transfer-to Code");
                    TransferHeader.TestField("In-Transit Code");

                    Clear(GetRequestLines);
                    GetRequestLines.CreateTransferLine(TransferHeader);
                    GetRequestLines.SetRecords(Rec);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}