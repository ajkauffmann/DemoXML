var editor;
var beautify;

function Init() {
    ace.config.set("basePath", "https://cdnjs.cloudflare.com/ajax/libs/ace/1.12.5");
    editor = ace.edit("controlAddIn");
    editor.setOptions({
        printMargin: 150,        
        wrap: -1,
        indentedSoftWrap: false
    });

    beautify = ace.require("ace/ext/beatify");
}

function SetTheme(theme) {
    editor.setTheme("ace/theme/" + theme);
}

function SetMode(mode) {
    editor.session.setMode("ace/mode/" + mode);
}

function SetValue(value) {
    editor.setValue(value, -1);
    beautify.beautify(editor.session);
}

function GetValue() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('GetValueRequested', [editor.getValue()]);
}

function SetReadOnly(readOnly) {
    editor.setReadOnly(readOnly);
}

function PrettifyXml() {
    var xml = editor.getValue();
    xml = prettifyXml(xml);
    editor.setValue(xml, -1);
}

var prettifyXml = function(sourceXml) {
    var xmlDoc = new DOMParser().parseFromString(sourceXml, 'application/xml');
    var xsltDoc = new DOMParser().parseFromString([
      // describes how we want to modify the XML - indent everything
        '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">',
        '  <xsl:strip-space elements="*"/>',
        '  <xsl:template match="para[content-style][not(text())]">', // change to just text() to strip space in text nodes
        '    <xsl:value-of select="normalize-space(.)"/>',
        '  </xsl:template>',
        '  <xsl:template match="node()|@*">',
        '    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>',
        '  </xsl:template>',
        '  <xsl:output indent="yes"/>',
        '</xsl:stylesheet>',
    ].join('\n'), 'application/xml');

    var xsltProcessor = new XSLTProcessor();    
    xsltProcessor.importStylesheet(xsltDoc);
    var resultDoc = xsltProcessor.transformToDocument(xmlDoc);
    var resultXml = new XMLSerializer().serializeToString(resultDoc);
    return resultXml;
};