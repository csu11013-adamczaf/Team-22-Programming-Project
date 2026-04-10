abstract class Screen
{
    public abstract void draw();
    public void mousePressed() {}
}

class QueryScreen extends Screen
{
    private Dropdown queryDD;
    private String lastQuery = "";
    private int lastIndex = 0;
    private boolean lastDivertedValue;
    private boolean lastCancelledValue;
    private TableWidget queryFlights;
    private CheckBox divertedBox;
    private CheckBox cancelledBox;
    private Graphs filteredGraphs;
    private Table lowerCaseCache;

    

    QueryScreen()
    {
        // Initialize the dropdown, table widget, checkboxes, and graphs for the query screen, build lower case cache for efficient filtering.
        String[] queryLabels = {"Flight Date", "Carrier", "Flight Number", "Origin", "Origin City", "Origin State", "Origin WAC", "Destination", "Destination City", "Destination State", "Destination WAC", "CRS_DEP_TIME", "Departure Time", "CRS_ARR_TIME", "Arrival Time", "Cancelled", "Diverted", "Distance"};
        int[] queryIndices = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17};
        queryDD = new Dropdown(20, 50, 210, queryLabels, queryIndices);
        queryFlights = new TableWidget(flights.getData(), ((width / 2) - flights.getTableWidth() / 2));
        divertedBox = new CheckBox(query.boxXPos, query.boxYPos+41, "Show Diverted?");
        cancelledBox = new CheckBox(query.boxXPos, query.boxYPos+41, "Show Cancelled?");
        filteredGraphs = new Graphs(queryFlights.getData(), ROWS_TO_DISPLAY);
        lowerCaseCache = new Table();
        filteredGraphs.graphHeightOffset = 100;

        for(int row = 1; row < flights.getData().getRowCount(); row++)
        {
            TableRow currentRow = flights.getData().getRow(row);
            for(int col = 0; col < flights.getData().getColumnCount(); col++)
            {
                lowerCaseCache.setString(row, col, currentRow.getString(col).toLowerCase());
            }
        }
    }

    public void draw()
    {

        // Only filter when the query actually changes
        if (!(query.userQuery).equals(lastQuery) || (lastIndex != queryDD.getSelectedIndex()) 
            || lastDivertedValue != divertedBox.enabled || lastCancelledValue != cancelledBox.enabled) 
        {
            Table filtered = filterFlights(query.userQuery, queryDD.getSelectedIndex());
            queryFlights.setData(filtered);
            lastQuery = query.userQuery;
            lastIndex = queryDD.getSelectedIndex();
            lastDivertedValue = divertedBox.enabled;
            lastCancelledValue = cancelledBox.enabled;
            filteredGraphs.updateData(queryFlights.getData());
        }

        // Print Table
        prevButton.printButton("Previous Page", Visuals.BTN_BG, Visuals.BTN_TEXT);
        nextButton.printButton("Next Page", Visuals.BTN_BG, Visuals.BTN_TEXT);
        queryFlights.displayPageNumber(Visuals.BTN_BG, Visuals.BTN_TEXT);
        queryFlights.printWidget(ROWS_TO_DISPLAY, prevButton, nextButton, false);

        // If no matches, inform user
        if(queryFlights.flightData.getRowCount()==1)
        {
            queryFlights.currentPage = 0;
            textFont(query_QueryFontLarge);
            textSize(40);
            fill(#ffffff);
            String emptyTable = "No records match the search criteria";
            String emptyGraphs = "No data to display";
            text(emptyTable,(queryFlights.getXPos()+queryFlights.tableWidth/2-textWidth(emptyTable)/2),queryFlights.yPos+queryFlights.tableHeight/2+textAscent());
            text(emptyGraphs,(width/2-textWidth(emptyGraphs)/2),350);
        }
        else
        {
            filteredGraphs.printPieChart();
            filteredGraphs.printBarChart();
            filteredGraphs.printLineChart();
            filteredGraphs.printDropdownLists();
        }

        // Print Search Box
        query.getUserQueryString();
        query.printQueryBox(1920/2, queryFlights.yPos-115, queryDD);
        queryDD.setTextSize(15);
        queryDD.setCellHeight(query.textBoxHeight);
        queryDD.printDropdown();
        queryDD.printList();

        divertedBox.xPos = query.boxXPos;
        divertedBox.yPos = query.boxYPos+60;
        divertedBox.draw();

        cancelledBox.xPos = divertedBox.xPos+divertedBox.width+textWidth(divertedBox.text)+30;
        cancelledBox.yPos = divertedBox.yPos;
        cancelledBox.draw();


    }
    // Filters the flights table based on the user's query string, selected column, and checkbox states for diverted/cancelled
    public Table filterFlights(String sentence, int columnIndex)
    {
        Table all = flights.getData();
        Table filtered = new Table();
        String lowerCaseSentence = sentence.toLowerCase();
        String cell = null;


        // copy column titles
        for (int c = 0; c < all.getColumnCount(); c++) 
        {
            filtered.addColumn(all.getColumnTitle(c));
        }
        TableRow header = filtered.addRow();
        for (int c = 0; c < all.getColumnCount(); c++) 
        {
            header.setString(c, all.getString(0, c));
        }

        for (int r = 1; r < all.getRowCount(); r++) 
        {

        cell = lowerCaseCache.getString(r, columnIndex);

            if (cell.contains(lowerCaseSentence)) 
            {
                //Check if boxes are enabled and filter results if not
                if(divertedBox.enabled || ((all.getString(r, 16).equals("NO") && !divertedBox.enabled)))
                {
                    if(cancelledBox.enabled || ((all.getString(r, 15).equals("NO") && !cancelledBox.enabled)))
                    {
                        TableRow newRow = filtered.addRow();
                        for (int c = 0; c < all.getColumnCount(); c++) 
                        {
                            newRow.setString(c, all.getString(r, c));
                        }
                    }
                }
            }
        }

        return filtered;
    }

    // Handle mouse clicks for the checkboxes, dropdown, and buttons
    public void mousePressed()
    {
        filteredGraphs.mouseClicked();
        divertedBox.mouseClicked();
        cancelledBox.mouseClicked();
        queryDD.mouseClicked();

        if (nextButton.buttonPressed()) queryFlights.nextPage();

        if (prevButton.buttonPressed()) queryFlights.previousPage();
    }
}