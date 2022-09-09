pageextension 70829580 PPHRDS_PurchaseOrderSubform extends "Purchase Order Subform"
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
                    PurchaseHeader: Record "Purchase Header";
                    GetRequestLines: Page PPHRDS_GetRequestLines;
                    RequestPurchDocType: Enum PPHRDS_RequestPurchDocType;
                begin
                    PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
                    PurchaseHeader.TestField("Buy-from Vendor No.");
                    PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);

                    Clear(GetRequestLines);
                    GetRequestLines.CreatePurchaseLine(PurchaseHeader);
                    GetRequestLines.SetRecords(PurchaseHeader, RequestPurchDocType::Order);
                    GetRequestLines.RunModal();
                end;
            }
        }
    }
}
