table 70829576 "PPHRDS_ReqDocSysUserSetup"
{
    Caption = 'Request Document System User Setup';

    fields
    {
        field(1; "Requestor ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            NotBlank = true;

            trigger OnValidate();
            var
                User: Record User;
                UserSelctn: Codeunit "User Selection";
            begin
                UserSelctn.ValidateUserName("Requestor ID");

                User.SetRange("User Name", "Requestor ID");
                if User.FindFirst() then
                    "Requestor Name" := User."Full Name"
                else
                    "Requestor Name" := '';
            end;
        }
        field(2; "Requestor Name"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor Name';
        }
        field(20; "Requestor ID Filter"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor ID Filter';
        }
    }

    keys
    {
        key(Key1; "Requestor ID")
        {
            Clustered = true;
        }
    }

}