report 70829620 PPHRDS_Request
{
    Caption = 'Request';
    DefaultLayout = RDLC;
    RDLCLayout = 'src/report/Rep70829620.Request.rdlc';
    UsageCategory = None;

    dataset
    {
        dataitem("Req. Header"; PPHRDS_ReqHeader)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(CompanyTitle; CompanyInfo.Name)
            {
            }
            column(CompanyAdd; CompanyInfo.Address)
            {
            }
            column(CompanyAdd2; CompanyInfo."Address 2")
            {
            }
            column(CompanyCity; CompanyInfo.City)
            {
            }
            column(CompanyPhone; CompanyInfo."Phone No.")
            {
            }
            column(CompanyFax; CompanyInfo."Fax No.")
            {
            }
            column(CompanyPostCode; CompanyInfo."Post Code")
            {
            }
            column(No_ReqHeader; "No.")
            {
            }
            column(RequisitionDate; Format("Request Date", 0, 4))
            {
            }
            column(GlobalDim1; GlobalDim1)
            {
            }
            column(GlobalDim2; GlobalDim2)
            {
            }
            column(BranchDesc; BranchDesc)
            {
            }
            column(CostCenterDesc; CostCenterDesc)
            {
            }
            column(Requisitionedby; RequestedByName)
            {
            }
            column(Checkedby; CheckedbyName)
            {
            }
            column(Approvedby; ApprovedbyName)
            {
            }
            dataitem("Req. Line"; PPHRDS_ReqLine)
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(LineNo_ReqLine; "Line No.")
                {
                }
                column(Type_ReqLine; Type)
                {
                }
                column(No_ReqLine; "No.")
                {
                }
                column(Description_ReqLine; Description)
                {
                }
                column(Quantity_ReqLine; Quantity)
                {
                }
                column(UnitofMeasure_ReqLine; "Unit of Measure")
                {
                }
                column(DirectUnitCost_ReqLine; "Req. Line"."Direct Unit Cost")
                {
                }
                column(LineAmount_ReqLine; "Line Amount")
                {
                }
            }

            trigger OnPreDataItem()
            begin
                if RequestManagement.RequestorIDFilter(UserId) then
                    SetRange("Requestor ID", UserId);

                RequestedbyName := RequestManagement.GetUserFullName(Requestedby);
                CheckedbyName := RequestManagement.GetUserFullName(Checkedby);
                ApprovedbyName := RequestManagement.GetUserFullName(Approvedby);
            end;

            trigger OnAfterGetRecord()
            begin
                DimensionValue.Reset();
                DimensionValue.SetRange(Code, "Shortcut Dimension 1 Code");
                if DimensionValue.FindSet() then begin
                    Dimension.Get(DimensionValue."Dimension Code");
                    GlobalDim1 := Dimension.Name;
                    BranchDesc := DimensionValue.Name;
                end;

                DimensionValue.Reset();
                DimensionValue.SetRange(Code, "Shortcut Dimension 2 Code");
                if DimensionValue.FindSet() then begin
                    Dimension.Get(DimensionValue."Dimension Code");
                    GlobalDim2 := Dimension.Name;
                    CostCenterDesc := DimensionValue.Name;
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Signatories)
                {
                    field(FldRequestedby; Requestedby)
                    {
                        Tooltip = 'Specifies the FldRequestedby.';
                        Caption = 'Requested by';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(FldCheckedby; Checkedby)
                    {
                        Tooltip = 'Specifies the FldCheckedby.';
                        Caption = 'Checked by';
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            Checkedby := RequestManagement.LookUpUserName();
                        end;
                    }
                    field(FldApprovedby; Approvedby)
                    {
                        Tooltip = 'Specifies the FldApprovedby.';
                        Caption = 'Approved by';
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            Approvedby := RequestManagement.LookUpUserName();
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            ReqHeader.CopyFilters("Req. Header");
            if ReqHeader.FindFirst() then
                Requestedby := ReqHeader."Requestor ID";
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        OnBeforeInitReport();

        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        ReqHeader: Record PPHRDS_ReqHeader;
        RequestManagement: Codeunit PPHRDS_RequestManagement;
        Requestedby: Code[50];
        Checkedby: Code[50];
        Approvedby: Code[50];
        RequestedbyName: Text[80];
        CheckedbyName: Text[80];
        ApprovedbyName: Text[80];
        GlobalDim1: Text[30];
        GlobalDim2: Text[30];
        BranchDesc: Text[50];
        CostCenterDesc: Text[50];

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitReport();
    begin
    end;
}
