codeunit 50003 DemoCreateXmlPTE
{
    procedure CreateXmlFromSalesHeader(SalesHeader: Record "Sales Header") Element: XmlElement
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldRec: Record Field;
        FieldElm: XmlElement;
    begin
        Element := XmlElement.Create('SalesHeader');

        RecRef.GetTable(SalesHeader);
        GetFields(RecRef, FieldRec);

        if FieldRec.FindSet() then
            repeat
                FieldElm := XmlElement.Create(GetSafeXmlName(FieldRec.FieldName));
                FieldElm.Add(XmlAttribute.Create('FieldNo', Format(FieldRec."No.")));

                FldRef := RecRef.Field(FieldRec."No.");
                if FieldRec.Class = FieldRec.Class::FlowField then
                    FldRef.CalcField();

                FieldElm.Add(XmlText.Create(Format(FldRef.Value)));

                Element.Add(FieldElm);
            until FieldRec.Next() = 0;

        Element.Add(GetSalesLineXml(SalesHeader));
    end;

    local procedure GetSalesLineXml(SalesHeader: Record "Sales Header") Element: XmlElement
    var
        SalesLine: Record "Sales Line";
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldRec: Record Field;
        LineElm: XmlElement;
        FieldElm: XmlElement;
    begin
        Element := XmlElement.Create('SalesLines');

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                RecRef.GetTable(SalesLine);
                GetFields(RecRef, FieldRec);

                LineElm := XmlElement.Create('SalesLine');

                if FieldRec.FindSet() then
                    repeat
                        FieldElm := XmlElement.Create(GetSafeXmlName(FieldRec.FieldName));
                        FieldElm.Add(XmlAttribute.Create('FieldNo', Format(FieldRec."No.")));

                        FldRef := RecRef.Field(FieldRec."No.");
                        if FieldRec.Class = FieldRec.Class::FlowField then
                            FldRef.CalcField();

                        FieldElm.Add(XmlText.Create(Format(FldRef.Value)));

                        LineElm.Add(FieldElm);
                    until FieldRec.Next() = 0;
                Element.Add(LineElm);
            until SalesLine.Next() = 0;
    end;

    local procedure GetFields(RecRef: RecordRef; var FieldRec: Record Field)
    begin
        FieldRec.SetRange(TableNo, RecRef.Number);
        FieldRec.SetRange(Enabled, true);
        FieldRec.SetRange(ObsoleteState, FieldRec.ObsoleteState::No);
        FieldRec.SetFilter(Class, '%1|%2', FieldRec.Class::Normal, FieldRec.Class::FlowField);
    end;

    local procedure GetSafeXmlName(Value: Text) Result: Text
    begin
        Result := Value.Replace(' ', '')
                       .Replace('\', '')
                       .Replace('/', '')
                       .Replace('"', '')
                       .Replace('_', '')
                       .Replace('%', '')
                       .Replace('(', '')
                       .Replace(')', '')
                       .Replace('$', '')
                       .Replace('.', '')
                       .Replace('-', '');
    end;
}