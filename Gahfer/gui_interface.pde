color green = color(101, 255, 101);
color red = color(255, 101, 101);
color blue = color(101, 101, 255);
color white = color(236);
color black = color(19);
color yellow = color(255,255,0);
color gray = color(236, 20);

//VARS
PImage block;
PImage block2;
PImage erase;
PImage rocket;

String directory = "level.data";
boolean showMap = false;
int scene = 0;

player[] displayPlayers = new player[4];

//GUI DISPLAY
/*scene 0*/
gui play;
gui conf;
/*scene 1*/
gui back;
gui isAI;
gui next;
gui[] players_act;
/*scene 2*/
gui[] boxes;
/*scene 3*/
gui optimization_scr;
gui showCollisionPoints;
gui keys;

public void guiSetup()
{
  background(15);
  rectMode(CORNERS);
  // imageMode(CENTER);

  color[] temp = {blue, red, green, yellow};
  playerColors = temp;

  boxes = new gui[4];
  players_act = new gui[4];

  int w = width;
  int h = height;

  /*scene 0*/
  play = new gui(1*w/6, h/3, 5*w/6, 1*h/2, false, green, green);
  conf = new gui(1*w/6, h/2, 5*w/6, 2*h/3, false, blue, blue);
  /*scene 1*/
  back          = new gui(1     , 7*h/8, 1*w/5  , h-1  , false, red, red);
  next          = new gui(4*w/5 , 7*h/8, w-1    , h-1  , false, green, green);
  isAI          = new gui(3*w/16, 7*h/20, 15*w/32, 9*h/20, true, green, red);
  for(int i = 0; i < 4; i++) players_act[i] = new gui(6*w/64+i*(w/5), h/16, 6*w/64+(i+1)*w/5, h/8, true, playerColors[i], color(playerColors[i], 20));
  players_act[0].colorOff = color(10, 10, 25);
  /*scene 2*/
  boxes[0] = new gui(1,     7*h/8, w/8, h-1, false, blue, blue);
  boxes[1] = new gui(7*w/8, 7*h/8, w-1, h-1, false, red, red);
  boxes[2] = new gui(7*w/8, 1,     w-1, h/8, false, green, green);
  boxes[3] = new gui(1,     1,     w/8, h/8, false, yellow, yellow);
  /*scene 3*/
  optimization_scr    = new gui(w/8, h/5, 7*w/8, h/5, 30, 1, 10, true, white);
  showCollisionPoints = new gui(w/8, h/4, 7*w/8, 6*h/16, true, green, red);
  // keys             = new gui(w/8, h/6);

  play.text = "Play";
  conf.text = "Configuration";

  back.text = "Back";
  next.text = "Play";
  isAI.text = "A.I.";

  showCollisionPoints.text = "Show collision points";

  importLevel();
}

public void guiDraw()
{
  background(7);

  int w = width;
  int h = height;

  // camera.x = constrain(p1.pos.x, width/2, level_size-width/2);
  // camera.y = constrain(p1.pos.y, height/2, level_size-height/2);


  if(scene == 0) //START MENU
  {
    play.show();
    conf.show();
  }
  else if(scene == 1) //PREGAME CONFIGURATION
  {
    back.show();
    next.show();
    isAI.show();
    for(gui b : players_act) b.show();
  }
  else if(scene == 2) //GAME SCENE
  {
    showLevel();
    strokeWeight(1.4);
    for(gui box : boxes) box.show();
  }
  else if(scene == 3) //CONFIGURATION
  {
    back.show();
    optimization_scr.show();
    showCollisionPoints.show();
  }
}

public void keyPressed()
{
  for(int p = 0; p < keyBindings.length; p++)
  {
    for(int k = 0; k < keyBindings[p].length; k++)
    {
      if(keyCode == keyBindings[p][k])
      {
        pushingButtons[p][k] = true;
      }
    }

  }

   // println(keyCode);
}

public void keyReleased()
{

  for(int p = 0; p < keyBindings.length; p++)
  {
    for(int k = 0; k < keyBindings[p].length; k++)
    {
      if(keyCode == keyBindings[p][k])
      {
        pushingButtons[p][k] = false;
      }
    }

  }
}


public void mousePressed()
{
  if(scene == 0)
  {
    if(play.mouseOnTop) scene = 1;
    if(conf.mouseOnTop) scene = 3;
  }
  else if(scene == 1)
  {
    if(back.mouseOnTop) scene = 0;
    if(next.mouseOnTop) newGame();
    if(isAI.mouseOnTop) isAI.enabled = abs(isAI.enabled-1);
    for(int i = 0; i < 4; i++) if(players_act[i].mouseOnTop) players_act[i].enabled = abs(players_act[i].enabled-1);
  }
  else if(scene == 2)
  {
    for(int i = 0; i < 4; i++) if(players[i] != null && boxes[i].mouseOnTop) {players[i].crushed = true; reset(); break;}
  }
  else if(scene == 3)
  {
    if(back.mouseOnTop) scene = 0;
    if(showCollisionPoints.mouseOnTop) showCollisionPoints.enabled = abs(showCollisionPoints.enabled-1);
  }
}

int StringValue(String data)
{
  int value = 0;
  for(int i = 1; i < data.length(); i++)
  {
    value *= 10;
    value += int(data.charAt(i)) -48;
  }

  return value;
}


void importLevel()
{
  String[] raw_data = loadStrings(directory);
  int dimensions = int(raw_data[1]);
  int id = 0;

  level_size = dimensions;
  level = new tile[dimensions*dimensions];

  //spawnPoints[0] = new PVector(StringValue(raw_data[3]), StringValue(raw_data[4]));

  for(int i = 6; i < raw_data.length; i++)
  {
    if(raw_data[i].equals("{"))
    {
      int x  = StringValue(raw_data[i+1]);
      int y  = StringValue(raw_data[i+2]);
      int fx = StringValue(raw_data[i+3]);
      int fy = StringValue(raw_data[i+4]);

      //println(raw_data[i+1], x);
      //println(raw_data[i+2], y);

      boolean killOnTouch = StringValue(raw_data[i+5]) == 1;

      level[id] = new tile(x, y, killOnTouch, fx, fy, id);
      id++;
    }

    // level = new tile[dimensions*dimensions];

  }

}


int randomColor()
{
  return palette[int(random(palette.length))];
}

int inverseColor(color col)
{
  return color(255, 255, 255) - col;
}


class gui
{
  byte type; //1 BUTTON, 2 TEXTBOX, 3 SCROLLER
  int x, y, px, py;
  int size = 20;

  boolean mouseOnTop;
  boolean isToggle, showvalue = true;
  boolean mouselocked, showline;
  boolean inactive = false;

  float enabled;
  float minvalue, maxvalue;
  String text = null;

  color colorOn, colorOff;
  color defaultColor = color(255);

  public gui(int x, int y, int px, int py, boolean toggle, color colOn, color colOff)
  {
    this.x = x;
    this.y = y;
    this.px = px;
    this.py = py;

    this.isToggle = toggle;
    this.colorOn = (colOn);
    this.colorOff = (colOff);
    type = 1;

    if(px < x)
    {
      int temp = x;
      x = px;
      px = temp;
    }

    if(py < y)
    {
      int temp = y;
      y = py;
      py = temp;
    }

  }

  public gui(int x, int y, String text, int size, color defaultColor)
  {
    this.x = x;
    this.y = y;
    this.text = text;
    this.size = size;
    this.defaultColor = defaultColor;

    type = 2;
  }

  public gui(int x, int y, int px, int py, int size, float minv, float maxv, boolean showline, color defaultColor)
  {
    this.x = x;
    this.y = y;
    this.px = px;
    this.py = py;

    this.size = size;

    this.maxvalue = maxv;
    this.minvalue = minv;

    this.showline = showline;

    this.defaultColor = defaultColor;
    type = 3;
  }

  public void show()
  {
    stroke(defaultColor);
    strokeWeight(1);

    if (type == 1)
    {
      noFill();
      color col = int(this.enabled * colorOn + abs(this.enabled-1) * colorOff);

      if(mouseOnTop) fill(col, 150);
      else fill(col, 100);

      rect(x, y, px, py);

      if(text != null)
      {
        float mx = (x+px)/2;
        float my = (y+py)/2;

        textAlign(CENTER);
        fill((defaultColor));
        textSize(size);
        text(text, mx, my);
      }

    } else if(type == 2 && text != null)
    {
      fill(defaultColor);
      textSize(size);
      text(text, x, y);
    } else if(type == 3)
    {
      stroke(defaultColor);
      fill(defaultColor);

      if(inactive) {stroke(defaultColor, 20); fill(defaultColor, 20);}

      this.enabled = constrain(this.enabled, 0, 1);
      float posx = map(enabled, 0, 1, x, px);
      int posy = y-(size/2);
      strokeWeight(max(size * .05, 1));
      if(showline) line(x, y, px, py);
      strokeWeight(1);

      //ellipse(posx, y, size, size);
      posx -= (size/2);
      stroke(0);
      rect(posx, posy, posx+size, posy+size);

      if(dist(mouseX, mouseY, posx, y) < size && !inactive) mouseOnTop = true;
      else mouseOnTop = false;

      if(mousePressed && mouseOnTop && !inactive)
        mouselocked = true;

      if(!mousePressed && !inactive)
        mouselocked = false;

      if(mouselocked && !inactive)
      {
        enabled = map(mouseX, x, px, 0, 1);
        enabled = constrain(enabled, 0, 1);
      }

      if(this.text != null)
      {
        textAlign(CENTER);
        text(text, x, y);
      }

      if(showvalue)
      {
        fill(0);
        if(inactive) fill(30);
        textSize(12);
        textAlign(CENTER);
        text(round(getValue()), posx+size/2, y+size/5);
      }

    }
    //if(type == 1) println(x, y, px, py);
    if(x <= mouseX && mouseX <= px && y <= mouseY && mouseY <= py)
      mouseOnTop =    true;
    else mouseOnTop = false;



    if(enabled == 1 && !isToggle && type == 1) enabled = 0;
  }

  float getValue()
  {
    if(type == 3) return (this.enabled*(maxvalue-minvalue) + minvalue);
    else return 0;
  }

}


float rounded(float value, int ac)
{
  float temp = pow(10, ac) * value;
  temp = round(temp);
  temp /= pow(10, ac);
  return temp;
}
