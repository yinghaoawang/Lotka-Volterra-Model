class Graph {
    constructor(canvas) {
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;
        this.data = [[],[]];
    }
    setData(data) {
        this.data = data;
    }
    getMinMax() {
        var d1 = this.data[0];
        var d2 = this.data[1];
        if (d1.length == 0 && d2.length == 0) return [0, 0];
        var min, max;
        if (d1.length > 0) {
            var val = d1[0];
            min = val;
            max = val;
        } else if (d2.length > 0) {
            var val = d2[0];
            min = val;
            max = val;
        }
        for (var i = 0; i < d1.length; ++i) {
            var val = d1[i];
            if (val < min) min = val;
            if (val > max) max = val;
        }
        for (var i = 0; i < d2.length; ++i) {
            var val = d2[i];
            if (val < min) min = val;
            if (val > max) max = val;
        }
        return [min, max];
    }
    display() {
        this.ctx.clearRect(0, 0, this.width, this.height);
        var minMax = this.getMinMax();
        var min = minMax[0];
        var max = minMax[1];
        //min = Math.min(min, 0);
        var d1 = this.data[0];
        var d2 = this.data[1];
        var maxLen = Math.max(d1.length, d2.length);
        var stepLen = this.width * ((1/(maxLen-1)));
        // prey lines
        this.ctx.beginPath();
        this.ctx.strokeStyle = "red";
        for (var i = 0; i < d1.length; ++i) {
            var y = this.height-(this.height * (d1[i]/max));
            if (i == 0) {
                this.ctx.moveTo(stepLen*i, y);
            } else {
                this.ctx.lineTo(stepLen*i, y);
            }
        }
        this.ctx.stroke();
        // predator lines
        this.ctx.beginPath();
        this.ctx.strokeStyle = "blue";
        for (var i = 0; i < d2.length; ++i) {
            var y = this.height-(this.height * (d2[i]/max));
            if (i == 0) {
                this.ctx.moveTo(stepLen*i, y);
            } else {
                this.ctx.lineTo(stepLen*i, y);
            }
        }
        this.ctx.stroke();
    }
}
