$(function() {
    var chart;
    $('input').keypress(function(e) {
        if (e.which == 13) {
            $('#update').click();
        }
    });
    $('#update').click(function() {
        if (chart) chart.destroy();
        updateGraph();
    });
    updateGraph();
    function updateGraph() {
        var ctx = $('#myChart');
        var dt = parseFloat($('#dt').val());
        var xunit = $('#xunit').val();
        var yunit = $('#yunit').val();
        var xdata = $('#xdata').val();
        var ydata = $('#ydata').val();
        xdata = xdata.replace(/[^\d,]/g, '');
        ydata = ydata.replace(/[^\d,]/g, '');
        xdata = xdata.split(',');
        ydata = ydata.split(',');
        var tdata = [];
        var biglen = Math.max(xdata.length, ydata.length);
        for (var i = 0; i < biglen; ++i) {
            tdata.push(i * dt);
        }
        chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: tdata,
                datasets: [{
                    label: xunit,
                    fill: false,
                    pointRadius: 0,
                    borderColor: 'rgb(255, 80, 80)',
                    backgroundColor: 'rgb(255, 80, 80)',
                    data: xdata,
                },
                {
                    label: yunit,
                    fill: false,
                    pointRadius: 0,
                    borderColor: 'rgb(80, 80, 255)',
                    backgroundColor: 'rgb(80, 80, 255)',
                    data: ydata,
                }]
            },
            options: {
                scales: {
                    xAxes: [{
                        ticks: {
                            autoSkip: true,
                            maxTicksLimit: 20
                        }
                    }]
                }
            }
        });
    }
});
