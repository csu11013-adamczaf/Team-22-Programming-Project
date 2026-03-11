  boolean userMouse = false;
  TableWidget flights;
  
  void setup()
  {
    flights = new TableWidget(30, 30, "flights100k.csv");
    size(1920,1080);
    background(#ffffff);
  }
  
  void draw()
  {
    if(mousePressed)
    {
      if(!userMouse)
      {
        flights.printFlights(10);
        flights.pageNumber++;
        userMouse = true;
      }
    }
    else if(!mousePressed && userMouse)
    {
      userMouse = false;
    }
      
  }
