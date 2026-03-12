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
