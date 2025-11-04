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
                ValidateReqReferenceNo(ReqLine, ReqHeader, ItemReference2, false, 0);
                ReqLine.Validate("Direct Unit Cost");
            end;
        end;
    end;

    procedure ValidateReqReferenceNo(var ReqLine: Record PPHRDS_ReqLine; ReqHeader: Record PPHRDS_ReqHeader; ItemReference: Record "Item Reference"; SearchItem: Boolean; CurrentFieldNo: Integer)
    var
        ReturnedItemReference: Record "Item Reference";
    begin
        ReturnedItemReference.Init();
        if ReqLine."Item Reference No." <> '' then begin
            if SearchItem then
                ReferenceLookupReqItem(ReqLine, ReturnedItemReference, CurrentFieldNo <> 0)
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

    procedure ReferenceLookupReqItem(var ReqLine2: Record PPHRDS_ReqLine; var ReturnedItemReference: Record "Item Reference"; ShowDialog: Boolean)
    begin
        GlobalReqLine.Copy(ReqLine2);
        if GlobalReqLine.Type = GlobalReqLine.Type::Item then
            FindOrSelectFromItemReferenceList(
                ReturnedItemReference, ShowDialog, GlobalReqLine."No.", GlobalReqLine."Item Reference No.", GlobalReqLine."Vendor No.",
                ReturnedItemReference."Reference Type"::Vendor, GlobalReqLine.GetDateForCalculations());
    end;

    procedure FindOrSelectFromItemReferenceList(var ItemReferenceToReturn: Record "Item Reference"; ShowDialog: Boolean; ItemNo: Code[20]; ItemRefNo: Code[50]; ItemRefTypeNo: Code[30]; ItemRefType: Enum "Item Reference Type")
    begin
        FindOrSelectFromItemReferenceList(ItemReferenceToReturn, ShowDialog, ItemNo, ItemRefNo, ItemRefTypeNo, ItemRefType, 0D);
    end;

    procedure FindOrSelectFromItemReferenceList(var ItemReferenceToReturn: Record "Item Reference"; ShowDialog: Boolean; ItemNo: Code[20]; ItemRefNo: Code[50]; ItemRefTypeNo: Code[30]; ItemRefType: Enum "Item Reference Type"; ToDate: Date)
    var
        TempRecRequired: Boolean;
        MultipleItemsToChoose: Boolean;
        QtyCustOrVendCR: Integer;
        QtyBarCodeAndBlankCR: Integer;
    begin
        InitItemReferenceFilters(GlobalItemReference, ItemNo, ItemRefNo, ItemRefType, ToDate);
        CountItemReference(GlobalItemReference, QtyCustOrVendCR, QtyBarCodeAndBlankCR, ItemRefType, ItemRefTypeNo);
        MultipleItemsToChoose := true;

        ProcessDecisionTree(QtyCustOrVendCR, QtyBarCodeAndBlankCR, ItemRefNo, ItemRefType, ItemRefTypeNo, TempRecRequired, MultipleItemsToChoose);

        SelectOrFindReference(ItemRefNo, ItemRefType, ItemRefTypeNo, TempRecRequired, MultipleItemsToChoose, ShowDialog);

        ItemReferenceToReturn.Copy(GlobalItemReference);
    end;

    local procedure InitItemReferenceFilters(var ItemReference: Record "Item Reference"; ItemNo: Code[20]; ItemRefNo: Code[50]; ItemRefType: Enum "Item Reference Type"; ToDate: Date)
    begin
        ItemReference.Reset();
        ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.");
        ItemReference.SetRange("Reference No.", ItemRefNo);
        ItemReference.SetRange("Item No.", ItemNo);
        if ToDate <> 0D then begin
            ItemReference.SetFilter("Starting Date", '<=%1', ToDate);
            ItemReference.SetFilter("Ending Date", '>=%1|%2', ToDate, 0D);
        end;
        ExcludeOtherReferenceTypes(ItemReference, ItemRefType);

        if ItemReference.IsEmpty() then
            ItemReference.SetRange("Item No.");
    end;

    local procedure CountItemReference(var ItemReference: Record "Item Reference"; var QtyCustOrVendCR: Integer; var QtyBarCodeAndBlankCR: Integer; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30])
    var
        ItemReferenceToCheck: Record "Item Reference";
    begin
        ItemReferenceToCheck.CopyFilters(ItemReference);
        SetFiltersTypeAndTypeNoItemRef(ItemReferenceToCheck, ItemRefType, ItemRefTypeNo);
        QtyCustOrVendCR := ItemReferenceToCheck.Count();
        SetFiltersBlankTypeItemRef(ItemReferenceToCheck);
        QtyBarCodeAndBlankCR := ItemReferenceToCheck.Count();
    end;

    local procedure ExcludeOtherReferenceTypes(var ItemReference: Record "Item Reference"; ItemRefType: Enum "Item Reference Type")
    begin
        case ItemRefType of
            ItemReference."Reference Type"::" ":
                ItemReference.SetFilter("Reference Type", '<>%1&<>%2', ItemReference."Reference Type"::Customer, ItemReference."Reference Type"::Vendor);
            ItemReference."Reference Type"::Vendor:
                ItemReference.SetFilter("Reference Type", '<>%1', ItemReference."Reference Type"::Customer);
            ItemReference."Reference Type"::Customer:
                ItemReference.SetFilter("Reference Type", '<>%1', ItemReference."Reference Type"::Vendor);
            else
                Error(ItemRefWrongTypeErr);
        end;
    end;

    local procedure SetFiltersTypeAndTypeNoItemRef(var ItemReference: Record "Item Reference"; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30])
    begin
        ItemReference.SetRange("Reference Type", ItemRefType);
        ItemReference.SetRange("Reference Type No.", ItemRefTypeNo);
    end;

    local procedure SetFiltersBlankTypeItemRef(var ItemReference: Record "Item Reference")
    begin
        ItemReference.SetFilter("Reference Type", '%1|%2', ItemReference."Reference Type"::" ", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference Type No.");
    end;

    local procedure ProcessDecisionTree(QtyCustOrVendCR: Integer; QtyBarCodeAndBlankCR: Integer; ItemRefNo: Code[50]; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30]; var TempRecRequired: Boolean; var MultipleItemsToChoose: Boolean)
    begin
        case true of
            (QtyCustOrVendCR = 0) and (QtyBarCodeAndBlankCR = 0):
                Error(ItemRefNotExistErr, ItemRefNo);
            (QtyCustOrVendCR = 0) and (QtyBarCodeAndBlankCR = 1):
                MultipleItemsToChoose := false;
            (QtyCustOrVendCR = 0) and (QtyBarCodeAndBlankCR > 1):
                MultipleItemsToChoose := BarCodeCRAreMappedToDifferentItems(GlobalItemReference);
            (QtyCustOrVendCR = 1) and (QtyBarCodeAndBlankCR = 0):
                MultipleItemsToChoose := false;
            (QtyCustOrVendCR = 1) and (QtyBarCodeAndBlankCR > 0):
                MultipleItemsToChoose := CustVendAndBarCodeCRAreMappedToDifferentItems(GlobalItemReference, ItemRefType, ItemRefTypeNo);
            (QtyCustOrVendCR > 1) and (QtyBarCodeAndBlankCR = 0):
                SetFiltersTypeAndTypeNoItemRef(GlobalItemReference, ItemRefType, ItemRefTypeNo);
            (QtyCustOrVendCR > 1) and (QtyBarCodeAndBlankCR > 0):
                TempRecRequired := true;
        end;
    end;

    local procedure BarCodeCRAreMappedToDifferentItems(var ItemReference: Record "Item Reference"): Boolean
    var
        ItemReferenceToCheck: Record "Item Reference";
    begin
        ItemReferenceToCheck.CopyFilters(ItemReference);
        SetFiltersBlankTypeItemRef(ItemReferenceToCheck);
        ItemReferenceToCheck.FindFirst();
        ItemReferenceToCheck.SetFilter("Item No.", '<>%1', ItemReferenceToCheck."Item No.");
        exit(not ItemReferenceToCheck.IsEmpty);
    end;

    local procedure CustVendAndBarCodeCRAreMappedToDifferentItems(var ItemReference: Record "Item Reference"; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30]): Boolean
    var
        ItemReferenceToCheck: Record "Item Reference";
    begin
        ItemReferenceToCheck.CopyFilters(ItemReference);
        SetFiltersTypeAndTypeNoItemRef(ItemReferenceToCheck, ItemRefType, ItemRefTypeNo);
        ItemReferenceToCheck.FindFirst();
        ItemReferenceToCheck.SetFilter("Item No.", '<>%1', ItemReferenceToCheck."Item No.");
        SetFiltersBlankTypeItemRef(ItemReferenceToCheck);
        exit(not ItemReferenceToCheck.IsEmpty);
    end;

    local procedure SelectOrFindReference(ItemRefNo: Code[50]; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30];
                                                                            TempRecRequired: Boolean;
                                                                            MultipleItemsToChoose: Boolean;
                                                                            ShowDialog: Boolean)
    begin
        if ShowDialog and MultipleItemsToChoose then begin
            if not RunPageReferenceListOnRealOrTempRec(GlobalItemReference, TempRecRequired, ItemRefType, ItemRefTypeNo) then
                Error(ItemRefNotExistErr, ItemRefNo);
        end else
            if not FindFirstCustVendItemReference(GlobalItemReference, ItemRefType, ItemRefTypeNo) then
                FindFirstBarCodeOrBlankTypeItemReference(GlobalItemReference);
    end;

    local procedure RunPageReferenceListOnRealOrTempRec(var ItemReference: Record "Item Reference"; RunOnTempRec: Boolean; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30]): Boolean
    begin
        if RunOnTempRec then
            exit(RunPageReferenceListOnTempRecord(
                ItemReference, ItemRefType, ItemRefTypeNo));
        exit(RunPageReferenceList(ItemReference));
    end;

    local procedure FindFirstCustVendItemReference(var ItemReference: Record "Item Reference"; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30]): Boolean
    var
        ItemReferenceToCheck: Record "Item Reference";
    begin
        SetFiltersTypeAndTypeNoItemRef(ItemReference, ItemRefType, ItemRefTypeNo);
        ItemReferenceToCheck.CopyFilters(ItemReference);
        if ItemReferenceToCheck.FindFirst() then begin
            ItemReference.Copy(ItemReferenceToCheck);
            exit(true);
        end;
        exit(false);
    end;

    local procedure RunPageReferenceListOnTempRecord(var ItemReference: Record "Item Reference"; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[30]): Boolean
    var
        TempItemReference: Record "Item Reference" temporary;
        ItemReferenceToCopy: Record "Item Reference";
    begin
        ItemReferenceToCopy.CopyFilters(ItemReference);
        SetFiltersTypeAndTypeNoItemRef(ItemReferenceToCopy, ItemRefType, ItemRefTypeNo);
        InsertTempRecords(TempItemReference, ItemReferenceToCopy);
        SetFiltersBlankTypeItemRef(ItemReferenceToCopy);
        InsertTempRecords(TempItemReference, ItemReferenceToCopy);
        if RunPageReferenceList(TempItemReference) then begin
            ItemReference := TempItemReference;
            exit(true);
        end;
        exit(false);
    end;

    local procedure FindFirstBarCodeOrBlankTypeItemReference(var ItemReference: Record "Item Reference")
    var
        ItemReferenceToCheck: Record "Item Reference";
    begin
        SetFiltersBlankTypeItemRef(ItemReference);
        ItemReferenceToCheck.CopyFilters(ItemReference);
        ItemReferenceToCheck.FindFirst();
        ItemReference.Copy(ItemReferenceToCheck);
    end;

    local procedure RunPageReferenceList(var ItemReference: Record "Item Reference"): Boolean
    begin
        ItemReference.FindFirst();
        exit(PAGE.RunModal(PAGE::"Item Reference List", ItemReference) = ACTION::LookupOK);
    end;

    local procedure InsertTempRecords(var TempItemReference: Record "Item Reference" temporary; var ItemReferenceToCopy: Record "Item Reference")
    begin
        if ItemReferenceToCopy.FindSet() then
            repeat
                TempItemReference := ItemReferenceToCopy;
                TempItemReference.Insert();
            until ItemReferenceToCopy.Next() = 0;
    end;


    var
        GlobalReqLine: Record PPHRDS_ReqLine;
        GlobalItemReference: Record "Item Reference";
        ItemRefWrongTypeErr: Label 'The reference type must be Customer or Vendor.';
        ItemRefNotExistErr: Label 'There are no items with reference %1.', Comment = '%1=Reference No.';
}