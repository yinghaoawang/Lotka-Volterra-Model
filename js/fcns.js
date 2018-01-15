// doc refs
var table = document.getElementById("gtTable");
var rowCount = 0;
var colCount = 0;
var defaultCellText = "<input type='text' style='text-align: center;width: 50px' value='0,0'></input>";
var p1Arr = [];
var p2Arr = [];
// represents a 2d table where a 0 is no and a 1 is yes for NE
var nashPairs = [];
var p2Nash = [];
var p1Nash = [];

function addRow() {
    table.insertRow(rowCount);
    var row = table.rows[rowCount];
    var cell = row.insertCell(0);
    cell.innerHTML = "<input type='text' style='width:50px' value='" + rowCount++ + "'></input>";

    for (var i = 1; i < colCount; ++i) {
        cell = row.insertCell(i);
        cell.innerHTML = defaultCellText;
    }
}

function addCol() {
    if (table.rows.length <= 0) return;

    var cell = table.rows[0].insertCell(colCount);
    cell.innerHTML = "<input type='text' style='width:50px' value='" + colCount++ + "'></input>";

    for (var i = 1; i < rowCount; ++i) {
        var row = table.rows[i];
        cell = row.insertCell(colCount - 1);
        cell.innerHTML = defaultCellText;
    }
}

function resetRowValues() {
    for (var i = 1; i < rowCount; ++i) {
        table.rows[i].cells[0].innerHTML = i;
    }
}

function numToLetter(num) {
    return String.fromCharCode(num + 'a'.charCodeAt(0) - 1);
}

function isNumeric(num) {
    return !isNaN(num) && isFinite(num);
}

function resetColValues() {
    var tmpCount = 1;
    for (var i = 1; i < colCount; ++i) {
        table.rows[0].cells[i].innerHTML = i;
    }
}

function destroyRow(row) {
    --row;
    if (row > rowCount || row < 0) {
        alert("Invalid input");
        return;
    }
    if (rowCount == 2) {
        alert("Must exist at least one row");
        return;
    }
    table.deleteRow(row + 1);
    --rowCount;
    //resetRowValues();
}

function destroyCol(col) {
    if (col > colCount || col < 0) {
        alert("Invalid input");
        return;
    }
    if (colCount == 2) {
        alert("Must exist at least one col");
        return;
    }
    for (var i = 0; i < rowCount; ++i) {
        var row = table.rows[i];
        row.deleteCell(col);
    }
    --colCount;
    //resetColValues();
}

function parseTable() {
    for (var i = 1; i < rowCount; ++i) {
        p1Arr[i] = [];
        p2Arr[i] = [];
        for (var j = 1; j < colCount; ++j) {
            var value = getInputValue(i, j).split(",");
            p1Arr[i][j] = parseFloat(value[0]);
            p2Arr[i][j] = parseFloat(value[1]);
            if (!isNumeric(p1Arr[i][j]) || !isNumeric(p2Arr[i][j])) {
                alert("Invalid input in cell " + j + "," + i);
                break;
            }
        }
    }
}

function IDSDSRow() {
	var anyDeleted = false;
    for (var row1 = 1; row1 < rowCount - 1; ++row1) {
        for (var row2 = row1 + 1; row2 < rowCount; ++row2) {
            var allGreater = true;
            var allLesser = true;
            for (var col = 1; col < colCount; ++col) {
                var value1 = p1Arr[row1][col];
                var value2 = p1Arr[row2][col];
                if (value1 <= value2) allGreater = false;
                if (value1 >= value2) allLesser = false;
            }
            if (allGreater || allLesser) { // if there exists a dominant strategy
                // remove the dominant strategy
                if (allGreater) {
                    alert("Row " + getInputValue(row1, 0) + " dominates row " + getInputValue(row2, 0));
                    destroyRow(row2);
                } else {
                    alert("Row " + getInputValue(row2, 0) + " dominates row " + getInputValue(row1, 0));
                    destroyRow(row1);
                }
                // look through the table again
                parseTable();
                row1 = 0; // after breaking row1 = 1
				anyDeleted = true;
                break;
            }
        }
    }
	return anyDeleted;
}

function getInputValue(row, col) {
    return table.rows[row].cells[col].getElementsByTagName("input")[0].value;
}

function getInputRowName(row) {
    return getInputValue(row, 0);
}
function getInputColName(col) {
    return getInputValue(0, col);
}

function IDSDSCol() {
	var anyDeleted = false;
    for (var col1 = 1; col1 < colCount; ++col1) {
        for (var col2 = col1 + 1; col2 < colCount; ++col2) {
            var allGreater = true;
            var allLesser = true;
            for (var row = 1; row < rowCount; ++row) {
                var value1 = p2Arr[row][col1];
                var value2 = p2Arr[row][col2];
                if (value1 <= value2) allGreater = false;
                if (value1 >= value2) allLesser = false;
            }
            if (allGreater || allLesser) {
                if (allGreater) {
                    alert("Col " + getInputValue(0, col1) + " dominates col " + getInputValue(0, col2));
                    destroyCol(col2);
                } else {
                    alert("Col " + getInputValue(0, col2) + " dominates col " + getInputValue(0, col1));
                    destroyCol(col1);
                }
                parseTable();
                col1 = 0;
				anyDeleted = true;
                break;
            }
        }
    }
	return anyDeleted;
}

function IDSDS() {
    parseTable();
	while (true) {
		var rowDel = IDSDSRow();
		var colDel = IDSDSCol();
		// run idsds again if any rows or cols were deleted
		if (!rowDel && !colDel) break;
	}
}

function findNash() {
    if (rowCount < 1 || colCount < 1) return;
    parseTable();

    // reinit the nash arrays
    for (var i = 1; i < rowCount; ++i) {
        p1Nash[i] = [];
        p2Nash[i] = [];
        for (var j = 1; j < colCount; ++j) {
            p1Nash[i][j] = 0;
            p2Nash[i][j] = 0;
        }
    }

    // find the highest value in the rows for p2
    var highest;
    for (var j = 1; j < colCount; ++j) {
        highest = p1Arr[1][j];
        for (var i = 1; i < rowCount; ++i) {
            if (p1Arr[i][j] > highest) highest = p1Arr[i][j];
        }
        for (var i = 1; i < rowCount; ++i) {
            if (p1Arr[i][j] == highest) {
                p1Nash[i][j] = 1;
            }
        }
    }

    // find highest values in the cols for p1
    for (var i = 1; i < rowCount; ++i) {
        highest = p2Arr[i][1];
        for (var j = 1; j < colCount; ++j) {
            if (p2Arr[i][j] > highest) highest = p2Arr[i][j];
        }
        // after finding highest, add every index with this value
        for (var j = 1; j < colCount; ++j) {
            if (p2Arr[i][j] == highest) {
                p2Nash[i][j] = 1;
            }
        }
    }

    // find the matching p1 and p2 nashes for nash EQ
    nashPairs = [];
    for (var i = 1; i < rowCount; ++i) {
        for (var j = 1; j < colCount; ++j) {
            if (p1Nash[i][j] == 1 && p2Nash[i][j] == 1) {
                nashPairs.push([i, j]);
            }
        }
    }

    // print nash pairs
    var msg;
    if (nashPairs.length == 0) msg = "There is no nash equilibrium";
    else if (nashPairs.length == 1) msg = "The nash equilibrium is:\n";
    else msg = "The nash equilibria are:\n";
    for (var i = 0; i < nashPairs.length; ++i) {
        var row = nashPairs[i][0];
        var col = nashPairs[i][1];
        msg += "Row " + getInputRowName(row) + ", and col " + getInputColName(col) + "\n";
    }
    alert(msg);
}

// Add the first square
addRow();
++colCount;
table.rows[0].cells[0].innerHTML = "-";
// Add first row/col for the initial 1x1 board
addCol();
addRow();

// Event listeners
document.getElementById("addRowButton").addEventListener("click", addRow);
document.getElementById("addColButton").addEventListener("click", addCol);
document.getElementById("destroyRowButton").addEventListener("click", function() {
    var row = document.getElementById("destroyRowText").value;
    destroyRow(row)
});
document.getElementById("destroyColButton").addEventListener("click", function() {
    var col = document.getElementById("destroyColText").value;
    destroyCol(col)
});
document.getElementById("idsdsButton").addEventListener("click", IDSDS);
document.getElementById("nashButton").addEventListener("click", findNash);
