codeunit 70829626 PPHRDS_ReqWFEventHandling
{
    trigger OnRun();
    begin
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        RunWorkflowOnSendRequestforApprovalTxt: Label 'Approval of a request document is requested.';
        RunWorkflowOnCancelRequestforApprovalTxt: Label 'An approval request for a request document is canceled.';

    procedure RunWorkflowOnSendRequestforApprovalCode(): Code[128];
    begin
        exit(UpperCase('RunWorkflowOnSendRequestforApproval'));
    end;

    procedure RunWorkflowOnCancelRequestforApprovalCode(): Code[128];
    begin
        exit(UpperCase('RunWorkflowOnCancelRequestforApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary();
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRequestforApprovalCode(), DATABASE::PPHRDS_ReqHeader, RunWorkflowOnSendRequestforApprovalTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRequestforApprovalCode(), DATABASE::PPHRDS_ReqHeader, RunWorkflowOnCancelRequestforApprovalTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure WorkflowEventHandlingOnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(), RunWorkflowOnSendRequestforApprovalCode());
            RunWorkflowOnCancelRequestforApprovalCode():
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRequestforApprovalCode(), RunWorkflowOnSendRequestforApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_RequestApprovalMgt, 'OnSendRequestforApproval', '', false, false)]
    local procedure RunWorkflowOnSendRequestforApproval(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRequestforApprovalCode(), ReqHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PPHRDS_RequestApprovalMgt, 'OnCancelRequestforApproval', '', false, false)]
    local procedure RunWorkflowOnCancelRequestforApproval(var ReqHeader: Record PPHRDS_ReqHeader);
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRequestforApprovalCode(), ReqHeader);
    end;
}
