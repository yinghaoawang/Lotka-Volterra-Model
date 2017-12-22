// Determines if a rectangular object is in another rectangular object
boolean in(GridObject obj1, GridObject obj2) {
  return in(obj1.x-obj1.w/2, obj1.x+obj1.w/2, obj1.y-obj1.h/2, obj1.y+obj1.h/2, 
    obj2.x-obj2.w/2, obj2.x+obj2.w/2, obj2.y+obj2.h/2, obj2.y+obj2.h/2);
}
boolean in(QTNode node, GridObject obj) {
  return in(node, obj.x - obj.w/2, obj.x + obj.w/2, obj.y - obj.h/2, obj.y + obj.h/2);
}
boolean in(QTNode node, float x1, float x2, float y1, float y2) {
  return in(node.minX, node.maxX, node.minY, node.maxY, x1, x2, y1, y2);
}
boolean in(GridObject obj, float x1, float x2, float y1, float y2) {
  return in(obj.x - obj.w/2, obj.x+obj.w/2, obj.y-obj.h/2, obj.y+obj.h/2, x1, x2, y1, y2);
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
  return in(obj.x - obj.w/2, obj.x + obj.w/2, obj.y - obj.h/2, obj.y + obj.h/2, x, y);
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

// Object stored in the Quad Tree
class GridObject {
  float x, y, xVel, yVel;
  float w, h;
  color c;
  GridObject(float x, float y) {
    this(x, y, 10, 10);
  }
  GridObject(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
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
    rect(x, y, w, h);
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

// Quad Tree datastructure
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
        if (obj.x == x && obj.y == y) return obj;
      }
    }
    return null;
  }

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
      if (!(Math.abs(node.point.x - obj.x) <= epsilon) && !(Math.abs(node.point.y - obj.y) <= epsilon)) {
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
    node.point = new Point(obj.x, obj.y);
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
ArrayList<GridObject> pcObjs; // possibly colliding objects
int initCount = 500;
// Size of mouse box
float mbWidth = 50;
float mbHeight = 50;

boolean randomMotion = true;
boolean displayFPS = true;
boolean displayQT = true;
boolean displayObjects = true;

// Add an object on mouse click
void mouseClicked() {
  if (mouseButton == LEFT) {
    objs.add(new GridObject(mouseX, mouseY));
  } else if (mouseButton == RIGHT) {
    if (randomMotion) {
      randomMotion = false;
      for (int i = 0; i < objs.size(); ++i) {
        GridObject obj = objs.get(i);
        setObjectNoMotion(obj);
      }
    } else {
      randomMotion = true;
      for (int i= 0; i < objs.size(); ++i) {
        GridObject obj = objs.get(i);
        setObjectRandomMotion(obj);
      }
    }
  }
}

// Make object stop moving
void setObjectNoMotion(GridObject obj) {
  obj.xVel = 0;
  obj.yVel = 0;
}

// Make object move randomly
void setObjectRandomMotion(GridObject obj) {
  obj.xVel = (float)Math.random() * 5;
  obj.yVel = (float)Math.random() * 5;
  if (Math.random() < .5) obj.xVel *= -1;
  if (Math.random() < .5) obj.yVel *= -1;
}

// initialization
void setup() {
  size(1000, 1000); 
  objs = new ArrayList<GridObject>();
  pcObjs = new ArrayList<GridObject>();

  // create initial random objects
  for (int i = 0; i < initCount; ++i) {
    GridObject obj = new GridObject((int)(Math.random() * width), (int)(Math.random() * height));
    if (randomMotion) {
      setObjectRandomMotion(obj);
    }

    objs.add(obj);
  }
}

void draw() {
  background(230);
  // Create a quad tree every frame because objects are dynamic
  QuadTree qt = new QuadTree(width, height);

  /*
  rectMode(CENTER);
  fill(80, 200, 80);
  rect(mouseX, mouseY, mbWidth, mbHeight);
  */

  // Handle each object
  for (int i = 0; i < objs.size(); ++i) {
    GridObject obj = objs.get(i);
    // Change direction every 30 frames
    if (randomMotion && frameCount % 30 == 0) {
      setObjectRandomMotion(obj);
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
    if (displayObjects) obj.display();

    // Insert object into quad tree
    qt.insert(obj);
  }
  
  // Make every object have original color
  for (int i = 0; i < objs.size(); ++i) objs.get(i).c = color(80, 80, 80);
  
  // Collision detection and coloring
  for (int i = 0; i < objs.size(); ++i) {
    GridObject obj = objs.get(i);
    pcObjs = qt.getPossibleCollisions(obj.x-obj.w/2, obj.x+obj.w/2, obj.y-obj.h/2, obj.y+obj.h/2);
    for (int j = 0; j < pcObjs.size(); ++j) {
      GridObject collObj = pcObjs.get(j);
      if (obj == collObj) continue;
      if (eitherIn(obj.x-obj.w/2, obj.x+obj.w/2, obj.y-obj.h/2, obj.y+obj.h/2, collObj.x-collObj.w/2, collObj.x+collObj.w/2, collObj.y-collObj.h/2, collObj.y+collObj.h/2)) {
        obj.c = color(200, 80, 80);
        collObj.c = color(200, 80, 80);
      } else {
        if (collObj.c == color(80, 80, 80)) collObj.c = color(80, 80, 200);
      }
    }
  }
  
  /*
  for (int i = 0; i < pcObjs.size(); ++i) pcObjs.get(i).c = color(80, 80, 80);
  pcObjs = qt.getPossibleCollisions(mouseX - mbWidth/2, mouseX + mbWidth/2, mouseY - mbHeight/2, mouseY + mbHeight/2);
  for (int i = 0; i < pcObjs.size(); ++i) {
    GridObject obj = pcObjs.get(i);
    if (eitherIn(obj.x-obj.w/2, obj.x+obj.w/2, obj.y-obj.h/2, obj.y+obj.h/2, mouseX - mbWidth/2, mouseX + mbWidth/2, mouseY - mbHeight/2, mouseY + mbHeight/2)) {
      obj.c = color(200, 80, 80);
    } else {
      obj.c = color(80, 80, 200);
    }
  }
  */

  // Draw quadtree blocks
  if (displayQT) qt.display();

  // Draw fps
  if (displayFPS) {
    fill(0);
    text((int)frameRate, 10, 20);
  }
  
  /*
  // Choose a random object every 300 frames, and find it using search method and color it (just a demo)
   if (frameCount % 300 == 0 && objs.size() > 0) {
   GridObject obj = objs.get((int)(Math.random() * objs.size()));
   GridObject found = qt.search(obj.x, obj.y);
   println("We " + ((found == obj) ? "have " : "have not ") + "found the object");
   if (found != null) found.c = color(255, 0, 0);
   }
  */
}