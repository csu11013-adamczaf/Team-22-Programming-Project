final int GRAPHS_ROW_HEIGHT = 30;
final int GRAPHS_PADDING = 20;

class Graphs
{
    // Takes in an array of strings and outputs how many times a String has occured in the array, output as a Table
    // The table header contains the Strings and row1 contains the number occurences. Outputs as follows:
    //  (Taking a simple yes/no as an example)
    //  ------------
    //  | YES | NO |     <- First Row - Table Header (Index 0)
    //  |----------|
    //  | 26  | 53 |     <- Second Row - Number of occurences of each string in the provided array (Index 1)
    //  ------------
    //
    public Table createTableOfRelativeCount(String[] inputData)
    {
        Table outputTable = new Table();
        outputTable.addRow();
        outputTable.addRow();
        ArrayList<String> usedValues = new ArrayList<String>();
        Query query = new Query();
        int currentColumn = 0;
        for(int index =1; index < inputData.length; index++)
        {
            if(!query.exists(inputData[index], usedValues))
            {
                outputTable.addColumn(inputData[index]);
                int occurences = countOccurences(inputData[index],inputData);
                outputTable.setString(0, currentColumn, inputData[index]);
                outputTable.setInt(1, currentColumn, occurences);
                currentColumn++;
                usedValues.add(inputData[index]);
            }
        }
        return outputTable;
    }

    // Prints the contents of a table to the screen (ONLY USE THIS FOR DEBUGGING)
    public void printOutputTable(float xPos, float yPos, Table outputTable)
    {
        for(int row = 0; row < outputTable.getRowCount(); row++)
        {
            for(int column = 0; column < outputTable.getColumnCount(); column++)
            {
                text(outputTable.getString(row,column), xPos+(30*column), yPos+(30*row));
            }
        }
    }

    // Counts how many times a specified string occurs within a String Array.
    public int countOccurences(String searchTerm, String[] inputData)
    {
        int count = 0;
        for(int index = 0; index < inputData.length; index++)
        {
            if(searchTerm.equals(inputData[index]))
            {
                count++;
            }
        }
        return count;
    }


    public void printPieChart(float xPos, float yPos, float diameter, int colour, String title, Table data)
    {
        float startAngle = 0;
        float total = 0;
        final int HEADER_ROW = 0;
        final int DATA_ROW = 1;
        PFont graphsFont = loadFont(Visuals.GRAPHS_FONT);
        PFont titleFont = loadFont(Visuals.GRAPHS_FONT);
        float numberOfEntries = data.getColumnCount();
        float overallChartHeight = diameter+(2*GRAPHS_PADDING);
        float textYPos = (yPos+(overallChartHeight-(numberOfEntries*GRAPHS_ROW_HEIGHT))/2)+15;
        
        for(int index = 0; index < data.getColumnCount(); index++)
        {
            total += data.getFloat(DATA_ROW,index);
        }

        fill(Visuals.GRAPHS_BACKGROUND_COLOUR);
        noStroke();
        rect(xPos, yPos, diameter+(2*GRAPHS_PADDING)+200, overallChartHeight, 10);

        textFont(titleFont);
        fill(0);
        text(title, xPos+((diameter+(2*GRAPHS_PADDING)+200)/2)-((title.length()*8)/2), yPos);
        
        textFont(graphsFont);
        for(int index = 0; index < data.getColumnCount(); index++)
        {
            fill(colour);
            arc(xPos+diameter/2+GRAPHS_PADDING, yPos+diameter/2+GRAPHS_PADDING, diameter, diameter, startAngle, startAngle+radians((data.getFloat(DATA_ROW,index)/total)*360));
    
            rect(xPos+diameter+(2*GRAPHS_PADDING), textYPos+((index-0.5)*GRAPHS_ROW_HEIGHT), 15, 15);
            fill(0);
            text(data.getString(HEADER_ROW, index),xPos+diameter+(3*GRAPHS_PADDING), textYPos+(index*GRAPHS_ROW_HEIGHT));
            
            startAngle+=radians((data.getFloat(DATA_ROW,index)/total)*360);
            colour += 70;
        }   
    }

    public void printBarChart(float xPos, float yPos, float chartWidth, float barHeight, int baseColour, String title, Table data)
{
    final int HEADER_ROW = 0;
    final int DATA_ROW = 1;

    int numBars = data.getColumnCount();
    float maxValue = 0;

    // Find the maximum value for scaling
    for (int i = 0; i < numBars; i++)
    {
        float v = data.getFloat(DATA_ROW, i);
        if (v > maxValue) maxValue = v;
    }

    float chartHeight = numBars * (barHeight + 10) + GRAPHS_PADDING * 2;

    // Background panel
    fill(Visuals.GRAPHS_BACKGROUND_COLOUR);
    noStroke();
    rect(xPos, yPos, chartWidth + 200, chartHeight, 10);

    // Title
    PFont titleFont = loadFont(Visuals.GRAPHS_FONT);
    textFont(titleFont);
    fill(0);
    text(title, xPos + (chartWidth + 200)/2 - (title.length()*8)/2, yPos-2);

    // Bars + labels
    PFont graphsFont = loadFont(Visuals.GRAPHS_FONT);
    textFont(graphsFont);

    float barY = yPos + GRAPHS_PADDING + 20;
    int colour = baseColour;

    for (int i = 0; i < numBars; i++)
    {
        float value = data.getFloat(DATA_ROW, i);
        float barWidth = map(value, 0, maxValue, 0, chartWidth);

        // Bar colour
        fill(colour);
        rect(xPos + GRAPHS_PADDING, barY, barWidth, barHeight);

        // Label
        fill(0);
        text(data.getString(HEADER_ROW, i) + " (" + (int)value + ")", 
             xPos + GRAPHS_PADDING + barWidth + 10, 
             barY + barHeight - 5);

        barY += barHeight + 10;
        colour += 70; // same colour progression as your pie chart
    }
}
}