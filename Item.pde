//Individual ingredients

class Item
{
  float xPos, yPos;
  int price = 0;

  Type type;
  int freshness; //mostly for cooking patties

  public Item( int t )
  {
    type = determineType(t);

    freshness = determineFreshness();
    price = determinePrice();
  }

  public Item( Item i, float x, float y )
  {
    xPos = x;
    yPos = y;
    type = i.type;
    freshness = i.freshness;
    price = i.price;
  }

  void reduceFreshness( int amount )
  {
    freshness-= amount;
    if (freshness <= 0)
    {
      switch(type)
      {
      case TOP_BUN:
      case BOTTOM_BUN:
        type = Type.TOAST;
        freshness = 5;
        break;
      case PATTY:
        type = Type.RARE;
        freshness = 5;
        break;
      case RARE:
        type = Type.MEDIUM;
        freshness = 5;
        break;
      case MEDIUM:
        type = Type.WELL_DONE;
        freshness = 7;
        break;
      default:
        type = Type.RUINED;
      }
    }
  }

  PImage itemPic()
  {
    switch(type)
    {
    case TOP_BUN:
      return itemImages[0];
    case BOTTOM_BUN:
      return itemImages[1];
    case PATTY:
      return itemImages[2];
    case KATCHUP:
      return itemImages[3];
    case LETTUCE:
      return itemImages[4];
    case TOMATO:
      return itemImages[5];
    case CHEESE:
      return itemImages[6];
    case MUSTARD:
      return itemImages[7];
    case MAYO:
      return itemImages[8];
    case PICKLE:
      return itemImages[9];
    case ONION:
      return itemImages[10];
    case BACON:
      return itemImages[11];
    case SHROOM:
      return itemImages[12];
    case EGG:
      return itemImages[13];
    case AVOCADO:
      return itemImages[14];

    case RARE:
      return itemImages[15];
    case MEDIUM:
      return itemImages[16];
    case WELL_DONE:
      return itemImages[17];
    case RUINED:
      return itemImages[18];
    case TOAST:
      return itemImages[20];

    default:
      return itemImages[19];
    }
  }

  PImage platedPic()
  {
    switch(type)
    {
    case TOP_BUN:
      return platedImages[0];
    case BOTTOM_BUN:
      return platedImages[1];
    case PATTY:
      return platedImages[2];
    case KATCHUP:
      return platedImages[3];
    case LETTUCE:
      return platedImages[4];
    case TOMATO:
      return platedImages[5];
    case CHEESE:
      return platedImages[6];
    case MUSTARD:
      return platedImages[7];
    case MAYO:
      return platedImages[8];
    case PICKLE:
      return platedImages[9];
    case ONION:
      return platedImages[10];
    case BACON:
      return platedImages[11];
    case SHROOM:
      return platedImages[12];
    case EGG:
      return platedImages[13];
    case AVOCADO:
      return platedImages[14];

    case RARE:
      return platedImages[15];
    case MEDIUM:
      return platedImages[16];
    case WELL_DONE:
      return platedImages[17];
    case RUINED:
      return platedImages[18];
    case TOAST:
      return platedImages[20];

    default:
      return platedImages[19];
    }
  }

  Type determineType(int i)
  {
    switch(i)
    {
    case 0:
      return  Type.TOP_BUN;
    case 1:
      return  Type.BOTTOM_BUN;
    case 2:
      return  Type.PATTY;
    case 3:
      return  Type.KATCHUP;
    case 4:
      return  Type.LETTUCE;
    case 5:
      return  Type.TOMATO;
    case 6:
      return  Type.CHEESE;
    case 7:
      return  Type.MUSTARD;
    case 8:
      return  Type.MAYO;
    case 9:
      return  Type.PICKLE;
    case 10:
      return Type.ONION;
    case 11:
      return Type.BACON;
    case 12:
      return Type.SHROOM;
    case 13:
      return Type.EGG;
    case 14:
      return Type.AVOCADO;

    case 18:
      return Type.RUINED;
    case 20:
      return Type.TOAST;
    default:
      return Type.NONE;
    }
  }

  int determineFreshness()
  {
    switch(type)
    {
    case TOP_BUN:
    case BOTTOM_BUN:
    case PATTY:
    case RARE:
    case MEDIUM:
      return 5;
    case WELL_DONE:
    case TOAST:
      return 6;
    case KATCHUP:
    case MUSTARD:
    case MAYO:
    case LETTUCE:
    case TOMATO:
    case CHEESE:
    case PICKLE:
    case AVOCADO:
      return 1;
    case ONION:
    case BACON:
    case SHROOM:
    case EGG:
      return 5;

    case RUINED:
    default:
      return 0;
    }
  }

  int determinePrice()
  {
    switch(type)
    {
    case TOP_BUN:
    case TOAST:
      return 10;
    case BOTTOM_BUN:
      return 5;
    case PATTY:
    case RARE:
    case MEDIUM:
    case WELL_DONE:
      return 25;
    case KATCHUP:
      return 5;
    case MUSTARD:
      return 10;
    case MAYO:
      return 15;
    case LETTUCE:
      return 15;
    case TOMATO:
      return 20;
    case CHEESE:
      return 25;
    case PICKLE:
      return 25;
    case ONION:
      return 25;
    case EGG:
      return 75;
    case SHROOM:
      return 75;
    case BACON:
      return 100;
    case AVOCADO:
      return 150;

    case RUINED:
    default:
      return 0;
    }
  }

  String toString()
  {
    switch(type)
    {
    case TOP_BUN:
      return "Top Bun";
    case BOTTOM_BUN:
      return "Bottom Bun";
    case TOAST:
      return "Toast";
    case PATTY:
      return "Beef Patty";
    case KATCHUP:
      return "Katchup";
    case MUSTARD:
      return "Mustard";
    case MAYO:
      return "Mayonase";
    case LETTUCE:
      return "Lettuce";
    case TOMATO:
      return "Tomato";
    case CHEESE:
      return "Cheese";
    case PICKLE:
      return "Pickle";
    case AVOCADO:
      return "Avocado";
    case ONION:
      return "Onion";
    case BACON:
      return "Bacon";
    case SHROOM:
      return "Mushrooms";
    case EGG:
      return "Egg";

    case RARE:
      return "Rare Patty";
    case MEDIUM:
      return "Medium Patty";
    case WELL_DONE:
      return "Well-Done Patty";
    case RUINED:
      return "Ruined Item";
    default:
      return "";
    }
  }

  boolean touchable()
  {
    switch(type)
    {
    case TOP_BUN:
      return true;
    case BOTTOM_BUN:
      return true;
    case TOAST:
      return true;
    case PATTY:
      return true;
    case KATCHUP:
      return false;
    case MUSTARD:
      return false;
    case MAYO:
      return false;
    case LETTUCE:
      return true;
    case TOMATO:
      return true;
    case CHEESE:
      return false;
    case PICKLE:
      return true;
    case AVOCADO:
      return true;
    case ONION:
      return true;
    case BACON:
      return true;
    case SHROOM:
      return true;
    case EGG:
      return false;

    case RARE:
      return true;
    case MEDIUM:
      return true;
    case WELL_DONE:
      return true;
    case RUINED:
      return true;
    default:
      return false;
    }
  }
}
