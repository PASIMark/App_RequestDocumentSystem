pageextension 70829585 PPHRDS_TransferOrder extends "Transfer Order"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PPHRDS_TransferOrderFactbox; PPHRDS_ProcessedRequestFactBox)
            {
                ApplicationArea = All;
                Provider = TransferLines;
                SubPageLink = "Transfer Order No." = field("Document No."), "Transfer Order Line No." = field("Line No.");
            }
        }
    }

}