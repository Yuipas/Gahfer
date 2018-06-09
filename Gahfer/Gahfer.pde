tile[] level;
int _players;
PVector camera;
PVector[] spawnPoints = {new PVector(300, 30), new PVector(300, 30), new PVector(300, 30), new PVector(300, 30)};

int level_size;
boolean[][] pushingButtons = new boolean[4][3];
player[] players;
color[] playerColors = new color[4];

float gravity = 0.02;
//float zoom = 1;

int[][] keyBindings = {
  {87, 65, 68}, //P1 RED
  {38, 37, 39}, //P2 BLUE
  {87, 65, 68}, //P3 GREEN
  {38, 37, 39}  //P4 YELLOW
};

int _inputs;
int _outputs;


//TESTING VARS

void setup()
{
  size(600, 600);
  background(15);
  guiSetup();

  camera = new PVector(width/2, height/2);
}


void draw()
{
  guiDraw();
  playersDraw();
}

void playersDraw()
{
  for(int i = 0; i < 4 && players != null; i++)
  {
    if(players[i] != null)
    {
      players[i].loop();
      players[i].control(pushingButtons[i]);
      displayPlayers[i] = new player(players[i]);
      displayPlayers[i].noMove(new PVector(boxes[i].x, boxes[i].y), new PVector(boxes[i].px, boxes[i].py));
    }
  }
}


void showLevel()
{
  strokeWeight(1.2);
  for(int x = 0; x < level.length; x++)
  {
    if(level[x] == null) break;
    level[x].show();
  }
}



void reset()
{
  for(int i = 0; i < 4; i++)
  {
    if(players[i] != null && players[i].crushed)
    {
      if(players_act[i].enabled == 1)
      {
        players[i] = new player(spawnPoints[i], playerColors[i], null);
      }
      else if(isAI.enabled == 1)
      {
        players[i] = new player(spawnPoints[i], playerColors[i], new brain(5, _inputs, _outputs, 16));
      }

    }
  }
}

void newGame()
{
  scene = 2;
  players = new player[4];

  for(int i = 0; i < 4; i++)
  {
    if(players_act[i].enabled == 1)
    {
      players[i] = new player(spawnPoints[i], playerColors[i], null);
      displayPlayers[i] = new player(players[i]);
      _players++;
    }
    else if(isAI.enabled == 1)
    {
      players[i] = new player(spawnPoints[i], playerColors[i], new brain(5, _inputs, _outputs, 16));
    }
  }
}



float getX(float x) {
  float x_ = x;

  x_ = round(map(x_, 0, width, 0, level_size)/(10));
  x_ *= (10);
  return x_;
}

float getY(float y) {
  float y_ = y;

  y_ = round(map(y_, 0, height, 0, level_size)/(10));
  y_ *= (10);
  return y_;
}


PVector getCoords(PVector temp)
{
  return new PVector(getX(temp.x), getY(temp.y));
}
