color green = color(101, 255, 101);
color red = color(255, 101, 101);
color blue = color(101, 101, 255);
color white = color(236);
color black = color(19);

//VARS
boolean show = false;
boolean typing = level_name.equals("");
String directory = "";

//GUI DISPLAY
gui export;
gui export_text;
gui level_text;
gui type_toggle;
gui zoom_scr;//zoom text


public void guiSetup()
{
  rectMode(CORNERS);
  //textAlign(CENTER);

  int w = width;
  int h = height;

  export      = new gui(w/10, 13*h/15, 9*w/20, 19*h/20, false, white, white);
  export_text = new gui(11*w/40, 37*h/40, "Export", 20, white);
  level_text  = new gui(w/25, h/5, level_name, 60, white);
  type_toggle = new gui(3*w/5, 13*h/15, 19*w/20, 19*h/20, true, green, red);
  type_toggle.enabled = 1;
}

public void guiDraw()
{
  background(7);

  int w = width;
  int h = height;

  textAlign(LEFT);
  level_text.show();
  if(typing) level_text.text = level_name;

  if(show)
  {
    textAlign(CENTER);
    export.show();
    export_text.show();
    type_toggle.show();
  }

}

public void keyPressed()
{
  if(key == 's' && !typing) show = !show;
  if(key == 'c' && !typing) typing = true;
  if(keyCode == 10) typing = false; //ENTER

  if(key == 'r')
  {
    level = new tile[user_width*user_height];
    index = 0;
  }

  if(typing) level_name += key;
  //println(keyCode);
  if(keyCode == 8 && typing)
  {
    String lev = "";
    for(int i = 0; i < level_name.length()-2; lev += level_name.charAt(i++));
    level_name = lev;
    println(lev);
  }
}


public void mousePressed()
{
  if(export.mouseOnTop) export();
  else if(type_toggle.mouseOnTop) type_toggle.enabled = abs(type_toggle.enabled-1);
  else {
    int px = getMouseX();
    int py = getMouseY();

    level[index] = new tile(px, py, type_toggle.enabled == 1);
    for(int p = 0; p < index; p++) if(level[p].x == px && level[p].y == py) level[index--] = null;
    index++;
  }
}


void export()
{
  /*EXPORT LEVEL*/
  String[] file = new String[8*index+2];

  file[0] = level_name;
  file[1] = "";

  for(int i = 0; i < index; i++)
  {
    int in = 8*i+2;
    file[in+0] = "{";
    file[in+1] = " " + level[i].x;
    file[in+2] = " " + level[i].y;
    file[in+3] = " " + level[i].fx;
    file[in+4] = " " + level[i].fy;
    file[in+5] = " " + level[i].killOnTouch;
    file[in+6] = " " + level[i].interactable;
    file[in+7] = "}";
  }

  saveStrings("level.data", file);

  exit();
}


class gui
{
  byte type; //1 BUTTON, 2 TEXTBOX, 3 SCROLLER
  int x, y, px, py;
  int size;

  boolean mouseOnTop;
  boolean isToggle;
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
      color col = enabled == 1 ? colorOn : colorOff;

      if(mouseOnTop) fill(col, 150);
      else fill(col, 100);

      rect(x, y, px, py);
    } else if(type == 2 && text != null)
    {
      fill(defaultColor);
      textSize(size);
      text(text, x, y);
    } else if(type == 3)
    {
      stroke(0);
      fill(defaultColor);

      this.enabled = constrain(this.enabled, 0, 1);
      float posx = map(enabled, 0, 1, x, px);
      int posy = y-(size/2);
      strokeWeight(size * .05);
      if(showline) line(x, y, px, py);
      strokeWeight(1);

      //ellipse(posx, y, size, size);
      posx -= (size/2);
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
