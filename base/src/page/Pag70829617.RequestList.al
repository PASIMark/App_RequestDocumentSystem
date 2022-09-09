page 70829617 PPHRDS_RequestList
{
    Caption = 'Request List';
    CardPageID = PPHRDS_Request;
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Request,Request Approval,Print';
    SourceTable = PPHRDS_ReqHeader;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;
                }
                field("Requestor ID"; Rec."Requestor ID")
                {
                    Tooltip = 'Specifies the Requestor ID.';
                    ApplicationArea = All;
                }
                field("Requestor Name"; Rec."Requestor Name")
                {
                    Tooltip = 'Specifies the Requestor Name.';
                    ApplicationArea = All;
                }
                field("Request Date"; Rec."Request Date")
                {
                    Tooltip = 'Specifies the Request Date.';
                    ApplicationArea = All;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    Tooltip = 'Specifies the Approval ID.';
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Approval ID';
                }
                field("Request Code"; Rec."Request Code")
                {
                    Tooltip = 'Specifies the Request Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Request Description"; Rec."Request Description")
                {
                    Tooltip = 'Specifies the Request Description.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Tooltip = 'Specifies the Location Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Tooltip = 'Specifies the Shortcut Dimension 1 Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Tooltip = 'Specifies the Shortcut Dimension 2 Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    Tooltip = 'Specifies the Status.';
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(70829615),
                              "No." = FIELD("No."),
                              "Document Type" = const(PPHRDS_Request);
            }
            systempart(Control7; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control3; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Request)
            {
                Caption = 'Request';
                Image = "Order";
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Enabled = Rec."No." <> '';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category8;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edits dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction();
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category8;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction();
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RunWorkflowEntriesPage(Rec.RecordId, DATABASE::PPHRDS_ReqHeader, "Approval Document Type"::" ", Rec."No.");
                    end;
                }
            }
        }
        area(processing)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Reject the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Delegate the requested changes to the substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group(ActionGroup101)
            {
                Caption = 'Release';
                Image = ReleaseDoc;

                action(Release)
                {
                    ApplicationArea = All;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. When a document is released, it will be included in all availability calculations from the expected receipt date of the items. You must reopen the document before you can make changes to it.';

                    trigger OnAction();
                    begin
                        ReleaseReqDoc.PerformManualRelease(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = All;
                    Caption = 'Re&open';
                    Enabled = Rec.Status <> Rec.Status::Open;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed';

                    trigger OnAction();
                    begin
                        ReleaseReqDoc.PerformManualReopen(Rec);
                    end;
                }
                separator(Separator40)
                {
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category9;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction();
                    begin
                        if RequestApprovalMgt.PreProcessSendApprovalRequestCheckReq(rec) and RequestApprovalMgt.CheckRequestApprovalPossible(Rec) then
                            RequestApprovalMgt.OnSendRequestforApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category9;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction();
                    begin
                        RequestApprovalMgt.OnCancelRequestforApproval(Rec);
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                Image = Print;

                action("&Print")
                {
                    ApplicationArea = All;
                    Caption = '&Print';
                    Ellipsis = true;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Category10;
                    ToolTip = 'Prepare to print the document. The report request window for the document opens where you can specify what to include on the print-out.';
                    PromotedOnly = true;
                    Visible = false;

                    trigger OnAction();
                    var
                        ReqHeader: Record PPHRDS_ReqHeader;
                    begin
                        ReqHeader := Rec;
                        CurrPage.SETSELECTIONFILTER(ReqHeader);
                        report.run(Report::PPHRDS_Request, TRUE, TRUE, ReqHeader);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if RequestManagement.RequestorIDFilter(UserId) then begin
            Rec.FilterGroup(100);
            Rec.SetRange("Requestor ID", UserId);
            Rec.FilterGroup(0);
        end;
    end;

    trigger OnAfterGetCurrRecord();
    begin
        SetControlAppearance();
    end;

    var
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ReleaseReqDoc: Codeunit PPHRDS_ReleaseRequestDocument;
        RequestApprovalMgt: Codeunit PPHRDS_RequestApprovalMgt;
        RequestManagement: Codeunit PPHRDS_RequestManagement;

    local procedure SetControlAppearance();
    begin
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
    end;
}

