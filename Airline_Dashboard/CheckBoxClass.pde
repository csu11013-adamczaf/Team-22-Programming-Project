public class CheckBox
{
    float xPos;
    float yPos;
    float height;
    float width;
    int currentColour;
    String text;
    boolean enabled;

    CheckBox(float xPos, float yPos, String text)
    {
        this.xPos = xPos;
        this.yPos = yPos;
        this.text = text;
        height = width = 20;
        currentColour = #0D1526;
        enabled = true;
    }

    void draw()
    {
        stroke(0);
        fill(currentColour);
        rect(xPos, yPos, width, height, 5);
        textFont(loadFont(Visuals.QUERY_SEARCH_FONT));
        fill(0);
        textSize(20);
        text(this.text, xPos+height+10, (yPos+textAscent()+textDescent()));
    }

    void mouseClicked()
    {
        if((mouseX > xPos && mouseX < xPos+width) && (mouseY > yPos && mouseY < yPos+height))
        {
            currentColour = (currentColour == #ffffff ? #0D1526 : #ffffff);
            enabled = (enabled == true ? false : true);
        }
    }
}