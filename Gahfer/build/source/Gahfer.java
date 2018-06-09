import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Gahfer extends PApplet {

tile[] level;

player p1;

int level_size;
int cameraX, cameraY;


public void setup()
{
  
  background(15);
  guiSetup();

  cameraX = cameraY = width/2;

  brain b = new brain(5, 10, 3, 16);
  p1 = new player(width/2, height/2);
}


public void draw()
{
  background(15);
  showLevel();
  p1.loop();
}


public void showLevel()
{
  for(int x = 0; x < level.length; x++)
  {
    if(level[x] == null) break;
    level[x].show(cameraX, cameraY);
  }
}
class brain
{
  neurons[] network;


  brain(int complexity, int inputlength, int outputslength, int hiddenlength)
  {
    network = new neurons[complexity];

    network[complexity-1]                        = new neurons(outputslength, null);
    for(int i = complexity-2; i>0; network[i]    = new neurons(hiddenlength, network[i+1]), i--);
    network[0]                                   = new neurons(inputlength, network[1]);
  }

  public void think(float[] inputs_array)
  {
    network[0].f(inputs_array);
    //for(neurons con : network) con.print();
  }

  public void showNetwork(int w, int h) //width, height
  {
    stroke(0);
    fill(255);

    int totallayers = network.length;
    int actual_layer = 1;

    for(int layer = 0; layer < totallayers-1; layer++)
    {
      for(int or = 0; or < network[layer].numberofneurons; or++)
      {
        for(int de = 0; de < network[layer+1].numberofneurons; de++)
        {
          stroke(getColor(network[layer].layer[or].connections[de]));
          int xtemp = w/(totallayers+1);
          int x1 = (layer+1) * xtemp +10;
          int y1 = (or+1) * h/(network[layer].numberofneurons+1) +10;
          int x2 = (layer+2) * xtemp +10;
          int y2 = (de+1) * h/(network[layer+1].numberofneurons+1) +10;
          line(x1, y1, x2, y2);
        }
      }
    }

    stroke(0);
    for(neurons layer : network)
    {
      int x = actual_layer * w / (totallayers+1);
      int totalneurons = layer.layer.length;
      int actual_neuron = 1;


      for(neuron ne : layer.layer)
      {
        //if(actual_layer != network.length)
        //{
        //  fill(getColor(network[actual_layer-1].bias.link(actual_neuron-1)));
        //} else fill(255);

        int y = actual_neuron * h / (totalneurons+1);
        rect(x, y, x+20, y+20);

        actual_neuron++;
      }
      actual_layer++;
    }

  }

}


class neuron
{

  float value;
  float[] connections;

  neuron(int ncon)
  {
    connections = new float[ncon];
    for(int i = 0; i < ncon; connections[i++] = random(-2, 2)); //random(-1, 1));
  }

  public float link(int pos)
  {
    return value*connections[pos];
  }

}

class neurons
{
  int numberofneurons;
  neurons linkedTo;
  neuron bias;
  neuron[] layer;

  neurons(int numberofneurons, neurons linkedTo)
  {
    layer = new neuron[numberofneurons];
    this.numberofneurons = numberofneurons;
    this.linkedTo = linkedTo;

    if(linkedTo != null) for(int i=0; i<numberofneurons; layer[i] = new neuron(linkedTo.numberofneurons), i++);
    else for(int i=0; i<numberofneurons; layer[i] = new neuron(0), i++);

    if(linkedTo != null)
    {
      bias = new neuron(linkedTo.numberofneurons);
      bias.value = 1;
    }

  }

  public void f(float[] inputs)
  {
    if(inputs.length != numberofneurons)
    {
      println("Error when loading inputs in 'brain.neurons.f(inputs)' function.");
      return;
    }

    for(int i = 0; i < inputs.length; this.layer[i].value = inputs[i], i++);

    this.activate();
    if(linkedTo != null)
    {
      //this.activate();
      float[] outputs = new float[linkedTo.numberofneurons];

      for(int i1 = 0; i1 < numberofneurons; i1++)
      {
        for(int i2 = 0; i2 < outputs.length; i2++)
        {
          outputs[i2] += layer[i1].link(i2);
        }
      }

      for(int i = 0; i < outputs.length; outputs[i] += bias.link(i), i++);

      if(linkedTo != null) linkedTo.f(outputs);
    } //else this.activate();

  }

  public void activate()
  {
    for(int i = 0; i < numberofneurons; layer[i].value = sigmoid(layer[i].value), i++);
  }


  public void print()
  {
    int n = 0;
    for(neuron ne : layer)
    {
      System.out.print("["+(n++)+"] " + ne.value + ".  ");
    }
    println();
  }

}


public int getColor(float val)
{
  int col = color(255);
  if (val < 0)
  {
    float r = constrain(-val * 255, 0, 255);
    float gb = constrain(val * 255 * -sigmoid(val), 10, 100);
    col = color(r, gb, gb);
  }
  if (val > 0)
  {
    float g = constrain(val * 255, 0, 255);
    float rb = constrain(val * 255 * -sigmoid(val), 10, 100);
    col = color(rb, g, rb);
  }
  return col;
}

public float sigmoid(float x)
{
  return (1/(1+exp(-x)));
}
int green = color(101, 255, 101);
int red = color(255, 101, 101);
int blue = color(101, 101, 255);
int white = color(236);
int black = color(19);

//VARS
PImage block;
PImage block2;
PImage erase;
PImage rocket;

String directory = "level.data";
boolean showMap = false;
int scene = 0;

//GUI DISPLAY


public void guiSetup()
{
  background(15);
  rectMode(CORNERS);
  imageMode(CENTER);

  block   = loadImage("textures/block.tif");
  block2  = loadImage("textures/block2.tif");
  erase   = loadImage("textures/erase.tif");
  rocket  = loadImage("textures/rocket.jpg");

  int w = width;
  int h = height;

  importLevel();

  level_size = PApplet.parseInt(sqrt(level.length));
}

public void guiDraw()
{
  background(7);

  int w = width;
  int h = height;

  if(scene == 0)
  {

  }
  else if(scene == 1)
  {

  }
  else if(scene == 2)
  {
  }
}

public void keyPressed()
{

  //println(keyCode);
}


public void mousePressed()
{
  if(scene == 0)
  {

  }
  else if(scene == 1)
  {

  }
  else if(scene == 2)
  {

  }
}

public int StringValue(String data)
{
  int value = 0;
  for(int i = 1; i < data.length(); i++)
  {
    value *= 10;
    value += PApplet.parseInt(data.charAt(i)) -48;
  }

  return value;
}


public void importLevel()
{
  String[] raw_data = loadStrings(directory);
  int dimensions = PApplet.parseInt(raw_data[1]);
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

}


public int randomColor()
{
  return palette[PApplet.parseInt(random(palette.length))];
}

public int inverseColor(int col)
{
  return color(255, 255, 255) - col;
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

  int colorOn, colorOff;
  int defaultColor = color(255);

  public gui(int x, int y, int px, int py, boolean toggle, int colOn, int colOff)
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

  public gui(int x, int y, String text, int size, int defaultColor)
  {
    this.x = x;
    this.y = y;
    this.text = text;
    this.size = size;
    this.defaultColor = defaultColor;

    type = 2;
  }

  public gui(int x, int y, int px, int py, int size, float minv, float maxv, boolean showline, int defaultColor)
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
      int col = PApplet.parseInt(this.enabled * colorOn + abs(this.enabled-1) * colorOff);

      if(mouseOnTop) fill(col, 150);
      else fill(col, 100);

      rect(x, y, px, py);

      if(text != null)
      {
        float mx = (x+px)/2;
        float my = (y+py)/2;

        textAlign(CENTER);
        fill(inverseColor(defaultColor));
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
      strokeWeight(size * .05f);
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

  public float getValue()
  {
    if(type == 3) return (this.enabled*(maxvalue-minvalue) + minvalue);
    else return 0;
  }

}


public float rounded(float value, int ac)
{
  float temp = pow(10, ac) * value;
  temp = round(temp);
  temp /= pow(10, ac);
  return temp;
}
class player
{
  boolean isAI;
  brain brain;

  int x;
  int y;

  int angle = 0;
  int fuel;

  int fitness;

  boolean leftturning;
  boolean rigthturning;

  public player(int x, int y)
  {
    this.isAI = false;
    this.x = x;
    this.y = y;
  }

  public player(int x, int y, brain brain)
  {
    this.isAI = true;
    this.brain = brain;
  }


  public void loop()
  {
    this.show();

    if(isAI)
    {
      float[] inputs = {};
    }
    
  }

  public void show()
  {
    float si = 20*width/level_size;
    rotate(degrees(angle));
    image(rocket, x, y, si, 2*si);
  }


}
int[] palette = {color(170,82,237), color(244, 244, 244), color(255, 255, 51), color(11, 11, 244), color(11, 244, 11)};

class tile
{
  int id;

  int x;
  int y;

  int fx, fy;

  boolean interactable;
  boolean killOnTouch;
  boolean toggled = false;

  int col;

  tile(int x, int y, boolean killOnTouch, int id)
  {
    this.id = id;

    interactable = false;
    this.killOnTouch = killOnTouch;

    this.x = this.fx = x;
    this.y = this.fy = y;

    col = killOnTouch ? color(244, 15, 15) : palette[PApplet.parseInt(random(palette.length))];
  }

  tile(int x, int y, boolean killOnTouch, int fx, int fy, int id)
  {
    this.id = id;

    this.x = x;
    this.y = y;

    this.fx = fx;
    this.fy = fy;

    this.killOnTouch = killOnTouch;
    interactable = true;

    col = killOnTouch ? color(244, 15, 15) : palette[PApplet.parseInt(random(palette.length))];

    if(fx == x && fy == y) interactable = false;
  }

  public boolean onScreen(int cameraX, int cameraY)
  {
    if(this.x < cameraX-width/10) return false;
    if(this.x > cameraX+width/10) return false;

    if(this.y < cameraY-height/10) return false;
    if(this.y > cameraY+height/10) return false;


    return true;
  }

  public void show(int cameraX, int cameraY)
  {
    if(onScreen(cameraX, cameraY) || true)
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
  public void settings() {  size(650, 650); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Gahfer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
