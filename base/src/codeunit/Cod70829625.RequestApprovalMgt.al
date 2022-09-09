codeunit 70829625 PPHRDS_RequestApprovalMgt
{
    trigger OnRun();
    begin
    end;

    var
        WorkflowSetup: Codeunit "Workflow Setup";
        ReqHeader: Record PPHRDS_ReqHeader;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowManagement: Codeunit "Workflow Management";
        ReqWorkflowEventHandling: Codeunit PPHRDS_ReqWFEventHandling;
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        ReqPreProcessCheckErr: Label 'Request %1 must be approved and released before you can perform this action.', Comment = '%1=document type, %2=document no., e.g. Purchase Order 321 must be approved...';
        ReqDocWorkflowCategoryCodeTxt: Label 'REQDOC', Locked = true;
        ReqDocWorkflowCategoryDescTxt: Label 'Request Document';
        ReqDocApprovalWorkflowCodeTxt: Label 'RDAPW', Locked = true;
        ReqDocApprovalWorkflowDescTxt: Label 'Request Document Approval Workflow';
        ReqHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="UTF-8"?><ReportParameters><DataItems><DataItem name="PPHRDS_ReqHeader">%1</DataItem></DataItems></ReportParameters>', Locked = true;

    procedure IsRequestApprovalsWorkflowEnabled(locReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(locReqHeader, ReqWorkflowEventHandling.RunWorkflowOnSendRequestforApprovalCode()));
    end;

    procedure CheckRequestApprovalPossible(locReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        if not IsRequestApprovalsWorkflowEnabled(locReqHeader) then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    procedure IsReqApprovalsWFHasApprovalEntries(locReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        if WorkflowManagement.CanExecuteWorkflow(locReqHeader, ReqWorkflowEventHandling.RunWorkflowOnSendRequestforApprovalCode()) or ApprovalsMgmt.HasApprovalEntries(locReqHeader.RecordId) then
            exit(true)
        else
            exit(false);
    end;

    procedure IsReqApprovalsWFHasOpenOrPendingApprovalEntries(locReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        if WorkflowManagement.CanExecuteWorkflow(locReqHeader, ReqWorkflowEventHandling.RunWorkflowOnSendRequestforApprovalCode()) or ApprovalsMgmt.HasOpenOrPendingApprovalEntries(locReqHeader.RecordId) then
            exit(true)
        else
            exit(false);
    end;

    procedure IsRequestHeaderPendingApproval(var parReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        if parReqHeader.Status <> parReqHeader.Status::Open then
            exit(false);

        exit(IsRequestApprovalsWorkflowEnabled(parReqHeader));
    end;

    procedure PreProcessApprovalCheckReq(var parReqHeader: Record PPHRDS_ReqHeader): Boolean;
    begin
        if IsRequestHeaderPendingApproval(parReqHeader) then
            Error(ReqPreProcessCheckErr, parReqHeader."No.");

        exit(true);
    end;

    procedure PreProcessSendApprovalRequestCheckReq(var parReqHeader: Record PPHRDS_ReqHeader): Boolean;
    var
        InventorySetup: Record "Inventory Setup";
        ReqLine: Record PPHRDS_ReqLine;
    begin
        InventorySetup.Get();

        ReqLine.Reset();
        ReqLine.SetRange("Document No.", parReqHeader."No.");
        if ReqLine.FindSet() then
            repeat
                ReqLine.TestField("No.");
                ReqLine.TestField(ReqLine.Quantity);
                if (ReqLine.Type = ReqLine.Type::Item) and ReqLine.IsNonInventoriableItem() then
                    ReqLine.TestField("Location Code", '');
                if (ReqLine.Type = ReqLine.Type::Item) and (not ReqLine.IsNonInventoriableItem()) and InventorySetup."Location Mandatory" then
                    ReqLine.TestField("Location Code");
                if (ReqLine.Type = ReqLine.Type::Item) then
                    ReqLine.TestField("Unit of Measure Code");
                ReqLine.TestField("Request Code");
            until ReqLine.Next() = 0;
        exit(true);
    end;

    local procedure InsertReqDocApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(ReqDocApprovalWorkflowCodeTxt)) then
            exit;

        WorkflowSetup.InsertWorkflowTemplate(Workflow, ReqDocApprovalWorkflowCodeTxt, ReqDocApprovalWorkflowDescTxt, ReqDocWorkflowCategoryCodeTxt);
        InsertReqDocApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertReqDocApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        locReqHeader: Record PPHRDS_ReqHeader;
        ReqWFEventHandling: Codeunit PPHRDS_ReqWFEventHandling;
        BlankDateFormula: DateFormula;
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::PPHRDS_ReqHeader, 0, DATABASE::"Approval Entry", 22);

        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
            WorkflowStepArgument."Approver Limit Type"::"Approver Chain", 0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildReqHeaderTypeConditionsText(locReqHeader.Status::Open),
            ReqWFEventHandling.RunWorkflowOnSendRequestforApprovalCode(),
            BuildReqHeaderTypeConditionsText(locReqHeader.Status::"Pending Approval"),
            ReqWFEventHandling.RunWorkflowOnCancelRequestforApprovalCode(),
            WorkflowStepArgument, true);
    end;

    local procedure BuildReqHeaderTypeConditionsText(Status: Enum PPHRDS_ReqHeaderStatus): Text
    var
        locReqHeader: Record PPHRDS_ReqHeader;
    begin
        locReqHeader.SetRange(Status, Status);
        exit(StrSubstNo(ReqHeaderTypeCondnTxt, WorkflowSetup.Encode(locReqHeader.GetView(false))));
    end;

    local procedure IsSufficientReqApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean;
    begin
        if UserSetup."User ID" = UserSetup."Approver ID" then
            EXIT(TRUE);

        if UserSetup."Unlimited Request Approval" or
            ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") AND (UserSetup."Request Amount Approval Limit" <> 0))
        then
            exit(true);

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary();
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::PPHRDS_ReqHeader, 0, DATABASE::"Approval Entry", 22);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', false, false)]
    local procedure WorkflowSetupOnAddWorkflowCategoriesToLibrary()
    begin
        WorkflowSetup.InsertWorkflowCategory(ReqDocWorkflowCategoryCodeTxt, ReqDocWorkflowCategoryDescTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure WorkflowSetupOnAfterInitWorkflowTemplates()
    begin
        InsertReqDocApprovalWorkflowTemplate();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', true, true)]
    local procedure ApprovalsMgmtOnAfterIsSufficientApprover(ApprovalEntryArgument: Record "Approval Entry"; UserSetup: Record "User Setup"; var IsSufficient: Boolean; var IsHandled: Boolean)
    begin
        case ApprovalEntryArgument."Table ID" of
            Database::PPHRDS_ReqHeader:
                IsSufficient := IsSufficientReqApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure UpdateApprovalEntryArgumentDocNo(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance");
    begin
        case RecRef.Number of
            DATABASE::PPHRDS_ReqHeader:
                begin
                    RecRef.SetTable(ReqHeader);
                    ReqHeader.CalcFields(Amount);
                    ApprovalEntryArgument."Document No." := ReqHeader."No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := ReqHeader."Purchaser Code";
                    ApprovalEntryArgument.Amount := ReqHeader.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := ReqHeader.Amount;
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRequestforApproval(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRequestforApproval(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
    end;
}
