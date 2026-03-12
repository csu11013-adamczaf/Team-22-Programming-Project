final int BUTTON_PADDING = 20;

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
      this.buttonFont = loadFont("ArialMT-10.vlw");
  }
  
  public void printButton(String text, color fillColor, color textColor)
  {
    hoverButton();

    fill(fillColor);
    stroke(strokeColour);
    rect(btnX, btnY, btnW, btnH);
    fill(textColor);
    textFont(buttonFont);
    text(text, btnX + BUTTON_PADDING, btnY + BUTTON_PADDING);
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
}
