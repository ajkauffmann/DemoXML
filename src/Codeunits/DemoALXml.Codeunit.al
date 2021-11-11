codeunit 50001 DemoALXmlPTE
{
    var
        XmlDataLibrary: Codeunit XmlDataLibraryPTE;

    procedure ReadBooks(xml: Text; var Book: Record BookPTE)
    var
        XmlDoc: XmlDocument;
        RootElement: XmlElement;
        Node: XmlNode;
        Node2: XmlNode;
        Element: XmlElement;
        NodeList: XmlNodeList;
        XmlNamespaceMgr: XmlNamespaceManager;
        i: Integer;
    begin
        Book.DeleteAll();

        if not XmlDocument.ReadFrom(xml, XmlDoc) then
            Error('Invalid xml');

        if not XmlDoc.GetRoot(RootElement) then
            Error('Xml is empty');

        XmlNamespaceMgr := GetNamespaceManager(XmlDoc);

        // if RootElement.SelectNodes('bookx', NodeList) then begin
        //     Message('Count: %1', NodeList.Count);
        // end;

        foreach Node in RootElement.GetChildNodes() do begin
            if Node.IsXmlElement then begin

                i += 1;

                Book.Init();
                Book.Number := i;

                // ReadBook(Node, Book);
                ReadBookWithNamespace(Node, XmlNamespaceMgr, Book);

                Book.Insert();
            end;
        end;
    end;

    local procedure ReadBook(BookNode: XmlNode; var Book: Record BookPTE)
    var
        Node: XmlNode;
    begin
        BookNode.SelectSingleNode('title', Node);
        Book.Title := Node.AsXmlElement().InnerText;

        if BookNode.SelectSingleNode('author/first-name', Node) then begin
            Book.Author := Node.AsXmlElement().InnerText;

            BookNode.SelectSingleNode('author/last-name', Node);
            Book.Author += ' ' + Node.AsXmlElement().InnerText;
        end else begin
            BookNode.SelectSingleNode('author/name', Node);
            Book.Author := Node.AsXmlElement().InnerText;
        end;

        BookNode.SelectSingleNode('price', Node);
        Evaluate(Book.Price, Node.AsXmlElement().InnerText);
    end;

    local procedure GetNamespaceManager(XmlDoc: XmlDocument) XmlNamespaceMgr: XmlNamespaceManager
    begin
        XmlNamespaceMgr.NameTable := XmlDoc.NameTable;
        XmlNamespaceMgr.AddNamespace('ddc', XmlDataLibrary.GetNamespace());
    end;

    local procedure ReadBookWithNamespace(BookNode: XmlNode; XmlNamespaceMgr: XmlNamespaceManager; var Book: Record BookPTE)
    var
        Node: XmlNode;
    begin
        BookNode.SelectSingleNode('ddc:title', XmlNamespaceMgr, Node);
        Book.Title := Node.AsXmlElement().InnerText;

        if BookNode.SelectSingleNode('ddc:author/ddc:first-name', XmlNamespaceMgr, Node) then begin
            Book.Author := Node.AsXmlElement().InnerText;

            BookNode.SelectSingleNode('ddc:author/ddc:last-name', XmlNamespaceMgr, Node);
            Book.Author += ' ' + Node.AsXmlElement().InnerText;
        end else begin
            BookNode.SelectSingleNode('ddc:author/ddc:name', XmlNamespaceMgr, Node);
            Book.Author := Node.AsXmlElement().InnerText;
        end;

        BookNode.SelectSingleNode('ddc:price', XmlNamespaceMgr, Node);
        Evaluate(Book.Price, Node.AsXmlElement().InnerText);
    end;
}