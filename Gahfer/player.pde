int rocketleng = 15;
int rocketheig = 40;
int init_fuel = 1000;

class player
{
  boolean isAI;
  brain brain;

  Particles engine;
  Particles[] propellers;

  PVector pos;
  PVector spe;

  PVector[] collisionPoints;

  float angle;
  float a_spe;

  int fuel = init_fuel;
  int fitness;
  float engine_power = 0.04;

  boolean onGround = true;
  boolean crushed = false;

  color col;

  player(PVector spawnPoint, color col, brain brain)
  {
    propellers = new Particles[2];
    collisionPoints = new PVector[5];

    this.pos = new PVector(spawnPoint.x, spawnPoint.y);
    this.spe = new PVector(0, 0);

    this.brain = brain;
    isAI = brain == null;

    float x = spawnPoint.x;
    float y = spawnPoint.y;

    engine        = new Particles(new PVector(x, y+rocketheig/2),              col, -.2, 0.2,  0.0, 3.0);
    propellers[0] = new Particles(new PVector(x-rocketleng/2, y-rocketheig/4), col, -1, 0.0, -0.05, 0.05);
    propellers[1] = new Particles(new PVector(x+rocketleng/2, y-rocketheig/4), col,  1, 0.0, -0.05, 0.05);

    collisionPoints[0] = new PVector(x, y-rocketleng/1.5);
    collisionPoints[1] = new PVector(x+1.5*rocketleng, y);
    collisionPoints[2] = new PVector(x-1.5*rocketleng, y);
    collisionPoints[3] = new PVector(x+1.5*rocketleng, y-rocketleng/3);
    collisionPoints[4] = new PVector(x-1.5*rocketleng, y-rocketleng/3);

    this.col = col;
    engine.col = col;
  }

  player(player p)
  {
    this.isAI = p.isAI;
    this.brain = p.brain;

    pos = p.pos;
    spe = p.spe;

    this.angle = p.angle;
    this.col   = p.col;
    this.fuel = p.fuel;

    float x = pos.x;
    float y = pos.y;
    propellers = new Particles[2];

    engine        = new Particles(new PVector(x, y+rocketheig/2),              col, -.2, 0.2,  0.0, 3.0);
    propellers[0] = new Particles(new PVector(x-rocketleng/2, y-rocketheig/4), col, -1, 0.0, -0.05, 0.05);
    propellers[1] = new Particles(new PVector(x+rocketleng/2, y-rocketheig/4), col,  1, 0.0, -0.05, 0.05);
  }


  public void loop()
  {
    engine.pos        = this.pos.copy().add(new PVector(0, rocketheig/2));
    propellers[0].pos = this.pos.copy().add(new PVector(-rocketleng/2, -rocketheig/4));
    propellers[1].pos = this.pos.copy().add(new PVector(+rocketleng/2, -rocketheig/4));

    collisionPoints[0] = this.pos.copy().add(new PVector(0, -rocketleng/.4));
    collisionPoints[1] = this.pos.copy().add(new PVector(+1.5*rocketleng, 0));
    collisionPoints[2] = this.pos.copy().add(new PVector(-1.5*rocketleng, 0));
    collisionPoints[3] = this.pos.copy().add(new PVector(+1.5*rocketleng, -rocketleng/.8));
    collisionPoints[4] = this.pos.copy().add(new PVector(-1.5*rocketleng, -rocketleng/.8));

    //PHYSICS
    pos.add(spe);
    angle += a_spe;
    angle %= TWO_PI;
    a_spe *= .95;

    if(!onGround) spe.add(new PVector(0, gravity)); else spe.mult(0);
    if(onGround && angle != 0) a_spe += -angle*.05;
    if(collision()) reset();

    this.show();
  }

  public void noMove(PVector p1, PVector p2)
  {
    PVector av = p2.copy().add(p1).mult(.5);
    float w = av.x;
    float h = av.y;
    pos = new PVector(w, h);
    showShip();

    PVector di = p2.copy().sub(p1);
    w -= di.x/3;
    h += di.y/3;

    stroke(red);
    strokeWeight(1.3);
    float px = map(fuel, 0, init_fuel, w, w+2*di.x/3);
    line(px, h, w, h);
  }

  public void control(boolean[] buttons)
  {
    if(fuel > 0)
    {
      if(buttons[0])
      {
        //MOVE FORWARD
        engine.newParticle(1);
        float ax = sin(angle)*engine_power;
        float ay = cos(angle)*engine_power;
        this.spe.add(new PVector(ax, -ay));
        fuel -= 2;
      }

      if(buttons[1] && !onGround)
      {
        //TURN RIGHT (left pushing)
        if(frameCount % 2 == 0) propellers[1].newParticle(1);
        a_spe -= engine_power/50;
        fuel--;
      }

      if(buttons[2] && !onGround)
      {
        //TURN LEFT (right pushing)
        propellers[0].newParticle(1);
        a_spe += engine_power/50;
        fuel--;
      }
    }
  }

  boolean collision()
  {
    isOnGround();
    for(int i = 0; i < 5; i++)
    {
      PVector cords = getCoords(collisionPoints[i]);

      if(showCollisionPoints.enabled == 1) {
        stroke(col);
        noFill();
        ellipse(collisionPoints[i].x, collisionPoints[i].y, 3, 3);
      }

      int x = int(cords.x);
      int y = int(cords.y);

      for(int j = 0; j < level.length; j++)
      {
        if(level[j] == null) break;
        if(level[j] != null && x == level[j].x && y == level[j].y) return true;
      }

    }

    return false;
  }

  void isOnGround()
  {
    onGround = false;
    for(int i = 0; i < level.length; i++)
    {
      if(level[i] == null) break;

      if(level[i].x == getX(pos.x) && level[i].y+7 == getY(pos.y)+27)
      {
        onGround = true;
        if(spe.y > 1.5) {crushed = true; reset();}
        break;
      }
    }

  }

  void show()
  {
    translate(pos.x, pos.y);
    rotate((angle));
    translate(-pos.x, -pos.y);

    engine.show();
    propellers[0].show();
    propellers[1].show();

    translate(pos.x, pos.y);
    rotate(-(angle));
    translate(-pos.x, -pos.y);

    showShip();
  }


  void showShip()
  {
    stroke(col);
    fill(col, 150);


    translate(pos.x, pos.y);
    rotate((angle));
    translate(-pos.x, -pos.y);


    rectMode(CORNER);
    rect(pos.x-rocketleng/2, pos.y-rocketheig/2, rocketleng, rocketheig);
    rectMode(CORNERS);

    float x1 = pos.x-rocketleng/2-.3*rocketleng;
    float y1 = pos.y-rocketheig/2;
    float x2 = pos.x;
    float y2 = y1-.3*rocketheig;
    float x3 = pos.x+rocketleng/2+.3*rocketleng;
    float y3 = y1;
    triangle(x1, y1, x2, y2, x3, y3);

    translate(pos.x, pos.y);
    rotate(-(angle));
    translate(-pos.x, -pos.y);

  }


}
