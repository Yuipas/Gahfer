/*Level Maker - Main*/

int user_width = 600;
int user_height = 400;
String level_name = "The Yupi Level";

float zoom = 10;
int size = 2;
int index = 0;
int cameraX, cameraY;

tile[] level;

void setup()
{
  size(600, 400);
  background(15);
  guiSetup();
  cameraX = width/2;
  cameraY = height/2;

  level = new tile[user_width*user_height];

  //println(user_width*zoom/width);
}

void mouseDragged()
{
  int px = getMouseX();
  int py = getMouseY();


  level[index] = new tile(px, py, type_toggle.enabled == 1);
  for(int p = 0; p < index; p++) if(level[p].x == px && level[p].y == py) level[index--] = null;
  index++;

}

void show()
{
  for(int x = 0; x < index; x++)
  {
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

  x_ = floor(map(x_, 0, width, 0, user_width*zoom)/100);
  x_ *= 100;
  return x_;
}

int getMouseY() {
  int y_ = mouseY;

  y_ = floor(map(y_, 0, height, 0, user_height*zoom)/100);
  y_ *= 100;
  return y_;
}
