//The assembled orders

class Order
{
  String name;
  int timer, lateTime;
  //int yCenter = 0; //where bottom bun is dropped
  boolean dumping = false;
  boolean finished = false;
  boolean empty = false;
  int doneness = -1; //-1 no beef / 0 - rare / 1 - medium / 2 - well
  int price = 0;
  
  ArrayList<Type> reqs = new ArrayList<Type>();  //requirements
  ArrayList<Item> plate = new ArrayList<Item>(); //items on plate
  
  public Order( int time, int num )
  {
    reqs.add( Type.TOP_BUN );
    reqs.add( Type.BOTTOM_BUN );
    
    lateTime = time;
    
    addItemsByOrder( num );
    if( num != -1 )
    {
      determineDoneness();
      addExtra();
      changePattiesByDoneness();
    }
  }
  
  //******Requirements******
  
  void addItemsByOrder( int order )
  {
    switch( order )
    {
      case -1:
        name = "NONE";
        price = 0;
        break;
      
      //LEVEL 1 (buns, patty, katchup)
      case 0:
        name = "Single";
        price = 100;
        reqs.add( Type.PATTY );
        break;
      case 1:
        name = "Double";
        price = 150;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        break;
      case 2:
        name = "Single with katchup";
        price = 110;
        reqs.add( Type.PATTY );
        reqs.add( Type.KATCHUP );
        break;
      case 3:
        name = "Burger on toast";
        price = 150;
        replaceWithToast();
        reqs.add( Type.PATTY );
        break;
      case 4:
        name = "Single";
        price = 100;
        reqs.add( Type.PATTY );
        break;
        
      //LEVEL 2 (lettuce, tomato, cheese)
      
      case 5:
        name = "Garden burger";
        price = 175;
        reqs.add( Type.PATTY );
        reqs.add( Type.LETTUCE );
        reqs.add( Type.TOMATO );
        break;
      case 6:
        name = "Green single";
        price = 150;
        reqs.add( Type.PATTY );
        reqs.add( Type.LETTUCE );
        break;
      case 7:
        name = "Big red double";
        price = 185;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.TOMATO );
        reqs.add( Type.KATCHUP );
        break;
      case 8:
        name = "Cheeseburger";
        price = 175;
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        break;
      case 9:
        name = "Cheeseburger deluxe";
        price = 225;
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.LETTUCE );
        reqs.add( Type.TOMATO );
        break;
      case 10:
        name = "Super cheesey double";
        price = 250;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.CHEESE );
        break;
      case 11:
        name = "Tripple cheeseburger deluxe";
        price = 325;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.LETTUCE );
        reqs.add( Type.TOMATO );
        break;
      case 12:
        if( int( random(4) ) > 0 )
          name = "Grilled Cheese";
        else
          name = "Mouse Trap";
        price = 150;
        replaceWithToast();
        reqs.add( Type.CHEESE );
        break;
      case 13:
        name = "Super Grilled Cheese";
        price = 190;
        replaceWithToast();
        reqs.add( Type.CHEESE );
        reqs.add( Type.CHEESE );
        break;      
      case 14:
        name = "Jack Tommy";
        price = 175;
        replaceWithToast();
        reqs.add( Type.CHEESE );
        reqs.add( Type.TOMATO );
        break;
        
      //Level 3 (mustard, mayo)
        
      case 15:
        name = "Sauce rainbow tripple";
        price = 300;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.KATCHUP );
        reqs.add( Type.MUSTARD );
        reqs.add( Type.MAYO );
        break;
      case 16:
        name = "Single with mustard";
        price = 115;
        reqs.add( Type.PATTY );
        reqs.add( Type.MUSTARD );
        break;
      case 17:
        name = "Single with mayo";
        price = 120;
        reqs.add( Type.PATTY );
        reqs.add( Type.MAYO );
        break;
      case 18:
        name = "Soggy single";
        price = 150;
        reqs.add( Type.PATTY );
        reqs.add( Type.KATCHUP );
        reqs.add( Type.MUSTARD );
        reqs.add( Type.MAYO );
        break;
        
      //Level 4 (pickle, onion)
        
        
      //Level 5 (bacon, mushroom)
      
      case 19:
        name = "Bacon cheeseburger";
        price = 250;
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        break;
      case 20:
        name = "Double bacon cheeseburger";
        price = 300;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        break;
      case 21:
        name = "Tripple bacon cheeseburger";
        price = 350;
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        break;
      case 22:
        name = "Tripple 'merica burger";
        price = 500;
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        reqs.add( Type.PATTY );
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        break;
      case 23:
        name = "Jack Benny";
        price = 200;
        replaceWithToast();
        reqs.add( Type.CHEESE );
        reqs.add( Type.BACON );
        break;
      case 24:
        if( int(random(3))==0 )
          name = "Toasty Belt";
        else
          name = "Toasted BLT";
        price = 250;
        replaceWithToast();
        reqs.add( Type.LETTUCE );
        reqs.add( Type.TOMATO );
        reqs.add( Type.BACON );
        break;
      case 25:
        name = "BLT on toast";
        price = 250;
        replaceWithToast();
        reqs.add( Type.LETTUCE );
        reqs.add( Type.TOMATO );
        reqs.add( Type.BACON );
        break;
        
      //Level 6 (egg, avocado)
      
      case 26:
        name = "Big breakfast sandwich";
        price = 350;
        replaceWithToast();
        reqs.add( Type.EGG );
        reqs.add( Type.BACON );
        reqs.add( Type.CHEESE );
        break;
      case 27:
        name = "Eggwich";
        price = 200;
        replaceWithToast();
        reqs.add( Type.EGG );
        break;
      case 28:
        name = "Green machine";
        price = 300;
        reqs.add( Type.LETTUCE );
        reqs.add( Type.PICKLE );
        reqs.add( Type.AVOCADO );
        break;
      case 29:
        if( int(random(3))>0 )
          name = "The works";
        else
          name = "The goat";
        price = 800;
        reqs.add( Type.PATTY );
        reqs.add( Type.KATCHUP );
        reqs.add( Type.LETTUCE );
        reqs.add( Type.TOMATO );
        reqs.add( Type.CHEESE );
        reqs.add( Type.MUSTARD );
        reqs.add( Type.MAYO );
        reqs.add( Type.PICKLE );
        reqs.add( Type.ONION );
        reqs.add( Type.BACON );
        reqs.add( Type.SHROOM );
        reqs.add( Type.EGG );
        reqs.add( Type.AVOCADO );
        break;
        
      default: //empty order
        break;
    }
  }
  
  void replaceWithToast()
  {
    for( int i = 0; i < reqs.size(); i++ )
      if( reqs.get(i) == Type.TOP_BUN || reqs.get(i) == Type.BOTTOM_BUN )
        reqs.set(i,Type.TOAST);
  }
  
  void addExtra()
  {
    int rand = max( int(random(-15,4)),int(random(-15, 4))); //-15 to 3
    if ( level >= 2 ) rand += 3; //= min( rand, 3 );
    if ( level >= 3 ) rand += 2; //= min( rand, 6 );
    if ( level >= 4 ) rand += 2; //= min( rand, 8 );
    if ( level >= 5 ) rand += 2; //= min( rand, 10 );
    if ( level == 6 ) rand += 2; //= min( rand, 12 );
    int rand2 = int(random(4));
    
    switch( rand )
    {
      case 0: //top bun
        break;
      case 1: //toasted bun
        for( Type t: reqs ) //<>//
          if( t == Type.TOAST ) // <- don't sub toast if it's already toast
            return;
        if(rand2==0)name += "\n\non toast";
        if(rand2==1)name += "\n\ntoasted buns";
        if(rand2==2)name += "\n\non toast";
        if(rand2==3)name += "\n\non a raft";
        price += 50;
        for( int i = 0; i < reqs.size(); i++ )
        {
          if( reqs.get(i) == Type.TOP_BUN || reqs.get(i) == Type.BOTTOM_BUN )
            reqs.set(i,Type.TOAST);
        }
        break;
      case 2: //patty
        boolean hasBeef = false;
        for( Type t: reqs )
          if( t == Type.PATTY )
          {
            hasBeef = true;
            break;
          }
        if(!hasBeef)
          return;
        if(rand2==0)name += "\n\nextra beef";
        if(rand2==1)name += "\n\nextra meat";
        if(rand2==2)name += "\n\nextra beef";
        if(rand2==3)name += "\n\nextra cow";
        price += 30;
        reqs.add( Type.PATTY );
        break;
      case 3: //katchup
        if(rand2==0)name += "\n\nadd katchup";
        if(rand2==1)name += "\n\npaint it red";
        if(rand2==2)name += "\n\nhemorrhage";
        if(rand2==3)name += "\n\nadd katchup";
        price += 10;
        reqs.add( Type.KATCHUP );
        break;
      case 4: //lettuce
        if(rand2==0)name += "\n\nadd lettuce";
        if(rand2==1)name += "\n\npeel it off the wall";
        if(rand2==2)name += "\n\nrabbit food";
        if(rand2==3)name += "\n\nadd lettuce";
        price += 20;
        reqs.add( Type.LETTUCE );
        break;
      case 5: //tomato
        if(rand2==0)name += "\n\nadd tomato";
        if(rand2==1)name += "\n\nadd tomato";
        if(rand2==2)name += "\n\nextra love apple";
        if(rand2==3)name += "\n\nadd tomato";
        price += 30;
        reqs.add( Type.TOMATO );
        break;
      case 6: //cheese
        if(rand2==0)name += "\n\nadd cheese";
        if(rand2==1)name += "\n\nadd cheese";
        if(rand2==2)name += "\n\nwith wax";
        if(rand2==3)name += "\n\ndrag it through Wisconsin";
        price += 40;
        reqs.add( Type.CHEESE );
        break;
      case 7: //mustard
        if(rand2==0)name += "\n\nadd mustard";
        if(rand2==1)name += "\n\nadd mustard";
        if(rand2==2)name += "\n\npaint it yellow";
        if(rand2==3)name += "\n\nMississippi mud";
        price += 15;
        reqs.add( Type.MUSTARD );
        break;
      case 8: //mayo
        if(rand2==0)name += "\n\npaint it white";
        if(rand2==1)name += "\n\nadd mayo";
        if(rand2==2)name += "\n\nadd mayonase";
        if(rand2==3)name += "\n\nadd mayo";
        price += 20;
        reqs.add( Type.MAYO );
        break;
      case 9: //pickle
        if(rand2==0)name += "\n\nadd pickle";
        if(rand2==1)name += "\n\nadd pickles";
        if(rand2==2)name += "\n\ncowcumber";
        if(rand2==3)name += "\n\ndon't forget the pickles!";
        price += 40;
        reqs.add( Type.PICKLE );
        break;
      case 10: //onion
        if(rand2==0)name += "\n\nadd onion";
        if(rand2==1)name += "\n\nadd onions";
        if(rand2==2)name += "\n\nmake it cry";
        if(rand2==3)name += "\n\nbad breath";
        price += 40;
        reqs.add( Type.ONION );
        break;
      case 11: //bacon
        if(rand2==0)name += "\n\nadd bacon";
        if(rand2==1)name += "\n\nadd bacon";
        if(rand2==2)name += "\n\nmake it oink";
        if(rand2==3)name += "\n\nwith pigs";
        price += 200;
        reqs.add( Type.BACON );
        break;
      case 12: //shroom
        if(rand2==0)name += "\n\nadd mush";
        if(rand2==1)name += "\n\nadd mushrooms";
        if(rand2==2)name += "\n\nadd shrooms";
        if(rand2==3)name += "\n\nfungal infection";
        price += 125;
        reqs.add( Type.SHROOM );
        break;
      case 13: //egg
        if(rand2==0)name += "\n\nsomething eggstra";
        if(rand2==1)name += "\n\nadd a fried egg";
        if(rand2==2)name += "\n\nadd egg";
        if(rand2==3)name += "\n\ncackleberries";
        price += 125;
        reqs.add( Type.EGG );
        break;
      case 14://avocado
        if(rand2==0)name += "\n\nadd avocado";
        if(rand2==1)name += "\n\nadd avocado";
        if(rand2==2)name += "\n\nadd alligator pear";
        if(rand2==3)name += "\n\nadd avocados";
        price += 300;
        reqs.add( Type.AVOCADO );
        break;
        
    }
  }
  
  void determineDoneness()
  {
    for( Type t: reqs )
      if( t == Type.PATTY )
      {
        doneness = int(random(3));
        break;
      }
    name += donenessMessage(doneness);
  }
  
  String donenessMessage( int d )
  {
    int rand = int(random(5));
    switch(d)
    {
      case 0:
        if(rand==0) return "\n\nrare";
        if(rand==1) return "\n\nrare";
        if(rand==2) return "\n\non the hoof";
        if(rand==3) return "\n\nstill mooing";
        if(rand==4) return "\n\nlet him chew it";
      case 1:
        if(rand==0) return "\n\nmedium";
        if(rand==1) return "\n\nmedium";
        if(rand==2) return "\n\nmedium";
        if(rand==3) return "\n\nmedium";
        if(rand==4) return "\n\nmedium";
      case 2:
        if(rand==0) return "\n\nwell done";
        if(rand==1) return "\n\nwell done";
        if(rand==2) return "\n\nhockey puck";
        if(rand==3) return "\n\nwell done";
        if(rand==4) return "\n\nburn it";
      default: return "";
    }
  }
  
  void changePattiesByDoneness()
  {
    for( int i = 0; i < reqs.size(); i++ )
    {
      if( reqs.get(i) == Type.PATTY )
      {
        if( doneness == 0 )
          reqs.set(i, Type.RARE);
        if( doneness == 1 )
          reqs.set(i, Type.MEDIUM);
        if( doneness == 2 )
          reqs.set(i, Type.WELL_DONE);
      }
    }
  }
  
  //******Plate******
  
  void handleOrder()
  {
    checkForBuns();
    shiftItemsDown();
    drawPlate();
  }
  
  void checkForBuns()
  {
    if( plate.size() == 1 && ( plate.get(0).type != Type.BOTTOM_BUN && plate.get(0).type != Type.TOAST ) )
      dumping = true;
    else if( plate.size() > 0 && ( plate.get(plate.size()-1).type == Type.TOP_BUN || ( plate.size() > 1 && plate.get(0).type == Type.TOAST && plate.get(plate.size()-1).type == Type.TOAST ) ) )
      finished = true;
  }
  
  void drawPlate() //doesn't actually draw the plate itself, just the items on it
  {
    for(Item i: plate)
      image( i.platedPic(), i.xPos, i.yPos );
  }
  
  void shiftItemsDown()
  {
    if(!dumping)
      for(int i = plate.size()-1; i >= 0; i-- )
      {
        if( plate.get(i).yPos < burgerBottom - i*40 )
          plate.get(i).yPos+=16;
        if( /*plate.get(i).type == Type.TOP_BUN && plate.size() > 1*/ finished && i > 0 && plate.get(i).yPos < burgerBottom - i*40 )
          plate.get(i).yPos = min(plate.get(i).yPos+32,plate.get(i-1).yPos);
        else if( plate.get(i).yPos > burgerBottom - i*40 )
          plate.get(i).yPos--;
      }
    else //dumping items
    {
      for(int i = 0; i < plate.size(); i++)
        plate.get(i).yPos+=30;
      if( ( plate.size() > 0 && plate.get(plate.size()-1).yPos > height*1.2) || plate.size() == 0 ) //reset order
      {
        plate.clear();
        dumping = false;
        finished = false;
      }
    }
  }
  
  String priceString()
  {
    String dollars = ""+price/100;
    String cents = ""+price%100;
    if( cents.length() < 2 )
      cents = "0"+cents;
    return "$"+dollars+"."+cents;
  }
  
  boolean checkOrder()
  { 
    //for( Type t: reqs )
    //  println(t);
    //for( Item i: plate )
    //  println(i.type);
    ArrayList<Type> tempReq = new ArrayList<Type>();
    tempReq.addAll(reqs);
    
    for( Item t: plate )
      tempReq.remove(t.type);

    if( tempReq.size() > 0 )
      return false;
        
    return true;
  }
  
  String hungryVersion()
  {
    char [] result = name.toCharArray();
    
    if( hunger > 60 )
      return name;
    if( hunger < 60 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'u' ) result[i] = 'o';
    if( hunger < 50 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'i' ) result[i] = 'a';
    if( hunger < 40 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'e' ) result[i] = 'o';
    if( hunger < 30 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'b' ) result[i] = 'g';
    if( hunger < 25 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'r' ) result[i] = 'm';
    if( hunger < 20 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'l' ) result[i] = ' ';
    if( hunger < 15 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 'h' ) result[i] = ' ';
    if( hunger < 10 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 't' ) result[i] = ' ';
    if( hunger < 5 )
      for( int i = 0; i < result.length; i++ )
        if( result[i] == 's' ) result[i] = ' ';
      
    return new String(result);
  }
}
