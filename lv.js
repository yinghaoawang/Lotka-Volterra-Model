$(function() {
    // initial graph
    updateGraph();
    var chart;
    $('#update').click(function() {
        chart.destroy();
        updateGraph();
    });

    function updateGraph() {
        var ctx = $('#myChart');
        var dt = parseFloat($('#dt').val());
        var t0 = parseFloat($('#t0').val());
        var tmax = parseFloat($('#tmax').val());
        var x0 = parseFloat($('#x0').val());
        var y0 = parseFloat($('#y0').val());
        var a = parseFloat($('#a').val());
        var b = parseFloat($('#b').val());
        var c = parseFloat($('#c').val());
        var d = parseFloat($('#d').val());
        var e = parseFloat($('#e').val());
        var f = parseFloat($('#f').val());
        var tvals = [t0];
        var xvals = [x0];
        var yvals = [y0];
        var x = x0;
        var y = y0;
        for (var i = t0; i <= tmax; i += dt) {
            var dx = (a-e)*x - b*x*y;
            var dy = c*x*y - (d-f)*y;
            /*
            console.log('dt',dt);
            console.log('dxdt',dx * dt);
            console.log('dxdy:',dx,dy);
            */
            x += dx*dt;
            y += dy*dt;
            console.log('xy:',x,y);
            xvals.push(x);
            yvals.push(y);
            tvals.push(i);
        }
        chart = new Chart(ctx, {
                // The type of chart we want to create
                type: 'line',

                // The data for our dataset
                data: {
                            //labels: ["January", "February", "March", "April", "May", "June", "July"],
                            labels: tvals,
                            datasets: [{
                                            label: "Deer",
                                            //backgroundColor: 'rgb(255, 99, 132)',
                                            fill: false,
                                            pointRadius: 0,
                                            borderColor: 'rgb(255, 80, 80)',
                                            backgroundColor: 'rgb(255, 80, 80)',
                                            //data: [0, 10, 5, 2, 20, 30, 45],
                                            data: xvals,
                                        },
                                        {
                                            label: "Coyote",
                                            //backgroundColor: 'rgb(255, 99, 132)',
                                            fill: false,
                                            pointRadius: 0,
                                            borderColor: 'rgb(80, 80, 255)',
                                            backgroundColor: 'rgb(80, 80, 255)',
                                            //data: [0, 10, 5, 2, 20, 30, 45],
                                            data: yvals,
                                        }
                            ]
                        },

                // Configuration options go here
                options: {}
        });
    }
});
