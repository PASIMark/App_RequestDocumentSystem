table 70829595 PPHRDS_FixedAssetBudget
{
    Caption = 'Fixed Asset Budget';

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = "Fixed Asset";

            trigger OnValidate();
            begin
                if BudgetedAsset.Get("No.") then
                    Error(BudgetAllocatedMsg, "No.");

                if FixedAsset.Get("No.") then
                    Description := FixedAsset.Description
                else
                    Description := '';
            end;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(11; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(30; Blocked; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Blocked';
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

    var
        BudgetAllocatedMsg: Label 'The Budget is already allocated to Fixed Asset No. %1.', Comment = '%1 = Fixed Asset No.';
        BudgetedAsset: Record PPHRDS_FixedAssetBudget;
        FixedAsset: Record "Fixed Asset";
}

