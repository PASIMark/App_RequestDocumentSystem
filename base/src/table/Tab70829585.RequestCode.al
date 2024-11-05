table 70829585 "PPHRDS_RequestCode"
{
    Caption = 'Request Code';
    LookupPageID = PPHRDS_RequestCodes;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(7; Type; Enum PPHRDS_RequestType)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(21; "Purchase Document Type"; Enum PPHRDS_RequestPurchDocType)
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Document Type';
        }
        field(35; "Purch. Quote Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Quote Nos.';

            trigger OnValidate();
            begin
                TestField(Type, Type::Purchase);
                TestField("Purchase Document Type", "Purchase Document Type"::Quote);
            end;
        }
        field(36; "Purch. Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Nos.';

            trigger OnValidate();
            begin
                TestField(Type, Type::Purchase);
                TestField("Purchase Document Type", "Purchase Document Type"::Order);
            end;
        }
        field(38; "Purch. Invoice Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Invoice Nos.';

            trigger OnValidate();
            begin
                TestField(Type, Type::Purchase);
                TestField("Purchase Document Type", "Purchase Document Type"::Invoice);
            end;
        }
        field(41; "Transfer-from Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate();
            begin
                "Transfer-from Name" := GetLocationName("Transfer-from Code");
            end;
        }
        field(42; "Transfer-from Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Name';
            Editable = false;
        }
        field(43; "In-Transit Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'In-Transit Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(true));
        }
        field(56; "Transfer Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Order Nos.';

            trigger OnValidate();
            begin
                TestField(Type, Type::"Transfer Order");
            end;
        }
        field(61; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Template Name';
            TableRelation = if (Type = const("General Journal")) "Gen. Journal Template" where("Page ID" = filter(39 | 256));
        }
        field(62; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Batch Name';
            TableRelation = if (Type = const("General Journal")) "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(63; "Gen. Jnl. Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = CustomerContent;
            Caption = 'General Journal Document Type';
        }
        field(64; "Gen. Jnl. Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'General Journal Account Type';
        }
        field(65; "Gen. Jnl. Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'General Journal Account No.';
            TableRelation = if ("Gen. Jnl. Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                          Blocked = const(false), "Direct Posting" = const(true))
            else
            if ("Gen. Jnl. Account Type" = const(Customer)) Customer
            else
            if ("Gen. Jnl. Account Type" = const(Vendor)) Vendor
            else
            if ("Gen. Jnl. Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Gen. Jnl. Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Gen. Jnl. Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Gen. Jnl. Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Gen. Jnl. Account Type" = const(Employee)) Employee;
        }
        field(66; "Entry Type"; Enum PPHRDS_RequestEntryType)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
        }
        field(69; "Gen. Prod. Posting Group"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(101; "Location Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location.Code WHERE("Use As In-Transit" = CONST(false));
        }
        // field(271; "Allow Editing Amount"; Boolean)
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Allow Editing Amount';
        // }
        field(300; Active; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Active';

            trigger OnValidate();
            begin
                if Active = false then
                    exit;

                TestField(Description);

                case Type of
                    Type::Purchase:
                        TestField("Purchase Document Type");
                    Type::"General Journal":
                        TestField("Journal Template Name");
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField(Active, false);
    end;

    local procedure GetLocationName(parLocationCode: Code[10]): Text[100];
    var
        Location: Record Location;
    begin
        if Location.Get(parLocationCode) then
            exit(Location.Name)
        else
            exit('');
    end;
}

