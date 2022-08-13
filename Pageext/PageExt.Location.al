pageextension 53102 "Location Ext" extends "Location Card"
{
    layout
    {
        addfirst(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(14),
                              "No." = FIELD(Code);
                Visible = true;
            }
        }
    }

    actions
    {
        addafter("Warehouse Employees")
        {
            action(Import)
            {
                Caption = 'Import Zip File';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ToolTip = 'Import Attachments from Zip';

                trigger OnAction()
                var
                    ImportCU: Codeunit Import;
                    FromRecRef: RecordRef;
                begin
                    //In this line we load the "RecordRef", here it would make it easier for us in case we want to use another list, such as Purch Order, 
                    //simply change the input parameter of this method with the relevant table.
                    FromRecRef.GETTABLE(Rec);

                    ImportCU.ImportAttachmentsFromZip(FromRecRef);
                end;
            }
        }
    }
}