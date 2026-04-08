// Button class to represent interactive buttons in the UI
class Button
{
  private float btnW = 80;
  private float btnH = 30;
  private float btnX = 0;
  private float btnY = 0;
  private int strokeColour = 0;  // Changes between light/dark depending on hover state

  Button(float btnW, float btnH, float btnX, float btnY)
  {
      this.btnW = btnW; 
      this.btnH = btnH; 
      this.btnX = btnX;
      this.btnY = btnY;
  }

  // Draw the button with the given text and colors
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
    textFont(button_ButtonFont);
    // Horizontal: padded from left edge. Vertical: 1.75× padding approximates centre
    text(text, btnX + BUTTON_PADDING, btnY + 1.75 * BUTTON_PADDING);
  }

  // Update the stroke color based on whether the mouse is hovering over the button
  public void hoverButton()
  {
    if ((mouseX > btnX && mouseX < btnX + btnW) && (mouseY > btnY && mouseY < btnY + btnH))
    {
      strokeColour = Visuals.GLOBAL_STROKE_COLOUR_LIGHT;
    }
    else
    {
      strokeColour = Visuals.GLOBAL_STROKE_COLOUR_DARK;
    }
  }

  // Check if the button is currently being pressed
  public boolean buttonPressed()
  {
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH && mousePressed)
    {
      return true;
    }
    else return false;
  }
}