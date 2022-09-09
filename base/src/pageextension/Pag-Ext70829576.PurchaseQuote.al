pageextension 70829576 PPHRDS_PurchaseQuote extends "Purchase Quote"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_PurchaseQuoteFactBox; PPHRDS_ProcessedRequestFactBox)
            {
                ApplicationArea = All;
                Provider = PurchLines;
                SubPageLink = "Purchase Document Type" = field("Document Type"), "Purchase Document No." = field("Document No."), "Purchase Document Line No." = field("Line No.");
            }
        }
    }
}
