import java.util.HashMap;

final color[] GRAPH_PALETTE = { #4E79A7, #F28E2B, #E15759, #76B7B2, #59A14F, #EDC948, #B07AA1, #FF9DA7 };

final int GRAPH_REGION_GAP = 10;
final int GRAPH_MARGIN = 20;
final int GRAPH_LEGEND_W = 260;
final int GRAPH_TITLE_H = 36;
final int GRAPH_DROPDOWN_H = 38;
final int GRAPH_AXIS_LABEL_H = 65;
final int GRAPH_Y_AXIS_W = 50;
final int GRAPH_LABEL_SIZE = 12;
final int GRAPH_TITLE_SIZE = 16;
final int GRAPH_DROPDOWN_W = 210;
final int GRAPH_DROPDOWN_GAP = 10;
final int GRAPH_POINT_PAD = 40;
final int GRAPH_PANEL_Y = 30;

final int[] CATEGORICAL_COLS = { 0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16 };
final int[] NUMERICAL_COLS = { 6, 10, 11, 12, 13, 14, 17 };

class Graphs
{
    private Table data;
    private PFont graphFont;
    private PFont titleFont;
    private int numberOfRows;

    private Dropdown pieCategoryDD;
    private Dropdown lineCategoryDD;
    private Dropdown lineValueDD;
    private Dropdown barCategoryDD;
    private Dropdown barValueDD;

    Graphs(Table data, int numberOfRows)
    {
        this.data = data;
        this.numberOfRows = numberOfRows;
        this.graphFont = loadFont(Visuals.TABLEWIDGET_TABLE_FONT);
        this.titleFont = loadFont(Visuals.TABLEWIDGET_HEADER_FONT);
        _initDropdowns();
    }

    private void _initDropdowns()
    {
        String[] catLabels = new String[CATEGORICAL_COLS.length];
        int[] catIndices = new int[CATEGORICAL_COLS.length];
        
        for (int i = 0; i < CATEGORICAL_COLS.length; i++)
        {
            catIndices[i] = CATEGORICAL_COLS[i];
            catLabels[i] = data.getString(0, CATEGORICAL_COLS[i]);
        }

        String[] numLabels = new String[NUMERICAL_COLS.length];
        int[] numIndices = new int[NUMERICAL_COLS.length];
        
        for (int i = 0; i < NUMERICAL_COLS.length; i++)
        {
            numIndices[i] = NUMERICAL_COLS[i];
            numLabels[i] = data.getString(0, NUMERICAL_COLS[i]);
        }

        pieCategoryDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices);
        lineCategoryDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices);
        lineValueDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, numLabels, numIndices);
        barCategoryDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, catLabels, catIndices);
        barValueDD = new Dropdown(0, 0, GRAPH_DROPDOWN_W, numLabels, numIndices);
    }

    private float tableTopY()
    {
        return height - TABLE_Y_OFFSET - (numberOfRows * ROW_HEIGHT) - HEADER_HEIGHT;
    }

    private float chartRegionHeight()
    {
        return tableTopY() - GRAPH_REGION_GAP - GRAPH_PANEL_Y;
    }

    public void printPieChart()
    {
        int categoryColumn = pieCategoryDD.getSelectedIndex();
        String title = "Flights by " + pieCategoryDD.getSelectedLabel();

        HashMap<String, Integer> counts = new HashMap<String, Integer>();
        
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

        float localLegendW = panelW * 0.35; // ADD THIS to shrink the legend space
        float chartY = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H;
        float innerX = panelX + GRAPH_MARGIN;
        float innerW = panelW - GRAPH_LEGEND_W - 2 * GRAPH_MARGIN;
        float innerH = panelH - GRAPH_TITLE_H - GRAPH_DROPDOWN_H - 2 * GRAPH_MARGIN;
        float diameter = min(innerW, innerH) * 0.85;
        float cx = innerX + innerW / 2.0;
        float cy = chartY + GRAPH_MARGIN + innerH / 2.0;

        float startAngle = -HALF_PI;
        noStroke();

        for (int i = 0; i < categories.length; i++)
        {
            float fraction = (float) counts.get(categories[i]) / total;
            float sweepAngle = fraction * TWO_PI;

            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            arc(cx, cy, diameter, diameter, startAngle, startAngle + sweepAngle, PIE);

            if (fraction > 0.05)
            {
                float midAngle = startAngle + sweepAngle / 2.0;
                float lx = cx + cos(midAngle) * diameter * 0.32;
                float ly = cy + sin(midAngle) * diameter * 0.32;
                fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
                textFont(graphFont);
                textSize(GRAPH_LABEL_SIZE);
                textAlign(CENTER, CENTER);
                text(nf(fraction * 100, 1, 1) + "%", lx, ly);
            }

            startAngle += sweepAngle;
        }

        stroke(255, 255, 255, 60);
        strokeWeight(1);
        noFill();
        ellipse(cx, cy, diameter, diameter);
        strokeWeight(1);

        _drawPieLegend(categories, counts, total, panelX + panelW - localLegendW - GRAPH_MARGIN, (panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H) + GRAPH_MARGIN);

        textAlign(LEFT, BASELINE);
    }

    public void printBarChart() 
    {
        int categoryColumn = barCategoryDD.getSelectedIndex();
        int valueColumn = barValueDD.getSelectedIndex();
        String title = "Avg " + barValueDD.getSelectedLabel() + " by " + barCategoryDD.getSelectedLabel();
    
        java.util.LinkedHashMap<String, Float>   sums = new java.util.LinkedHashMap<String, Float>();
        java.util.LinkedHashMap<String, Integer> cnt  = new java.util.LinkedHashMap<String, Integer>();
    
        for (int row = 1; row < data.getRowCount(); row++)
        {
            String catVal = data.getString(row, categoryColumn);
            if (catVal == null || catVal.trim().equals("")) continue;
    
            float numVal;
            try
            {
              numVal = Float.parseFloat(data.getString(row, valueColumn));
            }
            catch (NumberFormatException e)
            {
              continue;
            }
    
            sums.put(catVal, sums.containsKey(catVal) ? sums.get(catVal) + numVal : numVal);
            cnt.put(catVal, cnt.containsKey(catVal) ? cnt.get(catVal) + 1 : 1);
        }
    
        float panelW = width / 3.0;
        float panelX = panelW;
        float panelY = GRAPH_PANEL_Y;
        float panelH = chartRegionHeight();
    
        _drawPanelBackground(panelX, panelY, panelW, panelH);
        _drawTitle(title, panelX, panelY, panelW);
    
        float ddY = panelY + GRAPH_TITLE_H + (GRAPH_DROPDOWN_H - DROPDOWN_H) / 2.0;
        float dd1X = panelX + GRAPH_MARGIN;
        float dd2X = dd1X + GRAPH_DROPDOWN_W + GRAPH_DROPDOWN_GAP;
    
        barCategoryDD.setPosition(dd1X, ddY);
        barValueDD.setPosition(dd2X, ddY);
        barCategoryDD.printDropdown();
        barValueDD.printDropdown();
    
        if (sums.size() < 1) return;
    
        String[] categories = sums.keySet().toArray(new String[0]);
        float[] yValues = new float[categories.length];
        float yMax = 0;
        for (int i = 0; i < categories.length; i++)
        {
            yValues[i] = sums.get(categories[i]) / cnt.get(categories[i]);
            yMax = max(yMax, yValues[i]);
        }
        
        yMax *= 1.12; 
        float yRange = (yMax == 0) ? 1 : yMax;
    
        float plotX1 = panelX + GRAPH_MARGIN + GRAPH_Y_AXIS_W;
        float plotX2 = panelX + panelW - GRAPH_MARGIN;
        float plotY1 = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H + GRAPH_MARGIN + 6;
        float plotY2 = panelY + panelH + 5 - GRAPH_MARGIN - GRAPH_AXIS_LABEL_H;
        float plotW = plotX2 - plotX1;
        float plotH = plotY2 - plotY1;
    
        float barTotalW = plotW / categories.length;
        float barW = barTotalW * 0.7; 
    
        stroke(255, 255, 255, 35);
        strokeWeight(1);
        
        for (int t = 0; t <= 5; t++)
        {
            float frac = (float) t / 5;
            float py = plotY2 - frac * plotH;
            line(plotX1, py, plotX2, py);
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            textAlign(RIGHT, CENTER);
            text(nf(frac * yMax, 1, 1), plotX1 - 6, py);
        }
        stroke(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        strokeWeight(2);
        line(plotX1, plotY1, plotX1, plotY2);
        line(plotX1, plotY2, plotX2, plotY2);
    
        for (int i = 0; i < categories.length; i++)
        {
            float h = (yValues[i] / yRange) * plotH;
            float bx = plotX1 + (i * barTotalW) + (barTotalW - barW)/2.0;
            float by = plotY2 - h;
    
            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            noStroke();
            rect(bx, by, barW, h, 3, 3, 0, 0); 
    
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            pushMatrix();
            translate(bx + barW/2, plotY2 + 10);
            rotate(-PI / 3.0);
            textAlign(RIGHT, CENTER);
            text(categories[i], 0, 0);
            popMatrix();
            
            textAlign(CENTER, BOTTOM);
            text(nf(yValues[i], 1, 1), bx + barW/2, by - 4);
        }
    }


    public void printLineChart()
    {
        int categoryColumn = lineCategoryDD.getSelectedIndex();
        int valueColumn = lineValueDD.getSelectedIndex();
        String title = "Avg " + lineValueDD.getSelectedLabel() + " by " + lineCategoryDD.getSelectedLabel();

        java.util.LinkedHashMap<String, Float> sums = new java.util.LinkedHashMap<String, Float>();
        java.util.LinkedHashMap<String, Integer> cnt = new java.util.LinkedHashMap<String, Integer>();

        for (int row = 1; row < data.getRowCount(); row++)
        {
            String catVal = data.getString(row, categoryColumn);
            if (catVal == null || catVal.trim().equals("")) continue;

            float numVal;
            try
            {
              numVal = Float.parseFloat(data.getString(row, valueColumn));
            }
            catch (NumberFormatException e)
            {
              continue;
            }

            sums.put(catVal, sums.containsKey(catVal) ? sums.get(catVal) + numVal : numVal);
            cnt.put(catVal, cnt.containsKey(catVal) ? cnt.get(catVal) + 1 : 1);
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
            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            textFont(graphFont);
            textSize(GRAPH_LABEL_SIZE);
            textAlign(CENTER, CENTER);
            text("Not enough data for selected columns.", panelX + panelW / 2.0, panelY + panelH / 2.0);
            textAlign(LEFT, BASELINE);
            return;
        }

        String[] categories = sums.keySet().toArray(new String[0]);
        float[]  yValues = new float[categories.length];
        
        for (int i = 0; i < categories.length; i++)
            yValues[i] = sums.get(categories[i]) / cnt.get(categories[i]);

        float yMin = yValues[0], yMax = yValues[0];
        
        for (float v : yValues)
        {
          yMin = min(yMin, v);
          yMax = max(yMax, v);
        }
        
        yMax += (yMax - yMin) * 0.12;
        if (yMin > 0) yMin = 0;
        
        float yRange = (yMax == yMin) ? 1 : yMax - yMin;

        float plotX1 = panelX + GRAPH_MARGIN + GRAPH_Y_AXIS_W;
        float plotX2 = panelX + panelW - GRAPH_MARGIN;
        float plotY1 = panelY + GRAPH_TITLE_H + GRAPH_DROPDOWN_H + GRAPH_MARGIN;
        float plotY2 = panelY + panelH - GRAPH_MARGIN - GRAPH_AXIS_LABEL_H;
        float plotH  = plotY2 - plotY1;

        float drawX1 = plotX1 + GRAPH_POINT_PAD;
        float drawX2 = plotX2 - GRAPH_POINT_PAD;
        float drawW = drawX2 - drawX1;
        float xStep = (categories.length > 1) ? drawW / (categories.length - 1) : drawW;

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

        stroke(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
        strokeWeight(2);
        line(plotX1, plotY1, plotX1, plotY2);
        line(plotX1, plotY2, plotX2, plotY2);

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

        noStroke();
        fill(GRAPH_PALETTE[0], 55);
        beginShape();
        vertex(drawX1, plotY2);
        
        for (int i = 0; i < categories.length; i++)
            vertex(drawX1 + i * xStep, plotY2 - ((yValues[i] - yMin) / yRange) * plotH);

        vertex(drawX2, plotY2);
        endShape(CLOSE);

        stroke(GRAPH_PALETTE[0]);
        strokeWeight(2.5);
        noFill();
        beginShape();
        for (int i = 0; i < categories.length; i++)
            vertex(drawX1 + i * xStep,
                   plotY2 - ((yValues[i] - yMin) / yRange) * plotH);
        endShape();

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

    public void printDropdownLists()
    {
        pieCategoryDD.printList();
        lineCategoryDD.printList();
        lineValueDD.printList();
        barCategoryDD.printList(); // Added [cite: 117]
        barValueDD.printList();    // Added
    }

    public void mouseClicked()
    {
        pieCategoryDD.mouseClicked();
        lineCategoryDD.mouseClicked();
        lineValueDD.mouseClicked();
        barCategoryDD.mouseClicked(); // Added [cite: 118]
        barValueDD.mouseClicked();    // Added
    }

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

    private void _drawPieLegend(String[] categories, HashMap<String, Integer> counts, int total, float lx, float ly)
    {
        float swatchSize = 12;
        float rowGap = 22;

        textFont(graphFont);
        textSize(GRAPH_LABEL_SIZE - 1);
        textAlign(LEFT, CENTER);

        for (int i = 0; i < categories.length; i++)
        {
            float ry = ly + i * rowGap;

            noStroke();
            fill(GRAPH_PALETTE[i % GRAPH_PALETTE.length]);
            rect(lx, ry - swatchSize / 2.0, swatchSize, swatchSize, 2);

            fill(Visuals.GLOBAL_TEXT_COLOUR_LIGHT);
            float  pct   = (float) counts.get(categories[i]) / total * 100;
            String label = categories[i] + "  (" + counts.get(categories[i]) + ", " + nf(pct, 1, 1) + "%)";
            text(label, lx + swatchSize + 6, ry);
        }
    }
}
