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
  flights = new TableWidget(30, 75, "flights-short.csv");
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
  if (mouseX > nextX && mouseX < nextX + btnW && mouseY > nextY && mouseY < nextY + btnH)
  {
    flights.pageNumber++;
  }
  
  if (mouseX > prevX && mouseX < prevX + btnW && mouseY > prevY && mouseY < prevY + btnH)
  {
    if (flights.pageNumber > 0)
    {
      flights.pageNumber--;
    }
  }
}
