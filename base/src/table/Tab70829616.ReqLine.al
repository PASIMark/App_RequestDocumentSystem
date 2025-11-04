table 70829616 PPHRDS_ReqLine
{
    Caption = 'Req. Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Document No.';
            Editable = false;
            TableRelation = PPHRDS_ReqHeader."No.";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
            Editable = false;
        }
        field(5; Type; Enum PPHRDS_ReqLineType)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';

            trigger OnValidate();
            var
                TempReqLine: Record PPHRDS_ReqLine temporary;
            begin
                GetReqHeader();

                TestStatusOpen();

                TestField("Quantity Processed", 0);

                CheckTypeCombination();

                TempReqLine := Rec;
                Init();
                "Request Date" := ReqHeader."Request Date";
                Type := TempReqLine.Type;
            end;
        }
        field(6; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            ValidateTableRelation = false;
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                     "Account Type" = CONST(Posting),
                                                                                     Blocked = CONST(false))
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST(Employee)) Employee;

            trigger OnValidate();
            var
                RecId: RecordId;
            begin
                "No." := FindNoFromTypedValue("No.");

                TestStatusOpen();

                GetReqHeader();
                if ReqHeader."Request Code" <> '' then
                    Validate("Request Code", ReqHeader."Request Code");
                if (ReqHeader."Location Code" <> '') and not IsNonInventoriableItem() then
                    Validate("Location Code", ReqHeader."Location Code");

                case Type of
                    Type::" ":
                        begin
                            StandardText.Get("No.");
                            Description := StandardText.Description;
                        end;
                    Type::"G/L Account":
                        begin
                            GLAcc.Get("No.");
                            GLAcc.CheckGLAcc();
                            Description := GLAcc.Name;
                        end;
                    Type::Item:
                        begin
                            GetItem(Item);
                            GetGLSetup();
                            Item.TestField(Blocked, false);
                            Item.TestField("Gen. Prod. Posting Group");
                            if Item.Type = Item.Type::Inventory then
                                Item.TestField("Inventory Posting Group");
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            "Unit of Measure Code" := Item."Purch. Unit of Measure";
                            if "Request Type" in ["Request Type"::Purchase, "Request Type"::"Req. Worksheet"] then
                                Validate("Vendor No.", Item."Vendor No.");
                            "Vendor Item No." := Item."Vendor Item No.";
                        end;
                    //Type::"3":
                    //  Error(Text003);
                    Type::"Fixed Asset":
                        begin
                            FixedAsset.Get("No.");
                            FixedAsset.TestField(Inactive, false);
                            FixedAsset.TestField(Blocked, false);
                            Description := FixedAsset.Description;
                            "Description 2" := FixedAsset."Description 2";
                        end;
                    Type::Vendor:
                        begin
                            Vendor.Get("No.");
                            Vendor.TestField(Blocked, Vendor.Blocked::" ");
                            Description := Vendor.Name;
                        end;
                    Type::Employee:
                        begin
                            Employee.Get("No.");
                            Employee.TestField(Status, Employee.Status::Active);
                            Description := Employee.FullName();
                        end;
                end;

                if Type <> Type::" " then begin
                    Validate("Unit of Measure Code");
                    if Quantity <> 0 then begin
                        InitOutstanding();
                        InitQtyToReceive();
                    end;
                    UpdateDirectUnitCost(FieldNo("No."));
                end;

                "Expected Receipt Date" := ReqHeader."Request Date";

                if "Request Type" = "Request Type"::"Transfer Order" then
                    Validate("Direct Unit Cost", 0);

                if not IsTemporary then
                    case Type of
                        Type::"G/L Account", Type::Item, Type::"Fixed Asset":
                            CreateDim(DimMgt.PurchLineTypeToTableID(Type), "No.");
                        Type::Vendor:
                            begin
                                RecId := Vendor.RecordId;
                                CreateDim(RecId.TableNo, "No.");
                            end;
                        Type::Employee:
                            begin
                                RecId := Employee.RecordId;
                                CreateDim(RecId.TableNo, "No.");
                            end;
                    end;
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate();
            begin
                TestStatusOpen();
                CheckLocation();

                if (Type = Type::Item) and ("No." <> '') and (Quantity > 0) then
                    UpdateDirectUnitCost(FieldNo("Location Code"));
            end;
        }
        field(10; "Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(11; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";
            ValidateTableRelation = false;

            trigger OnValidate();
            var
                Item: Record Item;
                FindRecordMgt: Codeunit "Find Record Management";
                ReturnValue:
                        Text;
            begin
                TestStatusOpen();

                if Type = Type::" " then
                    exit;

                if (Type = Type::Item) and ("No." <> '') then begin
                    Item.SetFilter(Description, '''@' + ConvertStr(Description, '''', '?') + '''');
                    if not Item.FindFirst() then
                        exit;
                    if Item."No." = "No." then
                        exit;
                    if Confirm(AnotherItemWithSameDescrQst, false, Item."No.", Item.Description) then
                        Validate("No.", Item."No.");
                end else
                    if "No." = '' then
                        if FindRecordMgt.FindRecordByDescription(ReturnValue, Type.AsInteger(), Description) = 1 then begin
                            CurrFieldNo := FieldNo("No.");
                            Validate("No.", CopyStr(ReturnValue, 1, MaxStrLen("No.")));
                        end;
            end;
        }
        field(12; "Description 2"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description 2';

            trigger OnValidate();
            begin
                TestStatusOpen();
            end;
        }
        field(13; "Unit of Measure"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure';
        }
        field(15; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TestStatusOpen();

                GetReqHeader();
                if ReqHeader."Request Code" <> '' then begin
                    Validate("Request Code", ReqHeader."Request Code");
                    CheckRequestCode();
                end;

                if "Quantity Processed" > Quantity then
                    FieldError(Quantity);

                "Quantity (Base)" := CalcBaseQty(Quantity);

                if Type = Type::Item then
                    UpdateDirectUnitCost(FieldNo(Quantity));

                UpdateAmounts();

                if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") or
                   ("No." = xRec."No.")
                then begin
                    InitOutstanding();
                    InitQtyToReceive();
                end;
            end;
        }
        field(16; "Outstanding Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Outstanding Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; "Qty. to Process"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. to Process';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                CalcFields("Quantity Processed");
                if "Qty. to Process" = Quantity - "Quantity Processed" then
                    InitQtyToReceive()
                else
                    "Qty. to Process (Base)" := CalcBaseQty("Qty. to Process");

                if ((("Qty. to Process" < 0) xor (Quantity < 0)) and (Quantity <> 0) and ("Qty. to Process" <> 0)) or
                   (Abs("Qty. to Process") > Abs("Outstanding Quantity")) or
                   (((Quantity < 0) xor ("Outstanding Quantity" < 0)) and (Quantity <> 0) and ("Outstanding Quantity" <> 0))
                then
                    Error(
                      ProcessMoreUnitErr,
                      "Outstanding Quantity");
                if ((("Qty. to Process (Base)" < 0) xor ("Quantity (Base)" < 0)) and ("Quantity (Base)" <> 0) and ("Qty. to Process (Base)" <> 0)) or
                   (Abs("Qty. to Process (Base)") > Abs("Outstanding Qty. (Base)")) or
                   ((("Quantity (Base)" < 0) xor ("Outstanding Qty. (Base)" < 0)) and ("Quantity (Base)" <> 0) and ("Outstanding Qty. (Base)" <> 0))
                then
                    Error(
                      ProcessMoreBaseUnitErr,
                      "Outstanding Qty. (Base)");
            end;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';

            trigger OnValidate();
            begin
                TestStatusOpen();

                if not ("Request Type" in ["Request Type"::Purchase, "Request Type"::"Item Journal", "Request Type"::"Req. Worksheet", "Request Type"::"General Journal"]) then
                    TestField("Direct Unit Cost", 0);

                UpdateAmounts();
            end;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(45; "Job No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Job No.';
            TableRelation = Job;
        }
        field(60; "Quantity Processed"; Decimal)
        {
            CalcFormula = Sum(PPHRDS_ProcessedRequestEntry.Quantity WHERE("Request No." = FIELD("Document No."),
                                                                            "Request Line No." = FIELD("Line No."),
                                                                            Status = CONST(Processed)));
            Caption = 'Quantity Processed';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Vendor Item No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Item No.';
        }
        field(91; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;

            trigger OnValidate()
            begin
                TestField("Request Type", "Request Type"::"General Journal");
            end;
        }
        field(100; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;

            trigger OnValidate();
            begin
                TestStatusOpen();
            end;
        }
        field(103; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Line Amount';

            trigger OnValidate();
            begin
                TestStatusOpen();

                TestField(Type);
                TestField(Quantity);
                TestField("Direct Unit Cost");

                GetReqHeader();
                "Line Amount" := Round("Line Amount", Currency."Amount Rounding Precision");
            end;
        }
        field(107; "IC Partner Ref. Type"; Enum "IC Partner Reference Type")
        {
            AccessByPermission = TableData "IC G/L Account" = R;
            Caption = 'IC Partner Ref. Type';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "IC Partner Code" <> '' then
                    "IC Partner Ref. Type" := "IC Partner Ref. Type"::"G/L Account";
                if "IC Partner Ref. Type" <> xRec."IC Partner Ref. Type" then
                    "IC Partner Reference" := '';
                if "IC Partner Ref. Type" = "IC Partner Ref. Type"::"Common Item No." then begin
                    GetItem(Item);
                    Item.TestField("Common Item No.");
                    "IC Partner Reference" := Item."Common Item No.";
                end;
            end;
        }
        field(108; "IC Partner Reference"; Code[20])
        {
            AccessByPermission = TableData "IC G/L Account" = R;
            Caption = 'IC Partner Reference';

            trigger OnLookup()
            var
                ICGLAccount: Record "IC G/L Account";
                Item: Record Item;
                ItemVendorCatalog: Record "Item Vendor";
            begin
                if "No." <> '' then
                    case "IC Partner Ref. Type" of
                        "IC Partner Ref. Type"::"G/L Account":
                            begin
                                if ICGLAccount.Get("IC Partner Reference") then;
                                if PAGE.RunModal(PAGE::"IC G/L Account List", ICGLAccount) = ACTION::LookupOK then
                                    Validate("IC Partner Reference", ICGLAccount."No.");
                            end;
                        "IC Partner Ref. Type"::Item:
                            begin
                                if Item.Get("IC Partner Reference") then;
                                if PAGE.RunModal(PAGE::"Item List", Item) = ACTION::LookupOK then
                                    Validate("IC Partner Reference", Item."No.");
                            end;
                        "IC Partner Ref. Type"::"Vendor Item No.":
                            begin
                                ItemVendorCatalog.SetCurrentKey("Vendor No.");
                                ItemVendorCatalog.SetRange("Vendor No.", Rec."Vendor No.");
                                if PAGE.RunModal(PAGE::"Vendor Item Catalog", ItemVendorCatalog) = ACTION::LookupOK then
                                    Validate("IC Partner Reference", ItemVendorCatalog."Vendor Item No.");
                            end;
                    end;
            end;
        }
        field(120; Status; Enum PPHRDS_ReqHeaderStatus)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(125; "Buy-from IC Partner Code"; Code[20])
        {
            Caption = 'Buy-from IC Partner Code';
            Editable = false;
            TableRelation = "IC Partner";
        }
        field(126; "Pay-to IC Partner Code"; Code[20])
        {
            Caption = 'Pay-to IC Partner Code';
            Editable = false;
            TableRelation = "IC Partner";
        }
        field(130; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";
            trigger OnValidate()
            begin
                if Rec."IC Partner Code" <> '' then begin
                    Rec.TestField(Type, Type::"G/L Account");
                    Rec.Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::"G/L Account");
                end;
            end;
        }
        field(138; "IC Item Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'IC Item Reference No.';

            trigger OnLookup()
            var
                ItemReference: Record "Item Reference";
                ItemVendorCatalog: Record "Item Vendor";
            begin
                if "No." <> '' then
                    case "IC Partner Ref. Type" of
                        "IC Partner Ref. Type"::"Cross Reference":
                            begin
                                ItemReference.Reset();
                                ItemReference.SetCurrentKey("Reference Type", "Reference Type No.");
                                ItemReference.SetFilter(
                                    "Reference Type", '%1|%2',
                                    ItemReference."Reference Type"::Vendor, ItemReference."Reference Type"::" ");
                                ItemReference.SetFilter("Reference Type No.", '%1|%2', Rec."Vendor No.", '');
                                if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) = ACTION::LookupOK then
                                    Rec.Validate("IC Item Reference No.", ItemReference."Reference No.");
                            end;
                        "IC Partner Ref. Type"::"Vendor Item No.":
                            begin
                                ItemVendorCatalog.SetCurrentKey("Vendor No.");
                                ItemVendorCatalog.SetRange("Vendor No.", Rec."Vendor No.");
                                if PAGE.RunModal(PAGE::"Vendor Item Catalog", ItemVendorCatalog) = ACTION::LookupOK then
                                    Rec.Validate("IC Item Reference No.", ItemVendorCatalog."Vendor Item No.");
                            end;
                    end;
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDimensions();
            end;
        }
        field(501; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate();
            var
                Vendor: Record Vendor;
            begin
                if not ("Request Type" in ["Request Type"::Purchase, "Request Type"::"Req. Worksheet"]) then
                    FieldError("Request Type");

                if Vendor.Get("Vendor No.") then
                    "Vendor Name" := Vendor.Name
                else
                    "Vendor Name" := '';
            end;
        }
        field(521; "Transfer-from Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                RequestCode: Record PPHRDS_RequestCode;
            begin
                RequestCode.Get("Request Code");
                if RequestCode."Transfer-from Code" <> '' then
                    TestField("Transfer-from Code", RequestCode."Transfer-from Code");

                if "Transfer-from Code" = "Location Code" then
                    Error(TransferSameCodeErr, "Request Code", RequestCode."Transfer-from Code");
            end;
        }
        field(502; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Name';
            Editable = false;
        }
        field(551; Notes; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Notes';
        }
        field(1001; "Job Task No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."), Blocked = const(false), "Purchasing Blocked" = const(false))
            else
            if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."), Blocked = const(false));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
                RequestTypeErr: Label 'Request Type can only be either Purchase, Transfer Order or Item Journal';
            begin
                Rec.TestField(Type, Rec.Type::Item);

                if Rec."Variant Code" = '' then
                    exit;

                if not (Rec."Request Type" in [Rec."Request Type"::Purchase, Rec."Request Type"::"Transfer Order", Rec."Request Type"::"Item Journal"]) then
                    Error(RequestTypeErr);

                ItemVariant.SetLoadFields("Purchasing Blocked");
                ItemVariant.Get(Rec."No.", Rec."Variant Code");
                if Rec."Request Type" = Rec."Request Type"::Purchase then
                    ItemVariant.Testfield("Purchasing Blocked", false);

                TestStatusOpen();

                if xRec."Variant Code" <> Rec."Variant Code" then
                    TestField("Quantity Processed", 0);
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';

            trigger OnLookup();
            begin
                LookupUnitOfMeasureCode();
            end;

            trigger OnValidate();
            begin
                TestStatusOpen();

                if Type in [Type::Vendor, Type::Employee] then
                    TestField("Unit of Measure Code", '');

                if "Quantity Processed" > 0 then
                    FieldError("Unit of Measure Code");

                if "Unit of Measure Code" = '' then
                    "Unit of Measure" := ''
                else begin
                    UnitOfMeasure.Get("Unit of Measure Code");
                    "Unit of Measure" := UnitOfMeasure.Description;
                end;

                if (Type = Type::Item) and ("No." <> '') then begin
                    GetItem(Item);
                    "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                end else
                    "Qty. per Unit of Measure" := 1;

                if Type = Type::Item then
                    UpdateDirectUnitCost(FieldNo("Unit of Measure Code"));
            end;
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");

                if Type = Type::Item then
                    UpdateDirectUnitCost(FieldNo("Quantity (Base)"));
            end;
        }
        field(5416; "Outstanding Qty. (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5418; "Qty. to Process (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. to Process (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate();
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Process", "Qty. to Process (Base)");
            end;
        }
        field(5461; "Qty. Processed (Base)"; Decimal)
        {
            CalcFormula = Sum(PPHRDS_ProcessedRequestEntry."Quantity (Base)" WHERE("Request No." = FIELD("Document No."),
                                                                                    "Request Line No." = FIELD("Line No."),
                                                                                    Status = CONST(Processed)));
            Caption = 'Qty. Processed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5725; "Item Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Item Reference No.';
            ExtendedDatatype = Barcode;

            trigger OnLookup()
            var
                ItemReferenceMgt: codeunit "Item Reference Management";
                ItemRefMgt: codeunit PPHRDS_ItemReferenceMgt;
            begin
                IsValidReqCode();
                GetReqHeader();
                ItemRefMgt.PurchaseReferenceNoLookUp(Rec, ReqHeader);
            end;

            trigger OnValidate()
            var
                ItemReference: Record "Item Reference";
                ItemRefMgt: codeunit PPHRDS_ItemReferenceMgt;
            begin
                IsValidReqCode();
                GetReqHeader();
                ItemRefMgt.ValidateReqReferenceNo(Rec, ReqHeader, ItemReference, true, CurrFieldNo);
            end;
        }
        field(5726; "Item Reference Unit of Measure"; Code[10])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Item Reference Unit of Measure';
            TableRelation = if (Type = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(5727; "Item Reference Type"; Enum "Item Reference Type")
        {
            Caption = 'Item Reference Type';
        }
        field(5728; "Item Reference Type No."; Code[30])
        {
            Caption = 'Item Reference Type No.';
        }
        field(5752; "Completely Processed"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Completely Requested';
            Editable = false;
        }
        field(6015; "Request Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Date';
        }
        field(6030; "Request Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Code';
            TableRelation = PPHRDS_RequestCode WHERE(Active = CONST(true));

            trigger OnValidate();
            begin
                TestStatusOpen();

                if Type = Type::" " then
                    FieldError("Request Code");

                CheckRequestCode();
                if RequestCode.Get("Request Code") then
                    "Request Description" := RequestCode.Description
                else
                    "Request Description" := '';
                "Request Type" := RequestCode.Type;
                "Request Purch. Document Type" := RequestCode."Purchase Document Type";
                "Transfer-from Code" := RequestCode."Transfer-from Code";
                "Journal Template Name" := RequestCode."Journal Template Name";

                CheckTypeCombination();

                if ("No." <> '') and IsNonInventoriableItem() and ("Request Purch. Document Type" = "Request Purch. Document Type"::" ") then
                    FieldError("Request Code");

                if "Request Type" = "Request Type"::"Transfer Order" then
                    Validate("Direct Unit Cost", 0);
            end;
        }
        field(6031; "Request Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Description';
        }
        field(6032; "Request Type"; Enum PPHRDS_RequestType)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Type';
        }
        field(6033; "Request Purch. Document Type"; Enum PPHRDS_RequestPurchDocType)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Purch. Document Type';
        }
        field(6043; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(6044; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch";
        }
        field(6045; "Expense G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Expense G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(6100; "Applies-to Purch. Doc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Applies-to Purch. Doc. No.';

            trigger OnLookup();
            begin
                LookupAppliesToPurchDoc();
            end;

            trigger OnValidate();
            begin
                TestStatusOpen();

                CheckAppliesToPurchDoc();
            end;
        }
        field(8000; Budget; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Budget';
        }
        field(8001; "Budget Remaining"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Budget Remaining';
        }
        field(9000; Select; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Select';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
        }
        key(Key2; "Request Type", Type, "No.", "Job No.", "Job Task No.", "Location Code", "Request Date", Status, "Dimension Set ID")
        {
            SumIndexFields = Quantity, "Quantity (Base)", "Outstanding Quantity", "Outstanding Qty. (Base)", "Line Amount";
        }
        key(Key3; "Document No.", "Expected Receipt Date", "Request Code", "Vendor No.", "Location Code")
        {
        }
        key(Key4; Type, "Document No.")
        {
            SumIndexFields = "Line Amount";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        TestStatusOpen();
    end;

    trigger OnInsert();
    begin
        TestStatusOpen();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        RequestSetup: Record PPHRDS_ReqDocSysSetup;
        ReqHeader: Record PPHRDS_ReqHeader;
        StandardText: Record "Standard Text";
        GLAcc: Record "G/L Account";
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
        Vendor: Record Vendor;
        Employee: Record Employee;
        UnitOfMeasure: Record "Unit of Measure";
        Currency: Record Currency;
        RequestCode: Record PPHRDS_RequestCode;
        PurchaseHeader: Record "Purchase Header";
        UOMMgt: Codeunit "Unit of Measure Management";
        DimMgt: Codeunit DimensionManagement;
        RequestBudgetManagement: Codeunit PPHRDS_RequestBudgetManagement;
        TransferfromCodeErr: Label 'The Transfer-from Code in Request Code %1 must be different from Location Code %2.', Comment = '%1 = Request Code, %2 = Location Code';
        TransferSameCodeErr: Label 'The Transfer-from Code in Request Code %1 must be different from Transfer-to Code %2.', Comment = '%1 = Request Code, %2 = Transfer-to Code';
        ProcessMoreUnitErr: Label 'You cannot process more than %1 units.', Comment = '%1 = Outstanding Quantity';
        ProcessMoreBaseUnitErr: Label 'You cannot process more than %1 base units.', Comment = '%1 = Outstanding Qty. (Base)';
        AnotherItemWithSameDescrQst: Label 'Item No. %1 also has the description "%2".\Do you want to change the current item no. to %1?', Comment = '%1=Item no., %2=item description';

    procedure InitOutstanding();
    begin
        CalcFields("Quantity Processed");
        "Outstanding Quantity" := Quantity - "Quantity Processed";
        CalcFields("Qty. Processed (Base)");
        "Outstanding Qty. (Base)" := "Quantity (Base)" - "Qty. Processed (Base)";
        "Completely Processed" := (Quantity <> 0) and ("Outstanding Quantity" = 0);
    end;

    procedure InitQtyToReceive();
    begin
        "Qty. to Process" := "Outstanding Quantity";
        "Qty. to Process (Base)" := "Outstanding Qty. (Base)";
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal;
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetGLSetup();
    begin
        GLSetup.Get();
    end;

    local procedure GetReqHeader();
    begin
        TestField("Document No.");

        ReqHeader.Get("Document No.");
        // if ReqHeader."Currency Code" = '' then
        //     Currency.InitRoundingPrecision()
        // else begin
        //     ReqHeader.TestField("Currency Factor");
        //     Currency.Get(ReqHeader."Currency Code");
        //     Currency.TestField("Amount Rounding Precision");
        // end;
    end;

    local procedure GetItem(var parItem: Record Item)
    begin
        TestField("No.");
        if Type = Type::Item then
            parItem.Get("No.");
    end;

    // local procedure ItemIsNonInventoriableType(var parItem: Record Item): Boolean
    // begin
    //     EXIT(parItem.Type IN [parItem.Type::"Non-Inventory", parItem.Type::Service]);
    // end;

    local procedure UpdateDirectUnitCost(CalledByFieldNo: Integer);
    var
        TempRequisitionLine: Record "Requisition Line" temporary;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDirectUnitCost(CalledByFieldNo, CurrFieldNo, Rec, IsHandled);
        if IsHandled then
            exit;

        if (CurrFieldNo <> 0) then
            UpdateAmounts();

        if ((CalledByFieldNo <> CurrFieldNo) and (CurrFieldNo <> 0)) then
            exit;

        if IsNonInventoriableItem() then
            exit;

        if Type = Type::Item then begin
            TempRequisitionLine.DeleteAll();
            TempRequisitionLine.Init();
            TempRequisitionLine.Validate(Type, TempRequisitionLine.Type::Item);
            if "No." <> '' then
                TempRequisitionLine.Validate("No.", "No.");
            if "Unit of Measure Code" <> '' then
                TempRequisitionLine.Validate("Unit of Measure Code", "Unit of Measure Code");
            if "Vendor No." <> '' then
                TempRequisitionLine.Validate("Vendor No.", "Vendor No.");
            if "Expected Receipt Date" <> 0D then
                TempRequisitionLine.Validate("Order Date", "Expected Receipt Date");
            if "Currency Code" <> '' then
                TempRequisitionLine.Validate("Currency Code", "Currency Code");

            OnBeforeUpdateDirectUnitCostValue(TempRequisitionLine, Rec);
            if "Request Type" in ["Request Type"::Purchase, "Request Type"::"Item Journal", "Request Type"::"Req. Worksheet"] then
                Validate("Direct Unit Cost", TempRequisitionLine."Direct Unit Cost")
            else
                Validate("Direct Unit Cost", 0);
            OnAfterUpdateDirectUnitCostValue(TempRequisitionLine, Rec);
        end;

        OnAfterUpdateDirectUnitCost(CalledByFieldNo, CurrFieldNo, Rec);
    end;

    procedure UpdateAmounts();
    begin
        GetReqHeader();

        if "Line Amount" <> Round(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision") then
            "Line Amount" := Round(Quantity * "Direct Unit Cost", Currency."Amount Rounding Precision");

        OnAfterUpdateAmounts(Rec, xRec);
    end;

    procedure ShowDimensions();
    var
        CaptionFormatLbl: Label '%1 %2 %3', Comment = '%1 = Table Name, %2 = Document No., %3 = Line No.';
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo(CaptionFormatLbl, TableCaption, "Document No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        // UpdateHeaderDimension();
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]);
    var
        SourceCodeSetup: Record "Source Code Setup";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        SourceCodeSetup.Get();
        DimMgt.AddDimSource(DefaultDimSource, Type1, No1);
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetReqHeader();
        "Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", ReqHeader."Dimension Set ID", 0);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20]);
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    local procedure TestStatusOpen();
    begin
        GetReqHeader();
        ReqHeader.TestField(Status, ReqHeader.Status::Open);
    end;

    procedure HasTypeToFillMandatotyFields(): Boolean;
    begin
        exit(Type <> Type::" ");
    end;

    local procedure FindNoFromTypedValue(Value: Code[20]): Code[20];
    begin
        case Type of
            Type::Item:
                exit(Item.GetItemNo(Value));
            else
                exit("No.");
        end;
    end;

    procedure LookupUnitOfMeasureCode();
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (Type = Type::Item) and ("No." <> '') then begin
            ItemUnitOfMeasure.SetRange("Item No.", "No.");
            if PAGE.RunModal(0, ItemUnitOfMeasure) = ACTION::LookupOK then
                Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
        end else
            if PAGE.RunModal(0, UnitOfMeasure) = ACTION::LookupOK then
                Validate("Unit of Measure Code", UnitOfMeasure.Code);
    end;

    local procedure LookupAppliesToPurchDoc();
    begin
        PurchaseHeader.Reset();
        case "Request Purch. Document Type" of
            "Request Purch. Document Type"::Quote:
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Quote);
            "Request Purch. Document Type"::Order:
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
            "Request Purch. Document Type"::Invoice:
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        end;
        PurchaseHeader.SetRange("Buy-from Vendor No.", "Vendor No.");
        PurchaseHeader.SetRange(Status, Status::Open);
        if PAGE.RunModal(0, PurchaseHeader) = ACTION::LookupOK then
            Validate("Applies-to Purch. Doc. No.", PurchaseHeader."No.");
    end;

    procedure InitReqLineType()
    begin
        if not ReqHeader.Get("Document No.") then
            exit;

        if "Document No." <> '' then
            Validate(Type, xRec.Type);
    end;

    procedure ClearReqHeader();
    begin
        Clear(ReqHeader);
    end;

    local procedure CheckRequestCode();
    begin
        if not RequestCode.Get("Request Code") then
            exit;

        RequestCode.TestField(Active, true);

        if (RequestCode.Type = RequestCode.Type::"Transfer Order") and (Type in [Type::"G/L Account", Type::"Fixed Asset"]) then
            TestField(Type, Type::Item);

        if (RequestCode.Type = RequestCode.Type::"General Journal") and (not (Type in [Type::Vendor, Type::Employee])) then
            FieldError(Type);
    end;

    local procedure CheckAppliesToPurchDoc();
    begin
        if "Applies-to Purch. Doc. No." = '' then
            exit;

        TestField("Request Type", "Request Type"::Purchase);

        case "Request Purch. Document Type" of
            "Request Purch. Document Type"::Quote:
                PurchaseHeader.Get(PurchaseHeader."Document Type"::Quote, "Applies-to Purch. Doc. No.");
            "Request Purch. Document Type"::Order:
                PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, "Applies-to Purch. Doc. No.");
            "Request Purch. Document Type"::Invoice:
                PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, "Applies-to Purch. Doc. No.");
        end;
    end;

    local procedure GetReqSetup();
    begin
        RequestSetup.Get();
    end;

    local procedure CheckTypeCombination()
    begin
        if "Request Code" = '' then
            exit;

        case Type of
            Type::"G/L Account":
                if not ("Request Type" in ["Request Type"::Purchase, "Request Type"::"Req. Worksheet"]) then
                    FieldError(Type);
            Type::"Fixed Asset":
                if not ("Request Type" in ["Request Type"::Purchase]) then
                    FieldError(Type);
            Type::Vendor, Type::Employee:
                TestField("Request Type", "Request Type"::"General Journal");
        end;
    end;

    procedure CheckLocation();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();

        if Type in [Type::Vendor, Type::Employee] then
            TestField("Location Code", '');

        if "Location Code" <> '' then
            if IsNonInventoriableItem() then begin
                GetItem(Item);
                Item.TestField(Type, Item.Type::Inventory);
            end;

        if "Location Code" = '' then
            if (Type = Type::Item) and (not IsNonInventoriableItem()) and InventorySetup."Location Mandatory" then
                TestField("Location Code");

        if "Request Type" = "Request Type"::"Transfer Order" then begin
            TestField("Location Code");
            if RequestCode.Get("Request Code") and (RequestCode."Transfer-from Code" = "Location Code") then
                Error(TransferfromCodeErr, "Request Code", RequestCode."Transfer-from Code");
        end;
    end;

    procedure BudgetValue(): Decimal;
    begin
        if (Type in [Type::"G/L Account", Type::Item, Type::"Fixed Asset"]) and ("No." <> '') then
            exit(RequestBudgetManagement.GetBudget(Rec));
    end;

    procedure ActualValue(): Decimal;
    begin
        if (Type in [Type::"G/L Account", Type::Item, Type::"Fixed Asset"]) and ("No." <> '') then
            exit(RequestBudgetManagement.GetActual(Rec));
    end;

    procedure ReleasedValue(): Decimal;
    begin
        if (Type in [Type::"G/L Account", Type::Item, Type::"Fixed Asset"]) and ("No." <> '') then
            exit(RequestBudgetManagement.GetReleased(Rec));
    end;

    procedure PurchaseValue(): Decimal;
    begin
        if (Type in [Type::"G/L Account", Type::Item, Type::"Fixed Asset"]) and ("No." <> '') then
            exit(RequestBudgetManagement.GetPurchase(Rec));
    end;

    procedure CurrLineValue(): Decimal;
    begin
        if (Type in [Type::"G/L Account", Type::Item, Type::"Fixed Asset"]) and ("No." <> '') then
            exit(RequestBudgetManagement.GetCurrentLineValue(Rec));
    end;

    procedure BudgetDimensions(var varDimensionCode: array[8] of Code[20]; var varDimensionValueCode: array[8] of Code[20]) DimensionFound: Boolean;
    var
        GLBudgetName: Record "G/L Budget Name";
        DimensionSetEntry: Record "Dimension Set Entry";
        BudgetDimensionCtr: Integer;
    begin
        GetGLSetup();
        GetReqSetup();
        DimensionFound := false;

        Clear(varDimensionCode);
        Clear(varDimensionValueCode);

        case Type of
            Type::"G/L Account":
                begin
                    if GLBudgetName.Get(RequestSetup."G/L Budget Name") then;
                    varDimensionCode[1] := GLBudgetName."Budget Dimension 1 Code";
                    varDimensionCode[2] := GLBudgetName."Budget Dimension 2 Code";
                    varDimensionCode[3] := GLBudgetName."Budget Dimension 3 Code";
                    varDimensionCode[4] := GLBudgetName."Budget Dimension 4 Code";
                    varDimensionCode[5] := GLSetup."Global Dimension 1 Code";
                    varDimensionCode[6] := GLSetup."Global Dimension 2 Code";
                    for BudgetDimensionCtr := 1 to 4 do begin
                        if DimensionSetEntry.Get("Dimension Set ID", varDimensionCode[BudgetDimensionCtr]) then
                            varDimensionValueCode[BudgetDimensionCtr] := DimensionSetEntry."Dimension Value Code";
                        if varDimensionValueCode[BudgetDimensionCtr] <> '' then
                            DimensionFound := true;
                    end;
                    for BudgetDimensionCtr := 5 to 6 do begin
                        if DimensionSetEntry.Get("Dimension Set ID", varDimensionCode[BudgetDimensionCtr]) then
                            varDimensionValueCode[BudgetDimensionCtr] := DimensionSetEntry."Dimension Value Code";
                        if varDimensionValueCode[BudgetDimensionCtr] <> '' then
                            DimensionFound := true;
                    end;
                end;
            Type::Item:
                DimensionFound := true;
            Type::"Fixed Asset":
                DimensionFound := true;
        end;
    end;

    procedure IsNonInventoriableItem(): Boolean
    begin
        if Type <> Type::Item then
            exit(false);
        if "No." = '' then
            exit(false);
        GetItem(Item);
        exit(item.IsNonInventoriableType());
    end;

    procedure ShowItemByLocation(ItemNo: Code[20]);
    begin
        if Type = Type::Item then begin
            Item.Get("No.");
            PAGE.Run(PAGE::"Items by Location", Item);
        end;
    end;

    local procedure GetLineWithCalculatedPrice(var PriceCalculation: Interface "Price Calculation")
    var
        Line: Variant;
    begin
        PriceCalculation.GetLine(Line);
        Rec := Line;
    end;

    local procedure IsValidReqCode()
    var
        RequestCode: Record PPHRDS_RequestCode;
    begin
        Rec.TestField("Request Code");

        RequestCode.SetLoadFields(Code, Type);
        RequestCode.Get(Rec."Request Code");
        if RequestCode.Type <> RequestCode.Type::"General Journal" then
            Error('Request Code %1 is not valid. You cannot use a Request Code of type General Journal.', Rec."Request Code");
    end;

    procedure GetDateForCalculations() CalculationDate: Date;
    var
        FromReqHeader: Record PPHRDS_ReqHeader;
    begin
        if Rec."Document No." = '' then
            exit(WorkDate());

        GetReqHeader();
        FromReqHeader := ReqHeader;
        CalculationDate := GetDateForCalculations(FromReqHeader);
    end;

    procedure GetDateForCalculations(FromReqHeader: Record PPHRDS_ReqHeader) CalculationDate: Date;
    begin
        CalculationDate := FromReqHeader."Posting Date";

        if CalculationDate = 0D then
            CalculationDate := WorkDate();
    end;

    procedure SetReqhHeader(NewReqHeader: Record PPHRDS_ReqHeader)
    begin
        ReqHeader := NewReqHeader;
    end;

    procedure SetVendorItemNo()
    var
        Item: Record Item;
        ItemVend: Record "Item Vendor";
    begin
        GetItem(Item);
        ItemVend.Init();
        ItemVend."Vendor No." := Rec."Vendor No.";
        ItemVend."Variant Code" := Rec."Variant Code";
        Item.FindItemVend(ItemVend, "Location Code");
        Rec.Validate("Vendor Item No.", ItemVend."Vendor Item No.");
    end;

    procedure UpdateICPartner()
    var
        ICPartner: Record "IC Partner";
    begin
        if rec."IC Partner Code" = '' then
            exit;

        case Rec.Type of
            Rec.Type::" ":
                begin
                    Rec."IC Partner Ref. Type" := Type;
                    Rec."IC Partner Reference" := "No.";
                end;
            Rec.Type::"G/L Account":
                begin
                    "IC Partner Ref. Type" := Type;
                    "IC Partner Reference" := GLAcc."Default IC Partner G/L Acc. No";
                end;
            Rec.Type::Item:
                begin
                    ICPartner.Get(Rec."Buy-from IC Partner Code");
                    case ICPartner."Outbound Purch. Item No. Type" of
                        ICPartner."Outbound Purch. Item No. Type"::"Common Item No.":
                            Rec.Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::"Common Item No.");
                        ICPartner."Outbound Purch. Item No. Type"::"Internal No.":
                            begin
                                Rec.Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::Item);
                                Rec."IC Partner Reference" := "No.";
                            end;
                        ICPartner."Outbound Purch. Item No. Type"::"Cross Reference":
                            begin
                                Rec.Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::"Cross Reference");
                                UpdateICPartnerItemReference();
                            end;
                        ICPartner."Outbound Purch. Item No. Type"::"Vendor Item No.":
                            begin
                                "IC Partner Ref. Type" := "IC Partner Ref. Type"::"Vendor Item No.";
                                "IC Item Reference No." := "Vendor Item No.";
                            end;
                    end;
                end;
            Type::"Fixed Asset":
                begin
                    "IC Partner Ref. Type" := "IC Partner Ref. Type"::" ";
                    "IC Partner Reference" := '';
                end;

        end;
    end;

    local procedure UpdateICPartnerItemReference()
    var
        ItemReference: Record "Item Reference";
        ToDate: Date;
    begin
        ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", Rec."Vendor No.");
        ItemReference.SetRange("Item No.", "No.");
        ItemReference.SetRange("Variant Code", "Variant Code");
        ItemReference.SetRange("Unit of Measure", "Unit of Measure Code");
        ToDate := Rec.GetDateForCalculations();
        if ToDate <> 0D then begin
            ItemReference.SetFilter("Starting Date", '<=%1', ToDate);
            ItemReference.SetFilter("Ending Date", '>=%1|%2', ToDate, 0D);
        end;
        if ItemReference.FindFirst() then
            "IC Item Reference No." := ItemReference."Reference No."
        else
            "IC Partner Reference" := "No.";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmounts(var ReqLine: Record PPHRDS_ReqLine; var xReqLine: Record PPHRDS_ReqLine);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDirectUnitCost(CalledByFieldNo: Integer; CurrFieldNo: Integer; var ReqLine: Record PPHRDS_ReqLine; var IsHandled: Boolean);
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDirectUnitCostValue(var TempRequisitionLine: Record "Requisition Line" temporary; var ReqLine: Record PPHRDS_ReqLine);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDirectUnitCostValue(var TempRequisitionLine: Record "Requisition Line" temporary; var ReqLine: Record PPHRDS_ReqLine);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDirectUnitCost(CalledByFieldNo: Integer; CurrFieldNo: Integer; var ReqLine: Record PPHRDS_ReqLine);
    begin

    end;
}

