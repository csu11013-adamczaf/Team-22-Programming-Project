float btnW = 80;
float btnH = 30;
int ROWS_TO_DISPLAY = 10;
TableWidget flights;
Button prevButton;
Button nextButton;
Button screen1Button;
Button screen2Button;
Graphs graphs;
int screenSelected;
TableWidget queryFlights;
Query query;
Dropdown queryDD;

//Sets up screen size & placement, background, creates TableWidget object and sets it x position.
//Creates two buttons next to TableWidget object.
void setup()
{
  size(1920, 1080, P2D);
  surface.setLocation(-1, -1);
  background(#ffffff);
  screenSelected = 1;

  flights = new TableWidget("flights-short.csv");
  flights.setXPos((width/2) - flights.getTableWidth()/2);
  prevButton = new Button(btnW, btnH, 0, 0);
  nextButton = new Button(btnW, btnH, 0, 0);
  screen1Button = new Button(btnW, btnH, (1920/2)-(2*btnW), 0);
  screen2Button = new Button(btnW, btnH, (1920/2)+btnW, 0);
  graphs = new Graphs(flights.getData(), ROWS_TO_DISPLAY);
  query = new Query();
  String[] queryLabels = {"Flight Date", "Carrier", "Flight Number", "Origin", "Origin City", "Origin State", "Origin WAC", "Destination", "Destination City", "Destination State", "Destination WAC", "CRS_DEP_TIME", "Departure Time", "CRS_ARR_TIME", "Arrival Time", "Cancelled", "Diverted", "Distance"};
  int[] queryIndices = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17};
  queryDD = new Dropdown(20, 50, 210, queryLabels, queryIndices, loadFont(Visuals.QUERY_SEARCH_FONT));
}

void draw()
{
  background(#ffffff);
  screen1Button.printButton("Home", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  screen2Button.printButton("Query Tab", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);

  flights.printWidget(ROWS_TO_DISPLAY, prevButton, nextButton);
  prevButton.printButton("Previous Page", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  nextButton.printButton("Next Page", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  flights.displayPageNumber(Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);

if(screenSelected == 1)
{
  graphs.printPieChart();
  graphs.printBarChart();
  graphs.printLineChart();
  graphs.printDropdownLists();

}
else if(screenSelected == 2)
{

  flights.displayResultsCount(Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  
  query.getUserQueryString();
  query.printQueryBox(1920/2,500, queryDD);
  queryDD.setTextSize(20);
  queryDD.setCellHeight(query.textBoxHeight);
  queryDD.printDropdown();
  queryDD.printList();
}
}

void mousePressed()
{
  graphs.mouseClicked();
  queryDD.mouseClicked();

  if(screenSelected == 1 && screen2Button.buttonPressed())
  {
    screenSelected = 2;
  }
  else if(screenSelected ==2 && screen1Button.buttonPressed())
  {
    screenSelected = 1;
  }

  if (nextButton.buttonPressed())
  {
    flights.nextPage();
  }

  if (prevButton.buttonPressed())
  {
    if (flights.getCurrentPage() > 0)
    {
      flights.previousPage();
    }
    else
    {
      flights.setCurrentPage(flights.getMaxPage());
    }
  }
}
