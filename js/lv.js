$(function() {
    // initial graph
    updateGraph();
    var chart;
    var a,b,c,d;
    var showingMore = false;
    $('input').keypress(function(e) {
        if (e.which == 13) {
            $('#update').click();
        }
    });
    /*
    $('input').is('.sec').keypress(function(e) {
        if (e.which == 13) {
            $('#findxy').click();
        }
    });
    */
    $('#update').click(function() {
        chart.destroy();
        updateGraph();
    });
    $('#findxy').click(function() {
        findXY();
    });
    $('#moreBtn').click(function() {
        showMore();
    });

    function showMore() {
        if (showingMore) {
            $(".moreDiv").each(function() {
                $(this).attr('style', 'display: none');
            });
            $('#moreBtn').text("Show Advanced Options");
        } else {
            $(".moreDiv").each(function() {
                $(this).attr('style', 'display: block');
            });
            $('#moreBtn').text("Hide Advanced Options");
        }
        showingMore = !showingMore;
    }

    function findXY() {
        var xt = parseFloat($('#xt').val());
        var yt = parseFloat($('#yt').val());
        var xvals = chart.data.datasets[0].data;
        var yvals = chart.data.datasets[1].data;
        var dt = chart.data.labels[1];
        var xind = Math.round(xt/dt);
        var yind = Math.round(yt/dt);
        var x = xvals[xind];
        var y = yvals[yind];
        $('#xat').val(x);
        $('#yat').val(y);
        var esugg = a-y*b;
        var fsugg = x*d-c;
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
        var etime2 = parseFloat($('#etime2').val());
        var ftime2 = parseFloat($('#ftime2').val());
        var e2 = parseFloat($('#e2').val());
        var f2 = parseFloat($('#f2').val());
        var tvals = [];
        var xvals = [x0];
        var yvals = [y0];
        var x = x0;
        var y = y0;
        var xt1 = parseFloat($('#xt1').val());
        var xtv = parseFloat($('#xtv').val());
        var yt1 = parseFloat($('#yt1').val());
        var ytv = parseFloat($('#ytv').val());
        var xt = Math.round(xt1/dt);
        var yt = Math.round(yt1/dt);
        for (var i = t0; i <= tmax; i += dt) {
            var dx = (a)*x - b*x*y;
            var dy = d*x*y - (c)*y;
            if (i >= etime) {
                dx = (a-e)*x - b*x*y;
            }
            if (i >= ftime) {
                dy = d*x*y - (c+f)*y;
            }
            x = x+dx*dt;
            y = y+dy*dt;
            if (xtv != 0 && i >= xt1) {
                x += xtv;
                xtv = 0;
                e = 0;
                // if changes x at time, wildlife stops harvest rates on deer
            }
            if (ytv != 0 && i >= yt1) {
                y += ytv;
                ytv = 0;
                f = 0;
                // if changes y at time, wildlife stops pop. control rates on coyote
            }
            if (e2 != 0 && i >= etime2) {
                e = e2;
                e2 = 0;
            }
            if (f2 != 0 && i >= ftime2) {
                f = f2;
                f2 = 0;
            }
            x = Math.max(0, x);
            y = Math.max(0, y);
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
                                            label: "Prey",
                                            //backgroundColor: 'rgb(255, 99, 132)',
                                            fill: false,
                                            pointRadius: 0,
                                            borderColor: 'rgb(255, 80, 80)',
                                            backgroundColor: 'rgb(255, 80, 80)',
                                            //data: [0, 10, 5, 2, 20, 30, 45],
                                            data: xvals,
                                        },
                                        {
                                            label: "Predator",
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
        var ssx = (c+f)/d;
        var ssy = (a-e)/b;
        $('#ssx').val(ssx);
        $('#ssy').val(ssy);
    }
});
