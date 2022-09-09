pageextension 70829660 "PPHRDS_BusinessManagerRC" extends "Business Manager Role Center"
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