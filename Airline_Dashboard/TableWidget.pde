final int TABLE_PADDING = 10;
final int ROW_HEIGHT = 30;
final float ROW_DIVIDER_HEIGHT = 0.5;
final int HEADER_HEIGHT = 40;
float tableWidth;

class TableWidget
{
    private Table flightData;
    private PFont tableFont;
    public int pageNumber = 0;
    public float xPos;
    public float yPos;

    TableWidget(int xPos, int yPos, String flightData)
    {
        this.xPos = xPos;
        this.yPos = yPos;
        this.flightData = loadTable(flightData);
        this.tableFont = loadFont("ArialMT-10.vlw");
        tableWidth = getColumnOffset(18);
    }

    public void printWidget(int numberOfFlightsToDisplay)
    {
        fill(#F5F5DC);
        stroke(0);
        rect(xPos-TABLE_PADDING, yPos-HEADER_HEIGHT-TABLE_PADDING, tableWidth+TABLE_PADDING, numberOfFlightsToDisplay*ROW_HEIGHT+HEADER_HEIGHT+TABLE_PADDING, 10);
        printHeader();
        printFlights(numberOfFlightsToDisplay);
    }


    private void printHeader()
    {
        fill(0);
        textFont(tableFont);
        for(int column = 0; column < flightData.getColumnCount(); column++)
        {
            text(flightData.getString(0, column), ((getColumnOffset(column))+xPos), yPos-HEADER_HEIGHT+20);
        }
    }

    private void printFlights(int numberOfResults)
   {
    textFont(tableFont);
    
    int relativeRow = 0;
    for(int row = (pageNumber == 0 ? 1 : pageNumber*numberOfResults+1); row <= (pageNumber+1)*numberOfResults; row++)
    {
        if(row >= flightData.getRowCount())
        {
            pageNumber = 0;
        }
        else{
            for(int column = 0; column < flightData.getColumnCount(); column++)
            {
                text(flightData.getString(row,column),((getColumnOffset(column))+xPos),((relativeRow*ROW_HEIGHT)+yPos+15));
            }
            rect(xPos-TABLE_PADDING, relativeRow*ROW_HEIGHT+yPos-5, tableWidth+TABLE_PADDING, ROW_DIVIDER_HEIGHT);
            relativeRow++;
        }
    }

   }

   private int getColumnWidth(int column)
   {    
        int columnWidth = 85;
        switch(column)
        {
            case 0: columnWidth = 110;
            break;
            case 1: columnWidth = 50;
            break;
            case 2: columnWidth = 80;
            break;
            case 3: columnWidth = 60;
            break;
            case 4: columnWidth = 130;
            break;
            case 5: columnWidth = 80;
            break;
            case 6: columnWidth = 70;
            break;
            case 7: columnWidth = 80;
            break;
            case 8: columnWidth = 130;
            break;
            case 9: columnWidth = 100;
            break;
            case 10: columnWidth = 90;
            break;
            case 11: columnWidth = 90;
            break;
            case 12: columnWidth = 90;
            break;
            case 13: columnWidth = 90;
            break;
            case 14: columnWidth = 70;
            break;
            case 15: columnWidth = 65;
            break;
            default: columnWidth = 50;
        }
        return columnWidth;
   }
   private int getColumnOffset(int column)
   {
        int offset = 0;
        for(int index = 0; index < column; index++)
        {
            offset += getColumnWidth(index);
        }
        return offset;
   }
}