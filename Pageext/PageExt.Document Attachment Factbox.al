pageextension 53101 "Doc Attachment Factbox Ext" extends "Document Attachment Factbox"
{
    Caption = 'Documents Attached';

    layout
    {
        modify(Documents)
        {
            trigger OnDrillDown()
            var
                Location: Record Location;
                DocumentAttachmentDetails: Page "Document Attachment Details";
                RecRef: RecordRef;
            begin
                case Rec."Table ID" of
                    Database::Location:
                        begin
                            RecRef.Open(Database::Location);
                            if Location.Get(Rec."No.") then
                                RecRef.GetTable(Location);
                        end;
                end;
                DocumentAttachmentDetails.OpenForRecRef(RecRef);
                DocumentAttachmentDetails.RunModal;
            end;
        }
    }
}