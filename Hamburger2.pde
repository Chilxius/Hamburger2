/***********************************************
*                                              *
*       Hamburger Game II: Lunch Rush!         *
*                                              *
*  Prepare the orders as requested and hit the *
* ticket to serve it. Items can be stacked in  *
* your hand, first-in-last-out. Use the lingo  *
* book to translate the diner terms.           *
*                                              *
***********************************************/

import processing.sound.*;

//Easy mode
boolean noFail = false;

//16 hours, 30 orders, extras added at 9am, 1pm, 5pm, and 9pm, one extra added every 100 seconds
int orderDelays[] = {0,0,0,0,5,5,5,10,10,15,15,20,20,25,25,30,30,35,35,40,40,45,55,50,50,50,55,55,60,60};
ArrayList<Order> futureOrders = new ArrayList<Order>();

//Lists for items on grill or in hand (I created stacks - probably should have just used Stacks)
Item emptyItem = new Item(-1);
ArrayList<Item> hand = new ArrayList<Item>();
ArrayList<Item> grillItems = new ArrayList<Item>();

//The four orders on screen (emptyOrder can't be interacted with)
Order emptyOrder = new Order(-1,-1);
Order orders[] = {emptyOrder,emptyOrder,emptyOrder,emptyOrder};

//The 15 ingredient buttons
Button buttons[] = new Button[15];
int buttonSpace, buttonHeight;

//Images
PImage forkKnife;
PImage book;
PImage itemImages[] = new PImage[21];
PImage platedImages[] = new PImage[21]; //for when it's on the burger
PImage tubeImage[] = new PImage[2]; //for the stack tube

//HUD Data
float hunger = 100;
int time = 479; //seconds
int cash = 100; //in cents
int satisfaction = 100; //customer satisfaction
float grillRed; //for the grill's
boolean redUp;  //red flashes
boolean lingoScreen = false; //lingo book open

//Timer data
int nextSecond = 0;
int nextOrderTimer = 0;
int nextOrderIndex = 0;

//Ghost word data
ArrayList<GhostWords> words = new ArrayList<GhostWords>();

//Main items, fixings, sauces, exotic veggies, mush and bacon, egg and avocado
int level = 0; //level of unlocks, should start at 0, goes to 1 when game begins
float tab[][] = new float[6][6]; //data for upgrade tabs
String tabText[] = new String[6]; //words on the tabs

//Input mode booleans
boolean gameEnd = false;
boolean wonGame = false;
boolean shutterClosed = false;
boolean typingHighScore = false;

//End of game data
float shutterY = 0;
Score [] highScores = new Score[20];
char qwerty [] = {'Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M','_'};
int typeTimer = 0;
boolean showingScores = false;
String name = "";

//SOUND
SoundFile SFX[] = new SoundFile[3];

//Variables to reduce computation
float stackX, stackY, stackYAdd, stackPicSize;
int burgerBottom, itemSize;

void setup()
{
  fullScreen();
  imageMode(CENTER);
  textAlign(CENTER);
  
  //Set up empty slots
  emptyOrder.empty = true;
  hand.add( emptyItem );
  
  //Program setup
  setVariables();
  loadImages();
  setupButtons();
  setupTabs();
  loadSounds();
  shuffleOrderDelays();
  
  //Scores
  loadGame();
  sortScores();
  saveGame();
}

void draw()
{
  background(150);
  drawMainScreen();
  passTime();
  addNewOrders();
  drawGrillItems();
  for(Order o: orders)
    o.handleOrder();
  drawInfoHud();
  drawLingoScreen();   
  handleGhostWords();
  handleGameOver();
}

void handleGameOver()
{
  //Game Over Items
  if( satisfaction <= 0 )
  {
    gameEnd = true;
    println(calculateScore());
    typeTimer = 3000;
  }
  if( time > 1440 )
  {
    gameEnd = true;
    println(calculateScore());
    typeTimer = 3000;
    wonGame = true;
  }
  if( gameEnd || shutterY > 0 )
  {
    drawShutter();
    if(shutterClosed)
      handleHighScore();
  }
}

void passTime()
{
  if( level > 0 && !gameEnd && secondPassed() ) //checks every second
  {
    time++;
    hunger--;
    nextOrderTimer--;
    if( hunger < 0 )
      hunger = 0;
    checkForRush();
    if( !noFail )
      for( Order o: orders )
        o.lateTime--;
    
    for(int i = 0; i < orders.length; i++)
      if( orders[i].price > 0 && checkForLatePenalties(orders[i]) )
        orders[i] = emptyOrder;
        
    if( nextOrderTimer <=0 )
    {
      futureOrders.add( new Order( int(random(100,40)), orderByLevel() ) );
      nextOrderIndex++;
      if( nextOrderIndex < orderDelays.length )
        nextOrderTimer = orderDelays[nextOrderIndex];
    }
    for( Item i: grillItems )
      i.reduceFreshness(1);
  }
}

void setVariables()
{
  burgerBottom = int(height*16/18);
  itemSize = int(height/4.5);
  buttonSpace = int(width/15);
  buttonHeight = int(height/7);
  stackX = width*8.2/10;
  stackY = height*7/10;
  stackYAdd = height/20;
  stackPicSize = 45;
}

void drawShutter()
{
  if(!gameEnd)
    shutterY-=20;
  else if( shutterY < height+50 )
    shutterY+=20;
    
  fill(150);
  strokeWeight(4);
  stroke(255);
  rect(0,-50, width, shutterY, 50);
  strokeWeight(1);
  fill(100);
  for(int i = int(shutterY-50); i > 0; i-=100) //draw slat lines
    rect(0,i,width,5);
  if( !shutterClosed && !typingHighScore && !showingScores && shutterY >= height+50 ) //this is a gross mess and I know it
  {
    shutterClosed = true;
    typingHighScore = true;
  }
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
  else if( time == 780 ) //lunch at 1
  {
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 90, orderByLevel() ) );
    futureOrders.add( new Order( 100, orderByLevel() ) );
    futureOrders.add( new Order( 110, orderByLevel() ) );
    words.add( new GhostWords( "Lunch Rush!", 100 ) );
  }
  else if( time == 1020 ) //dinner at 5
  {
    futureOrders.add( new Order( 70, orderByLevel() ) );
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 90, orderByLevel() ) );
    futureOrders.add( new Order( 100, orderByLevel() ) );
    futureOrders.add( new Order( 110, orderByLevel() ) );
    words.add( new GhostWords( "Dinner Crowd!", 100 ) );
  }
  else if( time == 1260 ) //bus at 9
  {
    futureOrders.add( new Order( 70, orderByLevel() ) );
    futureOrders.add( new Order( 70, orderByLevel() ) );
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 80, orderByLevel() ) );
    futureOrders.add( new Order( 150, orderByLevel() ) );
    futureOrders.add( new Order( 30, orderByLevel() ) );
    words.add( new GhostWords( "Bus on the lot!", 100 ) );
  }
  else if ( time != 480 && time %100 == 0 )
  {
    futureOrders.add( new Order( 60, orderByLevel() ) );
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
    return int(random(5));
  if( level == 2 )
    return int(random(15));
  if( level == 3 )
    return int(random(5,19));
  if( level == 4 )
    return int(random(5,19));
  if( level == 5 )
    return int(random(10,26));
  else
    return int(random(10,30));
}

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
  itemImages[20] = loadImage("toast.png");   itemImages[20].resize(itemSize,0);
  
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
  platedImages[12] = loadImage("shroom5.png");       platedImages[12].resize(itemSize,0);
  platedImages[13] = loadImage("friedEgg.png");      platedImages[13].resize(itemSize,0);
  platedImages[14] = loadImage("avocadoSlices.png"); platedImages[14].resize(itemSize,0);
  
  platedImages[15] = itemImages[15];
  platedImages[16] = itemImages[16];
  platedImages[17] = itemImages[17];
  platedImages[18] = itemImages[18];
  platedImages[20] = itemImages[20];
  
  tubeImage[0] = loadImage("tubeT.png");  tubeImage[0].resize(75,0);
  tubeImage[1] = loadImage("tubeB.png");  tubeImage[1].resize(75,0);

  forkKnife = loadImage("forkKnife.png"); forkKnife.resize(100,0);
  book = loadImage("lingo.png");          book.resize(100,0);
}

void keyPressed() //for debugging
{
  //satisfaction -= 5;
  //time = 1439;
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
  if(!lingoScreen) return;
  
  strokeWeight(9);
  stroke(200,230);
  fill(100,230);
  rect(width/20,height/18,width*18/20,height*16/18);
  image( book, width*9.6/10, height*1.37/7 );
  fill(0);
  textSize(37);
  textAlign(LEFT);
  String lingoText = "";
  lingoText += "Alligator Pear - - Avocado\n";
  lingoText += "Bad Breath - - Onions\n";
  lingoText += "Belt - - BLT\n";
  lingoText += "Big Breakfast - - Bacon, Egg, Cheese, Toast\n";
  lingoText += "Big Red - - Katchup and Tomato\n";
  lingoText += "BLT - - Bacon, Lettuce, Tomato\n";
  lingoText += "Burn it - - Well Done\n";
  lingoText += "Cackleberries - - Eggs\n";
  lingoText += "Cowcumber - - Pickles\n";
  lingoText += "Deluxe - - Lettuce and Tomato\n";
  lingoText += "Double - - Two Patties\n";
  lingoText += "Drag it through Wisconson - - Cheese\n";
  lingoText += "Eggwich - - Eggs on toast\n";
  lingoText += "Fungal Infection - - Mushrooms\n";
  lingoText += "Garden Burger - - Lettuce and Tomato\n";
  lingoText += "Goat - - Everything on it\n";
  lingoText += "Green Machine - - Lettuce, Pickle, Avocado\n";
  lingoText += "Green - - Lettuce\n";
  lingoText += "Hemorrage - - Katchup\n";
  lingoText += "Hockey Puck - - Well Done\n";
  lingoText += "Jack Benny - - Grilled Cheese with Bacon\n";
  text(lingoText,width/16,height/10);
  
  lingoText  = "Jack Tommy - - Grilled Cheese with Tomato\n";
  lingoText += "Love Apple - - Tomato\n";
  lingoText += "Make it Cry - - Onions\n";
  lingoText += "Make it Oink - - Bacon\n";
  lingoText += "Mississippi Mud - - Mustard\n";
  lingoText += "Mouse Trap - - Grilled Cheese\n";
  lingoText += "On the Hoof - - Rare\n";
  lingoText += "On a Raft - - On Toast\n";
  lingoText += "Paint it - - Add sauce\n";
  lingoText += "Peel it off the Wall - - Lettuce\n";
  lingoText += "Pigs - - Bacon\n";
  lingoText += "Rabbit Food - - Lettuce\n";
  lingoText += "Sauce Rainbow - - All three sauces\n";
  lingoText += "Single - - One Patty\n";
  lingoText += "Soggy - - All three sauces\n";
  lingoText += "Still Mooing - - Rare\n";
  lingoText += "Super Cheese - - Two Cheese\n";
  lingoText += "The Works - - Everything on it\n";
  lingoText += "Tripple - - Three Patties\n";
  lingoText += "Tripple 'merica - - Three Patties, Three Cheese, Three Bacon\n";
  lingoText += "Wax - - Cheese\n";
  text(lingoText,width*.45,height/10);
  textAlign(CENTER);
}

void drawMainScreen()
{
  fill(150);
  strokeWeight(4);
  stroke(255);
  rect(0,0,width,height/7);
  //rect(0,height/7,width*4/5,height*1.5/7);
  rect(0,height*2.25/7,width*4/5,height*4.75/7);
  fill(200);
  circle(width*19.5/20,height*9.5/10,100);
  for( int i = 0; i < 17; i++ )
    circle( width/15*i+width/32, height/14, 100 );
  drawPlates();
  drawGrill();
  drawCurrentItem();  
  for(Button b: buttons)
    b.drawButton();
  if( tab[1][5] > -buttonHeight*2 )
    moveAndDrawUnlockTabs();
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
  if( grillRed > 100 )
    redUp = false;
  if( grillRed < 0 )
    redUp = true;
}

void drawCurrentItem()
{
  textSize(50);
  fill(0);
  if( hand.size() > 0 )
    text(hand.get(0).toString(), width*18/20, height*6.5/10);
  
  //Stacked Items
  image( tubeImage[0], stackX, height-32 );
  strokeWeight(4);
  stroke(255);
  fill(200);
  for( int i = 1; i < hand.size()-1; i++ )
  {
    circle( width*8.2/10, height*7/10+(height/20*i), 50 );
    image( hand.get(i).itemPic(), stackX, stackY+stackYAdd*i, stackPicSize, stackPicSize );
  }
  image( tubeImage[1], stackX, height-32 );
  circle(width*18.25/20,height*8/10,height/3.5);
  //if( selectedItem != null )
  if( hand.size() > 0 && hand.get(0) != null )
    image( hand.get(0).itemPic() /*selectedItem.itemPic()*/, width*18.25/20,height*8/10, height/3.5, height/3.5);
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
    case TOP_BUN:
    case BOTTOM_BUN:return 20;
    case TOAST:     return 25;
    case PATTY:     return -10;
    case KATCHUP:   return 5;
    case LETTUCE:
    case TOMATO:    return 20;
    case CHEESE:    return 40;
    case MUSTARD:   return 5;
    case MAYO:      return 10;
    case PICKLE:    return 25;
    case ONION:     return 15;
    case BACON:     return 40;
    case SHROOM:    return 25;
    case EGG:       return 20;
    case AVOCADO:   return 30;
  
    case RARE:      return 65;
    case MEDIUM:    return 75;
    case WELL_DONE: return 65;
  
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

int clickedTicket()
{
  for(int i = 0; i < 4; i++)
  {
    if( mouseX > (i+1)*width/5-125 && mouseX < (i+1)*width/5+25 && mouseY > height*2.25/7 && mouseY < height*2.25/7+240 )
      return i;
  }
  return -1;
}

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
  if( cash/100 >= level*2 )
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
    satisfaction = min( 100, satisfaction+1 );
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
    return "Prompt Service!  +1";
}

int checkDeviation( int index )
{
  int result = 0;
  for( Item i: orders[index].plate )
  {
    result += dist( i.xPos, 0, index*(width/5)+(width/10), 0 );
  }
  return result/15;
}

void mousePressed() //recently changed this to allow stacking held items
{                    //some messy bits still remain
  if( !gameEnd )
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
        for( Item i: orders[ticket].plate )
          if( i.type == Type.RUINED )
          {
            satisfaction -= 5;
            words.add( new GhostWords( width/5*(ticket+1), height/(random(2)), "Ruined Food   -5", 75 ) );
          }
        orders[ticket] = emptyOrder;
      }
      else
      {
        words.add( new GhostWords( width/5*(ticket+1), height/2, "MISTAKE", 100 ) );
        satisfaction-=5;
        orders[ticket].plate.remove(orders[ticket].plate.size()-1);
        orders[ticket].finished = false;
      }
    }
    else// if( /*selectedItem*/ hand.get(0) == emptyItem ) //Clicking buttons with empty inventory
    {
      for( Button b: buttons )
        if( b.onButton() && b.unlocked() )  //GET NEW ITEM
        {
          hand.add( 0, b.getItem() );
          cash -= hand.get(0)/*selectedItem*/.price;
        }
      if( level < 6 && mouseY < buttonHeight && mouseX > tab[0][level] ) //UPGRADE
      {
        attemptUpgrade();
      }
      for( int i = 0; i < grillItems.size(); i++ ) //GRAB ITEM OFF GRILL
      {
        if( mouseY > height/7 && dist( mouseX, mouseY, grillItems.get(i).xPos, grillItems.get(i).yPos ) < itemSize )
        {
          hand.add( 0,  grillItems.get(i) );
          grillItems.remove(i);
          return; // <- stop-gap
        }
      }
      if( mouseY > height*2.25/7 && mouseX < width*4/5 )  //DUMP OR TAKE FROM TOP
      {
        if( mouseY > height*19/20) //dump order
        { 
          orders[int(mouseX/( width/5 ))].dumping = true;
        }
        else if( hand.size() == 1 && orders[int(mouseX/( width/5 ))].plate.size() > 0 ) // if( orders[int(mouseX/( width/5 ))].plate.get(orders[int(mouseX/( width/5 ))].plate.size()-1).touchable() )
        {
          hand.add( 0, orders[int(mouseX/( width/5 ))].plate.remove(orders[int(mouseX/( width/5 ))].plate.size()-1) );
          if( hand.get(0).type == Type.TOP_BUN || hand.get(0).type == Type.TOAST )
            orders[int(mouseX/( width/5 )) ].finished = false;
          return; // <- stop-gap
        }
        else if( orders[int(mouseX/( width/5 ))].finished  ) //removing top bun of finished item
        {
          hand.add( 0, orders[int(mouseX/( width/5 ))].plate.remove(orders[int(mouseX/( width/5 ))].plate.size()-1) );
          orders[int(mouseX/( width/5 )) ].finished = false;
          return;
        }
      }
      if( hand.size() > 1 && dist(mouseX,mouseY,width*19.5/20,height*9.5/10) < 350 ) //consume held item
      {
        eat( nutrition( hand.get(0).type ), hand.get(0).type );
        //selectedItem = emptyItem;
        hand.remove(0);
      }
      else if( mouseY > height*2.25/7 && mouseX < width*4/5) //clicked in order area
      { 
        if( mouseY > height*19/20 ) //dumped an order
        {
          orders[int(mouseX/( width/5 ))].dumping = true;
        }
        else if( hand.size() > 1 && !orders[int(mouseX/( width/5 ))].empty && !orders[int(mouseX/( width/5 ))].dumping && !orders[int(mouseX/( width/5 ))].finished ) // <- ADD ITEM
        {
          hand.get(0).xPos = mouseX;
          orders[int(mouseX/( width/5 ))].plate.add( /*selectedItem*/ hand.remove(0) );
        }
      }
      else if( mouseY > height/7 && mouseY < height*2/7 && mouseX < width*4/5 ) //clicked on grill
      {
        if( hand.size() > 1 && grillSpaceAvailable( mouseX, mouseY ) )
        {
          grillItems.add( new Item( hand.remove(0), mouseX, mouseY ) );
        }
      }
    }
    
    if( dist(mouseX,mouseY,width*9.6/10, height*1.37/7) < 100 )
      lingoScreen = !lingoScreen;
  }
  else //in game over mode
  {
    if( showingScores && mouseX > width-150 && mouseY > height-150 )
      reset();
  
    if(typingHighScore)
    {
      char letter = checkForLetter();
      if( letter == ' ' )
        return;
      else if( letter == '-' && name.length() > 0 )
        name = name.substring(0,name.length()-1);
      else if( letter == '=' && name.length() > 0 )
      {
        typingHighScore = false; //<>//
        showingScores = true;
        highScores[highScores.length-1] = new Score( name, calculateScore() );
        sortScores();
        saveGame();
      }
      else if( letter == '_' )
        name += ' ';
      else
        name += letter;
    }
  }
}

void reset()
{
  shuffleOrderDelays();
  hand.clear();
  hand.add( emptyItem );
  grillItems.clear();
  futureOrders.clear();
  orders[0]=orders[1]=orders[2]=orders[3]=emptyOrder;
  hunger = 100;
  time = 479; //seconds
  cash = 100; //in cents
  satisfaction = 100; //customer satisfaction

  nextSecond = 0;
  nextOrderTimer = 0;
  nextOrderIndex = 0;
  lingoScreen = false;
  gameEnd = false;
  wonGame = false;
  typingHighScore = false;
  showingScores = false;
  shutterClosed = false;
  name = "";
  
  level = 0;
  setupTabs();
}

//***********************HIGH SCORE STUFF****************************//
void displayScores()
{
  fill(0,0,0);
  textSize(height/20);
  tint(255);
  for( int i = 0; i < 10; i++ )
  {
    textAlign(RIGHT);
    text(highScores[i].name+"   ",width/2,height/11.0*(i+1));
    textAlign(LEFT);
    text("   "+highScores[i].points,width/2,height/11.0*(i+1));
    image( scoreImage( i ), width/2, height/11.0*(i+1)-20, 50,50 );
  }
  push();
  noFill();
  stroke(0,0,0);
  strokeWeight(5);
  textSize(30);
  textAlign(CENTER);
  rect(width-75,height-75,150,150);
  text("NEW\nGAME",width-75,height-85);
  pop();
}

PImage scoreImage( int i )
{
  switch(i)
  {
    case 0:  return platedImages[0];
    case 1:  return platedImages[10];
    case 2:  return platedImages[5];
    case 3:  return platedImages[4];
    case 4:  return platedImages[8];
    case 5:  return platedImages[11];
    case 6:  return platedImages[6];
    case 7:  return platedImages[16];
    case 8:  return platedImages[9];
    default: return platedImages[1];
  }
}

char checkForLetter()
{
  for( int i = 0; i < 10; i++ )
    if( dist( mouseX, mouseY, 510+i*100, 760 ) < 50 )
      return qwerty[i];
  for( int i = 0; i < 9; i++ )
    if( dist( mouseX, mouseY, 560+i*100, 860 ) < 50 )
      return qwerty[i+10];
  for( int i = 0; i < 8; i++ )
    if( dist( mouseX, mouseY, 610+i*100, 960 ) < 50 )
      return qwerty[i+19];
      
  if( dist(mouseX,mouseY, width/6,height*4/5) < 75 )
    return '-';   
  if( dist(mouseX,mouseY, width*5/6,height*4/5) < 75 )
    return '=';
      
  return ' ';
}

void sortScores()
{
  int highestScore;
  int highestIndex;
  Score tempScores[] = new Score[highScores.length];
  println(highScores.length);
  for(int i = 0; i < highScores.length; i++)
  {
    highestScore = 0;
    highestIndex = 0;
    for( int j = 0; j < highScores.length; j++)
    {
      println(j);
      if( highScores[j].points > highestScore )
      {
        highestScore = highScores[j].points;
        highestIndex = j;
      }
    }
    tempScores[i] = highScores[highestIndex];
    highScores[highestIndex] = new Score();
  }
  
  highScores = tempScores;
}

void handleHighScore()
{
  rectMode(CENTER);
  if( !showingScores && millis() > typeTimer )
  {
    if( cash > highScores[highScores.length-1].points )
      typingHighScore = true;
    else
      showingScores = true;
  }
  if( shutterClosed && typingHighScore)
  {
    drawQwerty();
    drawScore();
  }
  else if(showingScores)
    displayScores();

  rectMode(CORNER);
}

int calculateScore()
{
  int result = cash*10;  //1000 points for every dollar
  result += 15000 * ( satisfaction/100.0 ); //up to 10000 for cusutomer satisfaction
  result += (level-1) * 5000; //5000 points per upgrade level
  int timeBonus = (time-480)*10;
  if( time >= 1440 )
    timeBonus = 15000;
  result += timeBonus; 
  return result;
}

void drawScore()
{
  push();
  textSize(50);
  fill(0);
  text("Score: " + calculateScore(),width/2,height*0.42);
  text("Cash: " + cash*10,width/3,height*0.52);
  text("Yelp Review: " + int(10000 * ( satisfaction/100.0 )),width/3,height*0.62);
  if( time >= 1440 )
    text("Time: 10000",width*2/3,height*0.52);
  else
    text("Time: " + (time - 480)*10,width*2/3,height*0.52);
  text("Upgrades: " + (level-1) * 5000,width*2/3,height*0.62);
  textSize(100);
  if(wonGame)
    text("CLOSING TIME!",width/2,height/6);
  else
    text("SHUT DOWN by order of FDA",width/2,height/6);
  pop();
}

void drawQwerty()
{
  fill(0);
  textSize(60);
  text(name+"_",width/2,height/3);
  textSize(30);
  for(int i = 0; i < 27; i++)
  {
    //noFill();
    strokeWeight(4);
    fill(150);
    stroke(180);
    if( i < 10 )
    {
      rect( width/2+50-(5*100)+(100*i), (height*2/3)+40, 90, 90);
      fill(0,0,0);
      text( qwerty[i], width/2+50-(5*100)+(100*i), (height*2/3)+50 );
    }
    else if( i < 19 )
    {
      rect( width/2+50-(4.5*100)+(100*(i-10)), (height*2/3)+140, 90, 90);
      fill(0,0,0);
      text( qwerty[i], width/2+50-(4.5*100)+(100*(i-10)), (height*2/3)+150 );
    }
    else
    {
      rect( width/2+50-(4*100)+(100*(i-19)), (height*2/3)+240, 90, 90);
      fill(0,0,0);
      text( qwerty[i], width/2+50-(4*100)+(100*(i-19)), (height*2/3)+250 );
    }
  }
  strokeWeight(4);
  fill(150);
  stroke(180);
  rect(width/6,height*4/5,200,100);
  rect(width*5/6,height*4/5,200,100);
  fill(0);
  text("DELETE",width/6,height*4/5+10);
  text("ENTER",width*5/6,height*4/5+10);
}

//***********************FILE I/O****************************//
void saveGame()
{
  try
  {
    PrintWriter pw = createWriter( "highScores.txt" );
    for(int i = 0; i < highScores.length; i++)
    {
      pw.println( highScores[i].name );
      pw.println( highScores[i].points );
    }
    
    pw.flush(); //Writes the remaining data to the file
    pw.close(); //Finishes the file
  }
  catch(Exception e)
  {
    println("SOMETHING WENT WRONG");
  }
}

void loadGame()
{
  int i = 0;
  String [] data;
  try
  {
    data = loadStrings("highScores.txt");
    for(; i < data.length; i+=2)
    {
      highScores[i/2] = new Score( data[i], Integer.parseInt(data[i+1]) );
    }
  }
  catch(Exception e)
  {
    println("SOMETHING WENT WRONG");
  }
  for(; i < highScores.length; i++)
    highScores[i] = new Score();
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
  TOAST,      //20
  
  NONE
}
