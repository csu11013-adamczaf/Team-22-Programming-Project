// Dropdown class to represent interactive dropdown menus in the UI

class Dropdown
{
    public float ddX;
    public float ddY;
    public float ddW;
    private boolean isOpen = false;
    private int selectedItem = 0;
    private String[] labels;
    private int[] columnIndices;  // Maps each label to its column index in the data table
    private final color COL_BAR_BG       = #2A3F5F;
    private final color COL_BAR_BG_HOVER = #344E75;
    private final color COL_LIST_BG      = #1E2F47;
    private final color COL_LIST_HOVER   = #2A3F5F;
    private final color COL_LIST_SEL     = #4E79A7;
    private final color COL_TEXT         = #FFFFFF;
    private final color COL_BORDER       = #4A6080;
    private int textSize = 11;

    Dropdown(float x, float y, float w, String[] labels, int[] columnIndices)
    {
        this.ddX           = x;
        this.ddY           = y;
        this.ddW           = w;
        this.labels        = labels;
        this.columnIndices = columnIndices; // Passed-in font ignored; always loads from Visuals
    }
    
    // Returns the column index corresponding to the currently selected item, for querying the data table
    public int getSelectedIndex()
    {
        return columnIndices[selectedItem];
    }

    // Returns the label of the currently selected item, for display purposes
    public String getSelectedLabel()
    {
        return labels[selectedItem];
    }
    
    // Returns whether the dropdown is currently open, for managing interactions in the main mouseClicked handler
    public boolean isOpen()
    {
        return isOpen;
    }

    // Changes the position of the dropdown
    public void setPosition(float x, float y)
    {
        this.ddX = x;
        this.ddY = y;
    }

    // Prints the dropdown bar with the currently selected item and the chevron icon to the screen
    public void printDropdown()
    {
        boolean hoveringBar = _hoveringBar();

        // Draw filled background first, then overlay the border as a separate no-fill rect
        // to avoid the fill bleeding over the stroke
        noStroke();
        fill(hoveringBar ? COL_BAR_BG_HOVER : COL_BAR_BG);
        rect(ddX, ddY, ddW, dropDowncellHeight, 4);

        stroke(COL_BORDER);
        strokeWeight(1);
        noFill();
        rect(ddX, ddY, ddW, dropDowncellHeight, 4);

        noStroke();
        fill(COL_TEXT);
        textFont(dropDown_DropDownFont);
        textSize(this.textSize);
        textAlign(LEFT, CENTER);

        // Truncate label so it never overlaps the chevron
        String label = _truncate(labels[selectedItem], ddW - DROPDOWN_CHEVRON_W - 2 * DROPDOWN_PADDING_X);
        text(label, ddX + DROPDOWN_PADDING_X, ddY + dropDowncellHeight / 2.0);

        // Chevron flips between ▼ (closed) and ▲ (open)
        fill(COL_TEXT);
        textAlign(CENTER, CENTER);
        text(isOpen ? "▲" : "▼", ddX + ddW - DROPDOWN_CHEVRON_W / 2.0, ddY + dropDowncellHeight / 2.0);

        textAlign(LEFT, BASELINE);
    }

    // Prints the dropdown list to the screen if the dropdown is currently open, with hover and selection highlights
    public void printList()
    {
        if (!isOpen) return;

        int visibleCount = min(labels.length, DROPDOWN_MAX_ITEMS);
        float listH = visibleCount * DROPDOWN_ITEM_H;
        float listY = ddY + dropDowncellHeight;

        // Rounded corners only on the bottom two corners so the list reads as an extension of the bar
        stroke(COL_BORDER);
        strokeWeight(1);
        fill(COL_LIST_BG);
        rect(ddX, listY, ddW, listH, 0, 0, 4, 4);

        textFont(dropDown_DropDownFont);
        textSize(this.textSize);
        textAlign(LEFT, CENTER);

        for (int i = 0; i < visibleCount; i++)
        {
            float rowY = listY + i * DROPDOWN_ITEM_H;
            boolean hover = _hoveringListItem(i);
            boolean sel   = (i == selectedItem);

            // Priority: selected overrides hover, hover overrides default
            noStroke();
            if      (sel)   fill(COL_LIST_SEL);
            else if (hover) fill(COL_LIST_HOVER);
            else            fill(COL_LIST_BG);
            rect(ddX, rowY, ddW, DROPDOWN_ITEM_H);

            fill(COL_TEXT);
            String label = _truncate(labels[i], ddW - 2 * DROPDOWN_PADDING_X);
            text(label, ddX + DROPDOWN_PADDING_X, rowY + DROPDOWN_ITEM_H / 2.0);

            // Divider skipped after the last visible row to avoid a double-border with the list outline
            if (i < visibleCount - 1)
            {
                stroke(COL_BORDER);
                strokeWeight(0.5);
                line(ddX, rowY + DROPDOWN_ITEM_H, ddX + ddW, rowY + DROPDOWN_ITEM_H);
            }
        }

        textAlign(LEFT, BASELINE);
    }

    // Handles mouse clicks to toggle the dropdown open/closed and update the selected item based on where the click landed
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

            // Click landed in the list area but missed every row — close anyway
            isOpen = false;
        }
    }

    // Setters for mutable properties
    public void setTextSize(int size)
    {
        this.textSize = size;
    }

    public void setCellHeight(int size)
    {
        dropDowncellHeight = size;
    }

    // Helper methods to determine whether the mouse is currently hovering over the dropdown bar or a given list item
    private boolean _hoveringBar()
    {
        return mouseX > ddX && mouseX < ddX + ddW && mouseY > ddY && mouseY < ddY + DROPDOWN_H;
    }

    private boolean _hoveringListItem(int i)
    {
        float listY = ddY + DROPDOWN_H;
        float rowY  = listY + i * DROPDOWN_ITEM_H;
        return mouseX > ddX && mouseX < ddX + ddW && mouseY > rowY && mouseY < rowY + DROPDOWN_ITEM_H;
    }

    private String _truncate(String s, float maxWidth)
    {
        // 6px per character is a rough estimate for the small font size used
        int maxChars = (int)(maxWidth / 6);
        if (s.length() <= maxChars) return s;
        return s.substring(0, max(0, maxChars - 1)) + "…";
    }
}