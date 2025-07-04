table 70829636 PPHRDS_ProcessedReqLine
{
    Caption = 'Processed Req. Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Document No.';
            Editable = false;
            TableRelation = PPHRDS_ProcessedReqHeader."No.";
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
        }
        field(6; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
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
            ValidateTableRelation = false;
        }
        field(7; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
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
        }
        field(12; "Description 2"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description 2';
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
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
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
        field(91; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(100; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(103; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Line Amount';
        }
        field(120; Status; Enum PPHRDS_ReqHeaderStatus)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(501; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(502; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Name';
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
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
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
        }
        field(5460; "Qty. Processed (Base)"; Decimal)
        {
            CalcFormula = Sum(PPHRDS_ProcessedRequestEntry."Quantity (Base)" WHERE("Request No." = FIELD("Document No."),
                                                                                     "Request Line No." = FIELD("Line No."),
                                                                                     Status = CONST(Processed)));
            Caption = 'Qty. Processed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
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
        field(9000; "Processed Request Entry Status"; Enum PPHRDS_ProcessedRequestStatus)
        {
            Caption = 'Status';
            FieldClass = FlowField;
            CalcFormula = lookup(PPHRDS_ProcessedRequestEntry.Status where("Processed Request No." = field("Document No."), "Processed Request Line No." = field("Line No.")));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;

    procedure ShowDimensions();
    var
        CaptionFormatLbl: Label '%1 %2 %3', Comment = '%1 = Table Caption, %2 = Document No. field, %3 = Line No. field';
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(CaptionFormatLbl, TableCaption, "Document No.", "Line No."));
    end;
}

