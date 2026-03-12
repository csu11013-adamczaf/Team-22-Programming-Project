final int TABLE_PADDING = 10;
final int ROW_HEIGHT = 40;
final float ROW_DIVIDER_HEIGHT = 0.5;
final int HEADER_HEIGHT = 40;
float tableWidth;

class TableWidget
{
    int pageNumber = 0;
    Table flightData;
    PFont tableFont;
    float xPos;
    float yPos;

    TableWidget(int xPos, int yPos, String flightData)
    {
        this.xPos = xPos;
        this.yPos = yPos;
        this.flightData = loadTable(flightData);
        this.tableFont = loadFont("ArialMT-15.vlw");
        tableWidth = getColumnOffset(18);
    }

    void printWidget(int numberOfFlightsToDisplay)
    {
        fill(#F5F5DC);
        rect(xPos-TABLE_PADDING, yPos-HEADER_HEIGHT-TABLE_PADDING, tableWidth+TABLE_PADDING, numberOfFlightsToDisplay*ROW_HEIGHT+HEADER_HEIGHT+TABLE_PADDING, 10);
        printHeader();
        printFlights(numberOfFlightsToDisplay);
    }


    void printHeader()
    {
        fill(0);
        textFont(tableFont);
        for(int column = 0; column < flightData.getColumnCount(); column++)
        {
            text(flightData.getString(0, column), ((getColumnOffset(column))+xPos), yPos-HEADER_HEIGHT+20);
        }
    }

    void printFlights(int numberOfResults)
   {
    textFont(tableFont);
    fill(0);
    
    int relativeRow = 0;
    for(int row = (pageNumber*numberOfResults == 0 ? 1 : pageNumber*numberOfResults); row < (pageNumber+1)*numberOfResults; row++)
    {
        for(int column = 0; column < flightData.getColumnCount(); column++)
        {
            text(flightData.getString(row,column),((getColumnOffset(column))+xPos),((relativeRow*ROW_HEIGHT)+yPos+20));
        }
        rect(xPos-TABLE_PADDING, relativeRow*ROW_HEIGHT+yPos-5, tableWidth+TABLE_PADDING, ROW_DIVIDER_HEIGHT);
        relativeRow++;
    }

   }

   int getColumnWidth(int column)
   {    
        int columnWidth = 85;
        switch(column)
        {
            case 0: columnWidth = 120;
            break;
            case 1: columnWidth = 60;
            break;
            case 2: columnWidth = 100;
            break;
            case 3: columnWidth = 60;
            break;
            case 4: columnWidth = 180;
            break;
            case 5: columnWidth = 100;
            break;
            case 6: columnWidth = 40;
            break;
            case 7: columnWidth = 50;
            break;
            case 8: columnWidth = 220;
            break;
            case 9: columnWidth = 30;
            break;
            default: columnWidth = 80;
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