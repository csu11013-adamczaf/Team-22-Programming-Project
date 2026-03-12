int btnW = 80;
int btnH = 30;
int nextX = 115;
int nextY = 460;
int prevX = 22;
int prevY = 460;
TableWidget flights;
Button prevButton;
Button nextButton;
  
void setup()
{
  fullScreen(P2D);
  background(#ffffff);
  flights = new TableWidget(30, height-315, "flights-short.csv");
  prevButton = new Button(btnW, btnH, prevX, prevY);
  nextButton = new Button(btnW, btnH, nextX, nextY);
}

void draw()
{
  background(#ffffff);

  flights.printWidget(10);
  prevButton.printButton("Previous Page", 200, 0);
  nextButton.printButton("Next Page", 200, 0);
}

void mousePressed()
{
  if (nextButton.buttonPressed())
  {
    flights.pageNumber++;
  }
  
  if (prevButton.buttonPressed())
  {
    if (flights.pageNumber > 0)
    {
      flights.pageNumber--;
    }
    else
    {
      flights.pageNumber = flights.maxPageNumber;
    }
  }
}
