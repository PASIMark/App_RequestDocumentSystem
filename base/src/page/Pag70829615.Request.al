page 70829615 PPHRDS_Request
{
    Caption = 'Request';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Request,Request Approval,Print';
    RefreshOnActivate = true;
    SourceTable = PPHRDS_ReqHeader;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the No..';
                    ApplicationArea = All;

                    trigger OnAssistEdit();
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Requestor ID"; Rec."Requestor ID")
                {
                    Tooltip = 'Specifies the Requestor ID.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requestor Name"; Rec."Requestor Name")
                {
                    Tooltip = 'Specifies the Requestor Name.';
                    ApplicationArea = All;
                    Editable = false;
                }

                group(Control38)
                {
                    Caption = '';
                    field("Purchaser Code"; Rec."Purchaser Code")
                    {
                        Tooltip = 'Specifies the Approval ID.';
                        ApplicationArea = All;
                        Caption = 'Approval ID';
                    }
                    field("Request Code"; Rec."Request Code")
                    {
                        Tooltip = 'Specifies the Request Code.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Request Description"; Rec."Request Description")
                    {
                        Tooltip = 'Specifies the Request Description.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        Tooltip = 'Specifies the Location Code.';
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Control10)
                {
                    Caption = '';
                    field("Request Date"; Rec."Request Date")
                    {
                        Tooltip = 'Specifies the Request Date.';
                        ApplicationArea = All;
                    }
                    field("Document Date"; Rec."Document Date")
                    {
                        Tooltip = 'Specifies the Document Date.';
                        ApplicationArea = All;
                    }
                    field("Posting Date"; Rec."Posting Date")
                    {
                        Tooltip = 'Specifies the Posting Date.';
                        ApplicationArea = All;
                    }
                    field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        Tooltip = 'Specifies the Shortcut Dimension 1 Code.';
                        ApplicationArea = All;
                    }
                    field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                    {
                        Tooltip = 'Specifies the Shortcut Dimension 2 Code.';
                        ApplicationArea = All;
                    }
                    field(Status; Rec.Status)
                    {
                        Tooltip = 'Specifies the Status.';
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
            part(Control12; PPHRDS_RequestSubform)
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(ReqLineFactBox; PPHRDS_ReqLineFactBox)
            {
                ApplicationArea = All;
                Provider = Control12;
                SubPageLink = "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
            }
            part(Control31; "Pending Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = CONST(70829615),
                              "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = All;
                Visible = false;
            }
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(70829615),
                              "No." = FIELD("No."),
                              "Document Type" = const(PPHRDS_Request);
            }
            systempart(Control13; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control7; Notes)
            {
                ApplicationArea = All;
                Visible = true;
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(GetRecurringRequestLines)
                {
                    ApplicationArea = Suite;
                    Caption = 'Get Recurring Request Lines';
                    Ellipsis = true;
                    Image = VendorCode;
                    ToolTip = 'Insert request document lines from the standard purchase code.';

                    trigger OnAction()
                    var
                        RequestManagement: Codeunit PPHRDS_RequestManagement;
                    begin
                        RequestManagement.GetRecurringRequestLines(Rec);
                    end;
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
                        if RequestApprovalMgt.PreProcessSendApprovalRequestCheckReq(Rec) and RequestApprovalMgt.CheckRequestApprovalPossible(Rec) then
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

    trigger OnAfterGetCurrRecord();
    begin
        SetControlAppearance();
        CurrPage.ApprovalFactBox.PAGE.UpdateApprovalEntriesFromSourceRecord(Rec.RecordId);
        ShowWorkflowStatus := CurrPage.WorkflowStatus.PAGE.SetFilterOnWorkflowRecord(Rec.RecordId);
    end;

    trigger OnDeleteRecord(): Boolean;
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ReleaseReqDoc: Codeunit PPHRDS_ReleaseRequestDocument;
        RequestApprovalMgt: Codeunit PPHRDS_RequestApprovalMgt;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        ShowWorkflowStatus: Boolean;
        CanCancelApprovalForRecord: Boolean;

    local procedure SetControlAppearance();
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
    end;
}