codeunit 70829576 "PPHRDS_ReqDocSysTempStorage"
{
    SingleInstance = true;

    trigger OnRun()
    begin

    end;

    procedure SetJnlTemplateAndBatchName(parCurrentJnlTemplateName: Code[10]; parCurrentJnlBatchName: Code[10])
    begin
        GlobalCurrentJnlTemplateName := parCurrentJnlTemplateName;
        GlobalCurrentJnlBatchName := parCurrentJnlBatchName;
    end;

    procedure GetJnlTemplateAndBatchName(var parCurrentJnlTemplateName: Code[10]; var parCurrentJnlBatchName: Code[10])
    begin
        parCurrentJnlTemplateName := GlobalCurrentJnlTemplateName;
        parCurrentJnlBatchName := GlobalCurrentJnlBatchName;
    end;

    procedure SetRequsitionLineCurrFieldNo(FieldNo: Integer);
    begin
        GlobalCurrFieldNo := FieldNo;
    end;

    procedure ClearJnlTemplateAndBatchName()
    begin
        clear(GlobalCurrentJnlTemplateName);
        clear(GlobalCurrentJnlBatchName);
    end;

    procedure GetRequsitionLineCurrFieldNo(): Integer
    begin
        exit(GlobalCurrFieldNo);
    end;

    procedure ClearRequsitionLineCurrFieldNo()
    begin
        Clear(GlobalCurrFieldNo);
    end;

    var
        GlobalCurrentJnlTemplateName: Code[10];
        GlobalCurrentJnlBatchName: Code[10];
        GlobalCurrFieldNo: Integer;
}