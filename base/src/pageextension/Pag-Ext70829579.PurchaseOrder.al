pageextension 70829579 PPHRDS_PurchaseOrder extends "Purchase Order"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_PurchaseOrderFactBox; PPHRDS_ProcessedRequestFactBox)
            {
                ApplicationArea = All;
                Provider = PurchLines;
                SubPageLink = "Purchase Document Type" = field("Document Type"), "Purchase Document No." = field("Document No."), "Purchase Document Line No." = field("Line No.");
            }
        }
    }
}
