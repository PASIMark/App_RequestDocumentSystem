enum 70829616 PPHRDS_ReqLineType
{
    Caption = 'Req. Line Type';
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; " ") { Caption = ' '; }
    value(1; "G/L Account") { Caption = 'G/L Account'; }
    value(2; "Item") { Caption = 'Item'; }
    value(3; "Fixed Asset") { Caption = 'Fixed Asset'; }
    value(4; "Vendor") { Caption = 'Vendor'; }
    value(5; "Employee") { Caption = 'Employee'; }
}