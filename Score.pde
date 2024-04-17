class Score
{
  String name;
  int cash;
  int food;
  
  public Score()
  {
    name = "---";
    cash = 0;
    food = 0;
  }
  
  public Score( String n, int s, int p )
  {
    name = n;
    cash = s;
    food = p;
  }
}
