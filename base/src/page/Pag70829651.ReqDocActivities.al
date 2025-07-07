page 70829651 PPHRDS_ReqDocActivities
{
    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = PPHRDS_RequestDocumentCue;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            cuegroup(Request)
            {
                Caption = 'Request';

                field("Req. - Open"; Rec."Req. - Open")
                {
                    Tooltip = 'Specifies the Req. - Open.';
                    ApplicationArea = All;
                    DrillDownPageID = PPHRDS_RequestList;
                }
                field("Req. - Released"; Rec."Req. - Released")
                {
                    Tooltip = 'Specifies the Req. - Released.';
                    ApplicationArea = All;
                    DrillDownPageID = PPHRDS_RequestList;
                }
                field("Req. - Pending Approval"; Rec."Req. - Pending Approval")
                {
                    Tooltip = 'Specifies the Req. - Pending Approval.';
                    ApplicationArea = All;
                    DrillDownPageID = PPHRDS_RequestList;
                }
            }

            cuegroup(History)
            {
                Caption = 'History';

                field("Processed Request"; Rec."Processed Request")
                {
                    Tooltip = 'Specifies the Processed Request.';
                    ApplicationArea = All;
                    DrillDownPageID = PPHRDS_ProcessedRequestList;
                }
            }
        }
    }

    var
        RequestManagement: Codeunit PPHRDS_RequestManagement;

    trigger OnOpenPage();
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        if RequestManagement.RequestorIDFilter(UserId) then
            Rec.SetFilter("User ID Filter", UserId);
    end;
}

