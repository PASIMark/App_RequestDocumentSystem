codeunit 70829617 PPHRDS_RequestInfoPaneMgt
{
    trigger OnRun();
    begin
    end;

    var
        Item: Record Item;

    procedure CalcAvailability(var ReqLine: Record PPHRDS_ReqLine): Decimal;
    var
        AvailableToPromise: Codeunit "Available to Promise";
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        AnalysisPeriodType: Enum "Analysis Period Type";
        AvailabilityDate: Date;
        LookaheadDateformula: DateFormula;
    begin
        if GetItem(ReqLine) then begin
            if ReqLine."Expected Receipt Date" <> 0D then
                AvailabilityDate := ReqLine."Expected Receipt Date"
            else
                AvailabilityDate := WorkDate();

            Item.Reset();
            Item.SetRange("Date Filter", 0D, AvailabilityDate);
            Item.SetRange("Location Filter", ReqLine."Location Code");
            Item.SetRange("Drop Shipment Filter", false);

            exit(
              AvailableToPromise.CalcQtyAvailabletoPromise(
                Item,
                GrossRequirement,
                ScheduledReceipt,
                AvailabilityDate,
                AnalysisPeriodType,
                LookaheadDateformula));
        end;
    end;

    local procedure GetItem(var ReqLine: Record PPHRDS_ReqLine): Boolean;
    begin
        if (ReqLine.Type <> ReqLine.Type::Item) or (ReqLine."No." = '') then
            exit(false);

        if ReqLine."No." <> Item."No." then
            Item.Get(ReqLine."No.");
        exit(true);
    end;
}

