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
                field(Number; Rec.Number) { }
                field(Title; Rec.Title) { }
                field(Author; Rec.Author) { }
                field(Price; Rec.Price) { }
            }
        }
    }
}