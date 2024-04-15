class GhostWords
{
  float xPos, yPos;
  String words;
  int duration;
  
  public GhostWords( String w, int d )
  {
    xPos = width/2;
    yPos = height/2;
    words = w;
    duration = d;
  }
  
  public GhostWords( float x, float y, String w, int d )
  {
    this(w,d);
    xPos = x;
    yPos = y;
  }
  
  void moveAndDraw()
  {
    push();
    textSize(50);
    fill(0,175);
    textAlign(CENTER);
    text(words,xPos,yPos);
    yPos--;
    pop();
  }
}
