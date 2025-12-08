table 70829600 PPHRDS_ProcessedRequestEntry
{
    Caption = 'Processed Request Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
        }
        field(2; "Request No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Request No.';
        }
        field(3; "Request Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Line No.';
        }
        field(4; "Processed Request No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Request No.';
        }
        field(5; "Processed Request Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Request Line No.';
        }
        field(11; "Requestor ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor ID';
        }
        field(12; "Requestor Name"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor Name';
        }
        field(13; "Purchaser Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(14; "Request Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Date';
        }
        field(15; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(16; "Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(17; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(18; "Currency Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(21; "Request Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Code';
        }
        field(22; "Request Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Description';
        }
        field(23; "Request Type"; Enum PPHRDS_RequestType)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Type';
        }
        field(31; Type; Enum PPHRDS_ReqLineType)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(32; "No."; Code[20])
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
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";
            ValidateTableRelation = false;
        }
        field(33; Description; Text[100])
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
        field(34; "Description 2"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description 2';
        }
        field(35; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(37; "Unit of Measure"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure';
        }
        field(38; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(39; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(40; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(41; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
        }
        field(42; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Requestor ID";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(43; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Line Amount';
        }
        field(46; "Job No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Job No.';
        }
        field(47; "Job Task No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Task No.';
        }
        field(51; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(52; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Name';
        }
        field(68; "Processor User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Processor User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(69; Status; Enum PPHRDS_ProcessedRequestStatus)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(70; "Processed SystemId"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed SystemId';
        }
        field(71; "Purchase Document Type"; Enum "Purchase Document Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Document Type';
        }
        field(72; "Purchase Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Document No.';
        }
        field(73; "Purchase Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Document Line No.';
        }
        field(76; "Transfer Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Order No.';
        }
        field(77; "Transfer Order Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Order Line No.';
        }
        field(81; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Template Name';
        }
        field(82; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Batch Name';
        }
        field(83; "Journal Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Line No.';
        }
        field(84; "Journal Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Document No.';
        }
        field(111; Notes; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Notes';
        }
        field(121; "Original Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Quantity';
        }
        field(301; "Generated Fixed Asset No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Generated Fixed Asset No.';
            Editable = false;
        }
        field(478; "Processed SystemId (Header)"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed SystemId (Header)';
            Editable = false;
        }
        field(479; "Dimension Set ID (Header)"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID (Header)';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Request No.", "Request Line No.")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }
}

