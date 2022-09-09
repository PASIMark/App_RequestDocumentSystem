page 70829650 "PPHRDS_ReqDocRoleCenter"
{
    Caption = 'Request';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(headlinepart; PPHRDS_HeadlineRCReqDocument)
            {
                ApplicationArea = All;
            }
            part(Control1904484608; PPHRDS_ReqDocActivities)
            {
                ApplicationArea = All;
            }
            part(Control32; "My Job Queue")
            {
                ApplicationArea = All;
                Visible = false;
            }
            part(MyVendors; "My Vendors")
            {
                ApplicationArea = All;
            }
            part(MyItems; "My Items")
            {
                ApplicationArea = All;
            }
            part(Control36; "Report Inbox Part")
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control1901377608; MyNotes)
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        // area(reporting)
        // {
        // }
        // area(embedding)
        // {
        //     action(RequestList)
        //     {
        //         ApplicationArea = All;
        //         Caption = 'Request List';
        //         RunObject = Page "Request List";
        //     }
        // }
        area(sections)
        {
            group(Planning)
            {
                Caption = 'Planning';
                Image = ExecuteBatch;

                action(Vendors)
                {
                    ApplicationArea = All;
                    Caption = 'Vendors';
                    RunObject = Page "Vendor List";
                }
                action(Employees)
                {
                    ApplicationArea = All;
                    Caption = 'Employees';
                    RunObject = Page "Employee List";
                }
                action("G/L Budgets")
                {
                    ApplicationArea = All;
                    Caption = 'G/L Budgets';
                    RunObject = Page "G/L Budget Names";
                }
                action("Purchase Budgets")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Budgets';
                    RunObject = Page "Budget Names Purchase";
                }
                action("Fixed Asset Budgets")
                {
                    ApplicationArea = All;
                    Caption = 'Fixed Asset Budgets';
                    RunObject = Page PPHRDS_FixedAssetBudgets;
                }
                action(RequestCodes)
                {
                    ApplicationArea = All;
                    Caption = 'Request Codes';
                    RunObject = Page PPHRDS_RequestCodes;
                }
            }
            group("Requision Processing")
            {
                Caption = 'Requision Processing';
            }
            group(History)
            {
                Caption = 'History';
                Image = Intrastat;
                action("Processed Requests")
                {
                    ApplicationArea = All;
                    Caption = 'Processed Requests';
                    RunObject = Page PPHRDS_ProcessedRequestList;
                }
                action("Processed Request Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Processed Request Entries';
                    RunObject = Page PPHRDS_ProcessedRequestEntries;
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;

                action(RequestSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Request Document System Setup';
                    RunObject = Page PPHRDS_ReqDocSysSetup;
                }
            }
        }
        area(creation)
        {
            action("Request Document")
            {
                ApplicationArea = All;
                Image = NewDocument;
                // Promoted = false;
                RunObject = Page PPHRDS_Request;
                RunPageMode = Create;
                ToolTip = 'Create a new request document.';
            }
        }
    }
}

