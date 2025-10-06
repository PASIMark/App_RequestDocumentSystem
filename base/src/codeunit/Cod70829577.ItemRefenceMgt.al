codeunit 70829577 PPHRDS_ItemReferenceMgt
{
    procedure PurchaseReferenceNoLookup(var ReqLine: Record PPHRDS_ReqLine)
    var
        ReqHeader: Record PPHRDS_ReqHeader;
    begin
        ReqHeader.Get(ReqLine."Document No.");
        PurchaseReferenceNoLookup(ReqLine, ReqHeader);
    end;

    procedure PurchaseReferenceNoLookup(var ReqLine: Record PPHRDS_ReqLine; ReqHeader: Record PPHRDS_ReqHeader)
    var
        ItemReference2: Record "Item Reference";
        ToDate: Date;
    begin
        if ReqLine.Type = ReqLine.Type::Item then begin
            ItemReference2.SetCurrentKey("Reference Type", "Reference Type No.");
            ItemReference2.SetFilter("Reference Type", '%1|%2', ItemReference2."Reference Type"::Vendor, ItemReference2."Reference Type"::" ");
            ItemReference2.SetFilter("Reference Type No.", '%1|%2', ReqLine."Vendor No.", '');
            ToDate := ReqLine.GetDateForCalculations();
            if ToDate <> 0D then begin
                ItemReference2.SetFilter("Starting Date", '<=%1', ToDate);
                ItemReference2.SetFilter("Ending Date", '>=%1|%2', ToDate, 0D);
            end;

            if PAGE.RunModal(PAGE::"Item Reference List", ItemReference2) = ACTION::LookupOK then begin
                ReqLine."Item Reference No." := ItemReference2."Reference No.";
                ValidatePurchaseReferenceNo(ReqLine, ReqHeader, ItemReference2, false, 0);
                //ReqLine.UpdateReferencePriceAndDiscount(); #TODO
                ReqLine.Validate("Direct Unit Cost");
            end;
        end;
    end;

    procedure ValidatePurchaseReferenceNo(var ReqLine: Record PPHRDS_ReqLine; ReqHeader: Record PPHRDS_ReqHeader; ItemReference: Record "Item Reference"; SearchItem: Boolean; CurrentFieldNo: Integer)
    var
        ReturnedItemReference: Record "Item Reference";
        b: Record "Purchase Line";
    begin
        ReturnedItemReference.Init();
        if ReqLine."Item Reference No." <> '' then begin
            if SearchItem then
                ReferenceLookupPurchaseItem(ReqLine, ReturnedItemReference, CurrentFieldNo <> 0)
            else
                ReturnedItemReference := ItemReference;

            ReqLine.SetReqhHeader(ReqHeader);
            ReqLine.Validate("No.", ReturnedItemReference."Item No.");
            ReqLine.SetVendorItemNo();
            if ReturnedItemReference."Variant Code" <> '' then
                ReqLine.Validate("Variant Code", ReturnedItemReference."Variant Code");
            if ReturnedItemReference."Unit of Measure" <> '' then
                ReqLine.Validate("Unit of Measure Code", ReturnedItemReference."Unit of Measure");
            ReqLine.UpdateAmounts();
        end;

        ReqLine."Item Reference Unit of Measure" := ReturnedItemReference."Unit of Measure";
        ReqLine."Item Reference Type" := ReturnedItemReference."Reference Type";
        ReqLine."Item Reference Type No." := ReturnedItemReference."Reference Type No.";
        ReqLine."Item Reference No." := ReturnedItemReference."Reference No.";

        if (ReturnedItemReference.Description <> '') or (ReturnedItemReference."Description 2" <> '') then begin
            ReqLine.Description := ReturnedItemReference.Description;
            ReqLine."Description 2" := ReturnedItemReference."Description 2";
        end;

        ReqLine.UpdateAmounts();
        ReqLine.UpdateICPartner();
    end;

    procedure ReferenceLookupPurchaseItem(var ReqLine2: Record PPHRDS_ReqLine; var ReturnedItemReference: Record "Item Reference"; ShowDialog: Boolean)
    begin
        GlobalPurchLine.Copy(ReqLine2);
        if GlobalPurchLine.Type = GlobalPurchLine.Type::Item then
            FindOrSelectFromItemReferenceList(
                ReturnedItemReference, ShowDialog, GlobalPurchLine."No.", GlobalPurchLine."Item Reference No.", GlobalPurchLine."Buy-from Vendor No.",
                ReturnedItemReference."Reference Type"::Vendor, GlobalPurchLine.GetDateForCalculations());
    end;

    var
        GlobalPurchLine: Record PPHRDS_ReqLine;
}