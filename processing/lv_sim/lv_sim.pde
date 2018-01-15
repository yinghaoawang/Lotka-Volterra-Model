ArrayList<Prey> preys = new ArrayList<Prey>();
ArrayList<Predator> predators = new ArrayList<Predator>();
ArrayList<Integer> preyData = new ArrayList<Integer>();
ArrayList<Integer> predatorData = new ArrayList<Integer>();
int maxPrey;
int maxPredator;

// variables to change
int x0 = 300;
int y0 = 100;
float a = .25; // % chance for a prey to reproduce per deltaT
float b = 1;//.5; // % chance for predator to kill prey on contact per delta%
float c = .1; // % chance for a predator to die per deltaT
float d = .2; // % chance on predator to reproduce on prey killed (when b triggered)
float dirChangeT = 30; // how often predator/prey change directions (higher = longer)
float deltaT = 30; // how many framkjes does it take for 1 set of lv calculations
boolean activeManagement = false; // change predator decay rate when it is greater than deer

float predatorSize = 5; // size of predator (only a visual)
float preySize = 5; // size of prey (larger is like larger b)
boolean randomSize = true; // if on, then random size of .2 * size to size
boolean useSquares = true;

// toggle these as needed
boolean isVisual = true; // sim visuals
boolean isDrawChart = true; // line chart of x and y data
boolean showFPS = true;
boolean showData = true;
boolean useQT = false;
boolean showQT = false;
boolean useSH = true;
boolean showSH = false;

// Chart button draws chart
// Visual button draws simulation objects
// DS button draws specified data structure visuals
Button chartButton, visualButton, dsButton;
float minFPS = 1000;

void setup() {
  size(1200, 1200);
  frameRate(60);
  preyData.add(x0);
  predatorData.add(y0);
  dsButton = new Button(width - 150, 10, 40, 10);
  chartButton = new Button(width - 100, 10, 40, 10);
  visualButton = new Button(width - 50, 10, 40, 10);
  dsButton.setColor(color(0, 255, 255));
  chartButton.setColor(color(255, 255, 0));
  visualButton.setColor(color(255, 0, 255));
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
  if (mouseOver(dsButton)) {
    showQT = !showQT;
    showSH = !showSH;
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
    rectMode(CORNER);
    rect(xPos, yPos, w, h);
  }
}

// checks collision of predator and prey
boolean checkCollision(Predator predator, Prey prey) {
  return eitherIn(predator, prey);
  //return checkCollision(predator.xPos, predator.yPos, prey.xPos, prey.yPos, huntRadius, preyRadius);
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
  dsButton.display();
  // draw chart if enabled
  if (isDrawChart) {
    drawChart(preyData, predatorData, maxPrey, maxPredator);
  }
  
  // output prey and predator to console
  if (frameCount % (deltaT * 2) == 0) {
    println("prey: " + preyData);
    println("predator: " + predatorData);
  }

  QuadTree qt = null;
  SpatialHash sh = null;
  
  // init quadtree or spatial hash if specified
  if (useQT) {
    // Create a quad tree every frame because objects are dynamic
    //for (int i = 0; i < predators.size(); ++i) qt.insert(predators.get(i));
    qt = new QuadTree(width, height);
    for (int i =  0; i < preys.size(); ++i) qt.insert(preys.get(i));
  } else if (useSH) {
    sh = new SpatialHash(((width+height)/2)/40);
    for (Prey prey : preys) sh.insert(prey);
  }
  
  // predator actions
  for (int i = 0; i < predators.size(); ++i) {
    Predator predator = predators.get(i);
    //move
    predator.step();
    //decay
    if (frameCount % deltaT == 0) {
      if (predators.size() > preys.size() && activeManagement) {
        if (random(0, 1) < c+.2) {// active management
          predators.remove(i);
          --i;
          continue;
        }
      } else
        if (random(0, 1) < c) {
          predators.remove(i);
          --i;
          continue;
        }
    }
    // draw
    if (isVisual) predator.display();
    // check for prey to eat
    ArrayList<GridObject> pcObjs = null;
    if (useSH) { // spatial hash method
      pcObjs = sh.getPossibleCollisions(predator);
    } else if (useQT) {// quad tree method
        pcObjs = qt.getPossibleCollisions(predator);
    } else { // brute force method
      pcObjs = new ArrayList<GridObject>();
      for (Prey prey : preys) pcObjs.add(prey);
    }
    for (int j = 0; j < pcObjs.size(); ++j) {
      GridObject collObj = pcObjs.get(j);
      if (collObj instanceof Predator) continue;
      if (predator == collObj) continue;
      if (checkCollision(predator, (Prey)collObj)) {
        preys.remove(collObj);
        // chance to birth
        if (random(0, 1) < d) {
          float w = predatorSize;
          float h = predatorSize;
          if (randomSize) {
            w = random(predatorSize * .2, predatorSize);
            h = random(predatorSize * .2, predatorSize);
          }
          if (useSquares) h = w;
          Predator childPredator = addPredator(predator.xPos, predator.yPos, w, h);
          childPredator.changeDirection();
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
      float w = preySize;
      float h = preySize;
      if (randomSize) {
        w = random(preySize * .2, preySize);
        h = random(preySize * .2, preySize);
      }
      if (useSquares) h = w;
      Prey childPrey = addPrey(prey.xPos, prey.yPos, w, h);
      childPrey.changeDirection();
    }
    if (isVisual) prey.display();
  }

  // Log x and y data
  if (frameCount % deltaT == 0) {
    preyData.add(preys.size());
    predatorData.add(predators.size());
  }
  
  if (useQT && showQT) qt.display();
  if (useSH && showSH) sh.display();
  if (showFPS) {
    if (frameRate < minFPS && frameCount > 30) minFPS = frameRate;
    fill(0);
    if (frameCount > 30)
      text((int)frameRate + " - " + (int)minFPS, 10, 20);
    else
      text((int)frameRate, 10, 20);
  }
  if (showData) {
    float yPos = 20;
    if (showFPS) yPos += 15;
    text("Prey: " + preys.size(), 10, yPos);
    yPos += 15;
    text("Predator: "+ predators.size(), 10, yPos);
  }
}

Prey addPrey(float xPos, float yPos) {
  return addPrey(xPos, yPos, preySize, predatorSize);
}
Prey addPrey(float xPos, float yPos, float w, float h) {
  Prey prey = new Prey(xPos, yPos, w, h);
  preys.add(prey);
  if (preys.size() > maxPrey) maxPrey = preys.size();
  return prey;  
}
Predator addPredator(float xPos, float yPos) {
  return addPredator(xPos, yPos, predatorSize, predatorSize);
}
Predator addPredator(float xPos, float yPos, float w, float h) {
  Predator predator = new Predator(xPos, yPos, w, h);
  predators.add(predator);
  if (predators.size() > maxPredator) maxPredator = predators.size();
  return predator;
}
Prey addRandomPrey() {
  float w = preySize;
  float h = preySize;
  if (randomSize) {
    w = random(preySize * .2, preySize);
    h = random(preySize * .2, preySize);
  }
  if (useSquares) h = w;
  return addPrey(random(0, width), random(0, height), w, h);
}
Predator addRandomPredator() {
  float w = predatorSize;
  float h = predatorSize;
  if (randomSize) {
    w = random(predatorSize * .2, predatorSize);
    h = random(predatorSize * .2, predatorSize);
  }
  if (useSquares) h = w;
  return addPredator(random(0, width), random(0, height), w, h);
}

abstract class Creature extends GridObject {
  float age;
  void changeDirection() {
    xVel = random(2, 4);
    if (random(0, 1) < .5) xVel *= -1;
    yVel = random(2, 4);
    if (random(0, 1) < .5) yVel *= -1;
  }
  Creature(float xPos, float yPos) {
    super(xPos, yPos);
    age = 0;
  }
  void step() {
    // age the creature
    age += deltaT;
    // move the creature
    if (frameCount % dirChangeT == 0) changeDirection();
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
  Prey(float xPos, float yPos, float w, float h) {
    super(xPos, yPos);
    this.w = w;
    this.h = h;
  }
  void step() {
    super.step();
  }
  void display() {
    noStroke();
    rectMode(CENTER);
    fill(255, 80, 80);
    rect(xPos, yPos, w, h);
  }
}

class Predator extends Creature {
  Predator(float xPos, float yPos) {
    super(xPos, yPos);
  }
  Predator(float xPos, float yPos, float w, float h) {
    super(xPos, yPos);
    this.w = w;
    this.h = h ;
  }
  void step() {
    super.step();
    // decay
  }
  void display() {
    noStroke();
    fill (80, 80, 255);
    rectMode(CENTER);
    rect(xPos, yPos, w, h);
  }
}



/* QUAD TREE */
// Determines if a rectangular object is in another rectangular object
boolean in(GridObject obj1, GridObject obj2) {
  return in(obj1.xPos-obj1.w/2, obj1.xPos+obj1.w/2, obj1.yPos-obj1.h/2, obj1.yPos+obj1.h/2, 
    obj2.xPos-obj2.w/2, obj2.xPos+obj2.w/2, obj2.yPos+obj2.h/2, obj2.yPos+obj2.h/2);
}
boolean in(QTNode node, GridObject obj) {
  return in(node, obj.xPos - obj.w/2, obj.xPos + obj.w/2, obj.yPos - obj.h/2, obj.yPos + obj.h/2);
}
boolean in(QTNode node, float x1, float x2, float y1, float y2) {
  return in(node.minX, node.maxX, node.minY, node.maxY, x1, x2, y1, y2);
}
boolean in(GridObject obj, float x1, float x2, float y1, float y2) {
  return in(obj.xPos - obj.w/2, obj.xPos+obj.w/2, obj.yPos-obj.h/2, obj.yPos+obj.h/2, x1, x2, y1, y2);
}
boolean in(float Ax1, float Ax2, float Ay1, float Ay2, float Bx1, float Bx2, float By1, float By2) {

  return (in(Ax1, Ax2, Bx1) || in(Ax1, Ax2, Bx2)) &&
    (in(Ay1, Ay2, By1) || in(Ay1, Ay2, By2));
}


// Determines if a point is in a rectangular object
boolean in(QTNode node, float x, float y) {
  return in(node.minX, node.maxX, node.minY, node.maxY, x, y);
}
boolean in(GridObject obj, float x, float y) {
  return in(obj.xPos - obj.w/2, obj.xPos + obj.w/2, obj.yPos - obj.h/2, obj.yPos + obj.h/2, x, y);
}
boolean in(float x1, float x2, float y1, float y2, float x, float y) {
  return x >= x1 && x <= x2 && y >= y1 && y <= y2;
}

// Determines if a point is on a line (can be x or y)
boolean in(float first, float second, float point) {
  return point >= first && point <= second;
}

// Determines if a rectangle is in a rectangle and vice versa
boolean eitherIn(float Ax1, float Ax2, float Ay1, float Ay2, float Bx1, float Bx2, float By1, float By2) {
  return in(Ax1, Ax2, Ay1, Ay2, Bx1, Bx2, By1, By2) || in(Bx1, Bx2, By1, By2, Ax1, Ax2, Ay1, Ay2);
}
boolean eitherIn(GridObject obj1, GridObject obj2) {
  return eitherIn(obj1.xPos-obj1.w/2, obj1.xPos+obj1.w/2, obj1.yPos-obj1.h/2, obj1.yPos+obj1.h/2, obj2.xPos-obj2.w/2, obj2.xPos+obj2.w/2, obj2.yPos-obj2.h/2, obj2.yPos+obj2.h/2);
}

// Object stored in the Quad Tree
abstract class GridObject {
  float xPos, yPos, xVel, yVel;
  float w, h;
  color c;
  GridObject(float x, float y) {
    this(x, y, 5, 5);
  }
  GridObject(float x, float y, float w, float h) {
    this.xPos = x;
    this.yPos = y;
    this.w = w;
    this.h = h;
    this.xVel = 0;
    this.yVel = 0;
    this.c = color(80, 80, 80);
  }
  void display() {
    rectMode(CENTER);
    noStroke();
    fill(c);
    rect(xPos, yPos, w, h);
  }
}

// Stores x y coords
class Point {
  float x, y;
  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

// Node used in the Quad Tree
class QTNode {
  float minX, maxX, minY, maxY;
  Point point;
  QTNode parent;
  QTNode[] children;
  ArrayList<GridObject> objects;
  QTNode(float minX, float maxX, float minY, float maxY, QTNode parent) {
    objects = null;
    children = null;
    this.parent = parent;
    this.minX = minX;
    this.minY = minY;
    this.maxX = maxX;
    this.maxY = maxY;
    this.point = null;
  }
  QTNode(float minX, float maxX, float minY, float maxY) {
    this(minX, maxX, minY, maxY, null);
  }
  QTNode(float x, float y) {
    this(0, x, 0, y);
  }
  void display() {
    rectMode(CORNER);
    noFill();
    stroke(0);
    strokeWeight(1);
    rect(minX, minY, maxX-minX, maxY-minY);
  }

  // Move objects into a node's children where they fit
  void placeObjectsInChildren(ArrayList<GridObject> objects) {
    if (objects == null) return;
    for (int i = 0; i < objects.size(); ++i) {
      GridObject obj = objects.get(i);
      for (int j = 0; j < children.length; ++j) {
        QTNode childNode = children[j];
        if (in(childNode, obj)) {
          if (childNode.objects == null) childNode.objects = new ArrayList<GridObject>();
          childNode.objects.add(obj);
        }
      }
    }
  }

  // Moves a point into a node's children where it fits
  void placePointInChildren(Point point) {
    for (int i = 0; i < children.length; ++i) {
      QTNode childNode = children[i];
      if (in(childNode, point.x, point.y)) {
        childNode.point = point;
        break;
      }
    }
  }

  // Create 4 child nodes in a node
  void createChildren() {
    float centerX = (minX + maxX)/2;
    float centerY = (minY + maxY)/2;
    children = new QTNode[4];
    children[0] = new QTNode(minX, centerX, minY, centerY, this);
    children[1] = new QTNode(centerX, maxX, minY, centerY, this);
    children[2] = new QTNode(minX, centerX, centerY, maxY, this);
    children[3] = new QTNode(centerX, maxX, centerY, maxY, this);
  }

  String toString() {
    return this.minX + ", " + this.maxX + ' ' + this.minY + ", " + this.maxY;
  }
}

// Quad Tree data structure
class QuadTree {
  QTNode head;
  float epsilon;
  QuadTree(float x, float y) {
    head = new QTNode(x, y);
    epsilon = 0; // When to stop dividing
  }

  // returns first grid object with corresponding x and y coords
  GridObject search(float x, float y) {
    return search(head, x, y);
  }
  GridObject search(QTNode node, float x, float y) { 
    if (!in(node, x, y)) {
      return null;
    }
    if (node.children != null) {
      for (int i = 0; i < node.children.length; ++i) {
        GridObject obj = search(node.children[i], x, y);
        if (obj != null) return obj;
      }
    }
    if (node.point != null && node.objects != null && node.point.x == x && node.point.y == y) {
      for (int i = 0; i < node.objects.size(); ++i) {
        GridObject obj = node.objects.get(i);
        if (obj.xPos == x && obj.yPos == y) return obj;
      }
    }
    return null;
  }

  // Gets a list of possible collisions in the quad tree given coordinates of rect object
  ArrayList<GridObject> getPossibleCollisions(float x1, float x2, float y1, float y2) {
    ArrayList<GridObject> result = new ArrayList<GridObject>();
    ArrayList<QTNode> queue = new ArrayList<QTNode>();
    queue.add(head);
    while (queue.size() > 0) {
      QTNode node = queue.remove(0);
      if (!eitherIn(node.minX, node.maxX, node.minY, node.maxY, x1, x2, y1, y2)) continue;
      if (node.children != null) {
        for (int i = 0; i < node.children.length; ++i) queue.add(node.children[i]);
        continue;
      }
      if (node.objects == null) continue;
      for (int i = 0; i < node.objects.size(); ++i) {
        result.add(node.objects.get(i));
      }
    }
    return result;
  }
  ArrayList<GridObject> getPossibleCollisions(GridObject obj) {
    return getPossibleCollisions(obj.xPos - obj.w/2, obj.xPos + obj.w/2, obj.yPos - obj.h/2, obj.yPos + obj.h/2);
  }

  // Insert a point into tree, adds object into every block that it touches
  void insert(GridObject obj) {
    insert(head, obj);
  }
  void insert(QTNode[] nodes, GridObject obj) {
    for (int i = 0; i < nodes.length; ++i) {
      insert(nodes[i], obj);
    }
  }
  void insert(QTNode node, GridObject obj) {
    if (!in(node, obj)) return;
    if (node.children != null) {
      insert(node.children, obj);
      return;
    }
    if (node.point != null) {
      if (!(Math.abs(node.point.x - obj.xPos) <= epsilon) && !(Math.abs(node.point.y - obj.yPos) <= epsilon)) {
        node.createChildren();
        node.placePointInChildren(node.point);
        node.point = null;
        node.placeObjectsInChildren(node.objects);
        node.objects = null;

        insert(node.children, obj);
        return;
      }
    }
    if (node.objects == null) node.objects = new ArrayList<GridObject>();
    node.objects.add(obj);
    node.point = new Point(obj.xPos, obj.yPos);
  }

  // Draw all the nodes/blocks in the tree
  void display() {
    ArrayList<QTNode> list = new ArrayList<QTNode>();
    list.add(head);
    for (int i = 0; i < list.size(); ++i) {
      list.get(i).display();
      if (list.get(i).children != null) {
        for (int j = 0; j < list.get(i).children.length; ++j) list.add(list.get(i).children[j]);
      }
    }
  }
}

// Spatial Hash data structure
class SpatialHash {
  float cellSize;
  HashMap<String, ArrayList<GridObject>> bucket;
  SpatialHash(float cellSize) {
    this.cellSize = cellSize;
    bucket = new HashMap<String, ArrayList<GridObject>>();
  }
  ArrayList<GridObject> getPossibleCollisions(GridObject obj) {
    ArrayList<GridObject> result = getPossibleCollisions(obj.xPos-obj.w/2, obj.xPos+obj.w/2, obj.yPos-obj.h/2, obj.yPos+obj.h/2);
    for (GridObject o : result) {
      if (o == obj) {
        result.remove(o);
        break;
      }
    }
    return result;
  }
  ArrayList<GridObject> getPossibleCollisions(float x1, float x2, float y1, float y2) {
    ArrayList<GridObject> result = new ArrayList<GridObject>();
    float cellMinX = (float)Math.floor(x1/cellSize) * cellSize;
    float cellMaxX = (float)Math.floor(x2/cellSize) * cellSize;
    float cellMinY = (float)Math.floor(y1/cellSize) * cellSize;
    float cellMaxY = (float)Math.floor(y2/cellSize) * cellSize;
    for (float i = cellMinX; i <= cellMaxX; i += cellSize) {
      for (float j = cellMinY; j <= cellMaxY; j += cellSize) {
        ArrayList<GridObject> b = bucket.get(i + "," + j);
        if (b == null) continue;
        for (GridObject obj : b) {
          if (!result.contains(obj)) result.add(obj);
        }
      }
    }
    return result;
  }
  void insert(GridObject obj) {
    float minX = obj.xPos-obj.w/2;
    float minY = obj.yPos-obj.h/2;
    float maxX = obj.xPos+obj.w/2;
    float maxY = obj.yPos+obj.h/2;
    float cellMinX = (float)Math.floor(minX/cellSize) * cellSize;
    float cellMaxX = (float)Math.floor(maxX/cellSize) * cellSize;
    float cellMinY = (float)Math.floor(minY/cellSize) * cellSize;
    float cellMaxY = (float)Math.floor(maxY/cellSize) * cellSize;
    for (float i = cellMinX; i <= cellMaxX; i += cellSize) {
      for (float j = cellMinY; j <= cellMaxY; j += cellSize) {
        if (eitherIn(minX, maxX, minY, maxY, i, i+cellSize, j, j+cellSize))
          insertToBucket(i+","+j, obj);
      }
    }
  }
  
  void insertToBucket(String k, GridObject obj) {
    ArrayList<GridObject> b = bucket.get(k);
    if (b == null) {
      bucket.put(k, new ArrayList<GridObject>());
      b = bucket.get(k);
    }
    if (!b.contains(obj)) b.add(obj);
  }
  
  void display() {
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i < width; i += cellSize) {
      line(i, 0, i, height);
    }
    for (int i = 0; i < height; i += cellSize) {
      line(0, i, width, i);
    }
    
  }
  String toString() {
    return bucket.toString();
  }
}
