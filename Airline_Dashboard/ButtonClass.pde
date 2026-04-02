final int BUTTON_PADDING = 10;

class Button
{
  private float btnW = 80;
  private float btnH = 30;
  private float btnX = 0;
  private float btnY = 0;
  private PFont buttonFont;
  private int strokeColour = 0;


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
    int textLength = text.length()*5;
    btnW = textLength + 2*BUTTON_PADDING;
    fill(fillColor);
    stroke(strokeColour);
    rect(btnX, btnY, btnW, btnH, 5);
    fill(textColor);
    textFont(buttonFont);
    text(text, btnX + BUTTON_PADDING, btnY + 1.75*BUTTON_PADDING);
  }

  public void hoverButton()
  {
    if((mouseX > btnX && mouseX < btnX+btnW) && (mouseY > btnY && mouseY < btnY+btnH))
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
      if(mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH && mousePressed)
      {
        return true;
      }
      else return false;
  }
}
