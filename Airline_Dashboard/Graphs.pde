import java.util.HashMap;

final color[] GRAPH_PALETTE = {
  #4E79A7, #F28E2B, #E15759, #76B7B2,
  #59A14F, #EDC948, #B07AA1, #FF9DA7
};

// ── Layout constants ──────────────────────────────────────────────────────────
final int   GRAPH_REGION_GAP   = 10;
final int   GRAPH_MARGIN       = 30;
final int   GRAPH_LEGEND_W     = 260;  // wide enough for date labels + count/pct
final int   GRAPH_TITLE_H      = 36;
final int   GRAPH_DROPDOWN_H   = 38;
final int   GRAPH_AXIS_LABEL_H = 65;  // tall enough for 60° rotated date labels
final int   GRAPH_Y_AXIS_W     = 55;
final int   GRAPH_LABEL_SIZE   = 12;
final int   GRAPH_TITLE_SIZE   = 16;
final int   GRAPH_DROPDOWN_W   = 210;
final int   GRAPH_DROPDOWN_GAP = 10;
final int   GRAPH_POINT_PAD    = 40;

// FIX 1: panels start at this y so the title and dropdown sit INSIDE the
// navy rectangle, not above it on the white canvas.
final int   GRAPH_PANEL_Y      = 30;

final int[] CATEGORICAL_COLS = { 0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16 };
final int[] NUMERICAL_COLS   = { 6, 10, 11, 12, 13, 14, 17 };

// ─────────────────────────────────────────────────────────────────────────────

class Graphs
{
    private Table    data;
    private PFont    graphFont;
    private PFont    titleFont;
    private int      numberOfRows;
    private Query    query;

    private Dropdown pieCategoryDD;
    private Dropdown lineCategoryDD;
    private Dropdown lineValueDD;

    Graphs(Table data, int numberOfRows)
    {
        this.data         = data;
        this.numberOfRows = numberOfRows;
        this.graphFont    = loadFont(Visuals.TABLEWIDGET_TABLE_FONT);
        this.titleFont    = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
        this.query        = new Query();
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

        pieCategoryDD  = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices);
        lineCategoryDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices);
        lineValueDD    = new Dropdown(0, 0, GRAPH_DROPDOWN_W, numLabels, numIndices);
    }

    // y-coordinate of the table's top edge
    private float tableTopY()
    {
        return height - TABLE_Y_OFFSET - (numberOfRows * ROW_HEIGHT) - HEADER_HEIGHT;
    }

    // pixel height available for both chart panels
    private float chartRegionHeight()
    {
        return tableTopY() - GRAPH_REGION_GAP - GRAPH_PANEL_Y;
    }


    // ═════════════════════════════════════════════════════════════════════════
    // createTableOfRelativeCount
    //
    // Produces a 2-row Table from a String[] column:
    //   Row 0 — unique values
    //   Row 1 — occurrence counts
    // ═════════════════════════════════════════════════════════════════════════
    public Table createTableOfRelativeCount(String[] inputData)
    {
        Table             outputTable  = new Table();
        ArrayList<String> usedValues  = new ArrayList<String>();
        outputTable.addRow();
        outputTable.addRow();
        int currentColumn = 0;

        for (int index = 1; index < inputData.length; index++)
        {
            String val = inputData[index];
            if (val == null || val.trim().equals("")) continue;

            if (!query.exists(val, usedValues))
            {
                outputTable.addColumn(val);
                int occurrences = query.countOccurences(val, inputData);
                outputTable.setString(0, currentColumn, val);
                outputTable.setInt(1, currentColumn, occurrences);
                currentColumn++;
                usedValues.add(val);
            }
        }
        return outputTable;
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printPieChart  — left half of chart region
    // ═════════════════════════════════════════════════════════════════════════
    public void printPieChart()
    {
        int    categoryColumn = pieCategoryDD.getSelectedIndex();
        String title          = "Flights by " + pieCategoryDD.getSelectedLabel();

        Table countTable    = createTableOfRelativeCount(data.getStringColumn(categoryColumn));
        int   numCategories = countTable.getColumnCount();
        if (numCategories == 0) return;

        int total = 0;
        for (int i = 0; i < numCategories; i++) total += countTable.getInt(1, i);
        if (total == 0) return;

        // ── Panel ─────────────────────────────────────────────────────────
        // FIX 1: panelY = GRAPH_PANEL_Y (not 0) so everything is inside navy rect
        float panelX = 0;
        float panelY = GRAPH_PANEL_Y;
        float panelW = width / 2.0;
        float panelH = chartRegionHeight();

        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);

        // ── Dropdown ──────────────────────────────────────────────────────
        float ddX = panelX + GRAPH_MARGIN;
        float ddY = panelY + GRAPH_TITLE_H + (GRAPH_DROPDOWN_H - DROPDOWN_H) / 2.0;
        pieCategoryDD.setPosition(ddX, ddY);
        pieCategoryDD.printDropdown();

        // ── Pie geometry ──────────────────────────────────────────────────
        float chartY   = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H;
        // FIX 2: reserve full GRAPH_LEGEND_W so the pie doesn't overlap legend
        float innerW   = panelW - GRAPH_LEGEND_W - 2 * GRAPH_MARGIN;
        float innerH   = panelH - GRAPH_TITLE_H - GRAPH_DROPDOWN_H - 2 * GRAPH_MARGIN;
        float diameter = min(innerW, innerH) * 0.85;
        float cx       = panelX + GRAPH_MARGIN + innerW / 2.0;
        float cy       = chartY + GRAPH_MARGIN + innerH / 2.0;

        float startAngle = -HALF_PI;
        noStroke();

        for (int i = 0; i < numCategories; i++)
        {
            float fraction   = (float) countTable.getInt(1, i) / total;
            float sweepAngle = fraction * TWO_PI;

            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            arc(cx, cy, diameter, diameter, startAngle, startAngle + sweepAngle, PIE);

            if (fraction > 0.05)
            {
                float midAngle = startAngle + sweepAngle / 2.0;
                fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
                textFont(graphFont);
                textSize(GRAPH_LABEL_SIZE);
                textAlign(CENTER, CENTER);
                text(nf(fraction * 100, 1, 1) + "%",
                     cx + cos(midAngle) * diameter * 0.32,
                     cy + sin(midAngle) * diameter * 0.32);
            }
            startAngle += sweepAngle;
        }

        stroke(255, 255, 255, 60);
        strokeWeight(1);
        noFill();
        ellipse(cx, cy, diameter, diameter);
        strokeWeight(1);

        // FIX 2: legend x uses full GRAPH_LEGEND_W inset from right edge
        _drawPieLegend(countTable, total,
                       panelX + panelW - GRAPH_LEGEND_W - GRAPH_MARGIN,
                       chartY + GRAPH_MARGIN);

        textAlign(LEFT, BASELINE);
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printBarChart  — can be placed anywhere; pass panel bounds explicitly
    // ═════════════════════════════════════════════════════════════════════════
    public void printBarChart(float panelX, float panelY, float panelW, float panelH,
                              String title, Table countTable)
    {
        int   numBars  = countTable.getColumnCount();
        if (numBars == 0) return;

        float maxValue = 0;
        for (int i = 0; i < numBars; i++)
        {
            float v = countTable.getFloat(1, i);
            if (v > maxValue) maxValue = v;
        }
        if (maxValue == 0) return;

        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);

        float barAreaX = panelX + GRAPH_MARGIN + GRAPH_Y_AXIS_W;
        float barAreaY = panelY + GRAPH_TITLE_H + GRAPH_MARGIN;
        float barAreaW = panelW - GRAPH_MARGIN - GRAPH_Y_AXIS_W - GRAPH_MARGIN;
        float barAreaH = panelH - GRAPH_TITLE_H - 2 * GRAPH_MARGIN;
        float totalBarH = barAreaH / numBars;
        float barH      = totalBarH * 0.6;
        float barGap    = totalBarH * 0.4;

        for (int i = 0; i < numBars; i++)
        {
            float value  = countTable.getFloat(1, i);
            float barW   = (value / maxValue) * barAreaW;
            float barY   = barAreaY + i * totalBarH + barGap / 2.0;

            noStroke();
            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            rect(barAreaX, barY, barW, barH, 3);

            String cat = countTable.getString(0, i);
            cat = cat.length() > 14 ? cat.substring(0, 13) + "…" : cat;
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE - 1);
            textAlign(RIGHT, CENTER);
            text(cat, barAreaX - 6, barY + barH / 2.0);

            textAlign(LEFT, CENTER);
            text((int) value, barAreaX + barW + 6, barY + barH / 2.0);
        }

        textAlign(LEFT, BASELINE);
    }


    // ═════════════════════════════════════════════════════════════════════════
    // printLineChart  — right half of chart region
    // ═════════════════════════════════════════════════════════════════════════
    public void printLineChart()
    {
        int    categoryColumn = lineCategoryDD.getSelectedIndex();
        int    valueColumn    = lineValueDD.getSelectedIndex();
        String title          = "Avg " + lineValueDD.getSelectedLabel()
                              + " by " + lineCategoryDD.getSelectedLabel();

        // Aggregate sums and counts per category
        java.util.LinkedHashMap<String, Float>   sums = new java.util.LinkedHashMap<String, Float>();
        java.util.LinkedHashMap<String, Integer> cnt  = new java.util.LinkedHashMap<String, Integer>();

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

        // ── Panel ─────────────────────────────────────────────────────────
        // FIX 1: panelY = GRAPH_PANEL_Y
        float panelX = width / 2.0;
        float panelY = GRAPH_PANEL_Y;
        float panelW = width / 2.0;
        float panelH = chartRegionHeight();

        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);

        // ── Dropdowns ─────────────────────────────────────────────────────
        float ddY  = panelY + GRAPH_TITLE_H + (GRAPH_DROPDOWN_H - DROPDOWN_H) / 2.0;
        float dd1X = panelX + GRAPH_MARGIN;
        float dd2X = dd1X + GRAPH_DROPDOWN_W + GRAPH_DROPDOWN_GAP;

        lineCategoryDD.setPosition(dd1X, ddY);
        lineValueDD.setPosition(dd2X, ddY);
        lineCategoryDD.printDropdown();
        lineValueDD.printDropdown();

        if (sums.size() < 2)
        {
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
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

        // ── Y bounds ──────────────────────────────────────────────────────
        float yMin = yValues[0], yMax = yValues[0];
        for (float v : yValues) { yMin = min(yMin, v); yMax = max(yMax, v); }
        yMax += (yMax - yMin) * 0.12;
        if (yMin > 0) yMin = 0;
        float yRange = (yMax == yMin) ? 1 : yMax - yMin;

        // ── Plot bounds ───────────────────────────────────────────────────
        float plotX1 = panelX + GRAPH_MARGIN + GRAPH_Y_AXIS_W;
        float plotX2 = panelX + panelW - GRAPH_MARGIN;
        float plotY1 = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H + GRAPH_MARGIN;
        float plotY2 = panelY + panelH - GRAPH_MARGIN - GRAPH_AXIS_LABEL_H;
        float plotH  = plotY2 - plotY1;

        // FIX 4: data points use padded inner bounds so they don't touch axes
        float drawX1 = plotX1 + GRAPH_POINT_PAD;
        float drawX2 = plotX2 - GRAPH_POINT_PAD;
        float drawW  = drawX2 - drawX1;
        float xStep  = (categories.length > 1) ? drawW / (categories.length - 1) : drawW;

        // ── Gridlines + y-axis labels ─────────────────────────────────────
        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 1);
        textAlign(RIGHT, CENTER);

        for (int t = 0; t <= 5; t++)
        {
            float frac = (float) t / 5;
            float py   = plotY2 - frac * plotH;

            stroke(255, 255, 255, 35);
            strokeWeight(1);
            line(plotX1, py, plotX2, py);

            noStroke();
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            text(nf(yMin + frac * yRange, 1, 1), plotX1 - 6, py);
        }

        // ── Axes ──────────────────────────────────────────────────────────
        stroke(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        strokeWeight(2);
        line(plotX1, plotY1, plotX1, plotY2);
        line(plotX1, plotY2, plotX2, plotY2);

        // ── X-axis labels — rotated 60° so dates don't overlap ────────────
        // FIX 3: steeper rotation (-PI/3 ≈ 60°) gives each label more
        // horizontal clearance; GRAPH_AXIS_LABEL_H=65 gives vertical room.
        for (int i = 0; i < categories.length; i++)
        {
            float px = drawX1 + i * xStep;

            stroke(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            strokeWeight(1);
            line(px, plotY2, px, plotY2 + 5);

            noStroke();
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE - 1);
            textAlign(RIGHT, CENTER);
            pushMatrix();
            translate(px, plotY2 + 10);
            rotate(-PI / 3.0);
            text(categories[i], 0, 0);
            popMatrix();
        }

        // ── Filled area ───────────────────────────────────────────────────
        noStroke();
        fill(GRAPH_PALETTE[0], 55);
        beginShape();
        vertex(drawX1, plotY2);
        for (int i = 0; i < categories.length; i++)
            vertex(drawX1 + i * xStep,
                   plotY2 - ((yValues[i] - yMin) / yRange) * plotH);
        vertex(drawX2, plotY2);
        endShape(CLOSE);

        // ── Line ──────────────────────────────────────────────────────────
        stroke(GRAPH_PALETTE[0]);
        strokeWeight(2.5);
        noFill();
        beginShape();
        for (int i = 0; i < categories.length; i++)
            vertex(drawX1 + i * xStep,
                   plotY2 - ((yValues[i] - yMin) / yRange) * plotH);
        endShape();

        // ── Data points + value labels ────────────────────────────────────
        for (int i = 0; i < categories.length; i++)
        {
            float px = drawX1 + i * xStep;
            float py = plotY2 - ((yValues[i] - yMin) / yRange) * plotH;

            stroke(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            strokeWeight(1.5);
            fill(#1C2C48);
            ellipse(px, py, 9, 9);

            noStroke();
            fill(GRAPH_PALETTE[0]);
            ellipse(px, py, 5, 5);

            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE - 1);
            textAlign(CENTER, BOTTOM);
            text(nf(yValues[i], 1, 1), px, py - 6);
        }

        // ── Rotated y-axis label ──────────────────────────────────────────
        fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE);
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
        lineCategoryDD.printList();
        lineValueDD.printList();
    }

    public void mouseClicked()
    {
        pieCategoryDD.mouseClicked();
        lineCategoryDD.mouseClicked();
        lineValueDD.mouseClicked();
    }


    // ═════════════════════════════════════════════════════════════════════════
    // Private helpers
    // ═════════════════════════════════════════════════════════════════════════

    private void _drawPanelBackground(float x, float y, float w, float h)
    {
        noStroke();
        fill(#1C2C48);
        rect(x, y, w, h);
    }

    private void _drawTitle(String title, float panelX, float panelY, float panelW)
    {
        fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        textFont(titleFont);
        textSize(GRAPH_TITLE_SIZE);
        textAlign(CENTER, CENTER);
        text(title, panelX + panelW / 2.0, panelY + GRAPH_TITLE_H / 2.0 + GRAPH_MARGIN / 2.0);
    }

    private void _drawPieLegend(Table countTable, int total, float lx, float ly)
    {
        float swatchSize = 12;
        float rowGap     = 22;

        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 1);
        textAlign(LEFT, CENTER);

        for (int i = 0; i < countTable.getColumnCount(); i++)
        {
            float  ry  = ly + i * rowGap;
            int    cnt = countTable.getInt(1, i);
            float  pct = (float) cnt / total * 100;

            noStroke();
            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            rect(lx, ry - swatchSize / 2.0, swatchSize, swatchSize, 2);

            // FIX 2: truncate at 18 chars so count+pct annotation fits in GRAPH_LEGEND_W
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            String cat   = countTable.getString(0, i);
            cat = cat.length() > 18 ? cat.substring(0, 17) + "…" : cat;
            text(cat + "  (" + cnt + ", " + nf(pct, 1, 1) + "%)",
                 lx + swatchSize + 6, ry);
        }
    }
}
