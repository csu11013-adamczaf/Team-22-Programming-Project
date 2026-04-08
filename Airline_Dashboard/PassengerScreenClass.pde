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
        _drawCancelledTable();
    _drawDivertedTable();
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

private ArrayList<TableRow> getFirstFive(int columnIndex) {
    ArrayList<TableRow> result = new ArrayList<>();

    for (int i = 1; i < data.getRowCount(); i++) {
        if (data.getString(i, columnIndex).equals("YES")) {
            result.add(data.getRow(i));
            if (result.size() == 5) break;
        }
    }
    return result;
}
private void drawCompactFlightTable(
    String title,
    ArrayList<TableRow> rows,
    float x, float y,
    float w,
    color accent
) {
    float rowH = 22;   // smaller rows
    float headerH = 18;

    // Title
    fill(TEXT_MAIN);
    textFont(titleFont);
    textSize(14);
    text(title, x, y - 8);

    // Column headers (compact)
    String[] headers = {
    "Date", "Carrier", "Flt#", "Origin", "Org City",
    "Dest", "Dst City", "Dep", "ActDep", "Arr", "ActArr"
};

float[] colW = {
    70, 50, 45, 45, 90,
    45, 90, 45, 45, 45, 45
};
    // Header row
    fill(255, 20);
    noStroke();
    rect(x, y + 2, w, headerH, 6);

    fill(TEXT_MUTED);
    textFont(detailFont);
    textSize(10);

    float cx = x + 6;
    float hy = y + headerH - 5;

    for (int i = 0; i < headers.length; i++) {
        text(headers[i], cx, hy);
        cx += colW[i];
    }

    // Data rows
    for (int r = 0; r < rows.size(); r++) {
        TableRow row = rows.get(r);
        float ry = y + headerH + r * rowH;

        // Background
        fill(255, 12);
        stroke(accent, 40);
        rect(x, ry, w, rowH - 1, 4);

        // Text
        fill(accent);
        textFont(detailFont);
        textSize(10);

        cx = x + 6;
float ty = ry + rowH * 0.7;

text(row.getString(0),  cx, ty); cx += colW[0];   // Date
text(row.getString(1),  cx, ty); cx += colW[1];   // Carrier
text(row.getString(2),  cx, ty); cx += colW[2];   // Flight #
text(row.getString(3),  cx, ty); cx += colW[3];   // Origin
text(row.getString(4),  cx, ty); cx += colW[4];   // Origin City
text(row.getString(6),  cx, ty); cx += colW[5];   // Dest
text(row.getString(7),  cx, ty); cx += colW[6];   // Dest City
text(row.getString(9),  cx, ty); cx += colW[7];   // CRS Dep
text(row.getString(10), cx, ty); cx += colW[8];   // Act Dep
text(row.getString(11), cx, ty); cx += colW[9];   // CRS Arr
text(row.getString(12), cx, ty);                  // Act Arr
    }
}
private void _drawCancelledTable() {
    ArrayList<TableRow> rows = getFirstFive(15);

    drawCompactFlightTable(
        "CANCELLED FLIGHTS",
        rows,
        80,
        Visuals.NAVBAR_H + 260,
        600,
        color(255, 80, 80)
    );
}

private void _drawDivertedTable() {
    ArrayList<TableRow> rows = getFirstFive(16);

    drawCompactFlightTable(
        "DIVERTED FLIGHTS",
        rows,
        80,
        Visuals.NAVBAR_H + 260 + 150,
        600,
        color(245, 221, 39)
    );
}
}
