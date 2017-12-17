// Object stored in the Quad Tree
class GridObject {
  float x, y, xVel, yVel;
  color c;
  GridObject(float x, float y) {
    this.x = x;
    this.y = y;
    this.xVel = 0;
    this.yVel = 0;
    this.c = color(80, 80, 80);
  }
  void display() {
    noStroke();
    fill(c);
    ellipse(x, y, 5, 5);
  }
}

// Node used in the Quad Tree
class QTNode {
  float minX, maxX, minY, maxY;
  QTNode parent;
  QTNode nextSibling;
  QTNode[] children;
  GridObject datum;
  QTNode(float minX, float maxX, float minY, float maxY, QTNode parent) {
    datum = null;
    children = null;
    this.parent = parent;
    this.nextSibling = null;
    this.minX = minX;
    this.minY = minY;
    this.maxX = maxX;
    this.maxY = maxY;
  }
  QTNode(float minX, float maxX, float minY, float maxY) {
    this(minX, maxX, minY, maxY, null);
  }
  QTNode(float x, float y) {
    this(0, x, 0, y);
  }
  void display() {
    noFill();
    stroke(0);
    rect(minX, minY, maxX-minX, maxY-minY);
  }
  String toString() {
    // Draws the block the node represents
    return this.minX + ", " + this.maxX + ' ' + this.minY + ", " + this.maxY;
  }
}

class QuadTree {
  QTNode head;
  int maxDepth;
  float epsilon;
  QuadTree(float x, float y) {
    head = new QTNode(x, y);
    maxDepth = 5;
    epsilon = 0;
  }

  GridObject search(float x, float y) {
    QTNode node = head;
    while (node != null) {
      if (!in(node, x, y)) {
        node = node.nextSibling;
        continue;
      }
      if (node.children != null) {
        node = node.children[0];
        continue;
      }
      if (node.datum != null && node.datum.x == x && node.datum.y == y) {
        return node.datum;
      }
      break;
    }
    return null;
  }
  
  // Insert a point into 
  void insert(GridObject obj) {
    QTNode node = head;
    while (node != null) {
      if (!in(node, obj.x, obj.y)) {
        node = node.nextSibling;
        continue;
      }
      if (node.children != null) {
        node = node.children[0];
        continue;
      }
      if (node.datum != null) {
        //if (node.datum.x == obj.x && node.datum.y == obj.y) break; // TODO REMOVE
        if (Math.abs(node.datum.x - obj.x) <= epsilon || Math.abs(node.datum.y - obj.y) <= epsilon) break; // TODO REMOVE
        createChildNodes(node);
        transferObjIntoChildNodes(node);
        node = node.children[0];
        continue;
      }
      node.datum = obj;
      break;
    }
  }
  
  // Determines if a point is in bounds of the node/block
  boolean in(QTNode node, float x, float y) {
    return x >= node.minX && x <= node.maxX && y >= node.minY && y <= node.maxY;
  }
  void transferObjIntoChildNodes(QTNode node) {
    GridObject obj = node.datum;
    for (int i = 0; i < node.children.length; ++i) {
      QTNode childNode = node.children[i];
      if (in(childNode, obj.x, obj.y)) {
        childNode.datum = obj;
        node.datum = null;
        break;
      }
    }
  }
  
  // Create 4 child nodes in a node
  void createChildNodes(QTNode node) {
    float centerX = (node.minX + node.maxX)/2;
    float centerY = (node.minY + node.maxY)/2;
    node.children = new QTNode[4];
    node.children[0] = new QTNode(node.minX, centerX, node.minY, centerY, node);
    node.children[1] = new QTNode(centerX, node.maxX, node.minY, centerY, node);
    node.children[2] = new QTNode(node.minX, centerX, centerY, node.maxY, node);
    node.children[3] = new QTNode(centerX, node.maxX, centerY, node.maxY, node);
    node.children[0].nextSibling = node.children[1];
    node.children[1].nextSibling = node.children[2];
    node.children[2].nextSibling = node.children[3];
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

// globals
ArrayList<GridObject> objs;
int initCount = 300;//1000;

// Add an object on mouse click
void mouseClicked() {
  objs.add(new GridObject(mouseX, mouseY));
}

// initialization
void setup() {
  size(1000, 1000); 
  objs = new ArrayList<GridObject>();
  
  // create initial random objects
  for (int i = 0 ; i < initCount; ++i) {
    GridObject obj = new GridObject((int)(Math.random() * width), (int)(Math.random() * height));
    obj.xVel = (float)Math.random() * 5;
    obj.yVel = (float)Math.random() * 5;
    if (Math.random() < .5) obj.xVel *= -1;
    if (Math.random() < .5) obj.yVel *= -1;
    objs.add(obj);
  }
}

void draw() {
  background(230);
  // Create a quad tree every frame because objects are dynamic
  QuadTree qt = new QuadTree(width, height);
  
  // Handle each object
  for (int i = 0; i < objs.size(); ++i) {
    GridObject obj = objs.get(i);
    // Change direction every 30 frames
    if (frameCount % 30 == 0) {
      obj.xVel = (float)Math.random() * 5;
      obj.yVel = (float)Math.random() * 5;
      if (Math.random() < .5) obj.xVel *= -1;
      if (Math.random() < .5) obj.yVel *= -1;
      println((int)frameRate);
    }
    // Move objects
    obj.x += obj.xVel;
    obj.y += obj.yVel;
    // Move to other side if out of bounds
    if (obj.x > width) obj.x -= width;
    if (obj.x < 0) obj.x += width;
    if (obj.y > height) obj.y -= height;
    if (obj.y < 0) obj.y += height;
    
    // Draw object
    obj.display();
    // Insert object into quad tree
    qt.insert(obj);
  }
  // Choose a random object every 300 frames, and find it using search method and color it (just a demo)
  if (frameCount % 300 == 0 && objs.size() > 0) {
    GridObject obj = objs.get((int)(Math.random() * objs.size()));
    GridObject found = qt.search(obj.x, obj.y);
    println("We " + ((found == obj) ? "have " : "have not ") + "found the object");
    found.c = color(255, 0, 0);
  }

  // Draw quadtree blocks
  qt.display();
}