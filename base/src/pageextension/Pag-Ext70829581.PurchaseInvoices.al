pageextension 70829581 "PPHRDS_PurchaseInvoices" extends "Purchase Invoices"
{
    actions
    {
        addfirst(processing)
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
                    RequestPurchDocType: Enum PPHRDS_RequestPurchDocType;
                begin
                    Clear(GetRequestLines);
                    GetRequestLines.CreatePurchaseDocument(Rec);
                    GetRequestLines.SetRecords(Rec, RequestPurchDocType::Invoice);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}
