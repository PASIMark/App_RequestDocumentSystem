codeunit 70829627 PPHRDS_ReqWFResponseHandling
{
    trigger OnRun();
    begin
    end;

    var
        ReqHeader: Record PPHRDS_ReqHeader;
        ReleaseRequestDocument: Codeunit PPHRDS_ReleaseRequestDocument;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure WorkflowResponseHandlingOnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        ReqWFEventHandling: Codeunit PPHRDS_ReqWFEventHandling;
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(),
                    ReqWFEventHandling.RunWorkflowOnSendRequestforApprovalCode());

            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
                    ReqWFEventHandling.RunWorkflowOnSendRequestforApprovalCode());

            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(),
                    ReqWFEventHandling.RunWorkflowOnCancelRequestforApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure WorkflowResponseHandlingOnOpenDocument(RecRef: RecordRef; var Handled: Boolean);
    begin
        if not (RecRef.Number = DATABASE::PPHRDS_ReqHeader) then
            exit;

        RecRef.SetTable(ReqHeader);
        ReleaseRequestDocument.Reopen(ReqHeader);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure WorkflowResponseHandlingOnReleaseDocument(RecRef: RecordRef; var Handled: Boolean);
    begin
        if not (RecRef.Number = DATABASE::PPHRDS_ReqHeader) then
            exit;

        RecRef.SetTable(ReqHeader);
        ReleaseRequestDocument.PerformManualRelease(ReqHeader);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure ApprovalsMgmtOnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean);
    begin
        if not (RecRef.Number = DATABASE::PPHRDS_ReqHeader) then
            exit;

        RecRef.SetTable(ReqHeader);
        ReqHeader.Status := ReqHeader.Status::"Pending Approval";
        ReqHeader.Modify();

        IsHandled := true;
    end;
}
