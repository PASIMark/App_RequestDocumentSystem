codeunit 70829618 PPHRDS_RequestBudgetManagement
{
    trigger OnRun();
    begin
    end;

    var
        RequestSetup: Record PPHRDS_ReqDocSysSetup;
        ItemBudgetName: Record "Item Budget Name";
        GLBudgetName: Record "G/L Budget Name";
        ItemStatisticsBuf: Record "Item Statistics Buffer";
        GLAccBudgetBuffer: Record "G/L Acc. Budget Buffer";
        ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
        GLEntry: Record "G/L Entry";
        FixedAssetBudget: Record PPHRDS_FixedAssetBudget;
        FALedgerEntry: Record "FA Ledger Entry";
        ReqLine: Record PPHRDS_ReqLine;
        PurchaseLine: Record "Purchase Line";
        JobPlanningLine: Record "Job Planning Line";
        JobLedgerEntry: Record "Job Ledger Entry";
        ReqMgt: Codeunit PPHRDS_RequestManagement;
        FiscalYearFilterLbl: Label '%1..%2', Comment = '%1 = Start Date, %2 = End Date';

    procedure GetBudgetDetails(var parReqLine: Record PPHRDS_ReqLine; var parBudgetValue: Decimal; var parActualValue: Decimal; var parReleasedValue: Decimal; var parPurchaseValue: Decimal; var parAvailableValue: Decimal; var BudgetExist: Boolean; var isOverBudget: Boolean);
    var
        CurrentLineValue: Decimal;
    begin
        GetReqSetup();

        if (not (parReqLine."Request Type" in [parReqLine."Request Type"::Purchase, parReqLine."Request Type"::"Req. Worksheet"])) or (parReqLine."Request Code" = '') then begin
            parBudgetValue := 0;
            parActualValue := 0;
            parReleasedValue := 0;
            parPurchaseValue := 0;
            parAvailableValue := 0;
            isOverBudget := false;
            BudgetExist := false;
            exit;
        end;

        CurrentLineValue := GetCurrentLineValue(parReqLine);

        if (parReqLine.Type in [parReqLine.Type::"G/L Account", parReqLine.Type::Item, parReqLine.Type::"Fixed Asset"]) and (parReqLine."No." <> '') then begin
            parBudgetValue := GetBudget(parReqLine);
            parActualValue := GetActual(parReqLine);

            parReleasedValue := GetReleased(parReqLine);
            if parReqLine.Status = parReqLine.Status::Released then
                parReleasedValue := parReleasedValue - CurrentLineValue;

            parPurchaseValue := GetPurchase(parReqLine);
            parAvailableValue := parBudgetValue - parActualValue - parReleasedValue - parPurchaseValue;
        end;

        if parBudgetValue > 0 then
            BudgetExist := true
        else
            BudgetExist := false;

        if CurrentLineValue > parAvailableValue then
            isOverBudget := true
        else
            isOverBudget := false;

        if (RequestSetup."G/L Budget Name" = '') and (RequestSetup."Item Budget Name" = '') then
            isOverBudget := false;
    end;

    procedure GetBudget(parReqLine: Record PPHRDS_ReqLine): Decimal;
    var
        locGeneralLedgerSetup: Record "General Ledger Setup";
        ValueType: Option "Sales Amount","Cost Amount",Quantity;
        FiscalStartDate: Date;
        FiscalEndDate: Date;
        FiscalYearFilter: Text;
    begin
        locGeneralLedgerSetup.Get();
        GetReqSetup();

        if (not (parReqLine."Request Type" in [parReqLine."Request Type"::Purchase, parReqLine."Request Type"::"Req. Worksheet"])) or (parReqLine."Request Code" = '') then
            exit(0);

        if not BudgetSetupExist(parReqLine) then
            exit(0);

        case RequestSetup."Item Budget Type" of
            RequestSetup."Item Budget Type"::Quantity:
                ValueType := ValueType::Quantity;
            RequestSetup."Item Budget Type"::"Cost Amount":
                ValueType := ValueType::"Cost Amount";
        end;

        ReqMgt.GetFiscalYear(parReqLine."Expected Receipt Date", FiscalStartDate, FiscalEndDate);
        FiscalYearFilter := StrSubstNo(FiscalYearFilterLbl, FiscalStartDate, FiscalEndDate);

        case parReqLine.Type of
            parReqLine.Type::"G/L Account":
                begin
                    SetCommonBudgetGLFilters(GLBudgetName,
                        parReqLine."No.",
                        FiscalYearFilter,
                        parReqLine."Shortcut Dimension 1 Code",
                        parReqLine."Shortcut Dimension 2 Code",
                        '',
                        '',
                        '',
                        '');
                    GLAccBudgetBuffer.CalcFields("Budgeted Amount");
                    exit(GLAccBudgetBuffer."Budgeted Amount");
                end;
            parReqLine.Type::Item:
                if ReqLineIsItem(parReqLine) then begin
                    SetCommonBudgetItemFilters(ItemBudgetName, parReqLine."No.", 0, '',
                        parReqLine."Location Code",
                        FiscalYearFilter,
                        parReqLine."Shortcut Dimension 1 Code",
                        parReqLine."Shortcut Dimension 2 Code",
                        '',
                        '',
                        '');
                    case ValueType of
                        ValueType::"Cost Amount":
                            begin
                                ItemStatisticsBuf.CalcFields("Budgeted Cost Amount");
                                exit(ItemStatisticsBuf."Budgeted Cost Amount");
                            end;
                        ValueType::Quantity:
                            begin
                                ItemStatisticsBuf.CalcFields("Budgeted Quantity");
                                exit(ItemStatisticsBuf."Budgeted Quantity");
                            end;
                    end;

                end else begin
                    SetCommonBudgetJobItemFilters(parReqLine."Job No.", parReqLine."Job Task No.", parReqLine."No.", FiscalYearFilter);
                    exit(GetBudgetJobItemValue(ValueType));
                end;
            parReqLine.Type::"Fixed Asset":
                begin
                    if FixedAssetBudget.Get(parReqLine."No.") and (FixedAssetBudget.Blocked = true) then
                        exit(0);
                    exit(FixedAssetBudget.Amount);
                end;
        end;
    end;

    procedure GetActual(parReqLine: Record PPHRDS_ReqLine): Decimal;
    var
        ValueType: Option "Sales Amount","Cost Amount",Quantity;
        FiscalStartDate: Date;
        FiscalEndDate: Date;
        FiscalYearFilter: Text;
        Item: Record Item;
    begin
        GetReqSetup();

        if (not (parReqLine."Request Type" in [parReqLine."Request Type"::Purchase, parReqLine."Request Type"::"Req. Worksheet"])) or (parReqLine."Request Code" = '') then
            exit(0);

        if not BudgetSetupExist(parReqLine) then
            exit(0);

        case RequestSetup."Item Budget Type" of
            RequestSetup."Item Budget Type"::Quantity:
                ValueType := ValueType::Quantity;
            RequestSetup."Item Budget Type"::"Cost Amount":
                ValueType := ValueType::"Cost Amount";
        end;

        ReqMgt.GetFiscalYear(parReqLine."Expected Receipt Date", FiscalStartDate, FiscalEndDate);
        FiscalYearFilter := StrSubstNo(FiscalYearFilterLbl, FiscalStartDate, FiscalEndDate);

        case parReqLine.Type of
            parReqLine.Type::"G/L Account":
                begin
                    SetCommonActualGLFilters(parReqLine."No.", FiscalYearFilter, parReqLine."Shortcut Dimension 1 Code", parReqLine."Shortcut Dimension 2 Code");
                    GLEntry.CalcSums(Amount);
                    exit(GLEntry.Amount);
                end;
            parReqLine.Type::Item:
                if ReqLineIsItem(parReqLine) then
                    case ValueType of
                        ValueType::"Cost Amount":
                            if Item.Get(parReqLine."No.") and (Item.Type = Item.Type::Inventory) then begin
                                ItemStatisticsBuf.CalcFields("Cost Amount (Actual)");
                                exit(ItemStatisticsBuf."Cost Amount (Actual)");
                            end else begin
                                ItemStatisticsBuf.CalcFields("Cost Amount (Non-Invtbl.)");
                                exit(ItemStatisticsBuf."Cost Amount (Non-Invtbl.)");
                            end;
                        ValueType::Quantity:
                            begin
                                ItemStatisticsBuf.CalcFields(Quantity);
                                exit(ItemStatisticsBuf.Quantity);
                            end;
                    end
                else begin
                    SetCommonActualJobItemFilters(parReqLine."Job No.", parReqLine."Job Task No.", parReqLine."No.", FiscalYearFilter);
                    exit(GetActualJobItemValue(ValueType));
                end;
            parReqLine.Type::"Fixed Asset":
                begin
                    SetCommonActualFAFilters(parReqLine."No.",
                      FiscalYearFilter);
                    exit(GetActualFAValue());
                end;
        end;
    end;

    procedure GetReleased(parReqLine: Record PPHRDS_ReqLine): Decimal;
    var
        ValueType: Option "Sales Amount","Cost Amount",Quantity;
        FiscalStartDate: Date;
        FiscalEndDate: Date;
        FiscalYearFilter: Text;
    begin
        GetReqSetup();

        if (not (parReqLine."Request Type" in [parReqLine."Request Type"::Purchase, parReqLine."Request Type"::"Req. Worksheet"])) or (parReqLine."Request Code" = '') then
            exit(0);

        if not BudgetSetupExist(parReqLine) then
            exit(0);

        case RequestSetup."Item Budget Type" of
            RequestSetup."Item Budget Type"::Quantity:
                ValueType := ValueType::Quantity;
            RequestSetup."Item Budget Type"::"Cost Amount":
                ValueType := ValueType::"Cost Amount";
        end;

        ReqMgt.GetFiscalYear(parReqLine."Expected Receipt Date", FiscalStartDate, FiscalEndDate);
        FiscalYearFilter := StrSubstNo(FiscalYearFilterLbl, FiscalStartDate, FiscalEndDate);

        case parReqLine.Type of
            parReqLine.Type::"G/L Account":
                begin
                    SetCommonReqFilters(parReqLine.Type,
                      parReqLine."No.",
                      ReqLineIsItem(parReqLine),
                      '',
                      '',
                      '',
                      FiscalYearFilter,
                      parReqLine."Shortcut Dimension 1 Code",
                      parReqLine."Shortcut Dimension 2 Code");
                    ReqLine.CalcSums("Line Amount");
                    exit(ReqLine."Line Amount");
                end;
            parReqLine.Type::Item:
                begin
                    SetCommonReqFilters(parReqLine.Type,
                      parReqLine."No.",
                      ReqLineIsItem(parReqLine),
                      parReqLine."Job No.",
                      parReqLine."Job Task No.",
                      parReqLine."Location Code",
                      FiscalYearFilter,
                      parReqLine."Shortcut Dimension 1 Code",
                      parReqLine."Shortcut Dimension 2 Code");
                    exit(GetReleasedItemValue(ValueType));
                end;
            parReqLine.Type::"Fixed Asset":
                begin
                    SetCommonReqFilters(parReqLine.Type,
                      parReqLine."No.",
                      ReqLineIsItem(parReqLine),
                      '',
                      '',
                      '',
                      FiscalYearFilter,
                      parReqLine."Shortcut Dimension 1 Code",
                      parReqLine."Shortcut Dimension 2 Code");
                    exit(GetReleasedFAValue());
                end;
        end;
    end;

    procedure GetPurchase(parReqLine: Record PPHRDS_ReqLine): Decimal;
    var
        ValueType: Option "Sales Amount","Cost Amount",Quantity;
        FiscalStartDate: Date;
        FiscalEndDate: Date;
        FiscalYearFilter: Text;
    begin
        GetReqSetup();

        if (not (parReqLine."Request Type" in [parReqLine."Request Type"::Purchase, parReqLine."Request Type"::"Req. Worksheet"])) or (parReqLine."Request Code" = '') then
            exit(0);

        if not BudgetSetupExist(ReqLine) then
            exit(0);

        case RequestSetup."Item Budget Type" of
            RequestSetup."Item Budget Type"::Quantity:
                ValueType := ValueType::Quantity;
            RequestSetup."Item Budget Type"::"Cost Amount":
                ValueType := ValueType::"Cost Amount";
        end;

        ReqMgt.GetFiscalYear(parReqLine."Expected Receipt Date", FiscalStartDate, FiscalEndDate);
        FiscalYearFilter := StrSubstNo(FiscalYearFilterLbl, FiscalStartDate, FiscalEndDate);

        case parReqLine.Type of
            parReqLine.Type::"G/L Account":
                begin
                    SetCommonPurchaseFilters(ReqMgt.LineReqTypeToPurchType(parReqLine.Type), parReqLine."No.", '', parReqLine."Shortcut Dimension 1 Code", parReqLine."Shortcut Dimension 2 Code");
                    exit(GetPurchaseValue(FiscalStartDate, FiscalEndDate));
                end;
            parReqLine.Type::Item:
                begin
                    SetCommonPurchaseFilters(ReqMgt.LineReqTypeToPurchType(parReqLine.Type), parReqLine."No.", parReqLine."Location Code", parReqLine."Shortcut Dimension 1 Code", parReqLine."Shortcut Dimension 2 Code");
                    exit(GetPurchaseItemValue(ValueType, ReqLineIsItem(parReqLine), parReqLine."Job No.", parReqLine."Job Task No.", FiscalStartDate, FiscalEndDate));
                end;
            parReqLine.Type::"Fixed Asset":
                begin
                    SetCommonPurchaseFilters(ReqMgt.LineReqTypeToPurchType(parReqLine.Type), parReqLine."No.", '', parReqLine."Shortcut Dimension 1 Code", parReqLine."Shortcut Dimension 2 Code");
                    exit(GetPurchaseValue(FiscalStartDate, FiscalEndDate));
                end;
        end;
    end;

    procedure GetCurrentLineValue(parReqLine: Record PPHRDS_ReqLine): Decimal;
    var
        ValueType: Option "Sales Amount","Cost Amount",Quantity;
    begin
        GetReqSetup();

        if not (parReqLine."Request Type" in [parReqLine."Request Type"::Purchase, parReqLine."Request Type"::"Req. Worksheet"]) then
            exit(0);

        if not BudgetSetupExist(parReqLine) then
            exit(0);

        case RequestSetup."Item Budget Type" of
            RequestSetup."Item Budget Type"::Quantity:
                ValueType := ValueType::Quantity;
            RequestSetup."Item Budget Type"::"Cost Amount":
                ValueType := ValueType::"Cost Amount";
        end;

        case parReqLine.Type of
            parReqLine.Type::"G/L Account", parReqLine.Type::"Fixed Asset":
                exit(parReqLine."Line Amount");
            parReqLine.Type::Item:
                case ValueType of
                    ValueType::"Cost Amount":
                        exit(parReqLine."Line Amount");
                    ValueType::Quantity:
                        exit(parReqLine."Outstanding Qty. (Base)");
                end;
        end;
    end;

    procedure AddBudgetedAsset();
    var
        FixedAsset: Record "Fixed Asset";
    begin
        if FixedAsset.FindSet() then
            repeat
                if not FixedAssetBudget.Get(FixedAsset."No.") then begin
                    FixedAssetBudget.Init();
                    FixedAssetBudget.Validate("No.", FixedAsset."No.");
                    FixedAssetBudget.Insert();
                end;
            until FixedAsset.Next() = 0;
    end;

    local procedure SetCommonBudgetGLFilters(locGLBudgetName: Record "G/L Budget Name"; GLAccountFilter: Text; DateFilter: Text; GlobalDim1Filter: Text; GlobalDim2Filter: Text; BudgetDim1Filter: Text; BudgetDim2Filter: Text; BudgetDim3Filter: Text; BudgetDim4Filter: Text);
    begin
        GLAccBudgetBuffer.Reset();
        GLAccBudgetBuffer.SetRange(Code, locGLBudgetName.Name);
        GLAccBudgetBuffer.SetFilter("G/L Account Filter", GLAccountFilter);
        if DateFilter <> '' then
            GLAccBudgetBuffer.SetFilter("Date Filter", DateFilter);
        if GlobalDim1Filter <> '' then
            GLAccBudgetBuffer.SetFilter("Global Dimension 1 Filter", GlobalDim1Filter)
        else
            GLAccBudgetBuffer.SetRange("Global Dimension 1 Filter", '');
        if GlobalDim2Filter <> '' then
            GLAccBudgetBuffer.SetFilter("Global Dimension 2 Filter", GlobalDim2Filter)
        else
            GLAccBudgetBuffer.SetRange("Global Dimension 2 Filter", '');
        GLAccBudgetBuffer.SetFilter("Budget Dimension 1 Filter", BudgetDim1Filter);
        GLAccBudgetBuffer.SetFilter("Budget Dimension 2 Filter", BudgetDim2Filter);
        GLAccBudgetBuffer.SetFilter("Budget Dimension 3 Filter", BudgetDim3Filter);
        GLAccBudgetBuffer.SetFilter("Budget Dimension 4 Filter", BudgetDim4Filter);
    end;

    local procedure SetCommonBudgetItemFilters(locItemBudgetName: Record "Item Budget Name"; ItemFilter: Text; SourceTypeFilter: Option; SourceNoFilter: Text; LocationFilter: Text; DateFilter: Text; GlobalDim1Filter: Text; GlobalDim2Filter: Text; BudgetDim1Filter: Text; BudgetDim2Filter: Text; BudgetDim3Filter: Text);
    begin
        ItemStatisticsBuf.Reset();
        ItemStatisticsBuf.SetRange("Analysis Area Filter", locItemBudgetName."Analysis Area");
        ItemStatisticsBuf.SetRange("Budget Filter", locItemBudgetName.Name);
        if ItemFilter <> '' then
            ItemStatisticsBuf.SetFilter("Item Filter", ItemFilter);
        if SourceNoFilter <> '' then begin
            ItemStatisticsBuf.SetFilter("Source Type Filter", '%1', SourceTypeFilter);
            ItemStatisticsBuf.SetFilter("Source No. Filter", SourceNoFilter);
        end;
        if LocationFilter <> '' then
            ItemStatisticsBuf.SetFilter("Location Filter", LocationFilter);
        if DateFilter <> '' then
            ItemStatisticsBuf.SetFilter("Date Filter", DateFilter);
        if GlobalDim1Filter <> '' then
            ItemStatisticsBuf.SetFilter("Global Dimension 1 Filter", GlobalDim1Filter)
        else
            ItemStatisticsBuf.SetRange("Global Dimension 1 Filter", ' ');
        if GlobalDim2Filter <> '' then
            ItemStatisticsBuf.SetFilter("Global Dimension 2 Filter", GlobalDim2Filter)
        else
            ItemStatisticsBuf.SetRange("Global Dimension 2 Filter", ' ');
        if BudgetDim1Filter <> '' then
            ItemStatisticsBuf.SetFilter("Dimension 1 Filter", BudgetDim1Filter);
        if BudgetDim2Filter <> '' then
            ItemStatisticsBuf.SetFilter("Dimension 2 Filter", BudgetDim2Filter);
        if BudgetDim3Filter <> '' then
            ItemStatisticsBuf.SetFilter("Dimension 3 Filter", BudgetDim3Filter);
    end;

    local procedure SetCommonBudgetJobItemFilters(JobNo: Text; JobTaskNo: Text; ItemFilter: Text; DateFilter: Text);
    begin
        JobPlanningLine.Reset();
        JobPlanningLine.SetFilter("Job No.", JobNo);
        JobPlanningLine.SetFilter("Job Task No.", JobTaskNo);
        JobPlanningLine.SetFilter("Line Type", '%1|%2', JobPlanningLine."Line Type"::Budget, JobPlanningLine."Line Type"::"Both Budget and Billable");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
        JobPlanningLine.SetRange("No.", ItemFilter);
        JobPlanningLine.SetRange("Usage Link", true);
        if DateFilter <> '' then
            JobPlanningLine.SetFilter("Planning Date", DateFilter);
    end;

    local procedure SetCommonActualGLFilters(GLAccountFilter: Text; DateFilter: Text; GlobalDim1Filter: Text; GlobalDim2Filter: Text);
    begin
        GLEntry.Reset();
        GLEntry.SetCurrentKey("Posting Date", "G/L Account No.", "Dimension Set ID");
        if DateFilter <> '' then
            GLEntry.SetFilter("Posting Date", DateFilter);
        GLEntry.SetRange("G/L Account No.", GLAccountFilter);
        if GlobalDim1Filter <> '' then
            GLEntry.SetFilter("Global Dimension 1 Code", GlobalDim1Filter)
        else
            GLEntry.SetRange("Global Dimension 1 Code", '');
        if GlobalDim2Filter <> '' then
            GLEntry.SetFilter("Global Dimension 2 Code", GlobalDim2Filter)
        else
            GLEntry.SetRange("Global Dimension 2 Code", '');
    end;

    // local procedure SetCommonActualItemFilters(ItemFilter: Text; LocationFilter: Text; DateFilter: Text; GlobalDim1Filter: Text; GlobalDim2Filter: Text);
    // begin
    //     ItemLedgerEntry.Reset();
    //     ItemLedgerEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Global Dimension 1 Code", "Global Dimension 2 Code", "Location Code", "Posting Date");
    //     ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
    //     ItemLedgerEntry.SetRange("Item No.", ItemFilter);
    //     if LocationFilter <> '' then
    //         ItemLedgerEntry.SetRange("Location Code", LocationFilter);
    //     if DateFilter <> '' then
    //         ItemLedgerEntry.SetFilter("Posting Date", DateFilter);
    //     if GlobalDim1Filter <> '' then
    //         ItemLedgerEntry.SetFilter("Global Dimension 1 Code", GlobalDim1Filter);
    //     if GlobalDim2Filter <> '' then
    //         ItemLedgerEntry.SetFilter("Global Dimension 2 Code", GlobalDim2Filter);
    // end;

    local procedure SetCommonActualJobItemFilters(JobNo: Text; JobTaskNo: Text; ItemFilter: Text; DateFilter: Text);
    begin
        JobLedgerEntry.Reset();
        JobLedgerEntry.SetFilter("Job No.", JobNo);
        JobLedgerEntry.SetFilter("Job Task No.", JobTaskNo);
        JobLedgerEntry.SetRange("Entry Type", JobLedgerEntry."Entry Type"::Usage);
        JobLedgerEntry.SetRange(Type, JobLedgerEntry.Type::Item);
        JobLedgerEntry.SetRange("No.", ItemFilter);
        if DateFilter <> '' then
            JobLedgerEntry.SetFilter("Posting Date", DateFilter)
    end;

    local procedure SetCommonActualFAFilters(FAFilter: Text; DateFilter: Text);
    begin
        FALedgerEntry.Reset();
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "FA Posting Date", "Part of Book Value", "Reclassification Entry");
        FALedgerEntry.SetFilter("FA No.", FAFilter);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        if DateFilter <> '' then
            FALedgerEntry.SetFilter("FA Posting Date", DateFilter);
    end;

    local procedure SetCommonReqFilters(TypeFilter: Enum PPHRDS_ReqLineType; NoFilter: Text; JobItem: Boolean; JobNoFilter: Text; JobTaskNoFilter: Text; LocationFilter: Text; DateFilter: Text; GlobalDim1Filter: Text; GlobalDim2Filter: Text);
    begin
        ReqLine.Reset();
        ReqLine.SetCurrentKey("Request Type", Type, "No.", "Job No.", "Job Task No.", "Location Code", "Request Date", Status, "Dimension Set ID");
        ReqLine.SetFilter("Request Type", '%1|%2', ReqLine."Request Type"::Purchase, ReqLine."Request Type"::"Req. Worksheet");
        ReqLine.SetRange(Type, TypeFilter);
        ReqLine.SetRange("No.", NoFilter);
        if not JobItem then begin
            ReqLine.SetRange("Job No.", JobNoFilter);
            ReqLine.SetRange("Job Task No.", JobTaskNoFilter);
        end;
        if LocationFilter <> '' then
            ReqLine.SetFilter("Location Code", LocationFilter);
        if DateFilter <> '' then
            ReqLine.SetFilter("Request Date", DateFilter);
        ReqLine.SetRange(Status, ReqLine.Status::Released);
        if GlobalDim1Filter <> '' then
            ReqLine.SetFilter("Shortcut Dimension 1 Code", GlobalDim1Filter)
        else
            ReqLine.SetRange("Shortcut Dimension 1 Code", ' ');
        if GlobalDim2Filter <> '' then
            ReqLine.SetFilter("Shortcut Dimension 2 Code", GlobalDim2Filter)
        else
            ReqLine.SetRange("Shortcut Dimension 2 Code", ' ');
    end;

    local procedure SetCommonPurchaseFilters(TypeFilter: Enum "Purchase Line Type"; NoFilter: Text; LocationFilter: Text; GlobalDim1Filter: Text; GlobalDim2Filter: Text);
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
        PurchaseLine.SetFilter("Document Type", '%1|%2', PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::Invoice);
        PurchaseLine.SetRange(Type, TypeFilter);
        PurchaseLine.SetRange("No.", NoFilter);
        if LocationFilter <> '' then
            PurchaseLine.SetRange("Location Code", LocationFilter);
        if GlobalDim1Filter <> '' then
            PurchaseLine.SetFilter("Shortcut Dimension 1 Code", GlobalDim1Filter)
        else
            PurchaseLine.SetRange("Shortcut Dimension 1 Code", ' ');
        if GlobalDim2Filter <> '' then
            PurchaseLine.SetFilter("Shortcut Dimension 2 Code", GlobalDim2Filter)
        else
            PurchaseLine.SetRange("Shortcut Dimension 2 Code", ' ');
    end;

    local procedure GetBudgetJobItemValue(ValueType: Option "Sales Amount","Cost Amount",Quantity): Decimal;
    var
        JobPlanningLineValue: Decimal;
    begin
        JobPlanningLineValue := 0;

        if JobPlanningLine.FindFirst() then
            repeat
                case ValueType of
                    ValueType::"Cost Amount":
                        JobPlanningLineValue += JobPlanningLine."Total Cost (LCY)";
                    ValueType::Quantity:
                        JobPlanningLineValue += JobPlanningLine."Quantity (Base)";
                end;
            until JobPlanningLine.Next() = 0;

        exit(JobPlanningLineValue);
    end;

    // local procedure GetActualItemValue(ValueType: Option "Sales Amount","Cost Amount",Quantity): Decimal;
    // var
    //     LineValue: Decimal;
    //     TotalValue: Decimal;
    // begin
    //     TotalValue := 0;

    //     if ItemLedgerEntry.FindFirst() then
    //         repeat
    //             ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
    //             case ValueType of
    //                 ValueType::"Cost Amount":
    //                     LineValue := ItemLedgerEntry."Cost Amount (Actual)";
    //                 ValueType::Quantity:
    //                     LineValue := ItemLedgerEntry.Quantity;
    //             end;
    //             TotalValue += LineValue;
    //         until ItemLedgerEntry.Next() = 0;

    //     exit(TotalValue);
    // end;

    local procedure GetActualFAValue(): Decimal;
    begin
        FALedgerEntry.CalcSums(Amount);
        exit(FALedgerEntry.Amount);
    end;

    local procedure GetActualJobItemValue(ValueType: Option "Sales Amount","Cost Amount",Quantity): Decimal;
    var
        TotalValue: Decimal;
    begin
        TotalValue := 0;

        if JobLedgerEntry.FindFirst() then
            repeat
                case ValueType of
                    ValueType::"Cost Amount":
                        TotalValue += JobLedgerEntry."Total Cost (LCY)";
                    ValueType::Quantity:
                        TotalValue += JobLedgerEntry."Quantity (Base)";
                end;
            until JobLedgerEntry.Next() = 0;

        exit(TotalValue);
    end;

    local procedure GetReleasedFAValue(): Decimal;
    begin
        ReqLine.CalcSums("Line Amount");
        exit(ReqLine."Line Amount");
    end;

    local procedure GetReleasedItemValue(ValueType: Option "Sales Amount","Cost Amount",Quantity): Decimal;
    var
        TotalValue: Decimal;
    begin
        TotalValue := 0;

        if ReqLine.FindFirst() then
            repeat
                case ValueType of
                    ValueType::"Cost Amount":
                        // TotalValue += GetBaseUnitCost(ReqLine."Line Amount", ReqLine."Quantity (Base)");
                        TotalValue += ReqLine."Line Amount";
                    ValueType::Quantity:
                        TotalValue += ReqLine."Quantity (Base)";
                end;
            until ReqLine.Next() = 0;

        exit(TotalValue);
    end;

    local procedure GetPurchaseValue(DateFrom: Date; DateTo: Date): Decimal;
    var
        PurchaseHeader: Record "Purchase Header";
        TotalValue: Decimal;
    begin

        TotalValue := 0;

        if PurchaseLine.FindFirst() then
            repeat

                PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                if (PurchaseHeader."Posting Date" >= DateFrom) and (PurchaseHeader."Posting Date" <= DateTo) then
                    TotalValue += PurchaseLine."Outstanding Amount (LCY)";

            until PurchaseLine.Next() = 0;

        exit(TotalValue);
    end;

    local procedure GetPurchaseItemValue(ValueType: Option "Sales Amount","Cost Amount",Quantity; RegItem: Boolean; JobNoFilter: Text; JobTaskNoFilter: Text; DateFrom: Date; DateTo: Date): Decimal;
    var
        PurchaseHeader: Record "Purchase Header";
        LineValue: Decimal;
        TotalValue: Decimal;
    begin
        TotalValue := 0;

        if PurchaseLine.FindFirst() then
            repeat

                PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                if (PurchaseHeader."Posting Date" >= DateFrom) and (PurchaseHeader."Posting Date" <= DateTo) then begin

                    case ValueType of
                        ValueType::"Cost Amount":
                            LineValue := PurchaseLine."Outstanding Amount (LCY)";
                        ValueType::Quantity:
                            LineValue := PurchaseLine."Outstanding Qty. (Base)";
                    end;

                    if RegItem then
                        TotalValue += LineValue
                    else begin
                        ProcessedRequestEntry.Reset();
                        ProcessedRequestEntry.SetRange("Purchase Document Type", ProcessedRequestEntry."Purchase Document Type"::Order);
                        ProcessedRequestEntry.SetRange("Purchase Document No.", PurchaseLine."Document No.");
                        ProcessedRequestEntry.SetRange("Purchase Document Line No.", PurchaseLine."Line No.");
                        ProcessedRequestEntry.SetRange("Job No.", JobNoFilter);
                        ProcessedRequestEntry.SetRange("Job Task No.", JobTaskNoFilter);
                        if ProcessedRequestEntry.FindFirst() then
                            TotalValue += LineValue;
                    end;

                end;

            until PurchaseLine.Next() = 0;

        exit(TotalValue);
    end;

    local procedure BudgetSetupExist(parReqLine: Record PPHRDS_ReqLine): Boolean;
    begin
        GetReqSetup();

        case parReqLine.Type of
            parReqLine.Type::"G/L Account":
                if ReqLineIsItem(parReqLine) then begin
                    if RequestSetup."G/L Budget Name" = '' then
                        exit(false);
                    if GLBudgetName.Get(RequestSetup."G/L Budget Name") then
                        if GLBudgetName.Blocked then
                            exit(false);
                end;
            parReqLine.Type::Item:
                begin
                    if RequestSetup."Item Budget Name" = '' then
                        exit(false);
                    if ItemBudgetName.Get(ItemBudgetName."Analysis Area"::Purchase, RequestSetup."Item Budget Name") then
                        if ItemBudgetName.Blocked then
                            exit(false);
                end;
            parReqLine.Type::"Fixed Asset":
                begin
                    FixedAssetBudget.Reset();
                    FixedAssetBudget.SetRange(Blocked, false);
                    if not FixedAssetBudget.FindFirst() then
                        exit(false);
                end;
        end;

        exit(true);

    end;

    local procedure GetReqSetup();
    begin
        RequestSetup.Get();
    end;

    local procedure ReqLineIsItem(parReqLine: Record PPHRDS_ReqLine): Boolean;
    begin
        if (parReqLine."Job No." <> '') and (parReqLine."Job Task No." <> '') then
            exit(false)
        else
            exit(true);
    end;

    // local procedure GetBaseUnitCost(parAmount: Decimal; parBaseQty: Decimal): Decimal;
    // begin
    //     if parAmount > 0 then
    //         exit(parAmount / parBaseQty)
    //     else
    //         exit(0);
    // end;
}

