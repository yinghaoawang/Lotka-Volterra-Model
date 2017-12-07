$(function() {
    // initial graph
    updateGraph();
    var chart;
    var a,b,c,d;
    $('input').keypress(function(e) {
        if (e.which == 13) {
            $('#update').click();
        }
    });
    $('#update').click(function() {
        chart.destroy();
        updateGraph();
    });
    $('#findxy').click(function() {
        findXY();
    });

    function findXY() {
        var xt = parseFloat($('#xt').val());
        var yt = parseFloat($('#yt').val());
        var xvals = chart.data.datasets[0].data;
        var yvals = chart.data.datasets[1].data;
        var dt = chart.data.labels[1];
        var xind = xt/dt;
        var yind = yt/dt;
        var x = xvals[xind];
        var y = yvals[yind];
        $('#xat').val(x);
        $('#yat').val(y);
        var esugg = a-y*b;
        var fsugg = d-x*c;
        $('#esug').val(esugg);
        $('#fsug').val(fsugg);
    }

    function updateGraph() {
        var ctx = $('#myChart');
        var dt = parseFloat($('#dt').val());
        var t0 = parseFloat($('#t0').val());
        var tmax = parseFloat($('#tmax').val());
        var x0 = parseFloat($('#x0').val());
        var y0 = parseFloat($('#y0').val());
        a = parseFloat($('#a').val());
        b = parseFloat($('#b').val());
        c = parseFloat($('#c').val());
        d = parseFloat($('#d').val());
        var e = parseFloat($('#e').val());
        var f = parseFloat($('#f').val());
        var etime = parseFloat($('#etime').val());
        var ftime = parseFloat($('#ftime').val());
        var tvals = [];
        var xvals = [x0];
        var yvals = [y0];
        var x = x0;
        var y = y0;
        for (var i = t0; i <= tmax; i += dt) {
            var dx = (a)*x - b*x*y;
            var dy = c*x*y - (d)*y;
            if (i >= etime) {
                dx = (a-e)*x - b*x*y;
            }
            if (i >= ftime) {
                dy = c*x*y - (d-f)*y;
            }
            x = Math.max(0, x+dx*dt);
            y = Math.max(0, y+dy*dt);
            xvals.push(x);
            yvals.push(y);
            tvals.push(i);
            if (x == 0 && y == 0) break;
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
        var ssx = (d-f)/c;
        var ssy = (a-e)/b;
        $('#ssx').val(ssx);
        $('#ssy').val(ssy);
    }
});
