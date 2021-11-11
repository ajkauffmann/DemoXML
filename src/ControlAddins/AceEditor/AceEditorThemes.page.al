page 50003 AceEditorThemesPTE
{
    PageType = ListPart;
    SourceTable = Integer;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(themes)
            {
                field(Name; Format(Enum::AceEditorThemePTE.FromInteger(Rec.Number)))
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    Style = Strong;
                    StyleExpr = IsCurrentTheme;

                    trigger OnDrillDown()
                    begin
                        CurrentTheme := Enum::AceEditorThemePTE.FromInteger(Rec.Number);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        CurrentTheme: Enum AceEditorThemePTE;
        IsCurrentTheme: Boolean;

    trigger OnInit()
    begin
        Rec.SetRange(Number, 1, Enum::AceEditorThemePTE.Names().Count);
    end;

    trigger OnAfterGetRecord()
    begin
        IsCurrentTheme := Enum::AceEditorThemePTE.FromInteger(Rec.Number) = CurrentTheme;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsCurrentTheme := Enum::AceEditorThemePTE.FromInteger(Rec.Number) = CurrentTheme;
    end;

    procedure GetSelectedTheme(): Enum AceEditorThemePTE
    begin
        exit(CurrentTheme);
    end;

    procedure SetTheme(Theme: Enum AceEditorThemePTE)
    begin
        CurrentTheme := Theme;
        Rec.Get(Theme.AsInteger());
        CurrPage.Update(false);
    end;
}