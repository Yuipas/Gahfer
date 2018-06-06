color green = color(101, 255, 101);
color red = color(255, 101, 101);
color blue = color(101, 101, 255);
color white = color(236);
color black = color(19);

//VARS
PImage block;
PImage block2;
PImage erase;
boolean show = false;
boolean typing = level_name.equals("");
boolean placingPlayer = false;
String directory = "level.data";
int scene = 0;

//GUI DISPLAY
gui newlevel;
gui inport;
gui export;
gui level_text;
gui type_toggle;
gui icount;
gui size_scr;
gui next;
gui back;


public void guiSetup()
{
  background(15);
  rectMode(CORNERS);
  imageMode(CENTER);
  block  = loadImage("textures/block.tif");
  block2 = loadImage("textures/block2.tif");
  erase  = loadImage("textures/erase.tif");
  //textAlign(CENTER);

  int w = width;
  int h = height;

  newlevel    = new gui(w/4, 00+h/4, 3*w/4, 1*h/2-10, false, black, black);
  inport      = new gui(w/4, 10+h/2, 3*w/4, 3*h/4-00, false, black, black);
  export      = new gui(w/10, 13*h/15, 9*w/20, 19*h/20, false, white, white);
  level_text  = new gui(w/25, h/5, level_name, 60, white);
  icount      = new gui(9*w/40+3*w/10, 19*h/40+7*h/15, "0", 30, white);
  size_scr    = new gui(w/4, 2*h/3, 3*w/4, 2*h/3, 30, 1, 1000, true, white);
  next        = new gui(7*w/8, 29*h/32, 99*w/100, 99*h/100, false, green, green);
  back        = new gui(1*w/100, 1*h/100,  1*w/8, 3*h/32, false, red, red);
  type_toggle = new gui(3*w/5, 13*h/15, 19*w/20, 19*h/20, true, red, randomColor());

  type_toggle.enabled = 1;
  size_scr.enabled = width/size_scr.maxvalue;
  size_scr.showvalue = true;
  newlevel.text = "New Level";
  inport.text   = "Import";
  export.text   = "Export";
  next.text     = "Create";
  back.text     = "Cancel";

  next.size = back.size = 18;
}

public void guiDraw()
{
  background(7);

  int w = width;
  int h = height;

  if(scene == 0)
  {
    image(block, width/2, height/2, width, height);
    inport.show();
    newlevel.show();
  }
  else if(scene == 1)
  {
    size_scr.show();
    next.show();
    back.show();
  }
  else if(scene == 2)
  {
    textAlign(LEFT);
    level_text.show();
    if(typing)
    {
      level_text.text = level_name;
      if(frameCount % 120 >= 60) level_text.text += "_";
    }

    if(show)
    {
      textAlign(CENTER);
      icount.text = str(index);
      export.show();
      type_toggle.show();
      icount.show();

      int mx = (type_toggle.x + type_toggle.px)/2;
      int my = (type_toggle.y + type_toggle.py)/2;

      stroke(0);
      noFill();
      rect(mx-21, my-21, mx+20, my+20);
      if(type_toggle.enabled == 1)   image(block2, mx, my, 40, 40);
      if(type_toggle.enabled == 0.5) image(block, mx, my, 40, 40);
      if(type_toggle.enabled == 0)   image(erase, mx, my, 40, 40);

    }
  }
}

public void keyPressed()
{
  if(scene == 2)
  {
    if(key == 's' && !typing) show = !show;
    else if(key == 'm' && !typing && type_toggle.enabled == 0) type_toggle.enabled = 1;
    else if(key == 'm' && !typing) type_toggle.enabled = abs(type_toggle.enabled-.5);
    else if(key == 'r')
    {
      level = new tile[level_size*level_size];
      importLevel();
    }
    if(keyCode == 10) typing = false; //ENTER
    if(typing) level_name += key;
    if(keyCode == 8 && typing) //ERASE / BACK BUTTON
    {
      String lev = "";
      for(int i = 0; i < level_name.length()-2; lev += level_name.charAt(i++));
        level_name = lev;
    }

    if(key == 'c' && !typing) typing = true;
  }

  if(key == 'o') for(int i = 0; i < index; println(level[i].x, level[i++].y));

  //println(keyCode);
}


public void mousePressed()
{
  if(scene == 0)
  {
    if(newlevel.mouseOnTop) scene = 1;
    else if(inport.mouseOnTop)
    {
      importLevel();
      scene = 2;
    }
  }
  else if(scene == 1)
  {
    if(next.mouseOnTop)
    {
      level_size = round(size_scr.getValue());
      scene = 2;
    }

    if(back.mouseOnTop)
    {
      scene = 0;
    }
  }
  else if(scene == 2)
  {
    if(export.mouseOnTop) export();
    else if(type_toggle.mouseOnTop && type_toggle.enabled == 0) type_toggle.enabled = 1;
    else if(type_toggle.mouseOnTop) type_toggle.enabled = abs(type_toggle.enabled-.5);
    else if(type_toggle.enabled != 0)
    {
      int px = getMouseX();
      int py = getMouseY();

      level[index] = new tile(px, py, type_toggle.enabled == 1, index);
      for(int p = 0; p < index; p++) if(level[p] != null && level[p].x == px && level[p].y == py) level[index--] = null;
      index++;
    }
  }
}


void export()
{
  /*EXPORT LEVEL*/
  String[] file = new String[8*index+3];

  file[0] = level_name;
  file[1] = str(level_size);
  file[2] = "";

  for(int i = 0; i < index; i++)
  {
    int in = 8*i+3;
    file[in+0] = "{";
    file[in+1] = " " + level[i].x;
    file[in+2] = " " + level[i].y;
    file[in+3] = " " + level[i].fx;
    file[in+4] = " " + level[i].fy;
    file[in+5] = " " + (level[i].killOnTouch ? 1 : 0);
    file[in+6] = " " + level[i].interactable;
    file[in+7] = "}";
  }

  saveStrings(directory, file);
  exit();
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

  level = new tile[dimensions*dimensions];

  for(int i = 3; i < raw_data.length; i++)
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
  }

  index = id;

}


int randomColor()
{
  return palette[int(random(palette.length))];
}


class gui
{
  byte type; //1 BUTTON, 2 TEXTBOX, 3 SCROLLER
  int x, y, px, py;
  int size = 20;

  boolean mouseOnTop;
  boolean isToggle, showvalue;
  boolean mouselocked, showline;

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
        fill(defaultColor);
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

      this.enabled = constrain(this.enabled, 0, 1);
      float posx = map(enabled, 0, 1, x, px);
      int posy = y-(size/2);
      strokeWeight(size * .05);
      if(showline) line(x, y, px, py);
      strokeWeight(1);

      //ellipse(posx, y, size, size);
      posx -= (size/2);
      stroke(0);
      rect(posx, posy, posx+size, posy+size);

      if(dist(mouseX, mouseY, posx, y) < size) mouseOnTop = true;
      else mouseOnTop = false;

      if(mousePressed && mouseOnTop)
        mouselocked = true;

      if(!mousePressed)
        mouselocked = false;

      if(mouselocked)
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
