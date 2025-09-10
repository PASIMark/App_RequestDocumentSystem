table 70829615 PPHRDS_ReqHeader
{
    Caption = 'Req. Header';
    LookupPageID = PPHRDS_RequestList;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'No.';

            trigger OnValidate();
            var
                ProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
            begin
                if "No." <> xRec."No." then begin
                    GetRequestSetup();
                    NoSeries.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;

                ProcessedRequestEntry.Reset();
                ProcessedRequestEntry.SetRange("Request No.", "No.");
                if not ProcessedRequestEntry.IsEmpty then
                    FieldError("No.");
            end;
        }
        // field(3; "Notification Req. No."; Code[20])
        // {
        //     CalcFormula = Lookup(PPHRDS_ReqHeader."No." WHERE("No." = FIELD("No.")));
        //     Caption = 'Notification Req. No.';
        //     Editable = false;
        //     FieldClass = FlowField;

        //     trigger OnValidate();
        //     begin
        //         if "No." <> xRec."No." then begin
        //             GetRequestSetup();
        //             NoSeriesMgt.TestManual(GetNoSeriesCode());
        //             "No. Series" := '';
        //         end;
        //     end;
        // }
        field(5; "Requestor ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate();
            var
                UserSelctn: Codeunit "User Selection";
            begin
                TestField(Status, Status::Open);

                UserSelctn.ValidateUserName("Requestor ID");

                User.SetRange("User Name", "Requestor ID");
                if User.FindFirst() then
                    "Requestor Name" := User."Full Name"
                else
                    "Requestor Name" := '';
            end;
        }
        field(6; "Requestor Name"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Requestor Name';
        }
        field(21; "Request Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Date';

            trigger OnValidate();
            begin
                TestField(Status, Status::Open);

                ReqLine.Reset();
                ReqLine.SetRange("Document No.", "No.");
                if ReqLine.FindFirst() then
                    repeat
                        ReqLine."Request Date" := "Request Date";
                        ReqLine.Modify();
                    until ReqLine.Next() = 0;
            end;
        }
        field(22; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';

            trigger OnValidate();
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(25; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(26; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(28; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate();
            begin
                TestField(Status, Status::Open);

                CheckLocation();
            end;
        }
        field(43; "Purchaser Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate();
            var
                ApprovalEntry: Record "Approval Entry";
            begin
                ApprovalEntry.SetRange("Table ID", DATABASE::PPHRDS_ReqHeader);
                ApprovalEntry.SetRange("Document No.", "No.");
                ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
                if not ApprovalEntry.IsEmpty then
                    Error(CancelApprovalErr, FieldCaption("Purchaser Code"));

                CreateDim(
                  DATABASE::"Salesperson/Purchaser", "Purchaser Code");
            end;
        }
        field(60; "Amount"; Decimal)
        {
            // AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            FieldClass = FlowField;
            CalcFormula = Sum(PPHRDS_ReqLine."Line Amount" where("Document No." = field("No.")));
            Editable = false;
        }
        field(81; "No. Series"; Code[20])
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
        field(120; Status; enum PPHRDS_ReqHeaderStatus)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            Editable = true;

            trigger OnValidate();
            begin
                UpdateReqLines(FieldCaption(Status), false);
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDocDim();
            end;
        }
        field(5752; "Completely Processed"; Boolean)
        {
            CalcFormula = Min(PPHRDS_ReqLine."Completely Processed" WHERE("Document No." = FIELD("No."),
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
            TableRelation = PPHRDS_RequestCode where(Active = const(true));

            trigger OnValidate();
            begin
                TestField(Status, Status::Open);

                CheckLocation();

                if RequestCode.Get("Request Code") then
                    "Request Description" := RequestCode.Description
                else
                    "Request Description" := '';

                if RequestCode.Type = RequestCode.Type::"Item Journal" then
                    Validate("Location Code", RequestCode."Location Code");
            end;
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
        ReqLine.Reset();
        ReqLine.SetRange("Document No.", "No.");
        if not ReqLine.IsEmpty then
            ReqLine.DeleteAll(true);

        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::PPHRDS_ReqHeader);
        DocumentAttachment.SetRange("No.", "No.");
        if not DocumentAttachment.IsEmpty then
            DocumentAttachment.DeleteAll();
    end;

    trigger OnInsert();
    begin
        InitInsert();
    end;

    trigger OnRename()
    begin
        Error(RenameKeyErr, TableCaption);
    end;

    var
        RequestSetup: Record PPHRDS_ReqDocSysSetup;
        ReqLine: Record PPHRDS_ReqLine;
        xReqLine: Record PPHRDS_ReqLine;
        User: Record User;
        RequestCode: Record PPHRDS_RequestCode;
        NoSeries: Codeunit "No. Series";
        DimMgt: Codeunit DimensionManagement;
        ChangedDimQst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        RequestApprovalMgt: Codeunit PPHRDS_RequestApprovalMgt;
        UserModifyQst: Label 'You have modified %1.\\', Comment = '%1 = Modified field name';
        UpdateLinesQst: Label 'Do you want to update the lines?';
        CancelApprovalErr: Label 'You must cancel the approval process if you wish to change the %1.', Comment = '%1 = Purchaser Code';
        TransferFromErr: Label 'The Transfer-from Code in Request Code %1 must be different from Location Code %2.', Comment = '%1 = Request Code, %2 Location Code';
        RenameKeyErr: Label 'You cannot rename a %1.', Comment = '%1 = Table Name';

    procedure InitInsert()
    begin
        if "No." = '' then begin
            TestNoSeries();
            "No. Series" := GetNoSeriesCode();
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate())
        end;

        InitRecord();
    end;

    procedure InitRecord();
    begin
        GetRequestSetup();

        Validate("Requestor ID", UserId);

        if "Request Date" = 0D then
            Validate("Request Date", WorkDate());

        "Document Date" := WorkDate();
        "Posting Date" := WorkDate();
    end;

    procedure AssistEdit(OldReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        GetRequestSetup();
        TestNoSeries();
        if NoSeries.LookupRelatedNoSeries(GetNoSeriesCode(), OldReqHeader."No. Series", "No. Series") then begin
            "No." := NoSeries.GetNextNo("No. Series");
            exit(true);
        end;
    end;

    local procedure TestNoSeries();
    begin
        GetRequestSetup();
        RequestSetup.TestField("Request Nos.");
        RequestSetup.TestField("Processed Request Nos.");
    end;

    local procedure GetNoSeriesCode(): Code[10];
    begin
        GetRequestSetup();
        exit(RequestSetup."Request Nos.");
    end;

    local procedure GetRequestSetup();
    begin
        RequestSetup.Get();
    end;

    procedure ReqLinesExist(): Boolean;
    begin
        ReqLine.Reset();
        ReqLine.SetRange("Document No.", "No.");
        exit(ReqLine.FindFirst());
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if ReqLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ShowDocDim();
    var
        OldDimSetID: Integer;
        TableCaptionLbl: Label '%1 %2', Comment = '%1 = No. field, %2 = Shortcut Dimension 1 Code';
    begin

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo(TableCaptionLbl, TableCaption, "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if ReqLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer);
    var
        NewDimSetID: Integer;
    begin
        // Update all lines with changed dimensions.

        if NewParentDimSetID = OldParentDimSetID then
            exit;
        if not Confirm(ChangedDimQst) then
            exit;

        ReqLine.Reset();
        ReqLine.SetRange("Document No.", "No.");
        ReqLine.LockTable();
        if ReqLine.Find('-') then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(ReqLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if ReqLine."Dimension Set ID" <> NewDimSetID then begin
                    ReqLine."Dimension Set ID" := NewDimSetID;

                    DimMgt.UpdateGlobalDimFromDimSetID(
                      ReqLine."Dimension Set ID", ReqLine."Shortcut Dimension 1 Code", ReqLine."Shortcut Dimension 2 Code");
                    ReqLine.Modify();
                end;
            until ReqLine.Next() = 0;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]);
    var
        SourceCodeSetup: Record "Source Code Setup";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        OldDimSetID: Integer;
    begin
        SourceCodeSetup.Get();
        DimMgt.AddDimSource(DefaultDimSource, Type1, No1);
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, SourceCodeSetup.Purchases, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        if (OldDimSetID <> "Dimension Set ID") and ReqLinesExist() then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure UpdateReqLines(ChangedFieldName: Text; AskQuestion: Boolean);
    var
        Question: Text[250];
    begin
        if not ReqLinesExist() then
            exit;

        if AskQuestion then begin
            Question := StrSubstNo(
                UserModifyQst +
                UpdateLinesQst, ChangedFieldName);
            if not DIALOG.Confirm(Question, true) then
                exit;
        end;

        ReqLine.LockTable();
        Modify();

        ReqLine.Reset();
        ReqLine.SetRange("Document No.", "No.");
        if ReqLine.FindSet() then
            repeat
                xReqLine := ReqLine;
                case ChangedFieldName of
                    FieldCaption(Status):
                        ReqLine.Validate(Status, Status);
                end;
                ReqLine.Modify();
            until ReqLine.Next() = 0;
    end;

    local procedure CheckLocation();
    begin
        if not RequestCode.Get("Request Code") then
            exit;

        if RequestCode.Type = RequestCode.Type::"General Journal" then
            TestField("Location Code", '');

        if ("Location Code" = '') or (RequestCode."Transfer-from Code" = '') then
            exit;

        if RequestCode.Type = RequestCode.Type::"Transfer Order" then
            if "Location Code" = RequestCode."Transfer-from Code" then
                Error(TransferFromErr, "Request Code", RequestCode."Transfer-from Code");
    end;

    [Scope('Cloud')]

    procedure CheckRequestReleaseRestrictions();
    begin
        OnCheckRequestReleaseRestrictions();
        RequestApprovalMgt.PreProcessApprovalCheckReq(Rec);
    end;

    procedure CheckRequestSendApprovalRequestRestrictions();
    begin
        RequestApprovalMgt.PreProcessSendApprovalRequestCheckReq(Rec);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnCheckRequestReleaseRestrictions()
    begin
    end;
}

