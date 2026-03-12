int btnW = 80;
int btnH = 30;
int nextX = 150;
int nextY = 400;
int prevX = 50;
int prevY = 400;
boolean userMouse = false;
TableWidget flights;
  
void setup()
{
  flights = new TableWidget(30, 75, "flights-short.csv");
  size(1920,1080);
  background(#ffffff);
}

void draw()
{
  background(#ffffff);

  flights.printWidget(10);

  fill(200);
  rect(prevX, prevY, btnW, btnH);
  fill(0);
  text("Prev", prevX + 20, prevY + 20);

  fill(200);
  rect(nextX, nextY, btnW, btnH);
  fill(0);
  text("Next", nextX + 20, nextY + 20);
  
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
