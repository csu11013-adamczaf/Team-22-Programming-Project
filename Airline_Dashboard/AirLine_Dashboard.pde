float btnW = 80;
float btnH = 30;
int   ROWS_TO_DISPLAY = 10;  

TableWidget flights;
Button prevButton;
Button nextButton;
Graphs graphs;
Query query;

QueryScreen    queryScreen;
MapScreen      mapScreen;
PassengerScreen passengerScreen; // Add this near other screens
Screen         currentScreen;
int            currentScreenIdx = 0;

final String[] SCREEN_NAMES = { "Search", "Map", "Passenger Mode" };
PFont navFont;
PFont navTitleFont;
PFont mapFont;      // loaded once here, passed to MapScreen
Table mapData;

void setup()
{
    size(1920, 1080, P2D);
    surface.setLocation(-1, -1);
    background(Visuals.BACKGROUND);

    navFont      = loadFont(Visuals.BUTTON_BUTTON_FONT);
    navTitleFont = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
    mapFont      = loadFont(Visuals.BUTTON_BUTTON_FONT);   // reuse button font for map labels
    mapData = loadTable("flights2k.csv", "csv");

    flights = new TableWidget("flights2k.csv");
    flights.setXPos((width / 2) - flights.getTableWidth() / 2);
    prevButton = new Button(btnW, btnH, 0, 0);
    nextButton = new Button(btnW, btnH, 0, 0);
    graphs = new Graphs(flights.getData(), ROWS_TO_DISPLAY);
    query  = new Query(flights.getData());

    queryScreen    = new QueryScreen();
    passengerScreen = new PassengerScreen(flights.getData());
    mapScreen = new MapScreen(mapData, mapFont, navTitleFont);

    currentScreen = queryScreen;
}

void draw()
{
    background(Visuals.BACKGROUND);
    currentScreen.draw();
    _drawNavbar();
}

void mousePressed()
{
    int clicked = _navbarTabAt(mouseX, mouseY);
    if (clicked >= 0)
    {
        _switchScreen(clicked);
        return;
    }
    currentScreen.mousePressed();
}

void _drawNavbar()
{
    int navH = Visuals.NAVBAR_H;

    noStroke();
    fill(Visuals.NAVBAR_BG);
    rect(0, 0, width, navH);

    stroke(Visuals.NAVBAR_BORDER);
    strokeWeight(1);
    line(0, navH, width, navH);

    noStroke();
    fill(Visuals.ACCENT);
    ellipse(28, navH / 2.0, 8, 8);

    fill(Visuals.NAVBAR_TITLE_COLOUR);
    textFont(navTitleFont);
    textSize(Visuals.NAVBAR_TITLE_SIZE);
    textAlign(LEFT, CENTER);
    text("Airline Dashboard", 42, navH / 2.0);

    float tabStartX = 320;
    textFont(navFont);
    textSize(13);

    for (int i = 0; i < SCREEN_NAMES.length; i++)
    {
        float   tx     = tabStartX + i * Visuals.TAB_W;
        boolean active = (i == currentScreenIdx);
        boolean hover  = (_navbarTabAt(mouseX, mouseY) == i);

        if (hover && !active)
        {
            noStroke();
            fill(Visuals.TAB_HOVER_BG);
            rect(tx, 0, Visuals.TAB_W, navH);
        }

        fill(active ? Visuals.TAB_TEXT_ACTIVE : Visuals.TAB_TEXT_IDLE);
        textAlign(CENTER, CENTER);
        text(SCREEN_NAMES[i], tx + Visuals.TAB_W / 2.0, navH / 2.0);

        if (active)
        {
            noStroke();
            fill(Visuals.TAB_INDICATOR);
            rect(tx + 16, navH - Visuals.TAB_INDICATOR_H,
                 Visuals.TAB_W - 32, Visuals.TAB_INDICATOR_H, 2);
        }
    }

    textAlign(LEFT, BASELINE);
    strokeWeight(1);
}

int _navbarTabAt(float mx, float my)
{
    if (my < 0 || my > Visuals.NAVBAR_H) return -1;
    float tabStartX = 320;
    for (int i = 0; i < SCREEN_NAMES.length; i++)
    {
        float tx = tabStartX + i * Visuals.TAB_W;
        if (mx >= tx && mx < tx + Visuals.TAB_W) return i;
    }
    return -1;
}

void _switchScreen(int idx)
{
    currentScreenIdx = idx;
    switch (idx)
    {
        case 0:  currentScreen = queryScreen;    break;
        case 1:  currentScreen = mapScreen;      break;
        case 2: currentScreen = passengerScreen; break;
        default: currentScreen = queryScreen;
    }
}