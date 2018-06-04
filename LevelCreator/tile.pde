color[] palette = {color(170,82,237), color(11, 11, 11), color(244, 244, 244), color(255, 255, 51), color(11, 11, 244, color(11, 244, 11))};

class tile
{
  int x;
  int y;

  int fx, fy;

  boolean interactable;
  boolean killOnTouch;
  boolean toggled = false;

  color col;

  tile(int x, int y, boolean killOnTouch)
  {
    interactable = false;
    this.killOnTouch = killOnTouch;

    this.x = this.fx = x;
    this.y = this.fy = y;

    col = killOnTouch ? color(244, 15, 15) : palette[int(random(palette.length))];
  }

  tile(int x, int y, boolean killOnTouch, int fx, int fy)
  {
    this.x = x;
    this.y = y;

    this.fx = fx;
    this.fy = fy;

    this.killOnTouch = killOnTouch;
    interactable = true;
    col = killOnTouch ? color(244, 15, 15) : palette[int(random(palette.length))];
  }

  boolean onScreen(int cameraX, int cameraY)
  {
    if(this.x < cameraX*zoom-width/10) return false;
    if(this.x > cameraX*zoom+width/10) return false;

    if(this.y < cameraY*zoom-height/10) return false;
    if(this.y > cameraY*zoom+height/10) return false;


    return true;
  }

  void show(int cameraX, int cameraY)
  {
    if(onScreen(cameraX, cameraY) || true)
    {
      float si = user_width*zoom/width;

      stroke(col);
      fill(col, 70);

      int x = round(map(this.x, 0, user_width*zoom, 0, width));
      int y = round(map(this.y, 0, user_height*zoom, 0, height));

      rect(x-si/2, y-si/2, x+si/2, y+si/2);
    }

  }

}