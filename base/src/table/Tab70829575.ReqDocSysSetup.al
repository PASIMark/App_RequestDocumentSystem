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

