final int BUTTON_PADDING = 10;

class Button
{
  private float btnW = 80;
  private float btnH = 30;
  private float btnX = 0;
  private float btnY = 0;
  private PFont buttonFont;
  private int strokeColour = 0;  // Changes between light/dark depending on hover state

  Button(float btnW, float btnH, float btnX, float btnY)
  {
      this.btnW = btnW; 
      this.btnH = btnH; 
      this.btnX = btnX;
      this.btnY = btnY;
      this.buttonFont = loadFont(Visuals.BUTTON_BUTTON_FONT);
  }
  
  public void printButton(String text, color fillColor, color textColor)
  {
    hoverButton();
    // Approximate text width at 5px per character, then pad both sides
    int textLength = text.length() * 5;
    btnW = textLength + 2 * BUTTON_PADDING;

    fill(fillColor);
    stroke(strokeColour);
    rect(btnX, btnY, btnW, btnH, 5);  // 5px corner radius

    fill(textColor);
    textFont(buttonFont);
    // Horizontal: padded from left edge. Vertical: 1.75× padding approximates centre
    text(text, btnX + BUTTON_PADDING, btnY + 1.75 * BUTTON_PADDING);
  }

  public void hoverButton()
  {
    // Highlight the border when the cursor is inside the button bounds
    if ((mouseX > btnX && mouseX < btnX + btnW) && (mouseY > btnY && mouseY < btnY + btnH))
    {
      strokeColour = Visuals.GLOBAL_STROKE_COLOUR_LIGHT;
    }
    else
    {
      strokeColour = Visuals.GLOBAL_STROKE_COLOUR_DARK;
    }
  }

  public boolean buttonPressed()
  {
    // Check if the mouse is currently pressed and within the button bounds
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH && mousePressed)
    {
      return true;
    }
    else return false;
  }
}