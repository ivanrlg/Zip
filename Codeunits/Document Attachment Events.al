codeunit 53101 "Document Attachment Events"
{
    /// <summary>
    /// Event that is executed when opening the Attached Documents. 
    /// Initialize the record with the "No." according to the primary Key.
    /// OnDrillDown -> OnAfterOpenForRecRef
    /// </summary>
    /// <param name="DocumentAttachment"></param>
    /// <param name="RecRef"></param>
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            Database::Location:
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;

        end;
    end;

    /// <summary>
    /// Event that is executed when saving the record
    /// OnDrillDown -> InitiateUploadFile -> SaveAttachment -> InsertAttachment -> InitFieldsFromRecRef 
    /// </summary>
    /// <param name="DocumentAttachment"></param>
    /// <param name="RecRef"></param>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            Database::Location:
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;

        end;
    end;
}