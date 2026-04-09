class PassengerScreen extends Screen {
    private Table data;
    private TableWidget divertedTable;
    private TableWidget cancelledTable;
    
    // Aesthetic Palette sampled from your reference and Visuals.pde
    private final color BG_DARK     = #050912;
    private final color ACCENT_BLUE = #3B82F6;
    private final color TEXT_MAIN   = #F8FAFC;

    PassengerScreen(Table data) {
        this.data = data;
        int[] temp = {0,1,2,3,4,5,7,8,9,12,14,17};
        divertedTable = new TableWidget(queryScreen.filterFlights("YES",16), 200);
        divertedTable.setYPos(375);
        divertedTable.setColumnsToPrint(temp);
        divertedTable.updateTableWidth();

        cancelledTable = new TableWidget(queryScreen.filterFlights("YES",15), 200);
        cancelledTable.setYPos(725);
        cancelledTable.setColumnsToPrint(temp);
        cancelledTable.updateTableWidth();

        _drawBackground();
        _drawGrid();
    }


    public void draw() {

        // 1. LEFT PANEL: Main Flight Focus (The "Hero" Card)
        _drawHeroFlight();

        // 2. RIGHT PANEL: Live Schedule (Glassmorphism List)
        _drawFlightArrivals();
        _drawFlightDepartures();

        textFont(passenger_PassengerHeaderFont);
        textSize(30);
        text("Diverted Flights", divertedTable.getXPos()+((divertedTable.getTableWidth()/2)-98), divertedTable.getYPos()-15);

        text("Cancelled Flights", cancelledTable.getXPos()+((cancelledTable.getTableWidth()/2)-105), cancelledTable.getYPos()-15);

        divertedTable.printWidget(8, true);
        cancelledTable.printWidget(8, true);

    }

    private void _drawBackground() {
        background(BG_DARK);
        // Subtle radial glow in the center
        noStroke();
        for (int i = 600; i > 0; i -= 20) {
            fill(ACCENT_BLUE, map(i, 0, 600, 15, 0));
            ellipse(width/2, height/2, i*2, i*2);
        }
    }

    private void _drawGrid() {
        stroke(255, 8);
        strokeWeight(1);
        for (int i = 0; i < width; i += 80) line(i, 0, i, height);
        for (int i = 0; i < height; i += 80) line(0, i, width, i);
    }

    private void _drawHeroFlight() {
        float x = 375;
        float y = Visuals.NAVBAR_H + 30;
        
        // Large Destination Label
        fill(TEXT_MAIN);
        textFont(passenger_PassengerHeaderFont);
        textSize(64);
        text("NEW YORK", 80, y + 60);
        textSize(24);
        fill(ACCENT_BLUE);
        text("JFK  ·  TERMINAL 1", 80, y + 100);

        // Visual Flight Path Logic
        stroke(ACCENT_BLUE, 100);
        strokeWeight(2);
        noFill();
        bezier(x, y + 250, x + 200, y + 50, x + 500, y + 50, x + 700, y + 250);
        
        // Animated Plane
        float t = (frameCount * 0.005) % 1.0;
        float px = bezierPoint(x, x + 200, x + 500, x + 700, t);
        float py = bezierPoint(y + 250, y + 50, y + 50, y + 250, t);
        
        fill(255);
        ellipse(px, py, 8, 8);
        // Glow effect for plane
        fill(ACCENT_BLUE, 50);
        ellipse(px, py, 20, 20);
    }

    private void _drawFlightArrivals() {
        float x = width - 450;
        float y = Visuals.NAVBAR_H + 40;
        float w = 370;

        // Header for list
        fill(TEXT_MAIN);
        textFont(passenger_PassengerHeaderFont);
        textSize(18);
        text("UPCOMING ARRIVALS", x, y);

        for (int i = 1; i < 6; i++) {
            float ry = y + 20 + (i-1) * 85;
            
            // Glass Card
            fill(255, 10);
            stroke(255, 20);
            rect(x, ry, w, 75, 12);
            
            // Flight Data
            fill(TEXT_MAIN);
            textFont(dropDown_DropDownFont);
            textSize(15);
            text(data.getString(i+3, 4) + "  -->  " + "New York, NY", x + 20, ry + 30);
            
            // Status Tag
            noStroke();
            fill(ACCENT_BLUE, 40);
            rect(x + 20, ry + 45, 70, 18, 4);
            fill(TEXT_MAIN);
            textSize(10);
            textAlign(CENTER, CENTER);
            text("ON TIME", x + 55, ry + 54);
            textAlign(LEFT, BASELINE);
        }
    }

    private void _drawFlightDepartures() {
        float x = width - 450;
        float y = Visuals.NAVBAR_H + 460+60;
        float w = 370;

        // Header for list
        fill(TEXT_MAIN);
        textFont(passenger_PassengerHeaderFont);
        textSize(18);
        text("UPCOMING DEPARTURES", x, y);

        for (int i = 1; i < 6; i++) {
            float ry = y + 20 + (i-1) * 85;
            
            // Glass Card
            fill(255, 10);
            stroke(255, 20);
            rect(x, ry, w, 75, 12);
            
            // Flight Data
            fill(TEXT_MAIN);
            textFont(dropDown_DropDownFont);
            textSize(15);
            text("New York, NY" + "  -->  " + data.getString(i+11, 8), x + 20, ry + 30);
            
            // Status Tag
            noStroke();
            fill(ACCENT_BLUE, 40);
            rect(x + 20, ry + 45, 70, 18, 4);
            fill(TEXT_MAIN);
            textSize(10);
            textAlign(CENTER, CENTER);
            text("ON TIME", x + 55, ry + 54);
            textAlign(LEFT, BASELINE);
        }
    }
}
