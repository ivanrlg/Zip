codeunit 53100 Import
{
    trigger OnRun()
    begin
    end;

    var
        FileManagement: Codeunit "File Management";

    procedure ImportAttachmentsFromZip(var SalesHeader: Record "Sales Header")
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        FromRecRef: RecordRef;
        Window: Dialog;
        DocStream: InStream;
        InStream: InStream;
        Count: Integer;
        Length: Integer;
        Msg: Label 'It has been attached successfully.';
        NoContentErr: Label 'The selected file has no content. Please choose another file.';
        SelectZIPFileMsg: Label 'Select ZIP File';
        EntryList: List of [Text];
        EntryOutStream: OutStream;
        EntryListKey: Text;
        FileExtension: Text;
        FileName: Text;
        ZipFileName: Text;
    begin
        //This method first uses the BLOBImportWithFilter procedure of the "File Management" codeunit
        //that allows reading the .zip and temporarily storing it in TempBlob: Codeunit "Temp Blob".
        if FileManagement.BLOBImportWithFilter(TempBlob, SelectZIPFileMsg, '', 'Zip Files|*.zip', '*.*') = '' then
            Error('');

        //If there is no information, we inform the user.
        if not TempBlob.HasValue then
            Error(NoContentErr);

        //The "Data Compression" Codeunit is then used to uncompress the file.
        DataCompression.OpenZipArchive(TempBlob, false);
        DataCompression.GetEntryList(EntryList);

        Window.Open('#1##############################');

        Count := 1;

        //We iterate over the list of files contained in the .zip
        foreach EntryListKey in EntryList do begin
            Clear(TempBlob);

            //We get the name and extension of each file.
            FileName := CopyStr(FileManagement.GetFileNameWithoutExtension(EntryListKey), 1, MaxStrLen(FileName));
            FileExtension := CopyStr(FileManagement.GetExtension(EntryListKey), 1, MaxStrLen(FileExtension));

            //We verify that there are no empty names or extensions.
            if (FileName <> '') and (FileExtension <> '') then begin

                //We read in an InStream variable the information of the file.
                TempBlob.CreateOutStream(EntryOutStream);
                DataCompression.ExtractEntry(EntryListKey, EntryOutStream, Length);
                TempBlob.CreateInStream(DocStream);

                //In this line we load the "RecordRef", here it would make it easier for us in case we want to use another list, such as Purch Order, 
                //simply change the input parameter of this method with the relevant table.
                FromRecRef.GETTABLE(SalesHeader);

                //We verify that the file that is iterating is not empty
                if TempBlob.HasValue then

                    //We insert in the Record "Document Attachment"
                    if InsertAttachment(DocStream, FromRecRef, FileName, FileExtension) then begin

                        //We are informing the user of the newly processed file.
                        Window.Update(1, FileName);
                        Count += 1;
                    end;
            end
        end;

        //We inform the user if the .zip files were really attached
        if Count > 1 then
            Message(Msg);

        DataCompression.CloseZipArchive();
        Window.Close;
    end;

    local procedure InsertAttachment(DocStream: InStream; RecRef: RecordRef; FileName: Text; FileExtension: Text): Boolean;
    var
        DocAttach: Record "Document Attachment";
    begin

        //We must notify the name and extension of the file and validate that they are acceptable.
        DocAttach.Validate("File Name", FileName);
        DocAttach.Validate("File Extension", FileExtension);

        //This line is where we will actually attach the file.
        DocAttach."Document Reference ID".ImportStream(DocStream, '');
        if not DocAttach."Document Reference ID".HasValue then
            exit(false);

        //Depending on the table we are using, this procedure will insert the information 
        //of "Table ID", "Document Type" and "No.", as appropriate.
        DocAttach.InitFieldsFromRecRef(RecRef);

        OnBeforeInsertAttachment(DocAttach, RecRef);

        exit(DocAttach.Insert(true));
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
    end;
}