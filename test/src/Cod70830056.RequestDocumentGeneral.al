codeunit 70830056 "PPHRDS_RequestDocumentGeneral"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        Initialize();
    end;

    var
        ReqDocSysSetup: Record PPHRDS_ReqDocSysSetup;
        RequestCode: Record PPHRDS_RequestCode;
        Assert: Codeunit "Library Assert";
        RequestManagement: Codeunit PPHRDS_RequestManagement;
        SetupDataHaveNotBeenInsertedLbl: Label '%1 setup data have not been inserted.', Comment = '%1 = Table name';

    [Test]
    procedure CreateRequestDocumentSystemSetup();
    begin
        // [GIVEN] Empty Request Document System Setup
        ReqDocSysSetup.DeleteAll();

        // [WHEN] Default setup is initialized
        RequestManagement.InitializeDefaultSetup();

        // [THEN] No. Series fields must be defined
        ReqDocSysSetup.Get();
        ReqDocSysSetup.TestField("Request Nos.");
        ReqDocSysSetup.TestField("Processed Request Nos.");
    end;

    [Test]
    procedure CreateRequestCode();
    begin
        // [GIVEN] Empty Request Code table
        RequestCode.DeleteAll();

        // [WHEN] Default setup is initialized
        RequestManagement.InitializeDefaultSetup();

        // [THEN] Request Code table must contain default request codes 
        Assert.IsTrue(RequestCode.Count > 0, StrSubstNo(SetupDataHaveNotBeenInsertedLbl, RequestCode.TableCaption));
    end;

    [Test]
    procedure DefaultRequestCodesIsComplete()
    var
        ReqCodeList: List of [Code[20]];
        ReqCode: Code[20];
    begin
        // [GIVEN] Set list of default request codes
        ReqCodeList.Add('QUOTE');
        ReqCodeList.Add('ORDER');
        ReqCodeList.Add('INVOICE');
        ReqCodeList.Add('TRANSFER');
        ReqCodeList.Add('POSADJ');
        ReqCodeList.Add('NEGADJ');
        ReqCodeList.Add('REQWHST');

        // [WHEN] Initialize default setup
        RequestManagement.InitializeDefaultSetup();

        // [THEN] Validate if default request code is complete
        foreach ReqCode in ReqCodeList do
            RequestCode.Get(ReqCode)
    end;

    [Test]
    procedure DefaultRequestCodesIsValid()
    var
        ReqCodeList: List of [Code[20]];
        ReqCode: Code[20];
    begin
        // [GIVEN] Set list of default request codes
        ReqCodeList.Add('QUOTE');
        ReqCodeList.Add('ORDER');
        ReqCodeList.Add('INVOICE');
        ReqCodeList.Add('TRANSFER');
        ReqCodeList.Add('POSADJ');
        ReqCodeList.Add('NEGADJ');
        ReqCodeList.Add('REQWHST');

        // [WHEN] Initialize default setup
        RequestManagement.InitializeDefaultSetup();

        // [THEN] Validate if default request code is complete
        foreach ReqCode in ReqCodeList do begin
            RequestCode.Get(ReqCode);
            RequestCode.TestField(Description);
            RequestCode.TestField(Active, true);
            case ReqCode of
                'QUOTE':
                    begin
                        RequestCode.TestField(Type, RequestCode.Type::Purchase);
                        RequestCode.TestField("Purchase Document Type", RequestCode."Purchase Document Type"::Quote);
                    end;
                'ORDER':
                    begin
                        RequestCode.TestField(Type, RequestCode.Type::Purchase);
                        RequestCode.TestField("Purchase Document Type", RequestCode."Purchase Document Type"::Order);
                    end;
                'INVOICE':
                    begin
                        RequestCode.TestField(Type, RequestCode.Type::Purchase);
                        RequestCode.TestField("Purchase Document Type", RequestCode."Purchase Document Type"::Invoice);
                    end;
                'TRANSFER':
                    RequestCode.TestField(Type, RequestCode.Type::"Transfer Order");
                'POSADJ':
                    begin
                        RequestCode.TestField(Type, RequestCode.Type::"Item Journal");
                        RequestCode.TestField("Entry Type", RequestCode."Entry Type"::"Positive Adjmt.");
                    end;
                'NEGADJ':
                    begin
                        RequestCode.TestField(Type, RequestCode.Type::"Item Journal");
                        RequestCode.TestField("Entry Type", RequestCode."Entry Type"::"Negative Adjmt.");
                    end;
                'REQWHST':
                    RequestCode.TestField(Type, RequestCode.Type::"Req. Worksheet");
            end;
        end;
    end;

    local procedure Initialize()
    var
        TestLibrary: Codeunit PPHRDS_TestLibrary;
    begin
        TestLibrary.RegisterApp();
        RequestManagement.InitializeDefaultSetup();
    end;
}