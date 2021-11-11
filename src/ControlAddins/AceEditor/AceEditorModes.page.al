page 50002 AceEditorModesPTE
{
    PageType = ListPart;
    SourceTable = Integer;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(modes)
            {
                field(Name; Format(Enum::AceEditorModePTE.FromInteger(Rec.Number)))
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    Style = Strong;
                    StyleExpr = IsCurrentMode;

                    trigger OnDrillDown()
                    begin
                        CurrentMode := Enum::AceEditorModePTE.FromInteger(Rec.Number);
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    var
        CurrentMode: Enum AceEditorModePTE;
        IsCurrentMode: Boolean;

    trigger OnInit()
    begin
        Rec.SetRange(Number, 1, Enum::AceEditorModePTE.Names().Count);
    end;

    trigger OnAfterGetRecord()
    begin
        IsCurrentMode := Enum::AceEditorModePTE.FromInteger(Rec.Number) = CurrentMode;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsCurrentMode := Enum::AceEditorModePTE.FromInteger(Rec.Number) = CurrentMode;
    end;


    procedure GetSelectedMode(): Enum AceEditorModePTE;
    begin
        exit(CurrentMode);
    end;

    procedure SetMode(Mode: Enum AceEditorModePTE)
    begin
        CurrentMode := Mode;
        Rec.Get(Mode.AsInteger());
        CurrPage.Update(false);
    end;
}