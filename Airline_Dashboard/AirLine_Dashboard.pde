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

//Sets up screen size & placement, background, creates TableWidget object and sets it x position.
//Creates two buttons next to TableWidget object.
void setup()
{
  size(1920, 1080, P2D);
  surface.setLocation(-1, -1);
  background(#ffffff);
  screenSelected = 1;

  queryFlights = new TableWidget(new Table());
  flights = new TableWidget("flights-short.csv");
  flights.setXPos((width/2) - flights.getTableWidth()/2);
  prevButton = new Button(btnW, btnH, 0, 0);
  nextButton = new Button(btnW, btnH, 0, 0);
  screen1Button = new Button(btnW, btnH, (1920/2)-(2*btnW), 0);
  screen2Button = new Button(btnW, btnH, (1920/2)+btnW, 0);
  graphs = new Graphs(flights.getData(), ROWS_TO_DISPLAY);
  query = new Query();
}

void draw()
{
  background(#ffffff);
  screen1Button.printButton("Home", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  screen2Button.printButton("Query Tab", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);



if(screenSelected == 1)
{
  graphs.printPieChart();
  graphs.printBarChart();
  graphs.printLineChart();
  graphs.printDropdownLists();

  flights.printWidget(ROWS_TO_DISPLAY, prevButton, nextButton);
  prevButton.printButton("Previous Page", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  nextButton.printButton("Next Page", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  flights.displayPageNumber(Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
}
else if(screenSelected == 2)
{
  queryFlights.printWidget(ROWS_TO_DISPLAY);
  query.getUserQueryString();
}
}

void mousePressed()
{
  graphs.mouseClicked();

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
