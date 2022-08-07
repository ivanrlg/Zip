pageextension 53100 SalesOrderListExt extends "Sales Order List"
{
    actions
    {
        addafter("&Order Confirmation")
        {
            action(Import)
            {
                Caption = 'Import Zip File';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Import;
                ToolTip = 'Import Attachments from Zip';

                trigger OnAction()
                var
                    ImportCU: Codeunit Import;
                begin
                    ImportCU.ImportAttachmentsFromZip(Rec);
                end;
            }
        }
    }
}