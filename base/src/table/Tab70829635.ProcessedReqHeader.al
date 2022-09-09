table 70829635 PPHRDS_ProcessedReqHeader
{
    Caption = 'Processed Req. Header';
    LookupPageID = PPHRDS_ProcessedRequestList;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'No.';
        }
        field(5; "Requestor ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor ID';
        }
        field(6; "Requestor Name"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor Name';
        }
        field(20; "Request No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Request No.';
        }
        field(21; "Request Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Date';
        }
        field(22; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(25; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(26; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(28; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(32; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(33; "Currency Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(43; "Purchaser Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(81; "No. Series"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(119; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(120; Status; Enum PPHRDS_ReqHeaderStatus)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(5752; "Completely Processed"; Boolean)
        {
            CalcFormula = Min(PPHRDS_ProcessedReqLine."Completely Processed" WHERE("Document No." = FIELD("No."),
                                                                        Type = FILTER(<> " ")));
            Caption = 'Completely Processed';
            FieldClass = FlowField;
        }
        field(5796; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(6030; "Request Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Code';
            TableRelation = PPHRDS_RequestCode;
        }
        field(6031; "Request Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Description';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        ProcessedReqLine.Reset();
        ProcessedReqLine.SetRange("Document No.", "No.");
        if not ProcessedReqLine.IsEmpty then
            ProcessedReqLine.DeleteAll();

        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::PPHRDS_ProcessedReqHeader);
        DocumentAttachment.SetRange("No.", "Request No.");
        if not DocumentAttachment.IsEmpty then
            DocumentAttachment.DeleteAll();
    end;

    var
        ProcessedReqLine: Record PPHRDS_ProcessedReqLine;
        DimMgt: Codeunit DimensionManagement;

    procedure ShowDimensions();
    var
        CaptionFormatLbl: Label '%1 %2', Comment = '%1 = Table Caption, %2 = No. field';
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(CaptionFormatLbl, TableCaption, "No."));
    end;
}

