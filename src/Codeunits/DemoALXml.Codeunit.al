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

        // if RootElement.SelectNodes('book', NodeList) then begin
        //     Message('Count: %1', NodeList.Count);
        //     exit;
        // end;

        // XmlNamespaceMgr := GetNamespaceManager(XmlDoc);
        foreach Node in RootElement.GetChildNodes() do begin
            // Message(GetNodeType(Node));
            // if Node.IsXmlElement then begin

            i += 1;

            Book.Init();
            Book.Number := i;

            ReadBook(Node, Book);
            // ReadBookWithNamespace(Node, XmlNamespaceMgr, Book);

            // Book.Insert();
            // end;
        end;
    end;

    local procedure ReadBook(BookNode: XmlNode; var Book: Record BookPTE)
    var
        Node: XmlNode;
        Attribute: XmlAttribute;
    begin
        if BookNode.AsXmlElement().Attributes().Get('ISBN', Attribute) then
            Book.ISBN := Attribute.Value
        else
            Book.ISBN := 'X-XXXXXX-XX-X';

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
        Attribute: XmlAttribute;
    begin
        if BookNode.AsXmlElement().Attributes().Get('ISBN', Attribute) then
            Book.ISBN := Attribute.Value
        else
            Book.ISBN := 'X-XXXXXX-XX-X';

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

    local procedure GetNodeType(Node: XmlNode) NodeType: Text;
    begin
        case true of
            Node.IsXmlAttribute:
                NodeType := 'Attribute';
            Node.IsXmlCData:
                NodeType := 'CData';
            Node.IsXmlComment:
                NodeType := 'Comment';
            Node.IsXmlDeclaration:
                NodeType := 'Declaration';
            Node.IsXmlDocument:
                NodeType := 'Document';
            Node.IsXmlDocumentType:
                NodeType := 'DocumentType';
            Node.IsXmlElement:
                NodeType := 'Element';
            Node.IsXmlProcessingInstruction:
                NodeType := 'ProcessingInstruction';
            Node.IsXmlText:
                NodeType := 'Text';
        end;
    end;
}