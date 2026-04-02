class PassengerScreen extends Screen {
    private Table data;
    private PFont titleFont, detailFont;
    
    // Aesthetic Palette sampled from your reference and Visuals.pde
    private final color BG_DARK     = #050912;
    private final color ACCENT_BLUE = #3B82F6;
    private final color GLOW_BLUE   = color(59, 130, 246, 40);
    private final color TEXT_MAIN   = #F8FAFC;
    private final color TEXT_MUTED  = #64748B;

    PassengerScreen(Table data) {
        this.data = data;
        this.titleFont = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
        this.detailFont = loadFont(Visuals.BUTTON_BUTTON_FONT);
    }

    public void draw() {
        _drawBackground();
        _drawGrid();

        // 1. LEFT PANEL: Main Flight Focus (The "Hero" Card)
        _drawHeroFlight();

        // 2. RIGHT PANEL: Live Schedule (Glassmorphism List)
        _drawFlightSchedule();

        // 3. BOTTOM: System Telemetry
        _drawTelemetryHUD();
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
        float x = 80;
        float y = Visuals.NAVBAR_H + 60;
        
        // Large Destination Label
        fill(TEXT_MAIN);
        textFont(titleFont);
        textSize(64);
        text("NEW YORK", x, y + 60);
        textSize(24);
        fill(ACCENT_BLUE);
        text("JFK  ·  GATE B22", x, y + 100);

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

    private void _drawFlightSchedule() {
        float x = width - 450;
        float y = Visuals.NAVBAR_H + 60;
        float w = 370;

        // Header for list
        fill(TEXT_MAIN);
        textFont(titleFont);
        textSize(18);
        text("UPCOMING ARRIVALS", x, y);

        for (int i = 1; i < 7; i++) {
            float ry = y + 40 + (i-1) * 90;
            
            // Glass Card
            fill(255, 10);
            stroke(255, 20);
            rect(x, ry, w, 75, 12);
            
            // Flight Data
            fill(TEXT_MAIN);
            textFont(detailFont);
            textSize(15);
            text(data.getString(i, 4) + " → " + data.getString(i, 8), x + 20, ry + 30);
            
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

    private void _drawTelemetryHUD() {
        float h = 120;
        float y = height - h;
        
        // Blurred divider
        stroke(255, 15);
        line(80, y, width - 80, y);

        String[] labels = {"ALTITUDE", "GROUND SPEED", "EST. ARRIVAL", "DISTANCE"};
        String[] values = {"36,000 FT", "542 MPH", "14:20", "420 MI"};

        for (int i = 0; i < 4; i++) {
            float x = 100 + i * (width/4.5);
            fill(TEXT_MUTED);
            textFont(detailFont);
            textSize(12);
            text(labels[i], x, y + 45);
            fill(TEXT_MAIN);
            textSize(24);
            text(values[i], x, y + 80);
        }
    }
}
