class MapScreen extends Screen
{
    // ── Data ──────────────────────────────────────────────────────────────────
    private Table    data;
    private String[] uniqueDates;
    private Dropdown dateDD;
    private PFont    mapFont;
    private PFont    labelFont;
    private PImage   mapImage; // Added for the background image

    // Airport coordinate lookup: IATA -> [lat, lon]
    private java.util.HashMap<String, float[]> airportCoords;

    // Cached per-date flight data — rebuilt only when date changes
    private int      lastDateIdx = -1;
    private float[]  cachedOriginX, cachedOriginY;
    private float[]  cachedDestX,   cachedDestY;
    private boolean[] cachedCancelled, cachedDiverted;
    private java.util.HashMap<String, Integer> cachedAirportFlightCount;

    // Map projection bounds (USA bounding box)
    private static final float LAT_MIN =  22.0;
    private static final float LAT_MAX =  52.0;
    private static final float LON_MIN = -128.0;
    private static final float LON_MAX =  -64.0;

    // Map canvas area (below navbar)
    private float mapX, mapY, mapW, mapH;

    private final color SEA_COLOR = #1ba8f3;

    // ── Constructor ───────────────────────────────────────────────────────────
    MapScreen(Table data, PFont mapFont, PFont labelFont)
    {
        this.data      = data;
        this.mapFont   = mapFont;
        this.labelFont = labelFont;
        
        // Load the map image provided
        this.mapImage  = loadImage("Map.png");

        _buildAirportCoords();
        _buildDateDropdown();

        int navH = Visuals.NAVBAR_H;
        mapX = 0;
        mapY = navH;
        mapW = width;
        mapH = height - navH;
    }

    // ── draw() ────────────────────────────────────────────────────────────────
    public void draw()
    {
        background(SEA_COLOR);
        // Rebuild cache if date changed
        int dateIdx = dateDD.getSelectedIndex();
        if (dateIdx != lastDateIdx)
        {
            _buildFlightCache(dateIdx);
            lastDateIdx = dateIdx;
        }

        // Draw the static map image as the background
        image(mapImage, mapX+40, mapY + 100, mapW - 160, mapH - 100);

        // Draw dynamic flight data on top of the image
        _drawFlightArcs();
        _drawAirportDots();
        _drawLegend();
        _drawDateLabel();

        // Dropdown on top
        dateDD.setPosition(mapX + 20, mapY + 16);
        dateDD.printDropdown();
        dateDD.printList();
    }

    // ── mousePressed() ────────────────────────────────────────────────────────
    public void mousePressed()
    {
        dateDD.mouseClicked();
    }

    // ── Coordinate projection ─────────────────────────────────────────────────
    private float lonToX(float lon)
    {
        return mapX + (lon - LON_MIN) / (LON_MAX - LON_MIN) * mapW;
    }

    private float latToY(float lat)
    {
        return mapY + (1.0 - (lat - LAT_MIN) / (LAT_MAX - LAT_MIN)) * mapH;
    }

    // ── Flight arcs ───────────────────────────────────────────────────────────
    private void _drawFlightArcs()
    {
        if (cachedOriginX == null) return;

        int n = cachedOriginX.length;
        for (int i = 0; i < n; i++)
        {
            float ox = cachedOriginX[i];
            float oy = cachedOriginY[i];
            float dx = cachedDestX[i];
            float dy = cachedDestY[i];

            if (ox < 0 || dx < 0) continue;

            color arcCol;
            if (cachedCancelled[i])
                arcCol = color(239, 68, 68, 55);
            else if (cachedDiverted[i])
                arcCol = color(245, 158, 11, 70);
            else
                arcCol = color(36, 255, 3);

            float mx = (ox + dx) / 2.0;
            float my = (oy + dy) / 2.0;
            float dist = dist(ox, oy, dx, dy);
            float lift = -dist * 0.25; 
            float cpx = mx;
            float cpy = my + lift;

            noFill();
            stroke(arcCol);
            strokeWeight(cachedCancelled[i] ? 1.5 : 0.8);
            bezier(ox, oy, cpx, cpy, cpx, cpy, dx, dy);
        }
        strokeWeight(1);
    }

    // ── Airport dots ──────────────────────────────────────────────────────────
    private void _drawAirportDots()
    {
        if (cachedAirportFlightCount == null) return;

        int maxFlights = 1;
        for (int v : cachedAirportFlightCount.values())
            if (v > maxFlights) maxFlights = v;

        for (java.util.Map.Entry<String, Integer> entry : cachedAirportFlightCount.entrySet())
        {
            String code = entry.getKey();
            int    ct   = entry.getValue();
            float[] coord = airportCoords.get(code);
            if (coord == null) continue;

            float lat = coord[0], lon = coord[1];

            if (lon < LON_MAX && lon > LON_MIN && lat > LAT_MIN && lat < LAT_MAX)
            {
                float px = lonToX(lon);
                float py = latToY(lat);

                float dotR = 2.5 + (float) ct / maxFlights * 8.0;

                noStroke();
                fill(red(Visuals.ACCENT), green(Visuals.ACCENT), blue(Visuals.ACCENT), 25);
                ellipse(px, py, dotR * 3, dotR * 3);

                fill(Visuals.ACCENT, 220);
                ellipse(px, py, dotR, dotR);

                if (ct > maxFlights * 0.08)
                {
                    fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
                    textFont(mapFont);
                    textSize(9);
                    textAlign(CENTER, BOTTOM);
                    text(code, px, py - dotR / 2.0 - 1);
                }
            }
        }
        textAlign(LEFT, BASELINE);
    }

    // ── Legend & Date Labels ──────────────────────────────────────────────────
    private void _drawLegend()
    {
        float lx = width - 220;
        float ly = mapY + 16;
        float lw = 200;
        float lh = 110;

        noStroke();
        fill(Visuals.NAVBAR_BG, 220);
        rect(lx, ly, lw, lh, 8);

        stroke(Visuals.PANEL_BORDER);
        strokeWeight(1);
        noFill();
        rect(lx, ly, lw, lh, 8);

        textFont(mapFont);
        textSize(11);
        fill(Visuals.PANEL_TITLE_COLOUR);
        textAlign(LEFT, CENTER);
        text("Flight Legend", lx + 12, ly + 14);

        color[] cols  = { color(36, 255, 3), color(239, 68, 68), color(245, 158, 11) };
        String[] labs = { "Normal flight", "Cancelled", "Diverted" };

        for (int i = 0; i < 3; i++)
        {
            float ry = ly + 34 + i * 24;
            stroke(cols[i]);
            strokeWeight(2);
            line(lx + 12, ry, lx + 36, ry);
            noStroke();
            fill(Visuals.CHART_LABEL);
            textSize(10);
            text(labs[i], lx + 44, ry);
        }

        noStroke();
        fill(Visuals.ACCENT, 180);
        ellipse(lx + 20, ly + 94, 5,  5);
        ellipse(lx + 34, ly + 94, 10, 10);
        fill(Visuals.CHART_LABEL);
        textSize(9);
        text("= fewer / more flights", lx + 44, ly + 94);
    }

    private void _drawDateLabel()
    {
        int idx = dateDD.getSelectedIndex();
        if (idx < 0 || idx >= uniqueDates.length) return;

        String dateLabel = uniqueDates[idx];
        if (dateLabel.contains(" ")) dateLabel = dateLabel.substring(0, dateLabel.indexOf(" "));

        textFont(labelFont);
        textSize(13);
        float tw = textWidth("Showing flights: " + dateLabel);

        fill(Visuals.NAVBAR_BG, 210);
        noStroke();
        rect(width - tw - 44, mapY + 140, tw + 30, 28, 6);

        fill(Visuals.PANEL_TITLE_COLOUR);
        textAlign(LEFT, CENTER);
        text("Showing: " + dateLabel, width - tw - 30, mapY + 154);
    }


    // ── Cache builder ─────────────────────────────────────────────────────────
    private void _buildFlightCache(int dateIdx)
    {
        if (dateIdx < 0 || dateIdx >= uniqueDates.length) return;
        String selectedDate = uniqueDates[dateIdx];

        // Count matches first
        int count = 0;
        for (int row = 1; row < data.getRowCount(); row++)
            if (data.getString(row, 0).equals(selectedDate)) count++;

        cachedOriginX    = new float[count];
        cachedOriginY    = new float[count];
        cachedDestX      = new float[count];
        cachedDestY      = new float[count];
        cachedCancelled  = new boolean[count];
        cachedDiverted   = new boolean[count];
        cachedAirportFlightCount = new java.util.HashMap<String, Integer>();

        int idx = 0;
        for (int row = 1; row < data.getRowCount(); row++)
        {
            if (!data.getString(row, 0).equals(selectedDate)) continue;

            String origin = data.getString(row, 3).trim();
            String dest   = data.getString(row, 7).trim();

            float[] oCoord = airportCoords.get(origin);
            float[] dCoord = airportCoords.get(dest);

            cachedOriginX[idx] = (oCoord != null) ? lonToX(oCoord[1]) : -1;
            cachedOriginY[idx] = (oCoord != null) ? latToY(oCoord[0]) : -1;
            cachedDestX[idx]   = (dCoord != null) ? lonToX(dCoord[1]) : -1;
            cachedDestY[idx]   = (dCoord != null) ? latToY(dCoord[0]) : -1;

            String cancelVal = data.getString(row, 15).trim();
            String divertVal = data.getString(row, 16).trim();
            cachedCancelled[idx] = cancelVal.equals("1") || cancelVal.equals("1.00")
                                || cancelVal.equalsIgnoreCase("YES");
            cachedDiverted[idx]  = divertVal.equals("1") || divertVal.equals("1.00")
                                || divertVal.equalsIgnoreCase("YES");

            // Airport flight count
            for (String ap : new String[]{ origin, dest })
            {
                cachedAirportFlightCount.put(ap,
                    cachedAirportFlightCount.containsKey(ap)
                    ? cachedAirportFlightCount.get(ap) + 1 : 1);
            }

            idx++;
        }
    }

    // ── Date dropdown builder ─────────────────────────────────────────────────
    private void _buildDateDropdown()
    {
        java.util.LinkedHashSet<String> dateSet = new java.util.LinkedHashSet<String>();
        for (int row = 1; row < data.getRowCount(); row++)
        {
            String d = data.getString(row, 0);
            if (d != null && !d.trim().isEmpty()) dateSet.add(d.trim());
        }

        uniqueDates = dateSet.toArray(new String[0]);
        int[] indices = new int[uniqueDates.length];
        for (int i = 0; i < indices.length; i++) indices[i] = i;

        // Shorten labels to just the date portion
        String[] labels = new String[uniqueDates.length];
        for (int i = 0; i < uniqueDates.length; i++)
        {
            String d = uniqueDates[i];
            labels[i] = d.contains(" ") ? d.substring(0, d.indexOf(" ")) : d;
        }

        dateDD = new Dropdown(mapX + 20, mapY + 16, 160, labels, indices, mapFont);
        dateDD.setTextSize(12);
        dateDD.setCellHeight(32);
    }

    // ── Airport coordinate lookup table ───────────────────────────────────────
    // lat/lon from OurAirports public dataset (ourairports.com, CC0)
    private void _buildAirportCoords()
    {
        airportCoords = new java.util.HashMap<String, float[]>();
        // format: code -> {lat, lon}
        airportCoords.put("ABE", new float[]{40.652,  -75.441});
        airportCoords.put("ABI", new float[]{32.411, -99.682});
        airportCoords.put("ABQ", new float[]{35.040, -106.609});
        airportCoords.put("ABR", new float[]{45.449,  -98.422});
        airportCoords.put("ABY", new float[]{31.535,  -84.194});
        airportCoords.put("ACT", new float[]{31.611,  -97.230});
        airportCoords.put("ACV", new float[]{40.978, -124.109});
        airportCoords.put("ACY", new float[]{39.458,  -74.577});
        airportCoords.put("ADK", new float[]{51.878, -176.646});
        airportCoords.put("ADQ", new float[]{57.750, -152.494});
        airportCoords.put("AEX", new float[]{31.327,  -92.549});
        airportCoords.put("AGS", new float[]{33.370,  -81.965});
        airportCoords.put("AKN", new float[]{58.676, -156.649});
        airportCoords.put("ALB", new float[]{42.748,  -73.802});
        airportCoords.put("ALO", new float[]{42.557,  -92.400});
        airportCoords.put("ALS", new float[]{37.435, -105.866});
        airportCoords.put("ALW", new float[]{46.095, -118.288});
        airportCoords.put("AMA", new float[]{35.220, -101.706});
        airportCoords.put("ANC", new float[]{61.174, -149.996});
        airportCoords.put("APN", new float[]{45.074,  -83.560});
        airportCoords.put("ART", new float[]{43.992,  -76.022});
        airportCoords.put("ASE", new float[]{39.223, -106.869});
        airportCoords.put("ATL", new float[]{33.641,  -84.427});
        airportCoords.put("ATW", new float[]{44.258,  -88.519});
        airportCoords.put("ATY", new float[]{44.915,  -97.154});
        airportCoords.put("AUS", new float[]{30.198,  -97.670});
        airportCoords.put("AVL", new float[]{35.436,  -82.542});
        airportCoords.put("AVP", new float[]{41.338,  -75.724});
        airportCoords.put("AZA", new float[]{33.308, -111.655});
        airportCoords.put("AZO", new float[]{42.235,  -85.552});
        airportCoords.put("BDL", new float[]{41.939,  -72.683});
        airportCoords.put("BET", new float[]{60.774, -161.838});
        airportCoords.put("BFF", new float[]{41.874, -103.596});
        airportCoords.put("BFL", new float[]{35.434, -119.057});
        airportCoords.put("BGM", new float[]{42.209,  -75.980});
        airportCoords.put("BGR", new float[]{44.808,  -68.828});
        airportCoords.put("BHM", new float[]{33.563,  -86.754});
        airportCoords.put("BIH", new float[]{37.373, -118.364});
        airportCoords.put("BIL", new float[]{45.807, -108.543});
        airportCoords.put("BIS", new float[]{46.773, -100.747});
        airportCoords.put("BJI", new float[]{47.508,  -94.934});
        airportCoords.put("BLI", new float[]{48.793, -122.538});
        airportCoords.put("BLV", new float[]{38.545,  -89.835});
        airportCoords.put("BMI", new float[]{40.477,  -88.916});
        airportCoords.put("BNA", new float[]{36.124,  -86.678});
        airportCoords.put("BOI", new float[]{43.564, -116.223});
        airportCoords.put("BOS", new float[]{42.365,  -71.010});
        airportCoords.put("BPT", new float[]{29.951,  -94.021});
        airportCoords.put("BQK", new float[]{31.258,  -81.466});
        airportCoords.put("BQN", new float[]{18.495,  -67.129});
        airportCoords.put("BRD", new float[]{46.394,  -94.138});
        airportCoords.put("BRO", new float[]{25.906,  -97.426});
        airportCoords.put("BRW", new float[]{71.285, -156.766});
        airportCoords.put("BTM", new float[]{45.955, -112.497});
        airportCoords.put("BTR", new float[]{30.533,  -91.150});
        airportCoords.put("BTV", new float[]{44.472,  -73.153});
        airportCoords.put("BUF", new float[]{42.940,  -78.732});
        airportCoords.put("BUR", new float[]{34.201, -118.359});
        airportCoords.put("BWI", new float[]{39.175,  -76.668});
        airportCoords.put("BZN", new float[]{45.777, -111.153});
        airportCoords.put("CAE", new float[]{33.939,  -81.119});
        airportCoords.put("CAK", new float[]{40.916,  -81.442});
        airportCoords.put("CDC", new float[]{37.701, -113.099});
        airportCoords.put("CDV", new float[]{60.492, -145.478});
        airportCoords.put("CGI", new float[]{37.226,  -89.571});
        airportCoords.put("CHA", new float[]{35.035,  -85.204});
        airportCoords.put("CHO", new float[]{38.139,  -78.453});
        airportCoords.put("CHS", new float[]{32.899,  -80.041});
        airportCoords.put("CID", new float[]{41.884,  -91.711});
        airportCoords.put("CIU", new float[]{46.251,  -84.472});
        airportCoords.put("CKB", new float[]{39.297,  -80.228});
        airportCoords.put("CLE", new float[]{41.412,  -81.850});
        airportCoords.put("CLL", new float[]{30.589,  -96.364});
        airportCoords.put("CLT", new float[]{35.214,  -80.943});
        airportCoords.put("CMH", new float[]{39.998,  -82.892});
        airportCoords.put("CMI", new float[]{40.040,  -88.278});
        airportCoords.put("CMX", new float[]{47.168,  -88.489});
        airportCoords.put("CNY", new float[]{38.755, -109.755});
        airportCoords.put("COD", new float[]{44.520, -109.024});
        airportCoords.put("COS", new float[]{38.806, -104.701});
        airportCoords.put("COU", new float[]{38.818,  -92.220});
        airportCoords.put("CPR", new float[]{42.908, -106.464});
        airportCoords.put("CRP", new float[]{27.770,  -97.502});
        airportCoords.put("CRW", new float[]{38.373,  -81.593});
        airportCoords.put("CSG", new float[]{32.516,  -84.939});
        airportCoords.put("CVG", new float[]{39.048,  -84.667});
        airportCoords.put("CWA", new float[]{44.778,  -89.667});
        airportCoords.put("CYS", new float[]{41.157, -104.812});
        airportCoords.put("DAB", new float[]{29.180,  -81.058});
        airportCoords.put("DAL", new float[]{32.847,  -96.852});
        airportCoords.put("DAY", new float[]{39.902,  -84.219});
        airportCoords.put("DBQ", new float[]{42.402,  -90.709});
        airportCoords.put("DCA", new float[]{38.852,  -77.038});
        airportCoords.put("DDC", new float[]{37.761,  -99.965});
        airportCoords.put("DEC", new float[]{39.835,  -88.866});
        airportCoords.put("DEN", new float[]{39.857, -104.673});
        airportCoords.put("DFW", new float[]{32.897,  -97.038});
        airportCoords.put("DHN", new float[]{31.321,  -85.449});
        airportCoords.put("DIK", new float[]{46.798, -102.802});
        airportCoords.put("DLG", new float[]{59.044, -158.507});
        airportCoords.put("DLH", new float[]{46.842,  -92.194});
        airportCoords.put("DRO", new float[]{37.151, -107.754});
        airportCoords.put("DRT", new float[]{29.502, -100.927});
        airportCoords.put("DSM", new float[]{41.534,  -93.663});
        airportCoords.put("DTW", new float[]{42.212,  -83.353});
        airportCoords.put("DVL", new float[]{48.115,  -98.908});
        airportCoords.put("EAR", new float[]{40.727,  -99.006});
        airportCoords.put("EAT", new float[]{47.399, -120.206});
        airportCoords.put("EAU", new float[]{44.866,  -91.485});
        airportCoords.put("ECP", new float[]{30.357,  -85.796});
        airportCoords.put("EGE", new float[]{39.643, -106.918});
        airportCoords.put("EKO", new float[]{40.825, -115.792});
        airportCoords.put("ELM", new float[]{42.160,  -76.891});
        airportCoords.put("ELP", new float[]{31.807, -106.378});
        airportCoords.put("ERI", new float[]{42.083,  -80.177});
        airportCoords.put("ESC", new float[]{45.723,  -87.094});
        airportCoords.put("EUG", new float[]{44.125, -123.212});
        airportCoords.put("EVV", new float[]{38.037,  -87.532});
        airportCoords.put("EWN", new float[]{35.073,  -77.043});
        airportCoords.put("EWR", new float[]{40.693,  -74.168});
        airportCoords.put("EYW", new float[]{24.556,  -81.760});
        airportCoords.put("FAI", new float[]{64.815, -147.856});
        airportCoords.put("FAR", new float[]{46.921,  -96.816});
        airportCoords.put("FAT", new float[]{36.776, -119.718});
        airportCoords.put("FAY", new float[]{34.992,  -78.880});
        airportCoords.put("FCA", new float[]{48.310, -114.256});
        airportCoords.put("FLG", new float[]{35.138, -111.671});
        airportCoords.put("FLL", new float[]{26.073,  -80.150});
        airportCoords.put("FLO", new float[]{34.185,  -79.724});
        airportCoords.put("FNT", new float[]{42.966,  -83.744});
        airportCoords.put("FOD", new float[]{42.551,  -94.192});
        airportCoords.put("FSD", new float[]{43.582,  -96.742});
        airportCoords.put("FSM", new float[]{35.337,  -94.368});
        airportCoords.put("FWA", new float[]{40.978,  -85.195});
        airportCoords.put("GCC", new float[]{44.349, -105.540});
        airportCoords.put("GCK", new float[]{37.928,  -100.724});
        airportCoords.put("GEG", new float[]{47.620, -117.534});
        airportCoords.put("GFK", new float[]{47.949,  -97.176});
        airportCoords.put("GGG", new float[]{32.384,  -94.712});
        airportCoords.put("GJT", new float[]{39.122, -108.527});
        airportCoords.put("GNV", new float[]{29.690,  -82.272});
        airportCoords.put("GPT", new float[]{30.407,  -89.070});
        airportCoords.put("GRB", new float[]{44.486,  -88.130});
        airportCoords.put("GRI", new float[]{40.968,  -98.310});
        airportCoords.put("GRK", new float[]{31.067,  -97.829});
        airportCoords.put("GRR", new float[]{42.881,  -85.523});
        airportCoords.put("GSO", new float[]{36.098,  -79.937});
        airportCoords.put("GSP", new float[]{34.896,  -82.219});
        airportCoords.put("GTF", new float[]{47.482, -111.371});
        airportCoords.put("GTR", new float[]{33.451,  -88.592});
        airportCoords.put("GUC", new float[]{38.534, -106.933});
        airportCoords.put("GUM", new float[]{13.484,  144.796});
        airportCoords.put("HDN", new float[]{40.481, -107.218});
        airportCoords.put("HGR", new float[]{39.708,  -77.729});
        airportCoords.put("HHH", new float[]{32.224,  -80.698});
        airportCoords.put("HIB", new float[]{47.387,  -92.839});
        airportCoords.put("HLN", new float[]{46.607, -111.983});
        airportCoords.put("HNL", new float[]{21.320, -157.924});
        airportCoords.put("HOB", new float[]{32.688, -103.217});
        airportCoords.put("HOU", new float[]{29.645,  -95.279});
        airportCoords.put("HPN", new float[]{41.067,  -73.708});
        airportCoords.put("HRL", new float[]{26.229,  -97.654});
        airportCoords.put("HSV", new float[]{34.637,  -86.775});
        airportCoords.put("HTS", new float[]{38.367,  -82.558});
        airportCoords.put("HYS", new float[]{38.845, -99.274});
        airportCoords.put("IAD", new float[]{38.944,  -77.456});
        airportCoords.put("IAG", new float[]{43.108,  -78.946});
        airportCoords.put("IAH", new float[]{29.984,  -95.341});
        airportCoords.put("ICT", new float[]{37.650,  -97.433});
        airportCoords.put("IDA", new float[]{43.514, -112.070});
        airportCoords.put("ILG", new float[]{39.679,  -75.607});
        airportCoords.put("ILM", new float[]{34.271,  -77.903});
        airportCoords.put("IMT", new float[]{45.818,  -88.114});
        airportCoords.put("IND", new float[]{39.717,  -86.295});
        airportCoords.put("INL", new float[]{48.566,  -93.403});
        airportCoords.put("ISP", new float[]{40.795,  -73.100});
        airportCoords.put("ITH", new float[]{42.491,  -76.459});
        airportCoords.put("ITO", new float[]{19.721, -155.048});
        airportCoords.put("JAC", new float[]{43.607, -110.738});
        airportCoords.put("JAN", new float[]{32.311,  -90.076});
        airportCoords.put("JAX", new float[]{30.494,  -81.688});
        airportCoords.put("JFK", new float[]{40.640,  -73.778});
        airportCoords.put("JLN", new float[]{37.152,  -94.498});
        airportCoords.put("JMS", new float[]{46.930,  -98.678});
        airportCoords.put("JNU", new float[]{58.355, -134.576});
        airportCoords.put("JST", new float[]{40.316,  -78.834});
        airportCoords.put("KOA", new float[]{19.739, -156.046});
        airportCoords.put("KTN", new float[]{55.355, -131.714});
        airportCoords.put("LAN", new float[]{42.779,  -84.587});
        airportCoords.put("LAR", new float[]{41.312, -105.675});
        airportCoords.put("LAS", new float[]{36.080, -115.152});
        airportCoords.put("LAW", new float[]{34.568,  -98.416});
        airportCoords.put("LAX", new float[]{33.943, -118.408});
        airportCoords.put("LBB", new float[]{33.664, -101.823});
        airportCoords.put("LBE", new float[]{40.276,  -79.405});
        airportCoords.put("LBF", new float[]{41.126, -100.960});
        airportCoords.put("LBL", new float[]{37.044, -100.960});
        airportCoords.put("LCH", new float[]{30.126,  -93.223});
        airportCoords.put("LCK", new float[]{39.815,  -82.927});
        airportCoords.put("LEX", new float[]{38.036,  -84.606});
        airportCoords.put("LFT", new float[]{30.205,  -91.988});
        airportCoords.put("LGA", new float[]{40.777,  -73.873});
        airportCoords.put("LGB", new float[]{33.818, -118.152});
        airportCoords.put("LIH", new float[]{21.976, -159.339});
        airportCoords.put("LIT", new float[]{34.729,  -92.224});
        airportCoords.put("LNK", new float[]{40.851,  -96.759});
        airportCoords.put("LRD", new float[]{27.544,  -99.462});
        airportCoords.put("LSE", new float[]{43.879,  -91.257});
        airportCoords.put("LWB", new float[]{37.858,  -80.399});
        airportCoords.put("LWS", new float[]{46.375, -117.015});
        airportCoords.put("LYH", new float[]{37.327,  -79.200});
        airportCoords.put("MAF", new float[]{31.943, -102.202});
        airportCoords.put("MBS", new float[]{43.533,  -84.080});
        airportCoords.put("MCI", new float[]{39.298,  -94.714});
        airportCoords.put("MCO", new float[]{28.429,  -81.309});
        airportCoords.put("MCW", new float[]{43.158,  -93.331});
        airportCoords.put("MDT", new float[]{40.194,  -76.763});
        airportCoords.put("MDW", new float[]{41.786,  -87.742});
        airportCoords.put("MEI", new float[]{32.333,  -88.751});
        airportCoords.put("MEM", new float[]{35.043,  -89.977});
        airportCoords.put("MFE", new float[]{26.176,  -98.239});
        airportCoords.put("MFR", new float[]{42.374, -122.873});
        airportCoords.put("MGM", new float[]{32.301,  -86.394});
        airportCoords.put("MHK", new float[]{39.141,  -96.671});
        airportCoords.put("MHT", new float[]{42.933,  -71.436});
        airportCoords.put("MIA", new float[]{25.796,  -80.287});
        airportCoords.put("MKE", new float[]{42.947,  -87.897});
        airportCoords.put("MKG", new float[]{43.170,  -86.238});
        airportCoords.put("MLB", new float[]{28.103,  -80.645});
        airportCoords.put("MLI", new float[]{41.449,  -90.508});
        airportCoords.put("MLU", new float[]{32.511,  -92.037});
        airportCoords.put("MOB", new float[]{30.691,  -88.243});
        airportCoords.put("MOT", new float[]{48.259, -101.280});
        airportCoords.put("MQT", new float[]{46.354,  -87.395});
        airportCoords.put("MRY", new float[]{36.587, -121.843});
        airportCoords.put("MSN", new float[]{43.140,  -89.338});
        airportCoords.put("MSO", new float[]{46.916, -114.091});
        airportCoords.put("MSP", new float[]{44.880,  -93.222});
        airportCoords.put("MSY", new float[]{29.993,  -90.258});
        airportCoords.put("MTJ", new float[]{38.509, -107.894});
        airportCoords.put("MYR", new float[]{33.680,  -78.928});
        airportCoords.put("OAJ", new float[]{34.829,  -77.612});
        airportCoords.put("OAK", new float[]{37.722, -122.221});
        airportCoords.put("OGD", new float[]{41.196, -112.012});
        airportCoords.put("OGG", new float[]{20.900, -156.430});
        airportCoords.put("OGS", new float[]{44.682,  -75.465});
        airportCoords.put("OKC", new float[]{35.394,  -97.601});
        airportCoords.put("OMA", new float[]{41.303,  -95.894});
        airportCoords.put("OME", new float[]{64.513, -165.445});
        airportCoords.put("ONT", new float[]{34.056, -117.601});
        airportCoords.put("ORD", new float[]{41.979,  -87.905});
        airportCoords.put("ORF", new float[]{36.898,  -76.018});
        airportCoords.put("ORH", new float[]{42.268,  -71.876});
        airportCoords.put("OTH", new float[]{43.417, -124.246});
        airportCoords.put("OTZ", new float[]{66.888, -162.599});
        airportCoords.put("PAE", new float[]{47.906, -122.282});
        airportCoords.put("PAH", new float[]{37.061,  -88.774});
        airportCoords.put("PBG", new float[]{44.651,  -73.468});
        airportCoords.put("PBI", new float[]{26.683,  -80.096});
        airportCoords.put("PDX", new float[]{45.589, -122.598});
        airportCoords.put("PGD", new float[]{26.920,  -81.990});
        airportCoords.put("PGV", new float[]{35.635,  -77.385});
        airportCoords.put("PHF", new float[]{37.132,  -76.493});
        airportCoords.put("PHL", new float[]{39.872,  -75.241});
        airportCoords.put("PHX", new float[]{33.437, -112.008});
        airportCoords.put("PIA", new float[]{40.664,  -89.693});
        airportCoords.put("PIB", new float[]{31.952,  -89.337});
        airportCoords.put("PIE", new float[]{27.910,  -82.687});
        airportCoords.put("PIH", new float[]{42.910, -112.596});
        airportCoords.put("PIR", new float[]{44.383, -100.286});
        airportCoords.put("PIT", new float[]{40.491,  -80.233});
        airportCoords.put("PLN", new float[]{45.571,  -84.797});
        airportCoords.put("PNS", new float[]{30.474,  -87.187});
        airportCoords.put("PQI", new float[]{46.689,  -68.045});
        airportCoords.put("PRC", new float[]{34.655, -112.420});
        airportCoords.put("PSC", new float[]{46.265, -119.119});
        airportCoords.put("PSE", new float[]{18.010,  -66.563});
        airportCoords.put("PSG", new float[]{56.802, -132.946});
        airportCoords.put("PSM", new float[]{43.079,  -70.823});
        airportCoords.put("PSP", new float[]{33.829, -116.507});
        airportCoords.put("PUB", new float[]{38.289, -104.497});
        airportCoords.put("PUW", new float[]{46.744, -117.110});
        airportCoords.put("PVD", new float[]{41.724,  -71.428});
        airportCoords.put("PVU", new float[]{40.219, -111.724});
        airportCoords.put("PWM", new float[]{43.646,  -70.309});
        airportCoords.put("RAP", new float[]{44.045, -103.057});
        airportCoords.put("RDD", new float[]{40.509, -122.293});
        airportCoords.put("RDM", new float[]{44.254, -121.150});
        airportCoords.put("RDU", new float[]{35.878,  -78.787});
        airportCoords.put("RFD", new float[]{42.196,  -89.097});
        airportCoords.put("RHI", new float[]{45.631,  -89.467});
        airportCoords.put("RIC", new float[]{37.505,  -77.320});
        airportCoords.put("RIW", new float[]{43.064, -108.460});
        airportCoords.put("RKS", new float[]{41.594, -109.065});
        airportCoords.put("RNO", new float[]{39.499, -119.768});
        airportCoords.put("ROA", new float[]{37.325,  -79.975});
        airportCoords.put("ROC", new float[]{43.119,  -77.672});
        airportCoords.put("ROW", new float[]{33.302, -104.531});
        airportCoords.put("RST", new float[]{43.909,  -92.500});
        airportCoords.put("RSW", new float[]{26.536,  -81.755});
        airportCoords.put("SAF", new float[]{35.617, -106.089});
        airportCoords.put("SAN", new float[]{32.734, -117.190});
        airportCoords.put("SAT", new float[]{29.534,  -98.470});
        airportCoords.put("SAV", new float[]{32.128,  -81.202});
        airportCoords.put("SBA", new float[]{34.426, -119.840});
        airportCoords.put("SBN", new float[]{41.709,  -86.317});
        airportCoords.put("SBP", new float[]{35.237, -120.642});
        airportCoords.put("SBY", new float[]{38.340,  -75.510});
        airportCoords.put("SCC", new float[]{66.248, -148.464});
        airportCoords.put("SCE", new float[]{40.849,  -77.847});
        airportCoords.put("SCK", new float[]{37.894, -121.238});
        airportCoords.put("SDF", new float[]{38.175,  -85.737});
        airportCoords.put("SEA", new float[]{47.450, -122.311});
        airportCoords.put("SFB", new float[]{28.777,  -81.238});
        airportCoords.put("SFO", new float[]{37.619, -122.375});
        airportCoords.put("SGF", new float[]{37.246,  -93.389});
        airportCoords.put("SGU", new float[]{37.036, -113.511});
        airportCoords.put("SHD", new float[]{38.264,  -78.896});
        airportCoords.put("SHR", new float[]{44.770, -106.980});
        airportCoords.put("SHV", new float[]{32.447,  -93.826});
        airportCoords.put("SIT", new float[]{57.047, -135.362});
        airportCoords.put("SJC", new float[]{37.362, -121.929});
        airportCoords.put("SJT", new float[]{31.357, -100.497});
        airportCoords.put("SJU", new float[]{18.439,  -66.001});
        airportCoords.put("SLC", new float[]{40.788, -111.978});
        airportCoords.put("SLN", new float[]{38.791,  -97.652});
        airportCoords.put("SMF", new float[]{38.695, -121.591});
        airportCoords.put("SMX", new float[]{34.899, -120.457});
        airportCoords.put("SNA", new float[]{33.676, -117.868});
        airportCoords.put("SPI", new float[]{39.844,  -89.678});
        airportCoords.put("SPN", new float[]{15.119,  145.729});
        airportCoords.put("SPS", new float[]{33.989,  -98.492});
        airportCoords.put("SRQ", new float[]{27.396,  -82.554});
        airportCoords.put("STC", new float[]{45.547,  -94.060});
        airportCoords.put("STL", new float[]{38.748,  -90.370});
        airportCoords.put("STS", new float[]{38.509, -122.813});
        airportCoords.put("STT", new float[]{18.337,  -64.973});
        airportCoords.put("STX", new float[]{17.702,  -64.799});
        airportCoords.put("SUN", new float[]{43.505, -114.296});
        airportCoords.put("SUX", new float[]{42.403,  -96.384});
        airportCoords.put("SWF", new float[]{41.504,  -74.105});
        airportCoords.put("SWO", new float[]{36.162,  -97.086});
        airportCoords.put("SYR", new float[]{43.111,  -76.106});
        airportCoords.put("TBN", new float[]{37.742,  -92.140});
        airportCoords.put("TLH", new float[]{30.397,  -84.351});
        airportCoords.put("TOL", new float[]{41.588,  -83.808});
        airportCoords.put("TPA", new float[]{27.975,  -82.533});
        airportCoords.put("TRI", new float[]{36.476,  -82.407});
        airportCoords.put("TTN", new float[]{40.277,  -74.813});
        airportCoords.put("TUL", new float[]{36.198,  -95.888});
        airportCoords.put("TUS", new float[]{32.116, -110.941});
        airportCoords.put("TVC", new float[]{44.741,  -85.582});
        airportCoords.put("TWF", new float[]{42.482, -114.488});
        airportCoords.put("TXK", new float[]{33.452,  -93.991});
        airportCoords.put("TYR", new float[]{32.354,  -95.402});
        airportCoords.put("TYS", new float[]{35.811,  -83.994});
        airportCoords.put("VCT", new float[]{28.860,  -96.919});
        airportCoords.put("VEL", new float[]{40.441, -109.510});
        airportCoords.put("VLD", new float[]{30.782,  -83.277});
        airportCoords.put("VPS", new float[]{30.483,  -86.525});
        airportCoords.put("WRG", new float[]{56.484, -132.370});
        airportCoords.put("XNA", new float[]{36.282,  -94.307});
        airportCoords.put("XWA", new float[]{48.259, -101.281});
        airportCoords.put("YAK", new float[]{59.503, -139.660});
        airportCoords.put("YKM", new float[]{46.568, -120.544});
        airportCoords.put("YUM", new float[]{32.657, -114.606});
        airportCoords.put("USA", new float[]{38.897,  -77.036}); // generic fallback
        airportCoords.put("TTN", new float[]{40.277,  -74.813});
        airportCoords.put("PGD", new float[]{26.920,  -81.990});
    }
}
