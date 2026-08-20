table 70829575 "PPHRDS_ReqDocSysSetup"
{
    Caption = 'Request Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        // field(46; "Allow Multiple Canvass Doc."; Boolean)
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Allow Multiple Canvass Doc.';
        // }       
        field(96; "G/L Budget Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Budget Name';
            TableRelation = "G/L Budget Name" WHERE(Blocked = CONST(false));
        }
        field(97; "Item Budget Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Budget Name';
            TableRelation = "Item Budget Name".Name WHERE("Analysis Area" = CONST(Purchase),
                                                           Blocked = CONST(false));
        }
        field(98; "Item Budget Type"; Enum PPHRDS_RequestItemBudgetType)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Budget Type';
        }
        // field(105; "Expense Nos."; Code[10])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Expense Nos.';
        //     TableRelation = "No. Series";
        // }
        field(125; "Request Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Request Nos.';
            TableRelation = "No. Series";
        }
        field(126; "Processed Request Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Request Nos.';
            TableRelation = "No. Series";
        }
        // field(127; "Archive Request Nos."; Code[10])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Archive Request Nos.';
        //     TableRelation = "No. Series";
        // }
        // field(141; "Quote Nos."; Code[10])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Quote Nos.';
        //     TableRelation = "No. Series";
        // }
        // field(161; "Canvass Nos."; Code[10])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Canvass Nos.';
        //     TableRelation = "No. Series";
        // }
        // field(162; "Canvass Archive Nos."; Code[10])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Canvass Archive Nos.';
        //     TableRelation = "No. Series";
        // }
        field(200; "Allow Edit Purchase Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Purchase Line';
        }
        field(201; "Allow Edit Transfer Header"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Transfer Header';
        }
        field(202; "Allow Edit Transfer Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Transfer Line';
        }
        field(203; "Allow Edit Item Journal Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Item Journal Line';
        }
        field(204; "Allow Edit Req. Wksh. Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Req. Worksheet Line';
        }
        field(205; "Allow Insert Restr. Req. Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Insert Restricted Req. Line';
        }
        field(206; "Allow Edit Gen. Journal Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Gen. Journal Line';
        }
        field(207; "Allow Edit Released Req. Hdr"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Released Request Header';
        }
        field(208; "Allow Edit Released Req. Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Released Request Line';
        }
        field(209; "Allow Edit Purch. Code w/ Appr"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Edit Purchaser w/ Approval';
        }
        field(210; "Allow Inactive Request Code"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Inactive Request Code';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

