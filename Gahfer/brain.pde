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

  void think(float[] inputs_array)
  {
    network[0].f(inputs_array);
    //for(neurons con : network) con.print();
  }

  void showNetwork(int w, int h) //width, height
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

  float link(int pos)
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

  void f(float[] inputs)
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

  void activate()
  {
    for(int i = 0; i < numberofneurons; layer[i].value = sigmoid(layer[i].value), i++);
  }


  void print()
  {
    int n = 0;
    for(neuron ne : layer)
    {
      System.out.print("["+(n++)+"] " + ne.value + ".  ");
    }
    println();
  }

}


color getColor(float val)
{
  color col = color(255);
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

float sigmoid(float x)
{
  return (1/(1+exp(-x)));
}
