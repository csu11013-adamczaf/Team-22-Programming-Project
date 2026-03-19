// ── Dropdown layout constants ─────────────────────────────────────────────────
final int DROPDOWN_H          = 28;    // height of the collapsed header bar
final int DROPDOWN_ITEM_H     = 26;    // height of each option row in the list
final int DROPDOWN_PADDING_X  = 10;    // horizontal text padding inside the bar
final int DROPDOWN_CHEVRON_W  = 20;    // width reserved for the ▼ chevron on the right
final int DROPDOWN_MAX_ITEMS  = 8;     // max visible rows before the list clips

// ─────────────────────────────────────────────────────────────────────────────
// Dropdown
//
// A self-contained dropdown widget. It renders a collapsed header bar showing
// the currently selected option. When clicked it expands a list downward over
// whatever is drawn beneath it. Clicking an option selects it and collapses
// the list. Clicking outside also collapses it.
//
// Each Dropdown holds a fixed list of (label, columnIndex) pairs supplied at
// construction time. Use getSelectedIndex() to read the chosen CSV column.
//
// Rendering is split into two calls that MUST be made in order inside draw():
//   1. dropdown.printDropdown()  — draws the header bar (always)
//   2. dropdown.printList()      — draws the expanded list ON TOP of everything
//                                  else; call this LAST in draw() so the list
//                                  overlays the chart rather than being hidden.
//
// Mouse events are handled by calling dropdown.mouseClicked() from
// mousePressed() in the main sketch.
// ─────────────────────────────────────────────────────────────────────────────

class Dropdown
{
    // ── Position & size ───────────────────────────────────────────────────────
    public float ddX;          // left edge of the dropdown
    public float ddY;          // top edge of the collapsed bar
    public float ddW;          // width of the dropdown

    // ── State ─────────────────────────────────────────────────────────────────
    private boolean isOpen       = false;
    private int     selectedItem = 0;    // index into items[]

    // ── Data ──────────────────────────────────────────────────────────────────
    private String[] labels;       // display names shown in the list
    private int[]    columnIndices; // corresponding CSV column indices

    // ── Fonts ─────────────────────────────────────────────────────────────────
    private PFont ddFont;

    // ── Colours (inherit from Visuals where possible) ─────────────────────────
    private final color COL_BAR_BG       = #2A3F5F;   // collapsed bar background
    private final color COL_BAR_BG_HOVER = #344E75;   // bar background on hover
    private final color COL_LIST_BG      = #1E2F47;   // list background
    private final color COL_LIST_HOVER   = #2A3F5F;   // list row on hover
    private final color COL_LIST_SEL     = #4E79A7;   // currently selected row
    private final color COL_TEXT         = #FFFFFF;
    private final color COL_BORDER       = #4A6080;

    // ── Constructor ───────────────────────────────────────────────────────────
    // x, y, w      – position and width of the dropdown bar
    // labels       – display names for each option
    // columnIndices – CSV column index that each label maps to
    Dropdown(float x, float y, float w, String[] labels, int[] columnIndices)
    {
        this.ddX           = x;
        this.ddY           = y;
        this.ddW           = w;
        this.labels        = labels;
        this.columnIndices = columnIndices;
        this.ddFont        = loadFont(Visuals.BUTTON_BUTTON_FONT);
    }

    // ── Accessors ─────────────────────────────────────────────────────────────

    // Returns the CSV column index of the currently selected option.
    public int getSelectedIndex()
    {
        return columnIndices[selectedItem];
    }

    // Returns the display label of the currently selected option.
    public String getSelectedLabel()
    {
        return labels[selectedItem];
    }

    public boolean isOpen()
    {
        return isOpen;
    }

    // Moves the dropdown to a new position (called by Graphs each frame so the
    // widget tracks its panel if the layout ever changes).
    public void setPosition(float x, float y)
    {
        this.ddX = x;
        this.ddY = y;
    }

    // ── Step 1: draw the collapsed header bar ─────────────────────────────────
    // Call this every frame in draw() before drawing charts so the bar is
    // always visible.
    public void printDropdown()
    {
        boolean hoveringBar = _hoveringBar();

        // Bar background
        noStroke();
        fill(hoveringBar ? COL_BAR_BG_HOVER : COL_BAR_BG);
        rect(ddX, ddY, ddW, DROPDOWN_H, 4);

        // Border
        stroke(COL_BORDER);
        strokeWeight(1);
        noFill();
        rect(ddX, ddY, ddW, DROPDOWN_H, 4);

        // Selected label text
        noStroke();
        fill(COL_TEXT);
        textFont(ddFont);
        textSize(11);
        textAlign(LEFT, CENTER);
        // Truncate label if too long for the bar
        String label = _truncate(labels[selectedItem], ddW - DROPDOWN_CHEVRON_W - 2 * DROPDOWN_PADDING_X);
        text(label, ddX + DROPDOWN_PADDING_X, ddY + DROPDOWN_H / 2.0);

        // Chevron ▼ / ▲
        fill(COL_TEXT);
        textAlign(CENTER, CENTER);
        text(isOpen ? "▲" : "▼", ddX + ddW - DROPDOWN_CHEVRON_W / 2.0, ddY + DROPDOWN_H / 2.0);

        textAlign(LEFT, BASELINE);   // reset
    }

    // ── Step 2: draw the expanded list ───────────────────────────────────────
    // Call this AFTER all chart drawing so the list overlays the chart.
    // Does nothing when the dropdown is collapsed.
    public void printList()
    {
        if (!isOpen) return;

        int visibleCount = min(labels.length, DROPDOWN_MAX_ITEMS);
        float listH      = visibleCount * DROPDOWN_ITEM_H;
        float listY      = ddY + DROPDOWN_H;   // list opens directly below the bar

        // List background + border
        stroke(COL_BORDER);
        strokeWeight(1);
        fill(COL_LIST_BG);
        rect(ddX, listY, ddW, listH, 0, 0, 4, 4);

        // Option rows
        textFont(ddFont);
        textSize(11);
        textAlign(LEFT, CENTER);

        for (int i = 0; i < visibleCount; i++)
        {
            float rowY    = listY + i * DROPDOWN_ITEM_H;
            boolean hover = _hoveringListItem(i);
            boolean sel   = (i == selectedItem);

            // Row background
            noStroke();
            if      (sel)   fill(COL_LIST_SEL);
            else if (hover) fill(COL_LIST_HOVER);
            else            fill(COL_LIST_BG);
            rect(ddX, rowY, ddW, DROPDOWN_ITEM_H);

            // Row text
            fill(COL_TEXT);
            String label = _truncate(labels[i], ddW - 2 * DROPDOWN_PADDING_X);
            text(label, ddX + DROPDOWN_PADDING_X, rowY + DROPDOWN_ITEM_H / 2.0);

            // Thin divider below each row except the last
            if (i < visibleCount - 1)
            {
                stroke(COL_BORDER);
                strokeWeight(0.5);
                line(ddX, rowY + DROPDOWN_ITEM_H, ddX + ddW, rowY + DROPDOWN_ITEM_H);
            }
        }

        textAlign(LEFT, BASELINE);   // reset
    }

    // ── Mouse handler ─────────────────────────────────────────────────────────
    // Call this from mousePressed() in the main sketch for every Dropdown.
    public void mouseClicked()
    {
        if (_hoveringBar())
        {
            // Toggle open/closed
            isOpen = !isOpen;
            return;
        }

        if (isOpen)
        {
            // Check if a list item was clicked
            int visibleCount = min(labels.length, DROPDOWN_MAX_ITEMS);
            float listY      = ddY + DROPDOWN_H;

            for (int i = 0; i < visibleCount; i++)
            {
                if (_hoveringListItem(i))
                {
                    selectedItem = i;
                    isOpen       = false;
                    return;
                }
            }

            // Clicked outside the list — collapse
            isOpen = false;
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

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

    // Truncates a string so it fits within maxWidth pixels (approximate, using
    // ~6px per character at size 11 as a heuristic matching Button's approach).
    private String _truncate(String s, float maxWidth)
    {
        int maxChars = (int)(maxWidth / 6);
        if (s.length() <= maxChars) return s;
        return s.substring(0, max(0, maxChars - 1)) + "…";
    }
}
