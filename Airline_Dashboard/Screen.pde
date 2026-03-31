class Screen
{
    public void draw() {}
    public void mousePressed() {}
}

class OverviewScreen extends Screen
{
    private Graphs graphs;
    private TableWidget flights;
    private Button prevButton;
    private Button nextButton;
    private int rowsToDisplay;

    OverviewScreen(Graphs graphs, TableWidget flights, Button prevButton, Button nextButton, int rowsToDisplay)
    {
        this.graphs = graphs;
        this.flights = flights;
        this.prevButton = prevButton;
        this.nextButton = nextButton;
        this.rowsToDisplay = rowsToDisplay;
    }

    public void draw()
    {
        graphs.printPieChart();
        graphs.printBarChart();
        graphs.printLineChart();
        graphs.printDropdownLists();

        flights.printWidget(rowsToDisplay, prevButton, nextButton);
        prevButton.printButton("Previous Page", Visuals.BTN_BG, Visuals.BTN_TEXT);
        nextButton.printButton("Next Page", Visuals.BTN_BG, Visuals.BTN_TEXT);
        flights.displayPageNumber(Visuals.BTN_BG, Visuals.BTN_TEXT);
    }

    public void mousePressed()
    {
        graphs.mouseClicked();

        if (nextButton.buttonPressed()) flights.nextPage();

        if (prevButton.buttonPressed())
        {
            if (flights.getCurrentPage() > 0)
                flights.previousPage();
            else
                flights.setCurrentPage(flights.getMaxPage());
        }
    }
}

class QueryScreen extends Screen
{
    private PFont font;

    QueryScreen()
    {
        this.font = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
    }

    public void draw()
    {
        _drawPlaceholder("Query", "Query search function coming soon.");
        query.getUserQueryString();
        query.printQueryBox(1920/2, 500);
    }
}

class MapScreen extends Screen
{
    private PFont font;

    MapScreen()
    {
        this.font = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
    }

    public void draw()
    {
        _drawPlaceholder("Maps", "Maps function coming soon.");
    }
}

class DelaysScreen extends Screen
{
    private PFont font;

    DelaysScreen()
    {
        this.font = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
    }

    public void draw()
    {
        _drawPlaceholder("Delays", "Delay analysis charts coming soon.");
    }
}

void _drawPlaceholder(String screenName, String message)
{
    int navH   = Visuals.NAVBAR_H;
    float cx   = width / 2.0;
    float cy   = navH + (height - navH) / 2.0;

    noStroke();
    fill(Visuals.PANEL_BG);
    ellipse(cx, cy - 60, 100, 100);

    fill(Visuals.ACCENT);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("✦", cx, cy - 60);

    fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
    textSize(28);
    text(screenName, cx, cy);

    fill(Visuals.TAB_TEXT_IDLE);
    textSize(14);
    text(message, cx, cy + 36);

    textAlign(LEFT, BASELINE);
}
