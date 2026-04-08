public class CheckBox
{
    float xPos;
    float yPos;
    float height;
    float width;
    int currentColour;
    String text;
    boolean enabled;  // True = checked, false = unchecked

    CheckBox(float xPos, float yPos, String text)
    {
        this.xPos = xPos;
        this.yPos = yPos;
        this.text = text;
        height = width = 20;
        currentColour = #0D1526;  // Default to dark (unchecked state)
        enabled = true;
    }

    void draw()
    {
        stroke(0);
        fill(currentColour);
        rect(xPos, yPos, width, height, 5);  // 5px corner radius
        textFont(loadFont(Visuals.QUERY_SEARCH_FONT));
        fill(0);
        textSize(20);
        // Position text to the right of the checkbox, with a 10px gap, and vertically aligned with the checkbox
        text(this.text, xPos + height + 10, (yPos + textAscent() + textDescent()));
    }

    void mouseClicked()
    {
        if ((mouseX > xPos && mouseX < xPos + width) && (mouseY > yPos && mouseY < yPos + height))
        {
            // Toggle fill between white (checked) and dark (unchecked)
            currentColour = (currentColour == #ffffff ? #0D1526 : #ffffff);
            enabled = (enabled == true ? false : true);
        }
    }
}