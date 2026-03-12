int btnW = 80;
int btnH = 30;
int nextX = 150;
int nextY = 400;
int prevX = 50;
int prevY = 400;
TableWidget flights;
Button prevButton;
Button nextButton;
  
void setup()
{
  flights = new TableWidget(30, 75, "flights2k.csv");
  prevButton = new Button(btnW, btnH, prevX, prevY);
  nextButton = new Button(btnW, btnH, nextX, nextY);
  size(1920,1080);
  background(#ffffff);
}

void draw()
{
  background(#ffffff);

  flights.printWidget(10);
  prevButton.printButton("Prev", 200, 0);
  nextButton.printButton("Next", 200, 0);
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
  }
}
