ArrayList<Prey> preys = new ArrayList<Prey>();
ArrayList<Predator> predators = new ArrayList<Predator>();
ArrayList<Integer> preyData = new ArrayList<Integer>();
ArrayList<Integer> predatorData = new ArrayList<Integer>();
int maxPrey;
int maxPredator;

// variables to change
int x0 = 1800;
int y0 = 600;
float a = .25; // % chance for a prey to reproduce per deltaT
float b = .5; // % chance for predator to kill prey on contact per delta%
float c = .15; // % chance for a predator to die per deltaT
float d = .1; // % chance on predator to reproduce on prey killed (when b triggered)
float dirChangeT = 30; // how often predator/prey change directions (higher = longer)
float predatorRadius = 3; // size of predator (only a visual)
float preyRadius = 3; // size of prey (larger is like larger b)
float huntRadius = predatorRadius; // size of predator can hunt prey (larger is like larger b)
float deltaT = 30; // how many frames does it take for 1 set of lv calculations
float predatorDeath = deltaT * 999999999; // predator lifespan. infinite = disabled

// toggle these as needed
boolean isVisual = false; // sim visuals
boolean isDrawChart = false; // line chart of x and y data

Button chartButton, visualButton;

void setup() {
  size(1200, 1200);
  frameRate(60);
  preyData.add(x0);
  predatorData.add(y0);
  chartButton = new Button(width - 100, 10, 40, 10);
  visualButton = new Button(width - 50, 10, 40, 10);
  color c = color(255, 255, 0);
  chartButton.setColor(c);
  c = color(255, 0, 255);
  visualButton.setColor(c);
  // add initial prey and predator
  for (int i = 0; i < x0; ++i) addRandomPrey();
  for (int i = 0; i < y0; ++i) addRandomPredator();
}

void mouseReleased() {
  if (mouseOver(chartButton)) {
    isDrawChart = !isDrawChart;
  }
  if (mouseOver(visualButton)) {
    isVisual = !isVisual;
  }
}

boolean mouseOver(Button b) {
  return mouseX >= b.xPos && mouseX <= b.xPos + b.w && 
         mouseY >= b.yPos && mouseY <= b.yPos + b.h;
}

class Button {
  float xPos, yPos, w, h;
  color c;
  
  Button(float xPos, float yPos, float w, float h) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.w = w;
    this.h = h;
  }
  void setColor(color c) {
    this.c = c;
  }
  void display() {
    strokeWeight(2);
    stroke(0);
    fill(c);
    rect(xPos, yPos, w, h);
  }
}

// checks collision of 2 circular objects
boolean checkCollision(float x1, float y1, float x2, float y2, float r1, float r2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float distance = sqrt(dx * dx + dy * dy);
  if (distance < r1 + r2) return true;
  return false;
}
// checks collision of predator and prey
boolean checkCollision(Predator predator, Prey prey) {
  return checkCollision(predator.xPos, predator.yPos, prey.xPos, prey.yPos, huntRadius, preyRadius);
}


void drawChart(ArrayList<Integer> dataset1, ArrayList<Integer> dataset2, int max1, int max2) {
  float startX = width/5;
  float startY = height/5;
  float endX = width - startX;
  float endY = height * 1/2;
  float deltaX = (endX - startX) / (dataset1.size() - 1);
  
  float maxY = Math.max(max1, max2);
  
  
  // draw chart background
  fill(240);
  noStroke();
  rect(startX, startY, endX-startX, endY-startY);
  
  stroke(0);
  strokeWeight(3);
  // draw ds1
  float prevVal = 0;
  float currVal = 0;
  for (int i = 0; i < dataset1.size(); ++i) {
    prevVal = currVal;
    currVal = dataset1.get(i);
    if (i == 0) continue;
    float currX = i * deltaX;
    float prevX = currX - deltaX;
    stroke(255, 80, 80);
    line(startX + prevX, endY - (endY - startY) * (prevVal/maxY), startX + currX, endY - (endY - startY) * (currVal/maxY));  
  }
  // draw ds2
  prevVal = 0;
  currVal = 0;
  for (int i = 0; i < dataset2.size(); ++i) {
    prevVal = currVal;
    currVal = dataset2.get(i);
    if (i == 0) continue;
    float currX = i * deltaX;
    float prevX = currX - deltaX;  
    stroke(80, 80, 255);

    line(startX + prevX, endY - (endY - startY) * (prevVal/maxY), startX + currX, endY - (endY - startY) * (currVal/maxY));  
  }
  
  // draw chart x and y axis
  //float tickSize = min(xOffset, yOffset);
  stroke(0);
  line(startX, startY, startX, endY);
  line(startX, endY, endX, endY);
  
}

void draw() {
  background(200);
  chartButton.display();
  visualButton.display();
  // draw chart if enabled
  if (isDrawChart) {
    drawChart(preyData, predatorData, maxPrey, maxPredator);
  }
  // output prey and predator to console
  if (frameCount % (deltaT * 2) == 0) {
    println("prey: " + preyData);
    println("predator: " + predatorData);
  }
  // predator actions
  for (int i = 0; i < predators.size(); ++i) {
    Predator predator = predators.get(i);
    //move
    predator.step();
    //decay
    if (frameCount % deltaT == 0) {
      if (predators.size() > preys.size()) {
        if (random(0, 1) < c+.2) {// active management
          predators.remove(i);
          --i;
          continue;
        }
      } else
      if (predator.age > predatorDeath || random(0, 1) < c) {
        predators.remove(i);
        --i;
        continue;
      }
    }
    // draw
    if (isVisual) predator.display();
    // check for prey to eat
    for (int j = 0; j < preys.size(); ++j) {
      Prey prey = preys.get(j);
      // if in vicinity of prey and rolls eat
      if (checkCollision(predator, prey) && random(0, 1) < b) {
        preys.remove(j);
        --j;
        // chance to birth
        if (random(0, 1) < d) {
          addPredator(predator.xPos, predator.yPos);
          ++predator.children;
        }
      }
    }
  }
  // prey actions
  for (int i = 0; i < preys.size(); ++i) {
    Prey prey = preys.get(i);
    prey.step();
    // growth
    if (frameCount % deltaT == 0 && random(0, 1) < a) {
      addPrey(prey.xPos, prey.yPos);
      ++prey.children;
    }
    if (isVisual) prey.display();
  }

  // Log x and y data
  if (frameCount % deltaT == 0) {
    preyData.add(preys.size());
    predatorData.add(predators.size());
  }
}

void addRandomPrey() {
  addPrey(random(0, width), random(0, height)); 
}
void addPrey(float xPos, float yPos) {
  Prey prey = new Prey(xPos, yPos);
  preys.add(prey);
  if (preys.size() > maxPrey) maxPrey = preys.size();
}
void addRandomPredator() {
  addPredator(random(0, width), random(0, height));
}
void addPredator(float xPos, float yPos) {
  Predator predator = new Predator(xPos, yPos);
  predators.add(predator);
  if (predators.size() > maxPredator) maxPredator = predators.size();
}

abstract class Creature {
  float xPos, yPos, xVel, yVel, age;
  int children;
  Creature parents;
  private void newRandVel() {
    xVel = random(2, 4);
    if (random(0, 1) < .5) xVel *= -1;
    yVel = random(2, 4);
    if (random(0, 1) < .5) yVel *= -1;
  }
  Creature() {
    xPos = 0;
    yPos = 0;
    children = 0;
    newRandVel();
    age = 0;
  }
  Creature(float xPos, float yPos) {
    this.xPos = xPos;
    this.yPos = yPos;
    newRandVel();
    this.age = 0;
  }
  void step() {
    // age the creature
    age += deltaT;
    // move the creature
    if (frameCount % dirChangeT == 0)
      newRandVel();
    xPos += xVel;
    yPos += yVel;
    // if hit corner, reverse direction
    if (xPos < 0) {
      //xPos = 0;
      //xVel *= -1;
      xPos = width;
    }
    if (xPos > width) {
      //xPos = width;
      //xVel *= -1;
      xPos = 0;
    }
    if (yPos < 0) {
      //yPos = 0;
      //yVel *= -1;
      yPos = height;
    }
    if (yPos > height) {
      //yPos = height;
      //yVel *= -1;
      yPos = 0;
    }
  }
  abstract void display();
}

class Prey extends Creature {
  Prey(float xPos, float yPos) {
    super(xPos, yPos);
  }
  void step() {
    super.step();

  }
  void display() {
    noStroke();
    fill(255, 80, 80);
    ellipse(xPos, yPos, preyRadius, preyRadius);
  }
}

class Predator extends Creature {
  Predator(float xPos, float yPos) {
    super(xPos, yPos);
  }
  void step() {
    super.step();
    // decay

  }
  void display() {
    noStroke();
    fill (80, 80, 255);
    ellipse(xPos, yPos, predatorRadius, predatorRadius);
    stroke(0);
    strokeWeight(1);
    noFill();
    ellipse(xPos, yPos, huntRadius, huntRadius);
  }
}