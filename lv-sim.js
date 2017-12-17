var LVSim = function(canvas) {
    this.fps = 30;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;
    this.a = .25;
    this.b = .15;
    this.c = .15;
    this.d = .1;
    this.dirChangeT = 10;
    this.predatorSize = 1;
    this.preySize = 1;
    this.deltaT = 30;
    this.x0 = 300;
    this.y0 = 100
    this.init = function() {
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
    this.run = function() {
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
    this.keepInBounds = function(creature) {
        if (creature.xPos > this.width) creature.xPos -= this.width;
        if (creature.xPos < 0) creature.xPos += this.width;
        if (creature.yPos > this.height) creature.yPos -= this.height;
        if (creature.yPos < 0) creature.yPos += this.height;
    }
    // creature interactions every frame
    this.update = function() {
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
    this.deltaTStep = function() {
        for (var i = 0; i < this.preys.length; ++i) {
            var prey = this.preys[i];
            // prevents recently produced babies from reproducing
            if (prey.age < 1) {
                ++prey.age;
                continue;
            }
            // prey reproduction
            if (Math.random() < this.a) {
                var preyChild = new Prey(prey.xPos, prey.yPos, prey.size);
                this.preys.push(preyChild);
                continue;
            }
            ++prey.age;
        }
        for (var i = 0; i < this.predators.length; ++i) {
            var predator = this.predators[i];
            // prevents recently produced babies from decaying
            if (predator.age < 1) {
                ++predator.age;
                continue;
            }
            // predator decay
            if (Math.random() < this.c) {
                this.predators.pop(i);
                --i;
                continue;
            }
            ++predator.age;
        }
        this.logData();
    }
    // stores the creature data into the data array
    this.logData = function() {
        this.data[0].push(this.preys.length);
        this.data[1].push(this.predators.length);
    }
    // draw preys and predators onto canvas
    this.draw = function() {
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
    this.newRandomPrey = function() {
        return new Prey(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.preySize);
    }
    this.newRandomPredator = function() {
        return new Predator(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.predatorSize);
    }
}

// classes
class Creature {
    constructor(xPos, yPos, size) {
        this.xPos = xPos;
        this.yPos = yPos;
        this.speed = 3;
        this.xVel = 0;
        this.yVel = 0;
        this.changeDirection();
        this.size = size;
        this.age = 0;
        this.color = new Color(0, 0, 0);
    }
    move() {
        this.xPos += this.xVel;
        this.yPos += this.yVel;
    }
    // changes direction to a random direction based on speed
    changeDirection() {
        this.xVel = Math.random() * this.speed;
        this.yVel = Math.random() * this.speed;
        if (Math.random() < .5) this.xVel *= -1;
        if (Math.random() < .5) this.yVel *= -1;
    }
    display(ctx) {
        // draw circle
        ctx.beginPath();
        ctx.arc(this.xPos, this.yPos, this.size, 0, 2 * Math.PI);
        ctx.fillStyle = this.color;
        ctx.fill();
    }
}


class Prey extends Creature {
    constructor(xPos, yPos, size) {
        super(xPos, yPos, size);
        this.color = new Color(255, 80, 80);
    }
}
class Predator extends Creature {
    constructor(xPos, yPos, size) {
        super(xPos, yPos, size);
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
