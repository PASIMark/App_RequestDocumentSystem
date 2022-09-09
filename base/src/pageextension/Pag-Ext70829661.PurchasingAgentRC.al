pageextension 70829661 "PPHRDS_PurchasingAgentRC" extends "Purchasing Agent Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part(PPHRDS_ReqDocActivities; PPHRDS_ReqDocActivities)
            {
                ApplicationArea = All;
                Visible = false;
                Caption = 'Request Document System';
            }
        }
    }
}