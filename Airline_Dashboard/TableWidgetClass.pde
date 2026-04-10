import java.lang.Math;
import java.util.ArrayList;

final int HORIZONTAL_PADDING = 20;
final int HEADER_PADDING = 24;
final int FLIGHT_DATA_PADDING = 15;
final int TABLE_Y_OFFSET = 10;
final int ROW_HEIGHT = 30;
final float ROW_DIVIDER_HEIGHT = 0.5;
final int HEADER_HEIGHT = 40;

// See GitHub Repo Wiki for detailed info on this class:
// https://github.com/csu11013-adamczaf/Team-22-Programming-Project/wiki/TableWidget-class

class TableWidget
{
    public float xPos = 0;
    private int currentPage = 0;
    private float yPos = 0;
    private int maxPageNumber;
    private Table flightData;
    private float tableWidth;
    private float tableHeight;
    private ArrayList<Integer> columnsToPrint = new ArrayList<>();
    private int[] columnWidths = {110, 50, 80, 60, 130, 80, 70, 80, 130, 100, 90, 90, 90, 90, 70, 65, 65, 65};

    // Creates a table widget object with parameters, sets up required fonts.
    // For columns 15 and 16, changes the boolean value "0" and "1" to "YES" and "NO" for a more polished look
    // If a cell is empty, fills it with "NO DATA" to avoid blank cells in the table.
    TableWidget(String flightData)
    {
        this.flightData = loadTable(flightData);

        for (int row = 1; row < this.flightData.getRowCount(); row++)
        {
            for (int column = 0; column <= 17; column++)
            {
                String currentCell = this.flightData.getString(row, column);
                if(currentCell.equals(null) || currentCell.equals(""))
                {
                    this.flightData.setString(row,column, "NO DATA");
                }

                if(column == 15 || column == 16)
                {
                    if (currentCell.equals("1"))
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
        // By default, all columns are printed. This can be changed with the setColumnsToPrint method.
        int[] temp = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18};
        setColumnsToPrint(temp);
        updateTableWidth();
    }
    // Alternate constructor for creating a table widget with a pre-loaded Table object, e.g. for query results. This skips the data cleaning steps in the first constructor, as the data is already cleaned when the query is made.
    TableWidget(Table table, float xPos)
    {
        this.xPos = xPos;
        this.flightData = table;
        int[] temp = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18};
        setColumnsToPrint(temp);
        updateTableWidth();
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

    public float getYPos()
    {
        return yPos;
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

    // Exposes the loaded Table so Graphs can read column data without making flightData public.
    public Table getData()
    {
        return flightData;
    }

    // Methods for traversing between pages
    public void nextPage()
    {
        if (currentPage < maxPageNumber)
            currentPage++;
        else
            currentPage = 0;
    }

    public void previousPage()
    {
        if (currentPage > 0)
            currentPage--;
        else
            currentPage = maxPageNumber;
    }

    public void setCurrentPage(int newPage)
    {
        if (newPage >= 0 && newPage <= maxPageNumber)
            currentPage = newPage;
    }

    // Setters for x and y position. The setYPos method only works if the y position is not being set by printWidget() i.e. override is set to true when calling printWidget.
    public void setXPos(float xPos)
    {
        this.xPos = xPos;
    }
    public void setYPos(float yPos)
    {
        this.yPos = yPos;
    }

    // Updates the table width based on the columns currently being printed. Called whenever the columnsToPrint variable is updated.
    public void updateTableWidth()
    {  
        int maxColumn = columnsToPrint.get(columnsToPrint.size()-1);
        tableWidth = getColumnOffset(maxColumn) + (maxColumn == columnsToPrint.size()-1 ? 0 : 50);
    }

    // Setter for the flight data. Used to update the table when a query is made, without needing to create a new TableWidget object.
    public void setData(Table newData)
    {
        this.flightData = newData;
        this.currentPage = 0;
    }

    // Setter for the columns to be printed.
    public void setColumnsToPrint(int[] columns)
    {
        ArrayList<Integer> temp = new ArrayList<Integer>();
        for(int index = 0; index < columns.length; index++)
        {
            temp.add(columns[index]);
        }
        columnsToPrint = temp; 
    }
    
    // Prints the current page number and total page count to the screen, in the format "Page X of Y". 
    public void displayPageNumber(color fillColor, color textColor)
    {
      String text = "Page "+(currentPage+1)+" of "+(maxPageNumber <=0 ? 1 : maxPageNumber+1);
      int textLength = text.length() * 5;
      float dispW = textLength + 2 * BUTTON_PADDING;
      float dispH = 30;
      float dispX = this.xPos+this.tableWidth-dispW;
      float dispY = this.yPos - BTN_H - Visuals.SPACE_BETWEEN_BUTTONS;
    
      // 3. Draw the background box
      fill(fillColor);
      stroke(15); // Consistent with your original requirement
      rect(dispX, dispY, dispW, dispH, 5);
    
      // 4. Draw the text
      fill(textColor);
      textFont(table_TableFont); // Using tableFont as in your original snippet
      
      textAlign(CENTER, CENTER);
      text(text, dispX + dispW/2, dispY + dispH/2);
      textAlign(LEFT, BASELINE);
    }
    
    // Prints the header row and flight data to the screen. 
    // Sets table height and number of pages based on number of flights to be displayed.
    public void printWidget(int numberOfFlightsToDisplay, boolean overrideY)
    {
        maxPageNumber = ((flightData.getRowCount()-1) / numberOfFlightsToDisplay);
        tableHeight = (numberOfFlightsToDisplay * ROW_HEIGHT) + HEADER_HEIGHT;
        if(!overrideY)
        {
            this.yPos = height - TABLE_Y_OFFSET - tableHeight;
        }

        stroke(Visuals.GLOBAL_STROKE_COLOUR_DARK);
        fill(#1C2C48);
        rect(xPos, yPos, tableWidth + HORIZONTAL_PADDING, tableHeight, 10);
        fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        printHeader();
        printFlights(numberOfFlightsToDisplay);
    }

    // Works like the printWidget() method, but allows for two buttons to be specified.
    // The positions of these buttons move with the table, so they are in the same spot regardless of the table position.
    public void printWidget(int numberOfFlightsToDisplay, Button prevButton, Button nextButton, boolean overrideY)
    {
        printWidget(numberOfFlightsToDisplay, overrideY);
        prevButton.btnY = this.yPos - prevButton.btnH - Visuals.SPACE_BETWEEN_BUTTONS;
        prevButton.btnX = this.xPos;
        nextButton.btnX = this.xPos + prevButton.btnW + Visuals.SPACE_BETWEEN_BUTTONS;
        nextButton.btnY = this.yPos - BTN_H - Visuals.SPACE_BETWEEN_BUTTONS;
    }

    // Prints the header of the table to the screen
    private void printHeader()
    {
        textFont(table_TableHeaderFont);
        for (int column = 0; column < flightData.getColumnCount(); column++)
        {
            if(columnsToPrint.contains(column))
            {
                text(flightData.getString(0, column), getColumnOffset(column) + xPos + HORIZONTAL_PADDING, yPos + HEADER_PADDING);
        
            }
        }
    }

    // Prints the flight rows of the table to the screen based on number of results and the current page number.
    // Formats text conditionally - cancelled flights in red and diverted flights in yellow.
    private void printFlights(int numberOfResults)
    {
        int relativeRow = 0;
        int startRow    = (currentPage == 0) ? 1 : currentPage * numberOfResults + 1;

        for (int row = startRow; row <= (currentPage + 1) * numberOfResults && row < flightData.getRowCount(); row++)
        {
            if (flightData.getString(row, 15).equals("YES"))
                {
                    fill(#FF0000);
                    textFont(table_TableHeaderFont);
                }
                else if (flightData.getString(row, 16).equals("YES"))
                {
                    fill(#F5DD27);
                    textFont(table_TableHeaderFont);
                }
                else
                {
                    fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
                    textFont(table_TableFont);
                }
            for (int column = 0; column < flightData.getColumnCount(); column++)
            {

                float fx = getColumnOffset(column) + xPos + HORIZONTAL_PADDING;
                float fy = relativeRow * ROW_HEIGHT + yPos + HEADER_HEIGHT + FLIGHT_DATA_PADDING;
                if(columnsToPrint.contains(column))
                {
                    text(flightData.getString(row, column), fx, fy);
                }
            }

            rect(xPos, relativeRow * ROW_HEIGHT + yPos - 5 + HEADER_HEIGHT, tableWidth + HORIZONTAL_PADDING, ROW_DIVIDER_HEIGHT);
            relativeRow++;
        }
    }

   // Returns sum of widths of preceding columns to be used as an offset.
    private int getColumnOffset(int column)
    {
        int offset = 0;
        for (int index = 0; index < columnWidths.length && index < column; index++)
        {
            if(columnsToPrint.contains(index))
            {
                offset += columnWidths[index];
            }
        }
        return offset;
    }
}
