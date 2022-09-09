pageextension 70829582 PPHRDS_PurchaseInvoice extends "Purchase Invoice"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_PurchaseInvoiceFactBox; PPHRDS_ProcessedRequestFactBox)
            {
                ApplicationArea = All;
                Provider = PurchLines;
                SubPageLink = "Purchase Document Type" = field("Document Type"), "Purchase Document No." = field("Document No."), "Purchase Document Line No." = field("Line No.");
            }
        }
    }
}