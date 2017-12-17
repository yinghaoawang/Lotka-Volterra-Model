class GridObject {
  float x, y;
  GridObject(float x, float y) {
    this.x = x;
    this.y = y;
  }
  void display() {
    noStroke();
    fill(200, 80, 80);
    ellipse(x, y, 5, 5);
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
    if (datum != null) datum.display();
  }
}

class QuadTree {
  QTNode head;
  int maxDepth;
  QuadTree(float x, float y) {
    head = new QTNode(x, y);
    maxDepth = 5;
  }
  void insert(float x, float y) {
    GridObject obj = new GridObject(x, y);
    insert(obj, x, y);
  }
  void insert(GridObject obj) {
    insert(obj, obj.x, obj.y);
  }
  void insert(GridObject obj, float x, float y) {
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
        createChildNodes(node);
        transferObjIntoChildNodes(node);
        node = node.children[0];
        continue;
      }
      node.datum = obj;
      break;
    }
    println("inserted " + obj.x + " " + obj.y);
  }
  boolean in(QTNode node, float x, float y) {
    return x >= head.minX && x <= head.maxX && y >= node.minY && y <= node.maxY;
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


QuadTree qt;
void mouseClicked() {
  qt.insert(new GridObject(mouseX, mouseY));
}
void setup() {
  size(1000, 1000);
  
  qt = new QuadTree(width, height);
  
}
void draw() {
  background(80);
  qt.display();
}