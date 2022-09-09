codeunit 70829675 "PPHRDS_ReqDocUpgradeMgt"
{
    Subtype = Upgrade;

    // trigger OnUpgradePerCompany()
    // begin
    //     NavApp.GetCurrentModuleInfo(ModuleInfo);
    //     if (ModuleInfo.DataVersion = Version.Create(1, 0, 0, 0)) and
    //         (ModuleInfo.AppVersion = Version.Create(1, 0, 0, 1))
    //     then
    //         UpgradeToVer1001();
    // end;

    // local procedure UpgradeToVer1001()
    // begin
    //     UpdateProcessedRequestEntry();
    // end;

    // local procedure UpdateProcessedRequestEntry()
    // var
    //     locProcessedRequestEntry: Record PPHRDS_ProcessedRequestEntry;
    //     locPurchaseHeader: Record "Purchase Header";
    //     locPurchaseLine: Record "Purchase Line";
    //     locTransferHeader: Record "Transfer Header";
    //     locTransferLine: Record "Transfer Line";
    //     locItemJournalLine: Record "Item Journal Line";
    //     locRequisitionLine: Record "Requisition Line";
    //     locGenJournalLine: Record "Gen. Journal Line";
    // begin
    //     locProcessedRequestEntry.Reset();
    //     locProcessedRequestEntry.SetRange(Status, locProcessedRequestEntry.Status::Processed);
    //     locProcessedRequestEntry.SetRange("Processed SystemId", NullGuid());
    //     if locProcessedRequestEntry.FindSet() then
    //         repeat

    //             case locProcessedRequestEntry."Request Type" of
    //                 locProcessedRequestEntry."Request Type"::Purchase:
    //                     begin
    //                         if locPurchaseHeader.Get(locProcessedRequestEntry."Purchase Document Type",
    //                             locProcessedRequestEntry."Purchase Document No.")
    //                         then
    //                             locProcessedRequestEntry."Processed SystemId (Header)" := locPurchaseHeader.SystemId;

    //                         locPurchaseLine.Reset();
    //                         locPurchaseLine.SetRange("Document Type", locProcessedRequestEntry."Purchase Document Type");
    //                         locPurchaseLine.SetRange("Document No.", locProcessedRequestEntry."Purchase Document No.");
    //                         locPurchaseLine.SetRange("Line No.", locProcessedRequestEntry."Purchase Document Line No.");
    //                         if locPurchaseLine.FindFirst() then
    //                             locProcessedRequestEntry."Processed SystemId" := locPurchaseLine.SystemId;
    //                     end;
    //                 locProcessedRequestEntry."Request Type"::"Transfer Order":
    //                     begin
    //                         if locTransferHeader.Get(locProcessedRequestEntry."Transfer Order No.") then
    //                             locProcessedRequestEntry."Processed SystemId (Header)" := locTransferHeader.SystemId;

    //                         locTransferLine.Reset();
    //                         locTransferLine.SetRange("Document No.", locProcessedRequestEntry."Transfer Order No.");
    //                         locTransferLine.SetRange("Line No.", locProcessedRequestEntry."Transfer Order Line No.");
    //                         if locTransferLine.FindFirst() then
    //                             locProcessedRequestEntry."Processed SystemId" := locTransferLine.SystemId;
    //                     end;
    //                 locProcessedRequestEntry."Request Type"::"Item Journal":
    //                     begin
    //                         locItemJournalLine.Reset();
    //                         locItemJournalLine.SetRange("Journal Template Name", locProcessedRequestEntry."Journal Template Name");
    //                         locItemJournalLine.SetRange("Journal Batch Name", locProcessedRequestEntry."Journal Batch Name");
    //                         locItemJournalLine.SetRange("Line No.", locProcessedRequestEntry."Journal Line No.");
    //                         locItemJournalLine.SetRange("Document No.", locProcessedRequestEntry."Journal Document No.");
    //                         if locItemJournalLine.FindFirst() then
    //                             locProcessedRequestEntry."Processed SystemId" := locItemJournalLine.SystemId;
    //                     end;
    //                 locProcessedRequestEntry."Request Type"::"Req. Worksheet":
    //                     begin
    //                         locRequisitionLine.Reset();
    //                         locRequisitionLine.SetRange("Worksheet Template Name", locProcessedRequestEntry."Journal Template Name");
    //                         locRequisitionLine.SetRange("Journal Batch Name", locProcessedRequestEntry."Journal Batch Name");
    //                         locRequisitionLine.SetRange("Line No.", locProcessedRequestEntry."Journal Line No.");
    //                         locRequisitionLine.SetRange("Demand Order No.", locProcessedRequestEntry."Request No.");
    //                         if locRequisitionLine.FindFirst() then
    //                             locProcessedRequestEntry."Processed SystemId" := locRequisitionLine.SystemId;
    //                     end;
    //                 locProcessedRequestEntry."Request Type"::"General Journal":
    //                     begin
    //                         locGenJournalLine.Reset();
    //                         locGenJournalLine.SetRange("Journal Template Name", locProcessedRequestEntry."Journal Template Name");
    //                         locGenJournalLine.SetRange("Journal Batch Name", locProcessedRequestEntry."Journal Batch Name");
    //                         locGenJournalLine.SetRange("Line No.", locProcessedRequestEntry."Journal Line No.");
    //                         locGenJournalLine.SetRange("Document No.", locProcessedRequestEntry."Journal Document No.");
    //                         if locGenJournalLine.FindFirst() then
    //                             locProcessedRequestEntry."Processed SystemId" := locGenJournalLine.SystemId;
    //                     end;
    //             end;
    //             locProcessedRequestEntry.Modify();

    //         until locProcessedRequestEntry.Next() = 0;
    // end;

    // local procedure NullGuid(): Text
    // begin
    //     exit('{00000000-0000-0000-0000-000000000000}');
    // end;

    // var
    //     ModuleInfo: ModuleInfo;
}