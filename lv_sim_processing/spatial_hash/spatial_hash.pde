
// Object that belongs on a grid
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

// Determines if a rectangular object is in another rectangular object
boolean in(GridObject obj1, GridObject obj2) {
  return in(obj1.x-obj1.w/2, obj1.x+obj1.w/2, obj1.y-obj1.h/2, obj1.y+obj1.h/2, 
    obj2.x-obj2.w/2, obj2.x+obj2.w/2, obj2.y+obj2.h/2, obj2.y+obj2.h/2);
}
boolean in(GridObject obj, float x1, float x2, float y1, float y2) {
  return in(obj.x - obj.w/2, obj.x+obj.w/2, obj.y-obj.h/2, obj.y+obj.h/2, x1, x2, y1, y2);
}
boolean in(float Ax1, float Ax2, float Ay1, float Ay2, float Bx1, float Bx2, float By1, float By2) {

  return (in(Ax1, Ax2, Bx1) || in(Ax1, Ax2, Bx2)) &&
    (in(Ay1, Ay2, By1) || in(Ay1, Ay2, By2));
}

// Determines if a point is in a rectangular object
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

class SpatialHash {
  float cellSize;
  HashMap<String, ArrayList<GridObject>> bucket;
  SpatialHash(float cellSize) {
    this.cellSize = cellSize;
    bucket = new HashMap<String, ArrayList<GridObject>>();
  }
  void insert(GridObject obj) {
    float minX = obj.x-obj.w/2;
    float minY = obj.y-obj.h/2;
    float maxX = obj.x+obj.w/2;
    float maxY = obj.y+obj.h/2;
    float cellMinX = (float)Math.floor(minX/cellSize) * cellSize;
    float cellMinY = (float)Math.floor(minY/cellSize) * cellSize;
    float cellMaxX = (float)Math.floor(maxX/cellSize) * cellSize;
    float cellMaxY = (float)Math.floor(maxY/cellSize) * cellSize;
    println(minX, minY, maxX, maxY, cellMinX, cellMinY, cellMaxX, cellMaxY);
    for (float i = cellMinX; i <= cellMaxX; i += cellSize) {
      for (float j = cellMinY; j <= cellMaxY; j += cellSize) {
        println(minX, maxX, minY, maxY, i, i+cellSize, j, j+cellSize);
        if (eitherIn(minX, maxX, minY, maxY, i, i+cellSize, j, j+cellSize))
          insertToBucket(i+","+j, obj);
      }
    }
  }
  
  void insertToBucket(String k, GridObject obj) {
    println(k);
    ArrayList<GridObject> b = bucket.get(k);
    if (b == null) {
      bucket.put(k, new ArrayList<GridObject>());
      b = bucket.get(k);
    }
    if (!b.contains(obj)) b.add(obj);
  }
  
  void display() {
    stroke(0);
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


boolean displaySH = true;
int x0 = 20;
ArrayList<GridObject> objs;
SpatialHash sh;
void setup() {
  size(1000, 1000);
  objs = new ArrayList<GridObject>();
  sh = new SpatialHash(width/10);
  //for (int i = 0; i < x0; ++i)
  objs.add(new GridObject((float)Math.random() * width, (float)Math.random() * height, 100, 200));
  for (GridObject obj : objs) {
    sh.insert(obj);
    obj.display();
  }
  println(sh);
}

void draw() {
  if (displaySH) sh.display();
}