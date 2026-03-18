float btnW = 80;
float btnH = 30;
TableWidget flights;
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

}

void mousePressed()
{
  if (nextButton.buttonPressed())
  {
    flights.nextPage();
  }
  
  if (prevButton.buttonPressed())
  {
    flights.previousPage();
  }
}
