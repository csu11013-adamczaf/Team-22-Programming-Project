import java.lang.Math;

final int HORIZONTAL_PADDING = 20;
final int HEADER_PADDING = 24;
final int FLIGHT_DATA_PADDING = 15;
final int TABLE_Y_OFFSET = 10;
final int ROW_HEIGHT = 30;
final float ROW_DIVIDER_HEIGHT = 0.5;
final int HEADER_HEIGHT = 40;
PFont tableFont;
PFont headerFont;

// See GitHub Repo Wiki for detailed info on this class:
// https://github.com/csu11013-adamczaf/Team-22-Programming-Project/wiki/TableWidget-class

class TableWidget
{
    public float xPos = 0;
    private int currentPage = 0;
    private float yPos = 0;
    private int maxPageNumber;
    private int numberOfFlightsToDisplay;
    private Table flightData;
    private float tableWidth = getColumnOffset(18);
    private float tableHeight;   

    // Creates a table widget object with parameters, sets up required fonts.
    // For columns 15 and 16, changes the boolean value "0" and "1" to "YES" and "NO" for a more polished look
    TableWidget(String flightData)
    {
        this.flightData = loadTable(flightData);
        tableFont = loadFont(Visuals.TABLEWIDGET_TABLE_FONT);
        headerFont = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);

        for(int row = 1; row < this.flightData.getRowCount(); row++)
        {
            for(int column = 15; column <= 16; column++)
            {
                if((this.flightData.getString(row, column)).equals("1"))
                {
                    this.flightData.setString(row, column, "YES");
                }
                else
                {
                    this.flightData.setString(row, column, "NO");
                }
            }
        }
    }

    // Accessor methods for private variables;
    public int getMaxPage()
    {
        return maxPageNumber;
    }
    public float getXPos()
    {
        return xPos;
    }
        public int getCurrentPage()
    {
        return currentPage;
    }
    public float getTableWidth()
    {
        return tableWidth;
    }
    public float getTableHeight()
    {
        return tableHeight;
    }

    // Methods for traversing between pages
    public void nextPage()
    {
        if(currentPage < (((flightData.getRowCount()-1) % numberOfFlightsToDisplay != 0 && flightData.getRowCount()-1 > numberOfFlightsToDisplay*(maxPageNumber+1)) ? maxPageNumber+1 : maxPageNumber))
        {
            currentPage++;
        }
        else
        {
            currentPage = 0;
        }
    }

    public void previousPage()
    {
        if(currentPage > 0)
        {
            currentPage--;
        }
        else
        {
            currentPage = ((flightData.getRowCount()-1) % numberOfFlightsToDisplay != 0 && flightData.getRowCount()-1 > numberOfFlightsToDisplay*(maxPageNumber+1)) ? maxPageNumber+1 : maxPageNumber;
        }
    }

     public void setCurrentPage(int newPage)
    {
        if(newPage >=0 && newPage <= maxPageNumber)
        {
            currentPage = newPage;
        }
    }
    public void setXPos(float xPos)
    {
        this.xPos = xPos;
    }

    // Prints the header row and flight data to the screen. 
    // Sets table height and number of pages based on number of flights to be displayed.
    public void printWidget(int numberOfFlightsToDisplay)
    {
        this.numberOfFlightsToDisplay = numberOfFlightsToDisplay;
        maxPageNumber = (flightData.getRowCount() / numberOfFlightsToDisplay)-1;
        tableHeight = (numberOfFlightsToDisplay * ROW_HEIGHT) + HEADER_HEIGHT;
        yPos = height-TABLE_Y_OFFSET-tableHeight;
        
        stroke(Visuals.GLOBAL_STROKE_COLOUR_DARK);
        fill(#1C2C48);
        rect(xPos, yPos, tableWidth + HORIZONTAL_PADDING, tableHeight, 10);
        fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        printHeader();
        printFlights(numberOfFlightsToDisplay);
    }

    // Works like the printWidget() method, but allows for two buttons to be specified.
    // The positions of these buttons move with the table, so they are in the same spot regardless of the table position.
    public void printWidget(int numberOfFlightsToDisplay, Button prevButton, Button nextButton)
    {
        printWidget(numberOfFlightsToDisplay);
        prevButton.btnY = this.yPos- prevButton.btnH -Visuals.SPACE_BETWEEN_BUTTONS;
        prevButton.btnX = this.xPos;
        nextButton.btnX = this.xPos+prevButton.btnW+Visuals.SPACE_BETWEEN_BUTTONS;
        nextButton.btnY = this.yPos-btnH-Visuals.SPACE_BETWEEN_BUTTONS;
    }

    // Prints the header of the table to the screen
    private void printHeader()
    {
        textFont(headerFont);
        for(int column = 0; column < flightData.getColumnCount(); column++)
        {
            text(flightData.getString(0, column), ((getColumnOffset(column)) + xPos + HORIZONTAL_PADDING), yPos + HEADER_PADDING);
        }
    }

    // Prints the flight rows of the table to the screen based on number of results and the current page number.
    // Formats text conditionally - cancelled flights in red and diverted flights in yellow.
    private void printFlights(int numberOfResults)
   {

    int relativeRow = 0;
    for(int row = (currentPage == 0 ? 1 : (currentPage*numberOfResults)+1); row <= (currentPage+1)*numberOfResults && row < flightData.getRowCount(); row++)
    {
        float flightDataXPos = 0;
        float flightDataYPos = 0;

        for(int column = 0; column < flightData.getColumnCount(); column++)
        {
            if((flightData.getString(row, 15)).equals("YES"))
            {
                fill(#FF0000);
                textFont(headerFont);
            }
            else if((flightData.getString(row, 16)).equals("YES"))
            {
                fill(#F5DD27);
                textFont(headerFont);
            }
            else
            {
                fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
                textFont(tableFont);
            }
            flightDataXPos = (getColumnOffset(column)) + xPos + HORIZONTAL_PADDING;
            flightDataYPos = (relativeRow*ROW_HEIGHT) + yPos + HEADER_HEIGHT + FLIGHT_DATA_PADDING;
            
            text(flightData.getString(row,column),flightDataXPos,flightDataYPos);
        }
        rect(xPos, relativeRow*ROW_HEIGHT+yPos-5+HEADER_HEIGHT, tableWidth+HORIZONTAL_PADDING, ROW_DIVIDER_HEIGHT);
        relativeRow++;
        
    }

   }

   // Returns the width of each column 
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

   // Returns sum of widths of preceding columns to be used as an offset.
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