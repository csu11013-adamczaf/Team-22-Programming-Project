import java.util.HashMap;

final color[] GRAPH_PALETTE = {
    #3B82F6, #F59E0B, #EF4444, #10B981,
    #8B5CF6, #EC4899, #06B6D4, #84CC16
};

final int GRAPH_REGION_GAP   = 50;
final int GRAPH_MARGIN       = 20;
final int GRAPH_LEGEND_W     = 220;
final int GRAPH_TITLE_H      = 36;
final int GRAPH_DROPDOWN_H   = 38;
final int GRAPH_AXIS_LABEL_H = 65;
final int GRAPH_Y_AXIS_W     = 55;
final int GRAPH_LABEL_SIZE   = 12;
final int GRAPH_TITLE_SIZE   = 15;
final int GRAPH_DROPDOWN_W   = 200;
final int GRAPH_DROPDOWN_GAP = 8;
final int GRAPH_POINT_PAD    = 30;
PFont GRAPH_FONT;

final int GRAPH_PANEL_Y = Visuals.NAVBAR_H + 8;

final int[] CATEGORICAL_COLS = { 0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16 };
final int[] NUMERICAL_COLS   = { 6, 10, 11, 12, 13, 14, 17 };

// ─────────────────────────────────────────────────────────────────────────────

class Graphs
{
    private Table data;
    private PFont graphFont;
    private PFont titleFont;
    private int   numberOfRows;

    private Dropdown pieCategoryDD;
    private Dropdown lineCategoryDD;
    private Dropdown lineValueDD;
    private Dropdown barCategoryDD;
    private Dropdown barValueDD;

    Graphs(Table data, int numberOfRows)
    {
        this.data         = data;
        this.numberOfRows = numberOfRows;
        this.graphFont    = loadFont(Visuals.TABLEWIDGET_TABLE_FONT);
        this.titleFont    = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
        GRAPH_FONT = loadFont(Visuals.BUTTON_BUTTON_FONT);
        _initDropdowns();
    }

    private void _initDropdowns()
    {
        String[] catLabels  = new String[CATEGORICAL_COLS.length];
        int[]    catIndices = new int[CATEGORICAL_COLS.length];
        for (int i = 0; i < CATEGORICAL_COLS.length; i++)
        {
            catIndices[i] = CATEGORICAL_COLS[i];
            catLabels[i]  = data.getString(0, CATEGORICAL_COLS[i]);
        }

        String[] numLabels  = new String[NUMERICAL_COLS.length];
        int[]    numIndices = new int[NUMERICAL_COLS.length];
        for (int i = 0; i < NUMERICAL_COLS.length; i++)
        {
            numIndices[i] = NUMERICAL_COLS[i];
            numLabels[i]  = data.getString(0, NUMERICAL_COLS[i]);
        }

        pieCategoryDD  = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices, GRAPH_FONT);
        lineCategoryDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices, GRAPH_FONT);
        lineValueDD    = new Dropdown(0, 0, GRAPH_DROPDOWN_W, numLabels, numIndices, GRAPH_FONT);
        barCategoryDD  = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices, GRAPH_FONT);
        barValueDD     = new Dropdown(0, 0, GRAPH_DROPDOWN_W, numLabels, numIndices, GRAPH_FONT);
    }

    private float tableTopY()
    {
        return height - TABLE_Y_OFFSET - (numberOfRows * ROW_HEIGHT) - HEADER_HEIGHT;
    }

    private float chartRegionHeight()
    {
        return tableTopY() - GRAPH_REGION_GAP - GRAPH_PANEL_Y;
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printPieChart  — left third
    // ═════════════════════════════════════════════════════════════════════════
    public void printPieChart()
    {
        int    categoryColumn = pieCategoryDD.getSelectedIndex();
        String title          = "Flights by " + pieCategoryDD.getSelectedLabel();

        // LinkedHashMap preserves encounter order so legend is stable
        java.util.LinkedHashMap<String, Integer> counts =
            new java.util.LinkedHashMap<String, Integer>();

        for (int row = 1; row < data.getRowCount(); row++)
        {
            String val = data.getString(row, categoryColumn);
            if (val == null || val.trim().equals("")) continue;
            counts.put(val, counts.containsKey(val) ? counts.get(val) + 1 : 1);
        }

        String[] categories = counts.keySet().toArray(new String[0]);
        int total = 0;
        for (String k : categories) total += counts.get(k);
        if (total == 0) return;

        float panelX = 0;
        float panelY = GRAPH_PANEL_Y;
        float panelW = width / 3.0;
        float panelH = chartRegionHeight();

        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);

        float ddX = panelX + GRAPH_MARGIN;
        float ddY = panelY + GRAPH_TITLE_H + (GRAPH_DROPDOWN_H - DROPDOWN_H) / 2.0;
        pieCategoryDD.setPosition(ddX, ddY);
        pieCategoryDD.printDropdown();

        // Legend gets right portion; circle gets the rest
        float legendW  = min(GRAPH_LEGEND_W, panelW * 0.38);
        float chartY   = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H;
        float innerW   = panelW - legendW - 2 * GRAPH_MARGIN;
        float innerH   = panelH - GRAPH_TITLE_H - GRAPH_DROPDOWN_H - 2 * GRAPH_MARGIN;
        float diameter = min(innerW, innerH) * 0.88;
        float cx       = panelX + GRAPH_MARGIN + innerW / 2.0;
        float cy       = chartY + GRAPH_MARGIN + innerH / 2.0;

        // Slices
        float startAngle = -HALF_PI;
        noStroke();

        for (int i = 0; i < categories.length; i++)
        {
            float fraction   = (float) counts.get(categories[i]) / total;
            float sweepAngle = fraction * TWO_PI;

            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            arc(cx, cy, diameter, diameter, startAngle, startAngle + sweepAngle, PIE);

            if (fraction > 0.05)
            {
                float mid = startAngle + sweepAngle / 2.0;
                fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
                textFont(graphFont);
                textSize(GRAPH_LABEL_SIZE - 1);
                textAlign(CENTER, CENTER);
                text(nf(fraction * 100, 1, 0) + "%",
                     cx + cos(mid) * diameter * 0.34,
                     cy + sin(mid) * diameter * 0.34);
            }
            startAngle += sweepAngle;
        }

        // Thin ring border
        stroke(255, 255, 255, 30);
        strokeWeight(1);
        noFill();
        ellipse(cx, cy, diameter, diameter);
        strokeWeight(1);

        // Legend
        _drawPieLegend(categories, counts, total,
                       panelX + panelW - legendW - GRAPH_MARGIN / 2.0,
                       chartY + GRAPH_MARGIN);

        textAlign(LEFT, BASELINE);
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printBarChart  — centre third
    // ═════════════════════════════════════════════════════════════════════════
    public void printBarChart()
    {
        int    categoryColumn = barCategoryDD.getSelectedIndex();
        int    valueColumn    = barValueDD.getSelectedIndex();
        String title          = "Avg " + barValueDD.getSelectedLabel()
                              + " by " + barCategoryDD.getSelectedLabel();

        java.util.LinkedHashMap<String, Float>   sums =
            new java.util.LinkedHashMap<String, Float>();
        java.util.LinkedHashMap<String, Integer> cnt  =
            new java.util.LinkedHashMap<String, Integer>();

        for (int row = 1; row < data.getRowCount(); row++)
        {
            String catVal = data.getString(row, categoryColumn);
            if (catVal == null || catVal.trim().equals("")) continue;
            float numVal;
            try   { numVal = Float.parseFloat(data.getString(row, valueColumn)); }
            catch (NumberFormatException e) { continue; }
            sums.put(catVal, sums.containsKey(catVal) ? sums.get(catVal) + numVal : numVal);
            cnt.put(catVal,  cnt.containsKey(catVal)  ? cnt.get(catVal)  + 1      : 1);
        }

        float panelW = width / 3.0;
        float panelX = panelW;
        float panelY = GRAPH_PANEL_Y;
        float panelH = chartRegionHeight();

        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);

        float ddY  = panelY + GRAPH_TITLE_H + (GRAPH_DROPDOWN_H - DROPDOWN_H) / 2.0;
        float dd1X = panelX + GRAPH_MARGIN;
        float dd2X = dd1X + GRAPH_DROPDOWN_W + GRAPH_DROPDOWN_GAP;
        barCategoryDD.setPosition(dd1X, ddY);
        barValueDD.setPosition(dd2X, ddY);
        barCategoryDD.printDropdown();
        barValueDD.printDropdown();

        if (sums.size() < 1) return;

        String[] categories = sums.keySet().toArray(new String[0]);
        float[]  yValues    = new float[categories.length];
        float    yMax       = 0;
        for (int i = 0; i < categories.length; i++)
        {
            yValues[i] = sums.get(categories[i]) / cnt.get(categories[i]);
            yMax = max(yMax, yValues[i]);
        }
        yMax  *= 1.15;
        float yRange = (yMax == 0) ? 1 : yMax;

        float plotX1 = panelX + GRAPH_MARGIN + GRAPH_Y_AXIS_W;
        float plotX2 = panelX + panelW - GRAPH_MARGIN;
        float plotY1 = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H + GRAPH_MARGIN;
        float plotY2 = panelY + panelH - GRAPH_MARGIN - GRAPH_AXIS_LABEL_H;
        float plotW  = plotX2 - plotX1;
        float plotH  = plotY2 - plotY1;

        // Gridlines + y labels
        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 2);
        textAlign(RIGHT, CENTER);
        for (int t = 0; t <= 5; t++)
        {
            float frac = (float) t / 5;
            float py   = plotY2 - frac * plotH;
            stroke(Visuals.CHART_GRIDLINE);
            strokeWeight(1);
            line(plotX1, py, plotX2, py);
            noStroke();
            fill(Visuals.CHART_LABEL);
            text(nf(frac * yMax, 1, 1), plotX1 - 6, py);
        }

        // Axes
        stroke(Visuals.CHART_AXIS);
        strokeWeight(1.5);
        line(plotX1, plotY1, plotX1, plotY2);
        line(plotX1, plotY2, plotX2, plotY2);

        // Bars
        float barTotalW = plotW / categories.length;
        float barW      = barTotalW * 0.65;

        for (int i = 0; i < categories.length; i++)
        {
            float h   = (yValues[i] / yRange) * plotH;
            float bx  = plotX1 + i * barTotalW + (barTotalW - barW) / 2.0;
            float by  = plotY2 - h;
            color col = GRAPH_PALETTE[i % GRAPH_PALETTE.length];

            // Subtle glow fill behind bar
            noStroke();
            fill(red(col), green(col), blue(col), 30);
            rect(bx, plotY1, barW, plotH, 3);

            // Bar itself
            fill(col);
            rect(bx, by, barW, h, 3, 3, 0, 0);

            // Value label above bar
            fill(Visuals.CHART_VALUE_LABEL);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE - 2);
            textAlign(CENTER, BOTTOM);
            text(nf(yValues[i], 1, 1), bx + barW / 2.0, by - 3);

            // X-axis label rotated
            fill(Visuals.CHART_LABEL);
            textAlign(RIGHT, CENTER);
            pushMatrix();
            translate(bx + barW / 2.0, plotY2 + 10);
            rotate(-PI / 3.0);
            text(categories[i], 0, 0);
            popMatrix();
        }

        textAlign(LEFT, BASELINE);
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printLineChart  — right third
    // ═════════════════════════════════════════════════════════════════════════
    public void printLineChart()
    {
        int    categoryColumn = lineCategoryDD.getSelectedIndex();
        int    valueColumn    = lineValueDD.getSelectedIndex();
        String title          = "Avg " + lineValueDD.getSelectedLabel()
                              + " by " + lineCategoryDD.getSelectedLabel();

        java.util.LinkedHashMap<String, Float>   sums =
            new java.util.LinkedHashMap<String, Float>();
        java.util.LinkedHashMap<String, Integer> cnt  =
            new java.util.LinkedHashMap<String, Integer>();

        for (int row = 1; row < data.getRowCount(); row++)
        {
            String catVal = data.getString(row, categoryColumn);
            if (catVal == null || catVal.trim().equals("")) continue;
            float numVal;
            try   { numVal = Float.parseFloat(data.getString(row, valueColumn)); }
            catch (NumberFormatException e) { continue; }
            sums.put(catVal, sums.containsKey(catVal) ? sums.get(catVal) + numVal : numVal);
            cnt.put(catVal,  cnt.containsKey(catVal)  ? cnt.get(catVal)  + 1      : 1);
        }

        float panelX = (width / 3.0) * 2;
        float panelY = GRAPH_PANEL_Y;
        float panelW = width / 3.0;
        float panelH = chartRegionHeight();

        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);

        float ddY  = panelY + GRAPH_TITLE_H + (GRAPH_DROPDOWN_H - DROPDOWN_H) / 2.0;
        float dd1X = panelX + GRAPH_MARGIN;
        float dd2X = dd1X + GRAPH_DROPDOWN_W + GRAPH_DROPDOWN_GAP;
        lineCategoryDD.setPosition(dd1X, ddY);
        lineValueDD.setPosition(dd2X, ddY);
        lineCategoryDD.printDropdown();
        lineValueDD.printDropdown();

        if (sums.size() < 2)
        {
            fill(Visuals.CHART_LABEL);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE);
            textAlign(CENTER, CENTER);
            text("Not enough data for selected columns.",
                 panelX + panelW / 2.0, panelY + panelH / 2.0);
            textAlign(LEFT, BASELINE);
            return;
        }

        String[] categories = sums.keySet().toArray(new String[0]);
        float[]  yValues    = new float[categories.length];
        for (int i = 0; i < categories.length; i++)
            yValues[i] = sums.get(categories[i]) / cnt.get(categories[i]);

        float yMin = yValues[0], yMax = yValues[0];
        for (float v : yValues) { yMin = min(yMin, v); yMax = max(yMax, v); }
        yMax += (yMax - yMin) * 0.15;
        if (yMin > 0) yMin = 0;
        float yRange = (yMax == yMin) ? 1 : yMax - yMin;

        float plotX1 = panelX + GRAPH_MARGIN + GRAPH_Y_AXIS_W;
        float plotX2 = panelX + panelW - GRAPH_MARGIN;
        float plotY1 = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H + GRAPH_MARGIN;
        float plotY2 = panelY + panelH - GRAPH_MARGIN - GRAPH_AXIS_LABEL_H;
        float plotH  = plotY2 - plotY1;

        float drawX1 = plotX1 + GRAPH_POINT_PAD;
        float drawX2 = plotX2 - GRAPH_POINT_PAD;
        float drawW  = drawX2 - drawX1;
        float xStep  = (categories.length > 1) ? drawW / (categories.length - 1) : drawW;

        // Gridlines + y labels
        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 2);
        textAlign(RIGHT, CENTER);
        for (int t = 0; t <= 5; t++)
        {
            float frac = (float) t / 5;
            float py   = plotY2 - frac * plotH;
            stroke(Visuals.CHART_GRIDLINE);
            strokeWeight(1);
            line(plotX1, py, plotX2, py);
            noStroke();
            fill(Visuals.CHART_LABEL);
            text(nf(yMin + frac * yRange, 1, 1), plotX1 - 6, py);
        }

        // Axes
        stroke(Visuals.CHART_AXIS);
        strokeWeight(1.5);
        line(plotX1, plotY1, plotX1, plotY2);
        line(plotX1, plotY2, plotX2, plotY2);

        // X-axis labels rotated
        for (int i = 0; i < categories.length; i++)
        {
            float px = drawX1 + i * xStep;
            stroke(Visuals.CHART_AXIS);
            strokeWeight(1);
            line(px, plotY2, px, plotY2 + 5);
            noStroke();
            fill(Visuals.CHART_LABEL);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE - 2);
            textAlign(RIGHT, CENTER);
            pushMatrix();
            translate(px, plotY2 + 10);
            rotate(-PI / 3.0);
            text(categories[i], 0, 0);
            popMatrix();
        }

        // Gradient-style filled area under line
        color lineCol = GRAPH_PALETTE[0];
        noStroke();
        fill(red(lineCol), green(lineCol), blue(lineCol), 40);
        beginShape();
        vertex(drawX1, plotY2);
        for (int i = 0; i < categories.length; i++)
            vertex(drawX1 + i * xStep,
                   plotY2 - ((yValues[i] - yMin) / yRange) * plotH);
        vertex(drawX2, plotY2);
        endShape(CLOSE);

        // Line
        stroke(lineCol);
        strokeWeight(2.5);
        noFill();
        beginShape();
        for (int i = 0; i < categories.length; i++)
            vertex(drawX1 + i * xStep,
                   plotY2 - ((yValues[i] - yMin) / yRange) * plotH);
        endShape();

        // Data points + value labels
        for (int i = 0; i < categories.length; i++)
        {
            float px = drawX1 + i * xStep;
            float py = plotY2 - ((yValues[i] - yMin) / yRange) * plotH;

            // Glow ring
            noStroke();
            fill(red(lineCol), green(lineCol), blue(lineCol), 40);
            ellipse(px, py, 16, 16);

            // Outer ring
            stroke(lineCol);
            strokeWeight(1.5);
            fill(Visuals.PANEL_BG);
            ellipse(px, py, 9, 9);

            // Inner dot
            noStroke();
            fill(lineCol);
            ellipse(px, py, 5, 5);

            // Value label
            fill(Visuals.CHART_VALUE_LABEL);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE - 2);
            textAlign(CENTER, BOTTOM);
            text(nf(yValues[i], 1, 1), px, py - 8);
        }

        // Y-axis label rotated
        fill(Visuals.CHART_LABEL);
        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 1);
        textAlign(CENTER, CENTER);
        pushMatrix();
        translate(panelX + GRAPH_MARGIN - 5, plotY1 + plotH / 2.0);
        rotate(-HALF_PI);
        text("Avg. " + data.getString(0, valueColumn), 0, 0);
        popMatrix();

        textAlign(LEFT, BASELINE);
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printDropdownLists — call LAST in draw() so lists overlay charts
    // ═════════════════════════════════════════════════════════════════════════
    public void printDropdownLists()
    {
        pieCategoryDD.printList();
        barCategoryDD.printList();
        barValueDD.printList();
        lineCategoryDD.printList();
        lineValueDD.printList();
    }

    public void mouseClicked()
    {
        pieCategoryDD.mouseClicked();
        lineCategoryDD.mouseClicked();
        lineValueDD.mouseClicked();
        barCategoryDD.mouseClicked();
        barValueDD.mouseClicked();
    }


    // ═════════════════════════════════════════════════════════════════════════
    // Private helpers
    // ═════════════════════════════════════════════════════════════════════════

    private void _drawPanelBackground(float x, float y, float w, float h)
    {
        // Subtle border
        noStroke();
        fill(Visuals.PANEL_BORDER);
        rect(x, y, w, h, Visuals.PANEL_RADIUS);

        // Panel fill inset by 1px
        fill(Visuals.PANEL_BG);
        rect(x + 1, y + 1, w - 2, h - 2, Visuals.PANEL_RADIUS - 1);
    }

    private void _drawTitle(String title, float panelX, float panelY, float panelW)
    {
        fill(Visuals.PANEL_TITLE_COLOUR);
        textFont(titleFont);
        textSize(GRAPH_TITLE_SIZE);
        textAlign(CENTER, CENTER);
        text(title, panelX + panelW / 2.0,
             panelY + GRAPH_TITLE_H / 2.0 + GRAPH_MARGIN / 2.0);
    }

    private void _drawPieLegend(String[] categories,
                                java.util.LinkedHashMap<String, Integer> counts,
                                int total, float lx, float ly)
    {
        float swatchSize = 10;
        float rowGap     = 20;

        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 2);
        textAlign(LEFT, CENTER);

        for (int i = 0; i < categories.length; i++)
        {
            float ry  = ly + i * rowGap;
            int   cnt = counts.get(categories[i]);
            float pct = (float) cnt / total * 100;

            noStroke();
            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            rect(lx, ry - swatchSize / 2.0, swatchSize, swatchSize, 2);

            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            String cat = categories[i].length() > 14
                       ? categories[i].substring(0, 13) + "…"
                       : categories[i];
            text(cat + "  (" + cnt + ", " + nf(pct, 1, 0) + "%)",
                 lx + swatchSize + 5, ry);
        }
    }
}
