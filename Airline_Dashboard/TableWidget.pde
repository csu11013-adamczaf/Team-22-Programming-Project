
class TableWidget
{
    int pageNumber = 0;
    Table flightData;
    PFont tableFont;
    int xPos;
    int yPos;
    static final float ROW_WIDTH = 40;

    TableWidget(int xPos, int yPos, String flightData)
    {
        this.xPos = xPos;
        this.yPos = yPos;
        this.flightData = loadTable(flightData, "header");
        this.tableFont = loadFont("ArialMT-15.vlw");
    }

    void printFlights(int numberOfResults)
   {
    fill(#F5F5DC);
    rect(xPos, yPos, getColumnOffset(18), numberOfResults*ROW_WIDTH);
    textFont(tableFont);

    int relativeRow = 0;
    for(int row = pageNumber*numberOfResults; row < (pageNumber+1)*numberOfResults; row++)
    {
        for(int column = 0; column < flightData.getColumnCount(); column++)
        {
            fill(0);
            text(flightData.getString(row,column),((getColumnOffset(column))+xPos),((relativeRow*40)+yPos+30));
        }
        relativeRow++;
    } 
   }

   int getColumnWidth(int column)
   {
        int columnWidth = 85;
        switch(column)
        {
            case 0: columnWidth = 150;
            break;
            case 1: columnWidth = 40;
            break;
            case 2: columnWidth = 50;
            break;
            case 3: columnWidth = 40;
            break;
            case 4: columnWidth = 220;
            break;
            case 5: columnWidth = 30;
            break;
            case 6: columnWidth = 40;
            break;
            case 7: columnWidth = 50;
            break;
            case 8: columnWidth = 220;
            break;
            case 9: columnWidth = 30;
            break;
            default: columnWidth = 50;
        }
        return columnWidth;
   }
   int getColumnOffset(int column)
   {
        int offset = 0;
        for(int index = 0; index < column; index++)
        {
            offset += getColumnWidth(index);
        }
        return offset;
   }
}