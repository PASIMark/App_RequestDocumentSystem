page 70829586 PPHRDS_RequestCodeCard
{
    Caption = 'Request Code Card';
    PageType = Card;
    SourceTable = PPHRDS_RequestCode;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    Tooltip = 'Specifies the Code.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Tooltip = 'Specifies the Description.';
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    Tooltip = 'Specifies the Type.';
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        SetupVisibility();
                    end;
                }
                field(Active; Rec.Active)
                {
                    Tooltip = 'Specifies the Active.';
                    ApplicationArea = All;
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                Visible = PurchaseSetupVisible;
                field("Purchase Document Type"; Rec."Purchase Document Type")
                {
                    Tooltip = 'Specifies the Purchase Document Type.';
                    ApplicationArea = All;
                    Caption = 'Document Type';

                    trigger OnValidate();
                    begin
                        SetupVisibility();
                    end;
                }
                group(Control21)
                {
                    ShowCaption = false;
                    Visible = PurchQuoteNosVisible;
                    field("Purch. Quote Nos."; Rec."Purch. Quote Nos.")
                    {
                        Tooltip = 'Specifies the Purch. Quote Nos..';
                        ApplicationArea = All;

                        trigger OnLookup(var Text: Text): Boolean;
                        begin
                            PurchSetup.Get();
                            NoSeries.LookupRelatedNoSeries(PurchSetup."Quote Nos.", Rec."Purch. Quote Nos.");
                        end;
                    }
                }
                group(Control23)
                {
                    ShowCaption = false;
                    Visible = PurchOrderNosVisible;
                    field("Purch. Order Nos."; Rec."Purch. Order Nos.")
                    {
                        Tooltip = 'Specifies the Purch. Order Nos..';
                        ApplicationArea = All;

                        trigger OnLookup(var Text: Text): Boolean;
                        begin
                            PurchSetup.Get();
                            NoSeries.LookupRelatedNoSeries(PurchSetup."Order Nos.", Rec."Purch. Order Nos.")
                        end;
                    }
                }
                group(Control24)
                {
                    ShowCaption = false;
                    Visible = PurchInvoiceNosVisible;
                    field("Purch. Invoice Nos."; Rec."Purch. Invoice Nos.")
                    {
                        Tooltip = 'Specifies the Purch. Invoice Nos..';
                        ApplicationArea = All;

                        trigger OnLookup(var Text: Text): Boolean;
                        begin
                            PurchSetup.Get();
                            NoSeries.LookupRelatedNoSeries(PurchSetup."Invoice Nos.", Rec."Purch. Invoice Nos.")
                        end;
                    }
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                Visible = TransferOrderSetupVisible;
                group(Control27)
                {
                    ShowCaption = false;
                    field("Transfer-from Code"; Rec."Transfer-from Code")
                    {
                        Tooltip = 'Specifies the Transfer-from Code.';
                        ApplicationArea = All;
                    }
                    field("Transfer-from Name"; Rec."Transfer-from Name")
                    {
                        Tooltip = 'Specifies the Transfer-from Name.';
                        ApplicationArea = All;
                    }
                    field("In-Transit Code"; Rec."In-Transit Code")
                    {
                        Tooltip = 'Specifies the In-Transit Code.';
                        ApplicationArea = All;
                    }
                }
                // group(Control25)
                // {
                //     ShowCaption = false;
                //     field("Transfer Order Nos."; Rec."Transfer Order Nos.")
                //     {
                //         Tooltip = 'Specifies the Transfer Order Nos..';
                //         ApplicationArea = All;

                //         trigger OnLookup(var Text: Text): Boolean;
                //         begin
                //             InventorySetup.Get();
                //             NoSeriesMgt.SelectSeries(InventorySetup."Transfer Order Nos.", InventorySetup."Transfer Order Nos.", Rec."Transfer Order Nos.");
                //         end;
                //     }
                // }
            }
            group("Item Journal")
            {
                Caption = 'Item Journal';
                Visible = ItemJournalSetupVisible;
                // field("Def. Journal Template Name"; Rec."Def. Journal Template Name")
                // {
                //     Tooltip = 'Specifies the Def. Journal Template Name.';
                //     ApplicationArea = All;
                // }
                // field("Def. Journal Batch Name"; Rec."Def. Journal Batch Name")
                // {
                //     Tooltip = 'Specifies the Def. Journal Batch Name.';
                //     ApplicationArea = All;
                // }
                field("Entry Type"; Rec."Entry Type")
                {
                    Tooltip = 'Specifies the Entry Type.';
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    Tooltip = 'Specifies the Gen. Prod. Posting Group.';
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Tooltip = 'Specifies the Location Code.';
                    ApplicationArea = All;
                }
            }
            group("General Journal")
            {
                Caption = 'General Journal';
                Visible = GenJnlVisible;
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    Tooltip = 'Specifies the Journal Template Name.';
                    ApplicationArea = All;
                }
            }
            // group("Req. Worksheet")
            // {
            //     Caption = 'Req. Worksheet';
            //     Visible = ReqWorksheetSetupVisible;
            //     field("Def. Worksheet Template Name"; Rec."Def. Worksheet Template Name")
            //     {
            //         Tooltip = 'Specifies the Def. Worksheet Template Name.';
            //         ApplicationArea = All;
            //     }
            //     field("Def. Worksheet Jnl. Batch Name"; Rec."Def. Worksheet Jnl. Batch Name")
            //     {
            //         Tooltip = 'Specifies the Def. Worksheet Jnl. Batch Name.';
            //         ApplicationArea = All;
            //     }
            // }
        }
        area(factboxes)
        {
            systempart(Control29; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control28; Notes)
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord();
    begin
        SetupVisibility();
    end;

    trigger OnOpenPage();
    begin
        SetupVisibility();
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeries: Codeunit "No. Series";
        PurchaseSetupVisible: Boolean;
        TransferOrderSetupVisible: Boolean;
        ItemJournalSetupVisible: Boolean;
        PurchQuoteNosVisible: Boolean;
        PurchOrderNosVisible: Boolean;
        PurchInvoiceNosVisible: Boolean;
        GenJnlVisible: Boolean;

    local procedure SetupVisibility();
    begin
        PurchaseSetupVisible := false;
        TransferOrderSetupVisible := false;
        ItemJournalSetupVisible := false;
        PurchQuoteNosVisible := false;
        PurchOrderNosVisible := false;
        PurchInvoiceNosVisible := false;
        GenJnlVisible := false;

        case Rec.Type of
            Rec.Type::Purchase:
                PurchaseSetupVisible := true;
            Rec.Type::"Transfer Order":
                TransferOrderSetupVisible := true;
            Rec.Type::"Item Journal":
                ItemJournalSetupVisible := true;
            rec.Type::"General Journal":
                GenJnlVisible := true;
        end;

        // case Rec."Purchase Document Type" of
        //     Rec."Purchase Document Type"::Quote:
        //         PurchQuoteNosVisible := true;
        //     Rec."Purchase Document Type"::Order:
        //         PurchOrderNosVisible := true;
        //     Rec."Purchase Document Type"::Invoice:
        //         PurchInvoiceNosVisible := true;
        // end;
    end;
}

