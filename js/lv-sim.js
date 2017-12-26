// Simulation is represented as an object
class LVSim {
    constructor(canvas) {
        this.fps = 60;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;
        this.a = .25;
        this.b = 1;
        this.c = .1;
        this.d = .2;
        this.dirChangeT = 30;
        this.predatorSize = 3;
        this.preySize = 3;
        this.deltaT = 30;
        this.x0 = this.width/3;
        this.y0 = this.x0/3;
        this.useSpatialHash = true;
        this.showSpatialHash = false;
        this.sh = null;
    }
    init() {
        this.data = [[], []]
        this.preys = [];
        this.predators = [];
        for (var i = 0; i < this.x0; ++i) this.preys.push(this.newRandomPrey());
        for (var i = 0; i < this.y0; ++i) this.predators.push(this.newRandomPredator());
        // log initial data
        //this.logData();
        this.frameCount = 0;
        this.draw();
    }
    // update and draw loop
    run() {
        var self = this;
        var intervalID = setInterval(function() {
            self.update();
            self.draw();
            ++self.frameCount;
        }, 1000/this.fps);
        this.intervalID = intervalID;
        return intervalID;
    }
    // move creature to other side of bounds if out of bounds
    keepInBounds(creature) {
        if (creature.xPos > this.width) creature.xPos -= this.width;
        if (creature.xPos < 0) creature.xPos += this.width;
        if (creature.yPos > this.height) creature.yPos -= this.height;
        if (creature.yPos < 0) creature.yPos += this.height;
    }
    // creature interactions every frame
    update() {
        if (this.useSpatialHash) this.sh = new SpatialHash(Math.max(this.preySize * 4, this.width/(this.preys.length/5)));

        // change direction at given times
        if (this.frameCount % this.dirChangeT == 0) {
            for (var i = 0; i < this.preys.length; ++i) this.preys[i].changeDirection();
            for (var i = 0; i < this.predators.length; ++i) this.predators[i].changeDirection();
        }

        // prey actions
        for (var i = 0; i < this.preys.length; ++i) {
            var prey = this.preys[i];
            // recently birthed children cannot act
            if (prey.age < 1) {
                ++prey.age;
                continue;
            }
            prey.move()
            this.keepInBounds(prey);
            // prey reproduction
            if (this.frameCount % this.deltaT == 0 && Math.random() < this.a) {
                var preyChild = new Prey(prey.xPos, prey.yPos, prey.width, prey.height);
                this.preys.push(preyChild);
            }

            ++prey.age;
        }

        if (this.useSpatialHash) {
            for (var i = 0; i < this.preys.length; ++i) {
                this.sh.insert(this.preys[i]);
            }
        }

        // Predator actions
        for (var i = 0; i < this.predators.length; ++i) {
            var predator = this.predators[i];
            // recently birthed children cannot act
            if (predator.age < 1) {
                ++predator.age;
                continue;
            }
            // predator decay
            if (this.frameCount % this.deltaT == 0 && Math.random() < this.c) {
                this.predators.splice(i, 1);
                --i;
                continue;
            }
            // move predator
            predator.move()
            this.keepInBounds(predator);
            // predator hunt
            var possibleCollisions;
            if (this.useSpatialHash) {
                possibleCollisions = this.sh.getPossibleCollisions(predator.xPos-predator.width/2, predator.xPos+predator.width/2, predator.yPos-predator.height/2, predator.yPos+predator.height/2);
            } else { // brute force algorithm
                possibleCollisions = this.preys;
            }
            for (var j = 0; j < possibleCollisions.length; ++j) {
                var prey = possibleCollisions[j];
                // if predator is touching prey
                if (checkCollision(predator, prey) && (Math.random() < this.b)) {
                    var index = this.preys.indexOf(prey);
                    this.preys.splice(index, 1);
                    // chance for predator to birth if succesfully hunts
                    if (Math.random() < this.d) {
                        var predatorChild = new Predator(predator.xPos, predator.yPos, predator.width, predator.height);
                        this.predators.push(predatorChild);
                    }
                }
            }
            ++predator.age;
        }
        if (this.frameCount % this.deltaT == 0) this.logData();

    }

    // stores the creature data into the data array
    logData() {
        this.data[0].push(this.preys.length);
        this.data[1].push(this.predators.length);
    }

    getData() {
        var data = "";
        data += "prey: [";
        for (var i = 0; i < this.data[0].length; ++i) {
            data+=this.data[0][i];
            if (i != this.data[0].length-1) data+= ",";
        }
        data += "]\npredator:[";
        for (var i = 0; i < this.data[1].length; ++i) {
            data+=this.data[1][i];
            if (i != this.data[1].length-1) data+= ",";
        }
        data += "]";
        return data;
    }
    getPairData() {
        return this.data;
    }
    // draw preys and predators onto canvas
    draw() {
        // clears screen
        this.ctx.clearRect(0, 0, this.width, this.height);
        // draws spatial hash chart if wanted
        if (this.useSpatialHash && this.showSpatialHash && this.sh != null) this.sh.display(this.ctx, this.width, this.height);
        // draw predator/prey every frame
        for (var i = 0; i < this.preys.length; ++i) {
            this.preys[i].display(this.ctx);
        }
        for (var i = 0; i < this.predators.length; ++i) {
            this.predators[i].display(this.ctx);
        }
    }
    // helpers
    newRandomPrey() {
        return new Prey(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.preySize, this.preySize);
    }
    newRandomPredator() {
        return new Predator(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.predatorSize, this.predatorSize);
    }
}

// true if a point is in a rectangle
function pointInRect(Ax1, Ax2, Ay1, Ay2, x, y) {
    return x >= Ax1 && x <= Ax2 && y >= Ay1 && y <= Ay2;
}
// true if second (B) rectangle is in first (A) rectangle
function rectInRect(Ax1, Ax2, Ay1, Ay2, Bx1, Bx2, By1, By2) {
    return pointInRect(Ax1, Ax2, Ay1, Ay2, Bx1, By1) || pointInRect(Ax1, Ax2, Ay1, Ay2, Bx1, By2)
        || pointInRect(Ax1, Ax2, Ay1, Ay2, Bx2, By1) || pointInRect(Ax1, Ax2, Ay1, Ay2, Bx2, By2);
}
// true if any rectangle is in the other rectangle
function eitherRectInRect(Ax1, Ax2, Ay1, Ay2, Bx1, Bx2, By1, By2) {
    return rectInRect(Ax1, Ax2, Ay1, Ay2, Bx1, Bx2, By1, By2) || rectInRect(Bx1, Bx2, By1, By2, Ax1, Ax2, Ay1, Ay2);
}

// checks collision between 2 circular creatures
function checkCollision(creature1, creature2) {
    if (creature1 == null || creature2 ==  null) {
        console.error('Collision check on a null object');
        return false;
    }
    return eitherRectInRect(creature1.xPos - creature1.width/2, creature1.xPos + creature1.width/2,
        creature1.yPos - creature1.height/2, creature1.yPos + creature1.height/2,
        creature2.xPos - creature2.width/2, creature2.xPos + creature2.width/2,
        creature2.yPos - creature2.height/2, creature2.yPos + creature2.height/2);
}

// classes
class Creature {
    constructor(xPos, yPos, width, height) {
        this.xPos = xPos;
        this.yPos = yPos;
        this.speed = 3;
        this.xVel = 0;
        this.yVel = 0;
        this.changeDirection();
        this.width = width;
        this.height = height;
        this.age = 0;
        this.color = new Color(0, 0, 0);
    }
    move() {
        this.xPos += this.xVel;
        this.yPos += this.yVel;
    }
    // changes direction to a random direction based on speed
    changeDirection() {
        this.xVel = Math.random() * this.speed + this.speed * .2;
        this.yVel = Math.random() * this.speed + this.speed * .2;
        /*
        this.xVel = this.speed;
        this.yVel = this.speed;
        */
        if (Math.random() < .5) this.xVel *= -1;
        if (Math.random() < .5) this.yVel *= -1;
    }
    display(ctx) {
        // draw circle
        ctx.fillStyle = this.color;
        ctx.fillRect(this.xPos - this.width/2, this.yPos - this.height/2, this.width, this.height);
    }
}


class Prey extends Creature {
    constructor(xPos, yPos, width, height) {
        super(xPos, yPos, width, height);
        this.color = new Color(255, 80, 80);
    }
}
class Predator extends Creature {
    constructor(xPos, yPos, width, height) {
        super(xPos, yPos, width, height);
        this.color = new Color(80, 80, 255);
    }
}

class Color {
    constructor(r, g, b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }
    toString() {
        return 'rgb(' + this.r + ',' + this.g + ',' + this.b + ')';
    }
}

class SpatialHash {
    constructor(cellSize) {
        this.cellSize = cellSize;
        this.buckets = {};
    }
    insert(creature) {
        var minX = creature.xPos - creature.width/2;
        var maxX = creature.xPos + creature.width/2;
        var minY = creature.yPos - creature.height/2;
        var maxY = creature.yPos + creature.height/2;
        var cellMinX = Math.floor(minX/this.cellSize)*this.cellSize;
        var cellMaxX = Math.floor(maxX/this.cellSize)*this.cellSize;
        var cellMinY = Math.floor(minY/this.cellSize)*this.cellSize;
        var cellMaxY = Math.floor(maxY/this.cellSize)*this.cellSize;
        for (var i = cellMinX; i <= cellMaxX; i+= this.cellSize) {
            for (var j = cellMinY; j <= cellMaxY; j+= this.cellSize) {
                if (eitherRectInRect(minX, maxX, minY, maxY, i, i+this.cellSize, j, j+this.cellSize)) {
                    this.insertToBucket(i+","+j, creature);
                }
            }
        }
    }
    insertToBucket(key, obj) {
        if (this.buckets[key] === undefined) this.buckets[key] = [];
        if (!this.buckets[key].includes(obj)) {
            this.buckets[key].push(obj);
        }
    }
    getPossibleCollisions(x1, x2, y1, y2) {
        var possibleCollisions = [];
        var cellMinX = Math.floor(x1/this.cellSize)*this.cellSize;
        var cellMaxX = Math.floor(x2/this.cellSize)*this.cellSize;
        var cellMinY = Math.floor(y1/this.cellSize)*this.cellSize;
        var cellMaxY = Math.floor(y2/this.cellSize)*this.cellSize;
        for (var i = cellMinX; i <= cellMaxX; i+= this.cellSize) {
            for (var j = cellMinY; j <= cellMaxY; j+= this.cellSize) {
                if (this.buckets[i+","+j] === undefined) {
                    continue;
                }
                for (var k = 0; k < this.buckets[i+","+j].length; ++k) {

                    var item = this.buckets[i+","+j][k];
                    if (!possibleCollisions.includes(item)) possibleCollisions.push(item);
                }
                /*
                this.buckets[i+","+j].forEach(function(item) {
                    if (!possibleCollisions.includes(item)) possibleCollisions.push(item);
                });
                */
            }
        }
        return possibleCollisions;
    }
    display(ctx, width, height) {
        ctx.lineWidth = .5;
        for (var i = 0; i <= width; i += this.cellSize) {
            ctx.beginPath();
            ctx.moveTo(i, 0);
            ctx.lineTo(i, height);
            ctx.stroke();
        }
        for (var i = 0; i <= height; i += this.cellSize) {
            ctx.beginPath();
            ctx.moveTo(0, i);
            ctx.lineTo(width, i);
            ctx.stroke();
        }
    }
}
