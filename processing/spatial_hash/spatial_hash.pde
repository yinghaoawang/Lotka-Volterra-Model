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

class SpatialHash {
  float cellSize;
  HashMap<String, ArrayList<GridObject>> bucket;
  SpatialHash(float cellSize) {
    this.cellSize = cellSize;
    bucket = new HashMap<String, ArrayList<GridObject>>();
  }
  ArrayList<GridObject> getPossibleCollisions(GridObject obj) {
    ArrayList<GridObject> result = getPossibleCollisions(obj.x-obj.w/2, obj.x+obj.w/2, obj.y-obj.h/2, obj.y+obj.h/2);
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
    float minX = obj.x-obj.w/2;
    float minY = obj.y-obj.h/2;
    float maxX = obj.x+obj.w/2;
    float maxY = obj.y+obj.h/2;
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

void stepObject(GridObject obj) {
  if (frameCount % deltaT == 0) {
    obj.xVel = (float)Math.random() * 3 + 2;
    obj.yVel = (float)Math.random() * 3 + 2;
    if (Math.random() < .5) obj.xVel *= -1;
    if (Math.random() < .5) obj.yVel *= -1;
  }
  obj.x += obj.xVel;
  obj.y += obj.yVel;
  if (obj.x > width) obj.x -= width;
  if (obj.x < 0) obj.x += width;
  if (obj.y > height) obj.y -= height;
  if (obj.y < 0) obj.y += height;
}


/* RUNNER -------------- */
boolean displaySH = true;
boolean displayFPS = true;
boolean displayMouseBox = true;
boolean displayObjects = true;

int x0 = 500;
ArrayList<GridObject> objs;
float mbWidth = 10;
float mbHeight = 10;
float objSize = 20;
float deltaT = 30;
SpatialHash sh;
void setup() {
  size(1000, 1000);
  objs = new ArrayList<GridObject>();
  sh = new SpatialHash(width/10);
  for (int i = 0; i < x0; ++i) {
    GridObject o = new GridObject((float)Math.random() * width, (float)Math.random() * height, objSize, objSize);
    stepObject(o);
    objs.add(o);
  }
  println(width/25, objSize*((float)width/(float)objs.size()));
}

void draw() {
  //sh = new SpatialHash(width/10);
  sh = new SpatialHash(Math.max(width/25, objSize*((float)width/objs.size())));
  
  background(200);
  for (GridObject obj : objs) {
    obj.c = color(80, 80, 80);
    stepObject(obj);
    sh.insert(obj);
  }
  ArrayList<GridObject> pcObjs = sh.getPossibleCollisions(mouseX - mbWidth/2, mouseX + mbWidth/2, mouseY - mbHeight/2, mouseY + mbHeight/2);
  for (GridObject o : pcObjs) {
    o.c = color(20, 220, 180);
    if (eitherIn(mouseX - mbWidth/2, mouseX + mbWidth/2, mouseY - mbHeight/2, mouseY + mbHeight/2,o.x-o.w/2, o.x+o.w/2, o.y-o.h/2, o.y+o.h/2))
      o.c = color(180, 20, 20);
  }
  if (displayObjects)
    for (GridObject obj : objs) obj.display();
  if (displayMouseBox) {
    rectMode(CENTER);
    fill(20, 180, 20);
    rect(mouseX, mouseY, mbWidth, mbHeight);
  }
  if (displaySH) sh.display();
  if (displayFPS) {
    rectMode(CORNER);
    fill(0);
    text((int)frameRate, 10, 20);
  }
}