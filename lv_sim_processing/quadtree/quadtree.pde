class GridObject {
  float x, y, xVel, yVel;
  GridObject(float x, float y) {
    this.x = x;
    this.y = y;
    this.xVel = 0;
    this.yVel = 0;
  }
  void display() {
    stroke(0);
    fill(80, 80, 80);
    ellipse(x, y, 10, 10);
  }
}

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
    //if (datum != null) datum.display();
  }
  String toString() {
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
  void insert(float x, float y) {
    GridObject obj = new GridObject(x, y);
    insert(obj, x, y);
  }
  void insert(GridObject obj) {
    insert(obj, obj.x, obj.y);
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
        //println("found: " + x + ", " + y);
        return node.datum;
      }
      break;
    }
    return null;
  }
  void insert(GridObject obj, float x, float y) {
    QTNode node = head;
    while (node != null) {
      if (!in(node, obj.x, obj.y)) {
        node = node.nextSibling;
        continue;
      }
      //println(x + ", " + y + " Is in " + node.minX + ", " + node.maxX + "-" + node.minY + ", " + node.maxY);
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
    //println("inserted " + obj.x + " " + obj.y);
  }
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
    //println(node.children[1]);
  }
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
int initCount = 0;//1000;

void mouseClicked() {
  objs.add(new GridObject(mouseX, mouseY));
}
void setup() {
  size(2000, 1500); 
  objs = new ArrayList<GridObject>();
  for (int i = 0 ; i < initCount; ++i) {
    objs.add(new GridObject((int)(Math.random() * width), (int)(Math.random() * height)));
  }
}
void draw() {
  background(230);
  QuadTree qt = new QuadTree(width, height);
  for (int i = 0; i < objs.size(); ++i) {
    GridObject obj = objs.get(i);
    if (frameCount % 30 == 0) {
      obj.xVel = (float)Math.random() * 5;
      obj.yVel = (float)Math.random() * 5;
      if (Math.random() < .5) obj.xVel *= -1;
      if (Math.random() < .5) obj.yVel *= -1;
      //println(frameRate);
    }
    obj.x += obj.xVel;
    obj.y += obj.yVel;
    if (obj.x > width) obj.x -= width;
    if (obj.x < 0) obj.x += width;
    if (obj.y > height) obj.y -= height;
    if (obj.y < 0) obj.y += height;
    
    obj.display();
    qt.insert(obj);
  }
  if (frameCount % 30 == 0 && objs.size() > 0) {
    GridObject obj = objs.get((int)(Math.random() * objs.size()));
    GridObject found = qt.search(obj.x, obj.y);
    //println(obj + " " + found);
  }

  qt.display();
}