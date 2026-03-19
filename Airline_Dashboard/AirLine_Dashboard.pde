float btnW = 80;
float btnH = 30;
TableWidget flights;
Graphs graphs;
Button prevButton;
Button nextButton;

//Sets up screen size & placement, background, creates TableWidget object and sets it x position.
//Creates two buttons next to TableWidget object.
void setup()
{
  size(1920,1080, P2D);
  surface.setLocation(-1,-1);
  background(#ffffff);

  flights = new TableWidget("flights-short.csv");
  graphs = new Graphs();
  flights.setXPos((width/2)-flights.getTableWidth()/2);
  prevButton = new Button(btnW, btnH, 0, 0);
  nextButton = new Button(btnW, btnH, 0, 0);
}

void draw()
{
  background(#ffffff);

  flights.printWidget(10, prevButton, nextButton);
  prevButton.printButton("Previous Page", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);
  nextButton.printButton("Next Page", Visuals.BUTTON_BUTTON_COLOUR, Visuals.GLOBAL_TEXT_COLOUR_DARK);

  //TESTING! This shows how the countRelative() function sorts the relative counts in a table
  Table test = graphs.createTableOfRelativeCount(flights.flightData.getStringColumn(17));
  text("This is how createTableOfRelativeCount() function organises the data",900, 475);
  graphs.printOutputTable(1000,500,test);
  graphs.printBarChart(50, 50, 300, 20, color(100, 150, 200), "Bar Chart", test);
  graphs.printPieChart(400, 400, 200, 0x0, "Flight Cancellations", test);
  //End of testing
}

void mousePressed()
{
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
