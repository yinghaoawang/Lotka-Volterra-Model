var LVSim = function(canvas) {
    var width, height;
    var a, b, c, d;
    var dirChangeT;
    var preySize, predatorSize;
    var deltaT;
    var preys, predators;
    var x0, y0;
    this.width = canvas.width();
    this.height = canvas.height();
    this.a = .25;
    this.b = .15;
    this.c = .15;
    this.d = .1;
    this.dirChangeT = 30;
    this.predatorSize = 3;
    this.preySize = 3;
    this.deltaT = 30;
    this.x0 = 300;
    this.y0 = 100;
    this.init = function() {
        this.preys = [];
        this.predators = [];
        for (var i = 0; i < this.x0; ++i) this.preys.push(this.newRandomPrey());
        for (var i = 0; i < this.y0; ++i) this.predators.push(this.newRandomPredator());
    }
    this.newRandomPrey = function() {
        return new Prey(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.preySize);
    }
    this.newRandomPredator = function() {
        return new Predator(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.predatorSize);
    }
}

LVSim.prototype.newRandomPredator = function() {
    return new Predator(Math.floor(Math.random() * this.width), Math.floor(Math.random() * this.height), this.predatorSize);
}

class Creature {
    constructor(xPos, yPos, size) {
        this.xPos = xPos;
        this.yPos = yPos;
        this.size = size;
        this.age = 0;
    }
}


class Prey extends Creature {
    constructor(xPos, yPos, size) {
        super(xPos, yPos, size);
        this.color =  new Color(255, 80, 80);
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
}
