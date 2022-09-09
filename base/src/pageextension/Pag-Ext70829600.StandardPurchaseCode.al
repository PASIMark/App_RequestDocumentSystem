pageextension 70829600 "PPHRDS_StandardPurchaseCode" extends "Standard Purchase Codes"
{
    [Obsolete('Refer to PPHRDS_GetSelected procedure. New procedure added in ver. 1.0.0.1')]
    procedure GetSelected(var StandardPurchaseCode: Record "Standard Purchase Code")
    begin
        CurrPage.SetSelectionFilter(StandardPurchaseCode);
    end;

    procedure PPHRDS_GetSelected(var StandardPurchaseCode: Record "Standard Purchase Code")
    begin
        CurrPage.SetSelectionFilter(StandardPurchaseCode);
    end;
}