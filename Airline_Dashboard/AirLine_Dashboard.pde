  boolean userMouse = false;
  TableWidget flights;
  
  void setup()
  {
    flights = new TableWidget(15, 75, "flights2k.csv");
    size(1920,1080);
    background(#ffffff);
  }
  
  void draw()
  {
    if(mousePressed)
    {
      if(!userMouse)
      {
        flights.printWidget(10);
        flights.pageNumber++;
        userMouse = true;
      }
    }
    else if(!mousePressed && userMouse)
    {
      userMouse = false;
    }
      
  }
