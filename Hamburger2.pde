import processing.sound.*;

//16 hours, 30 orders, extras added at 9am, 1pm, 5pm, and 9pm
int orderDelays[] = {0,0,0,0,5,5,10,10,15,15,20,20,25,25,30,30,35,35,40,40,45,45,50,50,50,55,55,60,60,70};
ArrayList<Order> futureOrders = new ArrayList<Order>();

Item emptyItem = new Item(-1);
Item selectedItem = emptyItem;
ArrayList<Item> grillItems = new ArrayList<Item>();

Order emptyOrder = new Order(-1,-1);
Order orders[] = {emptyOrder,emptyOrder,emptyOrder,emptyOrder};

boolean unlocks[] = {true,true,true,true,false,false,false,false,false,false,false,false,false,false,false};

Button buttons[] = new Button[15];
int buttonSpace, buttonHeight;

PImage testImage;
PImage forkKnife;
PImage book;
PImage itemImages[] = new PImage[20]; //inludes rare, medium, well-done, ruined
PImage platedImages[] = new PImage[20]; //for when it's on the burger
float grillRed;
boolean redUp;

//HUD Data
float hunger = 100;
int time = 479; //seconds
int cash = 100; //in cents
int satisfaction = 100; //customer satisfaction

int nextSecond = 0;
int nextOrderTimer = 0;
int nextOrderIndex = 0;

int burgerBottom;
int itemSize;

//Main items, fixings, sauces, exotic veggies, mush and bacon, egg and avocado
int level = 0; //level of unlocks, should start at 0, goes to 1 when game begins
float tab[][] = new float[6][6];
String tabText[] = new String[6];

boolean lingoScreen = false;

boolean gameEnd = false;

//SOUND
SoundFile SFX[] = new SoundFile[9];

void setup()
{
  fullScreen();
  setVariables();
  imageMode(CENTER);
  textAlign(CENTER);
  emptyOrder.empty = true;
  //TEST
  loadImages();
  setupButtons();
  setupTabs();
  loadSounds();
  shuffleOrderDelays();
 
  //futureOrders.add( new Order( 90, orderByLevel() ) );
}

void draw()
{
  background(150);
  drawTestScreen();
  for(Button b: buttons)
    b.drawButton();
  if( tab[1][5] > -buttonHeight*2 )
    moveAndDrawUnlockTabs();
  
  if( level > 0 && !gameEnd && secondPassed() ) //checks every second
  {
    time++;
    hunger--;
    nextOrderTimer--;
    if( hunger < 0 )
      hunger = 0;
    checkForRush();
    for( Order o: orders )
    {
      o.lateTime--;
      //if( o.lateTime < 0 )
      //  o.lateTime = 0;
    }
    
    for(int i = 0; i < orders.length; i++)
      if( orders[i].price > 0 && checkForLatePenalties(orders[i]) )
        orders[i] = emptyOrder;
        
    if( nextOrderTimer <=0 )
    {
      futureOrders.add( new Order( int(random(90,45)), orderByLevel() ) );
      nextOrderIndex++;
      if( nextOrderIndex < orderDelays.length )
        nextOrderTimer = orderDelays[nextOrderIndex];
    }
    for( Item i: grillItems )
      i.reduceFreshness(1);
  }
  
  addNewOrders();
  
  drawGrillItems();
  
  for(Order o: orders)
    o.handleOrder();
    
  drawInfoHud();
  
  if(lingoScreen)
    drawLingoScreen();
    
  handleGhostWords();
  
  //drawHungerIssue();
}

void setVariables()
{
  burgerBottom = int(height*16/18);
  itemSize = int(height/4.5);
  buttonSpace = int(width/15);
  buttonHeight = int(height/7);
}

  
boolean checkForLatePenalties( Order o )
{
  if( o.lateTime <= 0 )
    satisfaction--;
  if( o.lateTime < -9 )
  {
    satisfaction -=4;
    words.add( new GhostWords( "The customer left a bad review...", 50 ) );
    return true;
  }
  return false;
}

void checkForRush()
{
  if( time == 540 ) //breakfast at 9
  {
    futureOrders.add( new Order( 90, orderByLevel() ) );
    futureOrders.add( new Order( 90, orderByLevel() ) );
    futureOrders.add( new Order( 120, orderByLevel() ) );
    words.add( new GhostWords( "Breakfast Time!", 100 ) );
  }
  if( time == 780 ) //lunch at 1
  {
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 90, orderByLevel() ) );
    futureOrders.add( new Order( 100, orderByLevel() ) );
    futureOrders.add( new Order( 110, orderByLevel() ) );
    words.add( new GhostWords( "Lunch Rush!", 100 ) );
  }
  if( time == 1020 ) //dinner at 5
  {
    futureOrders.add( new Order( 70, orderByLevel() ) );
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 90, orderByLevel() ) );
    futureOrders.add( new Order( 100, orderByLevel() ) );
    futureOrders.add( new Order( 110, orderByLevel() ) );
    words.add( new GhostWords( "Supper Crowd!", 100 ) );
  }
  if( time == 1260 ) //bus at 9
  {
    futureOrders.add( new Order( 70, orderByLevel() ) );
    futureOrders.add( new Order( 70, orderByLevel() ) );
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 150, orderByLevel() ) );
    futureOrders.add( new Order( 30, orderByLevel() ) );
    words.add( new GhostWords( "Bus on the lot!", 100 ) );
  }
}

void setupTabs()
{
  //tab = { {0, width/15*4+width/32, width/15*7+width/32, width/15*9+width/32, width/15*11+width/32, width/15*13+width/32},
  //        {-height/7,-height/7,-height/7,-height/7,-height/7,-height/7} };
  tab[0][0] = 0;
  tab[0][1] = buttonSpace*4;
  tab[0][2] = buttonSpace*7;
  tab[0][3] = buttonSpace*9;
  tab[0][4] = buttonSpace*11;
  tab[0][5] = buttonSpace*13;
  for(int i = 0; i < 6; i++)
    tab[1][i] = -buttonHeight;
  tabText[0] = "Open Up Shop";
  tabText[1] = "Unlock More Ingredients: $2.00";
  tabText[2] = "$4.00";
  tabText[3] = "$6.00";
  tabText[4] = "$8.00";
  tabText[5] = "$10.00";
}

void shuffleOrderDelays()
{
  int [] newOrder = new int[orderDelays.length];
  for(int i = 0; i < orderDelays.length; i++ )
  {
    int rand = 0;
    while( orderDelays[rand] == -1 )
    {
      rand = int(random(orderDelays.length));
    }
    newOrder[i] = orderDelays[rand];
    orderDelays[rand] = -1;
  }
  orderDelays = newOrder;
}
  
void addNewOrders()
{
  for( int i = 0; i < 4; i++ )
  {
    if( orders[i].price == 0 && futureOrders.size() > 0 )
    {
      orders[i] = futureOrders.remove(0);
      return;
    }
  }
}

int orderByLevel()
{
  if( level == 1 )
    return int(random(3));
  if( level == 2 )
    return int(random(10));
  if( level == 3 )
    return int(random(14));
  if( level == 4 )
    return int(random(16));
  if( level == 5 )
    return int(random(16));
  else
    return int(random(18));
}

//defunct
//void drawHungerIssue()
//{
//  float multiplier = 100 - hunger;
//  fill(0,-255+(500*(multiplier/100.0)));
//  rect(0,0,width,height);
//  //println(500*(multiplier/100.0));
//}

void loadSounds()
{
  SFX[0] = new SoundFile(this, "littleBite.wav");
  SFX[1] = new SoundFile(this, "littleGulp.wav");
  SFX[2] = new SoundFile(this, "littleBell.wav");
}

void setupButtons()
{
  for(int i = 0; i < 15; i++)
    buttons[i] = new Button(width/32+buttonSpace*i,buttonHeight/2,itemImages[i],i);
}

//load to size of height/4.5
void loadImages()
{
  itemImages[0] = loadImage("bunA.png");     itemImages[0].resize(itemSize,0);
  itemImages[1] = loadImage("bun2.png");     itemImages[1].resize(itemSize,0);
  itemImages[2] = loadImage("raw.png");      itemImages[2].resize(itemSize,0);
  itemImages[3] = loadImage("katchupB.png"); itemImages[3].resize(itemSize,0);
  itemImages[4] = loadImage("lettuce.png");  itemImages[4].resize(itemSize,0);
  itemImages[5] = loadImage("tomato.png");   itemImages[5].resize(itemSize,0);
  itemImages[6] = loadImage("cheese.png");   itemImages[6].resize(itemSize,0);
  itemImages[7] = loadImage("mustardB.png"); itemImages[7].resize(itemSize,0);
  itemImages[8] = loadImage("mayoB.png");    itemImages[8].resize(itemSize,0);
  itemImages[9] = loadImage("pickle.png");   itemImages[9].resize(itemSize,0);
  itemImages[10] = loadImage("onion.png");   itemImages[10].resize(itemSize,0);
  itemImages[11] = loadImage("bacon.png");   itemImages[11].resize(itemSize,0);
  itemImages[12] = loadImage("shroom.png");  itemImages[12].resize(itemSize,0);
  itemImages[13] = loadImage("egg.png");     itemImages[13].resize(itemSize,0);
  itemImages[14] = loadImage("avocado.png"); itemImages[14].resize(itemSize,0);
  
  itemImages[15] = loadImage("rare.png");    itemImages[15].resize(itemSize,0);
  itemImages[16] = loadImage("med.png");     itemImages[16].resize(itemSize,0);
  itemImages[17] = loadImage("well.png");    itemImages[17].resize(itemSize,0);
  itemImages[18] = loadImage("ruined.png");  itemImages[18].resize(itemSize,0);
  itemImages[19] = loadImage("spatula.png"); itemImages[19].resize(itemSize,0);
  
  platedImages[0] = itemImages[0];
  platedImages[1] = itemImages[1];
  platedImages[2] = itemImages[2];
  platedImages[3] = loadImage("katchupSplat.png");   platedImages[3].resize(itemSize,0);
  platedImages[4] = loadImage("lettuceLeaf2.png");   platedImages[4].resize(itemSize,0);
  platedImages[5] = loadImage("tomatoSlice.png");    platedImages[5].resize(itemSize,0);
  platedImages[6] = loadImage("queso.png");          platedImages[6].resize(itemSize,0);
  platedImages[7] = loadImage("mustardSplat.png");   platedImages[7].resize(itemSize,0);
  platedImages[8] = loadImage("mayoSplat.png");      platedImages[8].resize(itemSize,0);
  platedImages[9] = loadImage("pickleSlice.png");    platedImages[9].resize(itemSize,0);
  platedImages[10] = loadImage("onionRings2.png");   platedImages[10].resize(itemSize,0);
  platedImages[11] = loadImage("bigBacon.png");      platedImages[11].resize(itemSize,0);
  platedImages[12] = loadImage("shroom5.png");      platedImages[12].resize(itemSize,0);
  platedImages[13] = loadImage("friedEgg.png");      platedImages[13].resize(itemSize,0);
  platedImages[14] = loadImage("avocadoSlices.png"); platedImages[14].resize(itemSize,0);
  
  platedImages[15] = itemImages[15];
  platedImages[16] = itemImages[16];
  platedImages[17] = itemImages[17];
  platedImages[18] = itemImages[18];

  forkKnife = loadImage("forkKnife.png"); forkKnife.resize(100,0);
  book = loadImage("lingo.png");          book.resize(100,0);
}

void keyPressed()
{
  level++;
}

void moveAndDrawUnlockTabs()
{
  //Move
  for( int i = 0; i < level; i++ )
  {
    if( tab[1][i] > -buttonHeight*2 )
      tab[1][i]-=5;
  }
  push();
  textSize(50);
  //Draw
  for( int i = 5; i >= 0; i-- )
  {
    fill(150);
    rect( tab[0][i], tab[1][i], width-tab[0][i], buttonHeight*2, 50 );
    fill(50);
    if( i == 0 )
    {
      textAlign(CENTER);
      text( tabText[i], width/2, tab[1][i]+buttonHeight*1.5+15 );
    }
    else
    {
      textAlign(LEFT);
      text( tabText[i], tab[0][i]+width/32, tab[1][i]+buttonHeight*1.5+15 );
    }
  }
  pop();
}

void drawInfoHud() //part on the right
{
  stroke(100);
  strokeWeight(1);
  fill(150);
  //rect(width*4/5,height/7,width*1/5,height*6/7);
  
  //Clock
  push();
  fill(0);
  stroke(255);
  strokeWeight(5);
  rectMode(CENTER);
  rect(width*8.7/10, height*1.37/7,170,80);
  fill(0,200,0);
  textSize(70);
  text( timeString(), width*8.7/10, height*1.5/7 );
  pop();
  
  //Book
  image( book, width*9.6/10, height*1.37/7 );
  
  line(width*8.2/10,height*1.83/7,width*9.8/10,height*1.83/7);
  
  //Cash
  push();
  textSize(80);
  fill(0);
  if( cash < 0 )
    fill(200,0,0);
  textAlign(LEFT);
  text( cashString(), width*8.5/10, height*1.65/5 );
  pop();
  
  line(width*8.2/10,height*2.47/7,width*9.8/10,height*2.47/7);
  
  //Customer Satisfaction
  push();
  textSize(120);
  fill(250-satisfaction*2.5,satisfaction*2.5,0);
  text(satisfactionString(),width*9/10, height*2.3/5);
  pop();
  
  line(width*8.2/10,height*3.4/7,width*9.8/10,height*3.4/7);
  
  //Hunger Bar
  push();
  fill(200,0,0);
  noStroke();
  rect(width*8.5/10,height*2.75/5,hunger*2,50);
  stroke(255);
  noFill();
  rect(width*8.5/10,height*2.75/5,200,50);
  fill(0);
  text("HUNGER",width*9/10,height*2.7/5);
  pop();
  
  //Eat Button
  image(forkKnife,width*19.5/20,height*9.5/10);
}

boolean secondPassed()
{
  if( nextSecond < millis() )
  {
    nextSecond = millis() + 1000;
    return true;
  }
  return false;
}

String timeString() //clock
{
  String min = ""+time%60;
  String hour = ""+time/60;
  if(min.length() < 2)
    min = "0"+min;
  if( hour.equals("0") )
    hour = "12";
  return hour + ":" + min;
}

String timerString( Order o ) //order timers
{
  if( o.lateTime <= 0 )
    return "!!!!!";
  String min = ""+int(o.lateTime / 60);
  String sec = ""+int(o.lateTime % 60);
  if(sec.length() < 2)
    sec = "0"+sec;
  return min + ":" + sec;
}

String cashString()
{
  String result = "$";
  String cents = ""+abs(cash%100);
  if( cents.length()<2)
    cents+="0";
  if( cash < 0 )
    result = "-$";
  return result+abs(cash/100) + "." + cents;
}

String satisfactionString()
{
  return "%" + satisfaction;
}

void drawLingoScreen()
{
  strokeWeight(9);
  stroke(200,230);
  fill(100,230);
  rect(width/20,height/18,width*18/20,height*16/18);
  image( book, width*9.6/10, height*1.37/7 );
}

void drawTestScreen()
{
  fill(150);
  strokeWeight(4);
  stroke(255);
  rect(0,0,width,height/7);
  //rect(0,height/7,width*4/5,height*1.5/7);
  rect(0,height*2.25/7,width*4/5,height*4.75/7);
  fill(200);
  circle(width*9/10,height*8/10,height/3.5);
  circle(width*19.5/20,height*9.5/10,100);
  for( int i = 0; i < 17; i++ )
    circle( width/15*i+width/32, height/14, 100 );
  drawPlates();
  drawGrill();
  drawCurrentItem();
}

void drawPlates()
{
  
  for(int i = 0; i < 4; i++)
  {
    //Pannels
    fill(150);
    strokeWeight(4);
    stroke(255);
    rect( i*(width/5), height*2.25/7, width/5, height*4.75/7 );
    
    //Eject
    stroke(200);
    fill(200,0,0);
    rect((i)*width/5,height*19/20,width/5,200);
    
    //Draw Plate
    if( !orders[i].dumping )
    {
      fill(255);
      stroke(200);
      ellipse( i*(width/5)+(width/10), height-height*1/15, width/5.2, height/9);
      ellipse( i*(width/5)+(width/10), height-height*1/15, width/6.5, height/12);
    }
  }
  
  for(int i = 0; i < 4; i++)  //Ticket Sheets
  {
    if( orders[i].price > 0 )
    {
      push();
      fill(255,255,220);
      noStroke();
      rect((i+1)*width/5-125,height*2.25/7,150,240);
      strokeWeight(0.5);
      stroke(0);
      for(int j = 1; j < 10; j++)
        line((i+1)*width/5-120 , height*2.28/7+ 23*j, (i+1)*width/5, height*2.28/7+ 23*j);
      textSize(20);
      textAlign(LEFT);
      fill(0);
      text(orders[i].hungryVersion(), (i+1)*(width/5)-120, height*2.3/7,150,240);
      textAlign(RIGHT);
      text( orders[i].priceString(), (i+1)*(width/5)+20, height*3.75/7);
      pop();
    }
  }
  
  for(int i = 0; i < 8; i+=2) //timers
  {
    if( orders[i/2].price > 0 )
    {
      push();
      stroke(255);
      fill(175);
      if( orders[i/2].lateTime < 20 )
        fill(250,250,0);
      if( orders[i/2].lateTime < 10 )
        fill(175,0,0);
      rect(width/10*i+width/14,2.25/7*height,100,40);
      fill(0);
      textSize(30);
      textAlign(LEFT);
      text( timerString(orders[i/2]), width/10*i+width/11.6,2.45/7*height);
      pop();
    }
  }
}

void drawGrill()
{
  fill(grillRed,0,0);
  rect(0,height/7,width*4/5,height*1.25/7);
  fill(100);
  noStroke();
  for( int i = 10; i < width*4/5; i+=30 )
    rect(i,height/7,15,height*1.25/7);
  strokeWeight(5);
  stroke(200);
  noFill();
  rect(0,height/7,width*4/5,height*1.25/7);
  if( redUp )
    grillRed+=0.5;
  else
    grillRed-=0.5;
  if( grillRed > 70 )
    redUp = false;
  if( grillRed < 0 )
    redUp = true;
}

void drawCurrentItem()
{
  if( selectedItem != null )
    image( selectedItem.itemPic(), width*9/10,height*8/10, height/3.5, height/3.5);
  textSize(50);
  fill(0);
  text(selectedItem.toString(), width*9/10, height*6.5/10);
}

void eat( int amount, Type t )
{
  hunger += amount;
  if( hunger > 100 )
    hunger = 100;
  if( t == Type.KATCHUP ||  t == Type.MUSTARD ||  t == Type.MAYO )
    SFX[1].play();
  else
    SFX[0].play();
}

int nutrition( Type t )
{
  switch( t )
  {
    case TOP_BUN:     return 20;
    case BOTTOM_BUN:  return 20;
    case PATTY:    return -10;
    case KATCHUP:  return 5;
    case LETTUCE:  return 20;
    case TOMATO:   return 20;
    case CHEESE:   return 40;
    case MUSTARD:  return 5;
    case MAYO:     return 10;
    case PICKLE:   return 25;
    case ONION:    return 15;
    case BACON:    return 40;
    case SHROOM:   return 25;
    case EGG:      return 20;
    case AVOCADO:  return 30;
  
    case RARE:       return 65;
    case MEDIUM:     return 75;
    case WELL_DONE:  return 65;
  
    case RUINED:     return -20;
  
    default: return 0;
  }
}

void drawGrillItems()
{
  for( Item i: grillItems )
    image( i.itemPic(), i.xPos, i.yPos );
}

boolean grillSpaceAvailable( float x, float y )
{
  for( Item i: grillItems )
    if( dist( x, y, i.xPos, i.yPos ) < itemSize )
      return false;
  return true;
}

// rect((i+1)*width/5-125,height*2.25/7,150,240);

int clickedTicket()
{
  for(int i = 0; i < 4; i++)
  {
    if( mouseX > (i+1)*width/5-125 && mouseX < (i+1)*width/5+25 && mouseY > height*2.25/7 && mouseY < height*2.25/7+240 )
      return i;
  }
  return -1;
}

//quick and dirty - change
ArrayList<GhostWords> words = new ArrayList<GhostWords>();
void handleGhostWords()
{
  for(int i = 0; i < words.size(); i++)
  {
    words.get(i).moveAndDraw();
    words.get(i).duration--;
    if( words.get(i).duration < 0 )
      words.remove(i);
  }
}

void attemptUpgrade()
{
  if( cash/100 > level*2 )
  {
    cash -= level*2*100;
    level++;
  }
}

//0 - prompt, 1 - on time, 2 - late, 3 - very late
int checkPromptness( int index )
{
  if( orders[index].lateTime == 0 )
  {
    satisfaction -= 3;
    return 3;
  }
  else if( orders[index].lateTime < 10 )
  {
    satisfaction -= 1;
    return 2;
  }
  else if( orders[index].lateTime < 20 )
    return 1;
  else
  {
    satisfaction = min( 100, satisfaction+2 );
    return 0;
  }
}

String promptString( int p )
{
  if( p == 3 )
    return "Better late than never...  -3";
  else if( p == 2 )
    return "Order served late  -2";
  else if( p == 1 )
    return "Order served on time";
  else
    return "Prompt Service!  +2";
}

int checkDeviation( int index )
{
  int result = 0;
  for( Item i: orders[index].plate )
  {
    result += dist( i.xPos, 0, index*(width/5)+(width/10), 0 );
  }
  println("RESULT: " + result);
  return result/15;
}

void mousePressed()
{
  int ticket = clickedTicket();
  if( ticket > -1 && orders[ticket].finished )               //checked ticket
  {
    if( orders[ticket].checkOrder() )
    {
      SFX[2].play();
      int deviation = checkDeviation(ticket);
      int promptness = checkPromptness(ticket);
      words.add( new GhostWords( width/5*(ticket+1), height/2, promptString(promptness) + "\nPresentation: %" + (100-deviation), 100 ));
      cash+=orders[ticket].price;
      if( deviation > 10 )
        satisfaction -= deviation-10;
      orders[ticket] = emptyOrder;
    }
    else
    {
      words.add( new GhostWords( width/5*(ticket+1), height/2, "MISTAKE", 100 ) );
      satisfaction-=5;
    }
  }
  else if( selectedItem == emptyItem ) //Clicking buttons with empty inventory
  {
    for( Button b: buttons )
      if( b.onButton() && b.unlocked() )
      {
        selectedItem = b.getItem();
        cash -= selectedItem.price;
        println(selectedItem.price);
      }
    if( level < 6 && mouseY < buttonHeight && mouseX > tab[0][level] )
    {
      attemptUpgrade();
    }
    for( int i = 0; i < grillItems.size(); i++ )
    {
      if( mouseY > height/7 && dist( mouseX, mouseY, grillItems.get(i).xPos, grillItems.get(i).yPos ) < itemSize )
      {
        selectedItem = grillItems.get(i);
        grillItems.remove(i);
        break;
      }
    }
    if( mouseY > height*2.25/7 && mouseX < width*4/5 && mouseY > height*19/20)
    { 
        orders[int(mouseX/( width/5 ))].dumping = true;
    }
  }
  else
  {
    if( dist(mouseX,mouseY,width*19.5/20,height*9.5/10) < 350 ) //consume held item
    {
      eat( nutrition( selectedItem.type ), selectedItem.type );
      selectedItem = emptyItem;
    }
    else if( mouseY > height*2.25/7 && mouseX < width*4/5) //clicked in order area
    { 
      if( mouseY > height*19/20 ) //dumped an order
      {
        orders[int(mouseX/( width/5 ))].dumping = true;
      }
      else if( !orders[int(mouseX/( width/5 ))].empty && !orders[int(mouseX/( width/5 ))].dumping && !orders[int(mouseX/( width/5 ))].finished ) // <- ADD ITEM
      {
        selectedItem.xPos = mouseX;
        orders[int(mouseX/( width/5 ))].plate.add( selectedItem );
        selectedItem = emptyItem;
      }
    }
    else if( mouseY > height/7 && mouseY < height*2/7 && mouseX < width*4/5 ) //clicked on grill
    {
      if( grillSpaceAvailable( mouseX, mouseY ) )
      {
        grillItems.add( new Item( selectedItem, mouseX, mouseY ) );
        selectedItem = emptyItem;
      }
    }
  }
  
  if( dist(mouseX,mouseY,width*9.6/10, height*1.37/7) < 100 )
    lingoScreen = !lingoScreen;
}

enum Type
{
  TOP_BUN,    //0
  BOTTOM_BUN, //1
  PATTY,      //2
  KATCHUP,    //3
  LETTUCE,    //4
  TOMATO,     //5
  CHEESE,     //6
  MUSTARD,    //7
  MAYO,       //8
  PICKLE,     //9
  ONION,      //10
  BACON,      //11
  SHROOM,     //12
  EGG,        //13
  AVOCADO,    //14
  
  RARE,       //15
  MEDIUM,     //16
  WELL_DONE,  //17
  
  RUINED,     //18
  
  NONE
}
