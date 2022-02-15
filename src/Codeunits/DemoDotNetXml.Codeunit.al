codeunit 50000 DemoDotNetXmlPTE
{
    var
        XmlDataLibrary: Codeunit XmlDataLibraryPTE;

    procedure ReadBooks(xml: Text; var Book: Record BookPTE)
    var
        DotNetXmlDocument: DotNet XmlDocument;
        RootElement: DotNet XmlElement;
        Element: DotNet XmlElement;
        Node: DotNet XmlNode;
        i: Integer;
    begin
        Book.DeleteAll();

        DotNetXmlDocument := DotNetXmlDocument.XmlDocument();
        DotNetXmlDocument.LoadXml(xml);
        RootElement := DotNetXmlDocument.DocumentElement;

        for i := 0 to RootElement.ChildNodes.Count - 1 do begin
            Node := RootElement.ChildNodes.Item(i);

            Book.Init();
            Book.Number := i + 1;

            Book.ISBN := Node.Attributes.GetNamedItem('ISBN').Value;
            Element := Node.SelectSingleNode('title');
            Book.Title := Element.InnerText;

            Element := Node.SelectSingleNode('author/first-name');
            if not IsNull(Element) then begin
                Book.Author := Element.InnerText;

                Element := Node.SelectSingleNode('author/last-name');
                Book.Author += ' ' + Element.InnerText;
            end else begin
                Element := Node.SelectSingleNode('author/name');
                Book.Author := Element.InnerText;
            end;

            Element := Node.SelectSingleNode('price');
            Evaluate(Book.Price, Element.InnerText);

            Book.Insert();
        end;
    end;


}