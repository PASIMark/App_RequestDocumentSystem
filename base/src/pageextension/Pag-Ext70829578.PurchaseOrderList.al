pageextension 70829578 PPHRDS_PurchaseOrderList extends "Purchase Order List"
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
                    GetRequestLines: Page PPHRDS_GetRequestLines;
                    RequestPurchDocType: Enum PPHRDS_RequestPurchDocType;
                begin
                    Clear(GetRequestLines);
                    GetRequestLines.CreatePurchaseDocument(Rec);
                    GetRequestLines.SetRecords(Rec, RequestPurchDocType::Order);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}
