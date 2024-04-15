class Button
{
  float xPos, yPos;
  PImage pic;
  int index;
  
  public Button( float x, float y, PImage p, int i )
  {
    xPos = x;
    yPos = y;
    pic = p;
    index = i;
  }
  
  void drawButton()
  {
    stroke(255);
    strokeWeight(5);
    fill(200);
    circle(xPos,yPos,100);
    image(pic,xPos,yPos,100,100);
  }
  
  boolean onButton()
  {
    return dist( mouseX, mouseY, xPos, yPos ) < 50;
  }
  
  boolean unlocked()
  {
    if( level >= 1 && index == 0 ) return true;
    if( level >= 1 && index == 1 ) return true;
    if( level >= 1 && index == 2 ) return true;
    if( level >= 1 && index == 3 ) return true;
    
    if( level >= 2 && index == 4 ) return true;
    if( level >= 2 && index == 5 ) return true;
    if( level >= 2 && index == 6 ) return true;
    
    if( level >= 3 && index == 7 ) return true;
    if( level >= 3 && index == 8 ) return true;
    
    if( level >= 4 && index == 9 ) return true;
    if( level >= 4 && index == 10 ) return true;
    
    if( level >= 5 && index == 11 ) return true;
    if( level >= 5 && index == 12 ) return true;
    
    if( level >= 6 && index == 13 ) return true;
    if( level >= 6 && index == 14 ) return true;
    
    return false;
  }
  
  Item getItem()
  {
    return ( new Item(index) );
  }
}
