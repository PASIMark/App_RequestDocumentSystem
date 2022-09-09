page 70829657 PPHRDS_HeadlineRCReqDocument
{
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group("AppName Headline")
            {
                Visible = AppNameHeadlineVisible;
                ShowCaption = false;
                Editable = false;

                field(FirstInsight; FirstInsightText)
                {
                    Tooltip = 'Specifies the FirstInsight.';
                    ApplicationArea = All;
                }
                group(SecondInsightGroup)
                {
                    Visible = SecondInsightVisible;
                    field(SecondInsight; SecondInsightText)
                    {
                        Tooltip = 'Specifies the SecondInsight.';
                        ApplicationArea = All;
                        trigger OnDrillDown();
                        var
                        begin
                            OnDrillDownSecondInsight();
                        end;
                    }
                }
                group(ThirdInsightGroup)
                {
                    Visible = ThirdInsightVisible;
                    field(ThirdInsight; ThirdInsightText)
                    {
                        Tooltip = 'Specifies the ThirdInsight.';
                        ApplicationArea = All;
                        trigger OnDrillDown();
                        var
                        begin
                            OnDrillDownThirdInsight();
                        end;
                    }
                }
            }
        }
    }

    var
        PendReqHdr: Record PPHRDS_ReqHeader;
        [InDataSet]
        AppNameHeadlineVisible: Boolean;
        FirstInsightText: Text;
        SecondInsightText: Text;
        ThirdInsightText: Text;
        SecondInsightVisible: Boolean;
        ThirdInsightVisible: Boolean;
        RequestDocumentCue: Record PPHRDS_RequestDocumentCue;
        ReqLt: Page PPHRDS_RequestList;
        HandleSecondInsightPayloadTxt: Label 'There are %1 open request assigned to you.', Comment = '%1 = Total request document assigned to the user.';
        HandleThirdInsightPayloadTxt: Label 'There are %1 pending  request assigned to you.', Comment = '%1 = Total pending request document assigned to the user.';

    trigger OnOpenPage()
    begin
        HandleVisibility();

        HandleFirstInsight();
        HandleSecondInsight();
        HandleThirdInsight();

        OnSetVisibility(AppNameHeadlineVisible);
    end;

    trigger OnAfterGetRecord()
    begin
        HandleVisibility();

        HandleFirstInsight();
        HandleSecondInsight();
        HandleThirdInsight();

        OnSetVisibility(AppNameHeadlineVisible);
    end;

    local procedure HandleVisibility()
    var
    begin
        AppNameHeadlineVisible := true;

        SecondInsightVisible := ShowOpenRequest();
        ThirdInsightVisible := ShowPendingRequest();
    end;

    local procedure HandleFirstInsight();
    var
        HeadlineManagement: Codeunit Headlines;
        PayloadText: Text;
        QualifierText: Text;
    begin
        PayloadText := HeadlineManagement.Emphasize('Some text to highlight') + ' Some other text';
        QualifierText := 'Headline';
        PayloadText := HeadlineManagement.GetUserGreetingText();
        HeadlineManagement.GetHeadlineText(QualifierText, PayloadText, FirstInsightText);
    end;

    local procedure HandleSecondInsight();
    var
        HeadlineManagement: Codeunit Headlines;
        PayloadText: Text;
        QualifierText: Text;
    begin
        PayloadText := HeadlineManagement.Emphasize('Some text to highlight') + ' Some other text';
        QualifierText := 'Today';
        PayloadText := StrSubstNo(HandleSecondInsightPayloadTxt, GetOpenRequest());
        HeadlineManagement.GetHeadlineText(QualifierText, PayloadText, SecondInsightText);
    end;

    local procedure HandleThirdInsight();
    var
        HeadlineManagement: Codeunit Headlines;
        PayloadText: Text;
        QualifierText: Text;
    begin
        PayloadText := HeadlineManagement.Emphasize('Some text to highlight') + ' Some other text';
        QualifierText := 'Today';
        PayloadText := StrSubstNo(HandleThirdInsightPayloadTxt, GetPendingRequest(PendReqHdr));
        HeadlineManagement.GetHeadlineText(QualifierText, PayloadText, ThirdInsightText);
    end;

    local procedure OnDrillDownSecondInsight();
    var
        ReqHdr: Record PPHRDS_ReqHeader;
    begin
        Clear(ReqLt);
        if ShowOpenRequest() then begin
            ReqHdr.Reset();
            ReqHdr.SetRange("Requestor ID", UserId);
            ReqHdr.SetRange(Status, ReqHdr.Status::Open);
            ReqHdr.SetFilter("Posting Date", Format(WorkDate()));
            ReqLt.SetTableView(ReqHdr);
            ReqLt.RunModal();
        end
    end;

    local procedure OnDrillDownThirdInsight();
    begin
        Clear(ReqLt);
        if ShowPendingRequest() then begin
            PendReqHdr.MarkedOnly;
            ReqLt.SetTableView(PendReqHdr);
            ReqLt.RunModal();
        end
    end;

    procedure ShowOpenRequest(): Boolean
    begin
        if GetOpenRequest() > 0 then
            exit(true);
        exit(false);
    end;

    procedure GetOpenRequest(): Integer
    begin
        RequestDocumentCue.Reset();
        RequestDocumentCue.SetFilter("User ID Filter", UserId);
        RequestDocumentCue.SetRange("Date Filter", WorkDate());
        RequestDocumentCue.CalcFields("User Req. - Open");
        exit(RequestDocumentCue."User Req. - Open");
    end;

    local procedure GetPendingRequest(var ReqHdr: Record PPHRDS_ReqHeader): Integer
    var
        ReqLn: Record PPHRDS_ReqLine;
        PendingRequestCount: Integer;
    begin
        ReqHdr.ClearMarks();
        PendingRequestCount := 0;

        ReqHdr.Reset();
        ReqHdr.SetRange("Requestor ID", UserId);
        ReqHdr.SetRange(Status, ReqHdr.Status::Released);
        if ReqHdr.FindSet() then
            repeat
                ReqLn.Reset();
                ReqLn.SetFilter("Outstanding Quantity", '>%1', 0);
                ReqLn.SetRange("Completely Processed", false);
                if not ReqLn.IsEmpty then begin
                    PendingRequestCount += 1;
                    ReqHdr.Mark(true);
                end;
            until ReqHdr.Next() = 0;
        exit(PendingRequestCount);
    end;

    procedure ShowPendingRequest(): Boolean
    begin
        if GetPendingRequest(PendReqHdr) > 0 then
            exit(true);
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetVisibility(var AppNameHeadlineVisible: Boolean)
    begin

    end;
}