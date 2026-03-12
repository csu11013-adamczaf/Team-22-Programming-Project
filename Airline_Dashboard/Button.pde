final int BUTTON_PADDING = 10;

class Button
{
  public int btnW = 80;
  public int btnH = 30;
  public int btnX = 150;
  public int btnY = 400;
  private PFont buttonFont;
  private int strokeColour = 0;


  Button(int btnW, int btnH, int btnX, int btnY)
  {
      this.btnW = btnW;
      this.btnH = btnH;
      this.btnX = btnX;
      this.btnY = btnY;
      this.buttonFont = loadFont("button-font.vlw");
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
      strokeColour = #ffffff;
    }
    else{
      strokeColour = 0;
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
