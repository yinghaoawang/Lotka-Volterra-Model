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
        this.predatorSize = 5;
        this.preySize = 5;
        this.deltaT = 30;
        this.x0 = 180;
        this.y0 = 60
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
        // move prey and predators
        for (var i = 0; i < this.preys.length; ++i) {
            var prey = this.preys[i];
            prey.move()
            this.keepInBounds(prey);
        }
        for (var i = 0; i < this.predators.length; ++i) {
            var predator = this.predators[i];
            predator.move()
            this.keepInBounds(predator);
            // predator hunt
            for (var j = 0; j < this.preys.length; ++j) {
                var prey = this.preys[j];
                // if predator is touching prey
                if (checkCollision(predator, prey) && (Math.random() < this.b)) {
                    this.preys.splice(j, 1);
                    --j;
                    // chance for predator to birth if succesfully hunts
                    if (Math.random() < this.d) {
                        var predatorChild = new Predator(predator.xPos, predator.yPos, predator.width, predator.height);
                        this.predators.push(predatorChild);
                        //console.log('predator ' + i + ' hunted prey ' + j + ' and produced a child');
                    }
                }
            }
        }

        // change direction at given times
        if (this.frameCount % this.dirChangeT == 0) {
            for (var i = 0; i < this.preys.length; ++i) this.preys[i].changeDirection();
            for (var i = 0; i < this.predators.length; ++i) this.predators[i].changeDirection();
        }

        // actions for a step
        if (this.frameCount % this.deltaT == 0) this.deltaTStep();
    }
    // actions every deltaT: reproduction, decay, hunting
    deltaTStep() {
        // predator acts second
        for (var i = 0; i < this.predators.length; ++i) {
            var predator = this.predators[i];
            // prevents recently produced babies from decaying
            if (predator.age < 1) {
                ++predator.age;
                continue;
            }
            // predator decay
            if (Math.random() < this.c) {
                this.predators.splice(i, 1);
                --i;
                continue;
            }
            ++predator.age;
        }
        // prey acts first
        for (var i = 0; i < this.preys.length; ++i) {
            var prey = this.preys[i];
            // prevents recently produced babies from reproducing
            if (prey.age < 1) {
                ++prey.age;
                continue;
            }
            // prey reproduction
            if (Math.random() < this.a) {
                var preyChild = new Prey(prey.xPos, prey.yPos, prey.width, prey.height);
                this.preys.push(preyChild);
            }
            ++prey.age;
        }
        this.logData();
    }
    // stores the creature data into the data array
    logData() {
        this.data[0].push(this.preys.length);
        this.data[1].push(this.predators.length);
    }
    // draw preys and predators onto canvas
    draw() {
        // clears screen
        this.ctx.clearRect(0, 0, this.width, this.height);
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
        
    }
}
