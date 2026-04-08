// CheckBox class to represent interactive checkboxes in the UI

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

    // Draw the checkbox and its label
    void draw()
    {
        stroke(0);
        fill(currentColour);
        rect(xPos, yPos, width, height, 5);  // 5px corner radius
        textFont(query_QueryFont);
        fill(0);
        textSize(20);
        if(enabled)
        {
            image(query_queryTick, xPos + 3.5, yPos + 3.5, width - 7.5, height - 7.5);
        }
        text(this.text, xPos + height + 10, (yPos + textAscent() + textDescent()));
    }
    
    // Handle mouse clicks to toggle the checkbox state
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