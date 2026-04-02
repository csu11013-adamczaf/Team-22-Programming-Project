// Central design token store for Airline Dashboard.
// All colours, fonts, sizes, and spacing live here.
public class Visuals
{

    // ── Global Data ─────────────────────────────────────────────────────
    public static final String DATA                = "flights2k.csv";

    // ── Global background ─────────────────────────────────────────────────────
    public static final int  BACKGROUND            = #0B1120;   // deep navy page bg

    // ── Navbar ────────────────────────────────────────────────────────────────
    public static final int  NAVBAR_BG             = #0D1526;   // slightly lighter than bg
    public static final int  NAVBAR_BORDER         = #1E3A5F;   // subtle bottom border
    public static final int  NAVBAR_H              = 56;        // navbar height in px
    public static final int  NAVBAR_TITLE_COLOUR   = #FFFFFF;
    public static final int  NAVBAR_TITLE_SIZE     = 20;

    // ── Nav tabs ──────────────────────────────────────────────────────────────
    public static final int  TAB_TEXT_IDLE         = #7B96B2;   // muted blue-grey
    public static final int  TAB_TEXT_ACTIVE       = #FFFFFF;
    public static final int  TAB_INDICATOR         = #3B82F6;   // electric blue underline
    public static final int  TAB_INDICATOR_H       = 3;
    public static final int  TAB_W                 = 120;
    public static final int  TAB_HOVER_BG          = #152035;

    // ── Chart panels ─────────────────────────────────────────────────────────
    public static final int  PANEL_BG              = #111D33;   // panel surface
    public static final int  PANEL_BORDER          = #1E3A5F;   // 1px border
    public static final int  PANEL_TITLE_COLOUR    = #E2E8F0;
    public static final int  PANEL_RADIUS          = 10;

    // ── Chart colours ────────────────────────────────────────────────────────
    public static final int  CHART_GRIDLINE        = #1E3A5F;
    public static final int  CHART_AXIS            = #2D5080;
    public static final int  CHART_LABEL           = #7B96B2;
    public static final int  CHART_VALUE_LABEL     = #E2E8F0;

    // ── Table ─────────────────────────────────────────────────────────────────
    public static final int  TABLE_BG              = #111D33;
    public static final int  TABLE_HEADER_BG       = #0D1526;
    public static final int  TABLE_ROW_CANCELLED   = #FF4D4D;
    public static final int  TABLE_ROW_DIVERTED    = #F5DD27;

    // ── Buttons / pagination ──────────────────────────────────────────────────
    public static final int  BTN_BG                = #1E3A5F;
    public static final int  BTN_BG_HOVER          = #2D5080;
    public static final int  BTN_TEXT              = #E2E8F0;
    public static final int  BTN_BORDER            = #2D5080;
    public static final int  SPACE_BETWEEN_BUTTONS = 10;

    // ── Accent ────────────────────────────────────────────────────────────────
    public static final int  ACCENT                = #3B82F6;   // primary blue accent
    public static final int  ACCENT_GLOW           = 0x223B82F6; // translucent for fills

    // ── Text ──────────────────────────────────────────────────────────────────
    public static final int  GLOBAL_TEXT_COLOUR_DARK  = #0B1120;
    public static final int  GLOBAL_TEXT_COLOUR_LIGHT = #E2E8F0;
    public static final int  GLOBAL_STROKE_COLOUR_DARK  = #1E3A5F;
    public static final int  GLOBAL_STROKE_COLOUR_LIGHT = #2D5080;

    // ── Fonts ─────────────────────────────────────────────────────────────────
    public static final String TABLEWIDGET_TABLE_FONT  = "TableWidget/table-font.vlw";
    public static final String TABLEWIDGET_HEADER_FONT = "TableWidget/header-font.vlw";
    public static final String BUTTON_BUTTON_FONT      = "Button/button-font.vlw";
    public static final String QUERY_SEARCH_FONT       = "Query/search-font.vlw";

    // ── Legacy constants kept for backward compatibility ──────────────────────
    public static final int  BUTTON_BUTTON_COLOUR      = #1E3A5F;
    public static final int  GRAPHS_BACKGROUND_COLOUR  = #111D33;
    public static final String GRAPHS_FONT             = "Graphs/graphs-font-18.vlw";
}
