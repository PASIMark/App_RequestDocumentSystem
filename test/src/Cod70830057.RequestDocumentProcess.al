codeunit 70830057 "PPHRDS_RequestDocumentProcess"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        Initialize();
    end;

    var
        TestLibrary: Codeunit PPHRDS_TestLibrary;

    [Test]
    procedure CreateRequestHeader();
    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReqNo: Code[20];
    begin
        // [GIVEN] Setup
        ReqNo := TestLibrary.GetRequestAssignedNoSeries();

        // [WHEN] Exercise
        TestLibrary.InsertRequestHeader(ReqHeader);

        // [THEN] Verify
        ReqHeader.TestField("No.", ReqNo);
        ReqHeader.TestField("Requestor ID", UserId);
        ReqHeader.TestField("Request Date");
        ReqHeader.TestField("Document Date");
        ReqHeader.TestField("Posting Date");
    end;

    local procedure Initialize()
    var
        RequestManagement: Codeunit PPHRDS_RequestManagement;
    begin
        TestLibrary.RegisterApp();
        RequestManagement.InitializeDefaultSetup();
    end;
}