table 70829650 PPHRDS_RequestDocumentCue
{
    Caption = 'Request Document Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Req. - Open"; Integer)
        {
            CalcFormula = Count(PPHRDS_ReqHeader WHERE(Status = CONST(Open), "Requestor ID" = FIELD("User ID Filter")));
            Caption = 'Open';
            FieldClass = FlowField;
        }
        field(11; "Req. - Released"; Integer)
        {
            CalcFormula = Count(PPHRDS_ReqHeader WHERE(Status = CONST(Released), "Requestor ID" = FIELD("User ID Filter")));
            Caption = 'Released';
            FieldClass = FlowField;
        }
        field(12; "Req. - Pending Approval"; Integer)
        {
            CalcFormula = Count(PPHRDS_ReqHeader WHERE(Status = CONST("Pending Approval"), "Requestor ID" = FIELD("User ID Filter")));
            Caption = 'Pending Approval';
            FieldClass = FlowField;
        }

        // field(20; "Req. - Rejected"; Integer)
        // {
        //     CalcFormula = Count("Approval Entry" WHERE("Table ID" = CONST(70829615), Status = CONST(Rejected), "Sender ID" = FIELD("User ID Filter")));
        //     Caption = 'Rejected';
        //     FieldClass = FlowField;
        // }
        field(24; "User Req. - Open"; Integer)
        {
            CalcFormula = Count(PPHRDS_ReqHeader WHERE(Status = CONST(Open), "Requestor ID" = field("User ID Filter"), "Posting Date" = field("Date Filter")));
            Caption = 'Open';
            FieldClass = FlowField;
        }
        field(25; "Processed Request"; Integer)
        {
            CalcFormula = Count(PPHRDS_ProcessedReqHeader WHERE("Requestor ID" = field("User ID Filter")));
            Caption = 'Processed Request';
            FieldClass = FlowField;
        }
        field(108; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(109; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
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

