color[] palette = {color(170,82,237), color(244, 244, 244), color(255, 255, 51), color(11, 11, 244), color(11, 244, 11)};

class tile
{
  int id;

  float x;
  float y;

  float fx, fy;

  boolean interactable;
  boolean killOnTouch;
  boolean toggled = false;

  color col;

  tile(float x, float y, boolean killOnTouch, int id)
  {
    this.id = id;

    interactable = false;
    this.killOnTouch = killOnTouch;

    this.x = this.fx = x;
    this.y = this.fy = y;

    col = killOnTouch ? color(244, 15, 15) : palette[int(random(palette.length))];
  }

  tile(float x, float y, boolean killOnTouch, float fx, float fy, int id)
  {
    this.id = id;

    this.x = x;
    this.y = y;

    this.fx = fx;
    this.fy = fy;

    this.killOnTouch = killOnTouch;
    interactable = true;

    col = killOnTouch ? color(244, 15, 15) : palette[int(random(palette.length))];

    if(fx == x && fy == y) interactable = false;
  }

  // boolean onScreen(int cameraX, int cameraY)
  // {
  //   if(this.x < cameraX-width/10) return false;
  //   if(this.x > cameraX+width/10) return false;
  //
  //   if(this.y < cameraY-height/10) return false;
  //   if(this.y > cameraY+height/10) return false;
  //
  //
  //   return true;
  // }

  void show()
  {
    if(true)
    {
      float si = 10*width/level_size;

      stroke(col);
      fill(col, 70);

      int x = round(map(this.x, 0, level_size, 0, width));
      int y = round(map(this.y, 0, level_size, 0, height));

      rect(x-si/2, y-si/2, x+si/2, y+si/2);
    }

  }

}


class Particles
{
  //particle[] content;
  ArrayList<particle> content;
  PVector pos;
  color col;

  PVector xrange;
  PVector yrange;

  public Particles(PVector pos, color col, float xmin, float xmax, float ymin, float ymax)
  {
    pos = pos.copy();
    content = new ArrayList<particle>();

    this.col = col;
    yrange = new PVector(ymin, ymax);
    xrange = new PVector(xmin, xmax);
  }

  public void show()
  {
    for(int i = content.size()-1; i >= 0; i--)
    {
      content.get(i).show();
      if(content.get(i).lifetime > 75) content.remove(i);
    }
  }

  public void newParticle(int count)
  {
    for(int i = 0; i < count; content.add(new particle(pos, xrange, yrange, col)), i++);
  }

}

class particle
{
  PVector pos;
  PVector spe;
  PVector ace;

  color col = 255;

  int lifetime = 0;

  particle(PVector pos, PVector ax, PVector ay, color col)
  {
    this.pos = pos;

    spe = new PVector(random(ax.x, ax.y), random(ay.x, ay.y));
    ace = new PVector(0, 0.01);
    this.col = col;
  }

  public void show()
  {
    if(pos == null) return;

    spe.add(ace);
    pos.add(spe);

    int temp = int(map(col - map(lifetime, 0, 20, 0, col), 0, col, 0, 255));

    stroke(col, 150+temp);
    fill(col, temp);
    ellipse(pos.x, pos.y, 2, 2);

    lifetime++;
  }


}
