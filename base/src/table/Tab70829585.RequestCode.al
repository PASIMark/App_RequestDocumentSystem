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

