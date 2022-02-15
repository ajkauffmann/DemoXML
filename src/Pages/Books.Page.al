page 50000 BooksPTE
{
    PageType = List;
    SourceTable = BookPTE;
    SourceTableTemporary = true;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(Number; Rec.Number) { ApplicationArea = All; }
                field(Title; Rec.Title) { ApplicationArea = All; }
                field(Author; Rec.Author) { ApplicationArea = All; }
                field(ISBN; Rec.ISBN) { ApplicationArea = All; }
                field(Price; Rec.Price) { ApplicationArea = All; }
            }
        }
    }
}