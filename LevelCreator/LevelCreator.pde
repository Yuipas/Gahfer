/*Level Maker - Main*/

int level_size = 600;
String level_name = "The Yupi Level";

//float zoom = 1;
//int size = 0;
int index = 0;
int cameraX, cameraY;

tile[] level;

void setup()
{
  size(600, 600);

  guiSetup();
  cameraX = width/2;
  cameraY = height/2;

  level = new tile[level_size*level_size];
}

void mouseDragged()
{
  if(scene == 2 && !export.mouseOnTop && !type_toggle.mouseOnTop)
  {
    int px = getMouseX();
    int py = getMouseY();

    if(type_toggle.enabled != 0)
    {
      level[index] = new tile(px, py, type_toggle.enabled == 1, index);
      for(int p = 0; p < index; p++) if(level[p] != null && level[p].x == px && level[p].y == py) level[index--] = null;
      index++;
    }
    else if(type_toggle.enabled == 0)
    {
      for(int i = 0; i < index; i++)
      {
        if(level[i].x == px && level[i].y == py)
        {
          pushArray(i);
          index--;
          break;
        }
      }
    }

  }
}


void pushArray(int pos)
{
  if(pos >= level.length) println("ERROR PUSH ARRAY");
  if(pos < 0) println("ERROR PUSH ARRAY");

  for(int i = pos; i < level.length-1; i++)
  {
    if(level[i+1] != null) level[i] = level[i+1];
  }
}

void show()
{
  for(int x = 0; x < index; x++)
  {
    if(level[x] != null)
    level[x].show(cameraX, cameraY);
  }
}

void draw()
{
  guiDraw();
  show();
}



int getMouseX() {
  int x_ = mouseX;

  x_ = round(map(x_, 0, width, 0, level_size)/(10));
  x_ *= (10);
  return x_;
}

int getMouseY() {
  int y_ = mouseY;

  y_ = round(map(y_, 0, height, 0, level_size)/(10));
  y_ *= (10);
  return y_;
}
