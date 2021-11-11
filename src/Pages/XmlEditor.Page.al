page 50004 XmlEditorPTE
{
    PageType = Card;
    Caption = 'XML Editor 🐱‍💻';
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {

            group(Editor1Group)
            {
                ShowCaption = false;
                usercontrol(Editor1; AceEditorPTE)
                {
                    ApplicationArea = All;

                    trigger ControlAddInReady()
                    begin
                        EditorControlIsReady := true;
                        InitEditor();
                    end;

                    trigger GetValueRequested(value: Text)
                    var
                        Selection: Integer;
                    begin
                        Editor1Value := value;
                        Selection := StrMenu('DotNet, AL');
                        case Selection of
                            1:
                                ReadBooksDotNet(value);
                            2:
                                ReadBooksAL(value);
                        end
                    end;
                }
            }
        }

        area(FactBoxes)
        {
            part(EditorModes; AceEditorModesPTE)
            {
                Caption = 'Modes';
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
            part(EditorThemes; AceEditorThemesPTE)
            {
                Caption = 'Themes';
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadFileAction)
            {
                Caption = 'Load file';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    LoadFile();
                end;
            }
            action(PrettifyXml)
            {
                Caption = 'Prettify XML';
                ApplicationArea = All;
                Image = XMLSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = CurrentMode = CurrentMode::xml;

                trigger OnAction()
                begin
                    CurrPage.Editor1.PrettifyXml();
                end;
            }
            action(InitXmlAction)
            {
                Caption = 'Init XML';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.Editor1.SetValue(XmlDataLibrary.GetValidXml());
                end;
            }
            action(DemoAction)
            {
                Caption = 'Demo';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Editor1Value := '';
                    CurrPage.Editor1.GetValue();
                end;
            }
            action(CreateXmlAction)
            {
                Caption = 'Create XML';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CreateXml();
                end;
            }
        }
    }

    var
        FileMgt: Codeunit "File Management";
        FileContent: Codeunit "Temp Blob";
        EditorControlIsReady, EditorControl2IsReady : Boolean;
        XmlDataLibrary: Codeunit XmlDataLibraryPTE;
        LoadFileCaptionTxt: Label 'Select a file';
        FileFilterTxt: Label 'All Files (*.*)|*.*';
        ExtFilterTxt: Label '';
        CurrentTheme: Enum AceEditorThemePTE;
        CurrentMode: Enum AceEditorModePTE;
        Editor1Value, Editor2Value : Text;

    trigger OnAfterGetRecord()
    begin
        SetEditorMode();
        SetEditorTheme();
    end;

    local procedure InitEditor()
    var
    begin
        if not EditorControlIsReady then
            exit;

        CurrPage.Editor1.Init();
        CurrPage.Editor1.SetValue(XmlDataLibrary.GetValidXml());

        CurrPage.EditorModes.Page.SetMode(Enum::AceEditorModePTE::xml);
        SetEditorMode();
        CurrPage.EditorThemes.Page.SetTheme(Enum::AceEditorThemePTE::sqlserver);
        SetEditorTheme();
    end;

    // local procedure InitEditor2()
    // begin
    //     if not EditorControl2IsReady then
    //         exit;

    //     CurrPage.Editor2.Init();
    //     CurrPage.Editor2.SetMode('xml');
    //     CurrPage.Editor2.SetTheme('monokai');
    // end;

    local procedure SetEditorMode()
    var
        Mode: Enum AceEditorModePTE;
    begin
        if not EditorControlIsReady then
            exit;

        Mode := CurrPage.EditorModes.Page.GetSelectedMode();
        if Mode <> CurrentMode then begin
            CurrPage.Editor1.SetMode(Mode.Names.Get(Mode.Ordinals.IndexOf(Mode.AsInteger())));
            // CurrPage.Editor2.SetMode(Mode.Names.Get(Mode.Ordinals.IndexOf(Mode.AsInteger())));
            CurrentMode := Mode;
        end;
    end;

    local procedure SetEditorTheme()
    var
        Theme: Enum AceEditorThemePTE;
    begin
        if not EditorControlIsReady then
            exit;

        Theme := CurrPage.EditorThemes.Page.GetSelectedTheme();
        if Theme <> CurrentTheme then begin
            CurrPage.Editor1.SetTheme(Theme.Names.Get(Theme.Ordinals.IndexOf(Theme.AsInteger())));
            // CurrPage.Editor2.SetTheme(Theme.Names.Get(Theme.Ordinals.IndexOf(Theme.AsInteger())));
            CurrentTheme := Theme;
        end;
    end;

    local procedure LoadFile()
    var
        Filename: Text;
        Content: Text;
        Mode: Enum AceEditorModePTE;
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
        InFile: File;
    begin
        Clear(FileContent);
        Filename := FileMgt.BLOBImport(FileContent, '');

        if Filename <> '' then begin

            case FileMgt.GetExtension(Filename) of
                'xml':
                    Mode := Mode::xml;
                'json':
                    Mode := Mode::json;
                'txt':
                    Mode := Mode::text;
                'js':
                    Mode := Mode::javascript;
                else
                    Mode := Mode::text;
            end;

            Content := GetContent();
            CurrPage.EditorModes.Page.SetMode(Mode);
            SetEditorMode();
            CurrPage.Editor1.SetValue(Content);
        end;
    end;

    local procedure GetContent(InStr: InStream) Content: Text
    var
        XmlDoc: XmlDocument;
        Declaration: XmlDeclaration;
        Line: Text;
        TxtBuilder: TextBuilder;
    begin
        if not XmlDocument.ReadFrom(InStr, XmlDoc) then
            Message('Could not read XML');
        // InStr.Read(Line);
        while not InStr.EOS do begin
            InStr.ReadText(Line);
            TxtBuilder.AppendLine(Line);
        end;

        Content := TxtBuilder.ToText();

        XmlDocument.ReadFrom(Content, XmlDoc);
        Declaration := XmlDeclaration.create('1.0', 'UTF-8', 'yes');
        XmlDoc.SetDeclaration(Declaration);
        XmlDoc.WriteTo(Content);

    end;

    local procedure GetContent() Content: Text;
    var
        InStr: InStream;
        Line: Text;
        TxtBuilder: TextBuilder;
        xmldoc: XmlDocument;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FileMgt: Codeunit "File Management";
    begin
        FileContent.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, xmldoc) then begin
            FileContent.CreateInStream(InStr, TextEncoding::Windows);
            XmlDocument.ReadFrom(InStr, xmldoc);
            while not InStr.EOS do begin
                InStr.ReadText(Line);
                TxtBuilder.AppendLine(Line);
            end;
            Content := TxtBuilder.ToText();
            XmlDocument.ReadFrom(Content, xmldoc);
        end;
        XmlDoc.WriteTo(Content);
    end;

    local procedure ReadBooksDotNet(xml: Text)
    var
        Book: Record BookPTE temporary;
        DemoDotNetXml: Codeunit DemoDotNetXmlPTE;
    begin
        DemoDotNetXml.ReadBooks(xml, Book);
        Page.Run(Page::BooksPTE, Book);
    end;

    local procedure ReadBooksAL(xml: Text)
    var
        Book: Record BookPTE temporary;
        DemoALXml: Codeunit DemoALXmlPTE;
    begin
        DemoALXml.ReadBooks(xml, Book);
        Page.Run(Page::BooksPTE, Book);
    end;

    local procedure CreateXml()
    var
        SalesHeader: Record "Sales Header";
        DemoCreateXml: Codeunit DemoCreateXmlPTE;
        Element: XmlElement;
        xml: Text;
        XmlDoc: XmlDocument;
    begin
        SalesHeader.FindFirst();
        Element := DemoCreateXml.CreateXmlFromSalesHeader(SalesHeader);
        // Element.WriteTo(xml);

        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        XmlDoc.Add(Element);
        XmlDoc.WriteTo(xml);

        CurrPage.Editor1.SetValue(xml);

    end;
}