final int DROPDOWN_H          = 28;
final int DROPDOWN_ITEM_H     = 26;
final int DROPDOWN_PADDING_X  = 10;
final int DROPDOWN_CHEVRON_W  = 20;
final int DROPDOWN_MAX_ITEMS  = 8;

class Dropdown
{
    public float ddX;
    public float ddY;
    public float ddW;
    private boolean isOpen = false;
    private int selectedItem = 0;
    private String[] labels;
    private int[] columnIndices;
    private PFont ddFont;
    private final color COL_BAR_BG = #2A3F5F;
    private final color COL_BAR_BG_HOVER = #344E75;
    private final color COL_LIST_BG = #1E2F47;
    private final color COL_LIST_HOVER = #2A3F5F;
    private final color COL_LIST_SEL = #4E79A7;
    private final color COL_TEXT = #FFFFFF;
    private final color COL_BORDER = #4A6080;

    Dropdown(float x, float y, float w, String[] labels, int[] columnIndices)
    {
        this.ddX           = x;
        this.ddY           = y;
        this.ddW           = w;
        this.labels        = labels;
        this.columnIndices = columnIndices;
        this.ddFont        = loadFont(Visuals.BUTTON_BUTTON_FONT);
    }

    public int getSelectedIndex()
    {
        return columnIndices[selectedItem];
    }

    public String getSelectedLabel()
    {
        return labels[selectedItem];
    }

    public boolean isOpen()
    {
        return isOpen;
    }

    public void setPosition(float x, float y)
    {
        this.ddX = x;
        this.ddY = y;
    }

    public void printDropdown()
    {
        boolean hoveringBar = _hoveringBar();

        noStroke();
        fill(hoveringBar ? COL_BAR_BG_HOVER : COL_BAR_BG);
        rect(ddX, ddY, ddW, DROPDOWN_H, 4);

        stroke(COL_BORDER);
        strokeWeight(1);
        noFill();
        rect(ddX, ddY, ddW, DROPDOWN_H, 4);

        noStroke();
        fill(COL_TEXT);
        textFont(ddFont);
        textSize(11);
        textAlign(LEFT, CENTER);

        String label = _truncate(labels[selectedItem], ddW - DROPDOWN_CHEVRON_W - 2 * DROPDOWN_PADDING_X);
        text(label, ddX + DROPDOWN_PADDING_X, ddY + DROPDOWN_H / 2.0);

        fill(COL_TEXT);
        textAlign(CENTER, CENTER);
        text(isOpen ? "▲" : "▼", ddX + ddW - DROPDOWN_CHEVRON_W / 2.0, ddY + DROPDOWN_H / 2.0);

        textAlign(LEFT, BASELINE);
    }

    public void printList()
    {
        if (!isOpen) return;

        int visibleCount = min(labels.length, DROPDOWN_MAX_ITEMS);
        float listH = visibleCount * DROPDOWN_ITEM_H;
        float listY = ddY + DROPDOWN_H;

        stroke(COL_BORDER);
        strokeWeight(1);
        fill(COL_LIST_BG);
        rect(ddX, listY, ddW, listH, 0, 0, 4, 4);

        textFont(ddFont);
        textSize(11);
        textAlign(LEFT, CENTER);

        for (int i = 0; i < visibleCount; i++)
        {
            float rowY    = listY + i * DROPDOWN_ITEM_H;
            boolean hover = _hoveringListItem(i);
            boolean sel   = (i == selectedItem);

            noStroke();
            if      (sel)   fill(COL_LIST_SEL);
            else if (hover) fill(COL_LIST_HOVER);
            else            fill(COL_LIST_BG);
            rect(ddX, rowY, ddW, DROPDOWN_ITEM_H);

            // Row text
            fill(COL_TEXT);
            String label = _truncate(labels[i], ddW - 2 * DROPDOWN_PADDING_X);
            text(label, ddX + DROPDOWN_PADDING_X, rowY + DROPDOWN_ITEM_H / 2.0);

            if (i < visibleCount - 1)
            {
                stroke(COL_BORDER);
                strokeWeight(0.5);
                line(ddX, rowY + DROPDOWN_ITEM_H, ddX + ddW, rowY + DROPDOWN_ITEM_H);
            }
        }

        textAlign(LEFT, BASELINE);
    }

    public void mouseClicked()
    {
        if (_hoveringBar())
        {
            isOpen = !isOpen;
            return;
        }

        if (isOpen)
        {
            int visibleCount = min(labels.length, DROPDOWN_MAX_ITEMS);

            for (int i = 0; i < visibleCount; i++)
            {
                if (_hoveringListItem(i))
                {
                    selectedItem = i;
                    isOpen       = false;
                    return;
                }
            }

            isOpen = false;
        }
    }

    private boolean _hoveringBar()
    {
        return mouseX > ddX && mouseX < ddX + ddW &&
               mouseY > ddY && mouseY < ddY + DROPDOWN_H;
    }

    private boolean _hoveringListItem(int i)
    {
        float listY = ddY + DROPDOWN_H;
        float rowY  = listY + i * DROPDOWN_ITEM_H;
        return mouseX > ddX && mouseX < ddX + ddW &&
               mouseY > rowY && mouseY < rowY + DROPDOWN_ITEM_H;
    }

    private String _truncate(String s, float maxWidth)
    {
        int maxChars = (int)(maxWidth / 6);
        if (s.length() <= maxChars) return s;
        return s.substring(0, max(0, maxChars - 1)) + "…";
    }
}
