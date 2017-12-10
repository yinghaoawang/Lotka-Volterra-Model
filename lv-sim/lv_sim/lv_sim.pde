ArrayList<Prey> preys = new ArrayList<Prey>();
ArrayList<Predator> predators = new ArrayList<Predator>();
ArrayList<Integer> preyData = new ArrayList<Integer>();
ArrayList<Integer> predatorData = new ArrayList<Integer>();
int x0 = 30;
int y0 = 6;
float a = .3;
float b = .0005;
float c = .2;
float d = .5;
float deltaT = 30; // in frames
float dirChangeT = 10; //in frames
float huntRadius = 99990;

void setup() {
  size(800, 800);
  frameRate(60);
  for (int i = 0; i < x0; ++i) addRandomPrey();
  for (int i = 0; i < y0; ++i) addRandomPredator();
}

boolean checkCollision(float x1, float y1, float x2, float y2, float radius) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float distance = dx * dx + dy * dy;
  if (distance < radius) return true;
  return false;
}

boolean checkCollision(Predator predator, Prey prey) {
  return checkCollision(predator.xPos, predator.yPos, prey.xPos, prey.yPos, huntRadius);
}

void draw() {
  background(255);
  if (frameCount % deltaT == 0) println(preyData);
  // Animal movements
  for (int i = 0; i < predators.size(); ++i) {
    predators.get(i).step();
    
    if (frameCount % deltaT == 0) {
      for (int j = 0; j < preys.size(); ++j) {
        if (checkCollision(predators.get(i), preys.get(j))) {
          preys.remove(j);
          if (random(0, 1) < d && predators.get(i).children < 3) {
            addPredator(predators.get(i).xPos, predators.get(i).yPos);
            ++predators.get(i).children;
          }
        }
      }
    }
    // decay
    if (frameCount % deltaT == 0 && random(0, 1) < c) {
      predators.remove(i);
      --i;
      continue;
    }
    predators.get(i).display();
  }
  for (int i = 0; i < preys.size(); ++i) {
    preys.get(i).step();
    preys.get(i).display();
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
}
void addRandomPredator() {
  addPredator(random(0, width), random(0, height));
}
void addPredator(float xPos, float yPos) {
  Predator predator = new Predator(xPos, yPos);
  predators.add(predator);
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
    if (max(0, xPos) == 0) {
      xPos = 0;
      xVel *= -1;
    }
    if (min(xPos, width) == width) {
      xPos = width;
      xVel *= -1;
    }
    if (max(0, yPos) == 0) {
      yPos = 0;
      yVel *= -1;
    }
    if (min(yPos, height) == height) {
      yPos = height;
      yVel *= -1;
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
    // growth
    if (frameCount % deltaT == 0 && random(0, 1) < a && children < 3) {
      addPrey(xPos, yPos);
      ++children;
    }
  }
  void display() {
    fill(255, 80, 80);
    ellipse(xPos, yPos, 10, 10);
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
    fill (80, 80, 255);
    ellipse(xPos, yPos, 10, 10);
    noFill();
    ellipse(xPos, yPos, huntRadius, huntRadius);
  }
}