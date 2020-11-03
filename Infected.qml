import QtQuick 2.12
import QtQuick.Controls 2.12
import QtCharts 2.3

Page {
    id: root
    title: qsTr("Incremental number of infected people - %1").arg(rangeCombo.currentText)

    QtObject {
        id: priv
        property var dataCache
    }

    function downloadData() {
        const xhr = new XMLHttpRequest;
        xhr.open("GET", "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/nakaza.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                priv.dataCache = JSON.parse(xhr.responseText);
                parseData();
            }
        }
        xhr.send();
    }

    function parseData(range = -1) {
        incrementalSeries.clear();
        var incrArr = Array();
        var datesArr = Array();

        var yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const lastWeek = new Date().setDate(yesterday.getDate() - 7);
        const last2Weeks = new Date().setDate(yesterday.getDate() - 14);
        const lastMonth = new Date().setMonth(yesterday.getMonth() - 1);

        for (var i in priv.dataCache.data) {
            const datapoint = priv.dataCache.data[i];
            const datum = Date.parse(datapoint.datum);

            if (range === 7) {
                if (datum <= lastWeek)
                    continue;
            } else if (range === 14) {
                if (datum <= last2Weeks)
                    continue;
            } else if (range === 30) {
                if (datum <= lastMonth)
                    continue;
            } else if (range !== -1) {
                continue;
            }

            const incr = datapoint.prirustkovy_pocet_nakazenych;
            incrArr.push(incr);
            datesArr.push(datum);
            incrementalSeries.append(datum, incr);
        }

        // set min/max values for the date (x) axis
        xAxis.min = new Date(Math.min(...datesArr));
        xAxis.max = new Date(Math.max(...datesArr));

        // set min/max for the values (y) axis
        yAxis.min = Math.min(...incrArr);
        yAxis.max = Math.max(...incrArr);
    }

    function handleHovered(point, state, series) {
        if (state) {
            var pos = chart.mapToPosition(point, series);
            tooltip.x = pos.x;
            tooltip.y = pos.y;
            tooltip.show("%1: %L2"
                         .arg(new Date(point.x).toLocaleDateString(Qt.locale(), Locale.ShortFormat))
                         .arg(Math.round(point.y)));
        }
        else
            tooltip.hide();
    }

    Component.onCompleted: downloadData()

    ToolTip {
        id: tooltip
        visible: false
    }

    ChartView {
        id: chart
        anchors.fill: parent
        legend.alignment: Qt.AlignTop
        antialiasing: true
        localizeNumbers: true
        theme: ChartView.ChartThemeBlueNcs
        legend.markerShape: Legend.MarkerShapeFromSeries

        DateTimeAxis {
            id: xAxis
            titleText: qsTr("Date")
            tickCount: rangeCombo.currentValue > 0 ? rangeCombo.currentValue : 12
            format: "d.M."
        }

        ValueAxis {
            id: yAxis
            //labelFormat: "d"
            titleText: qsTr("Number of ppl")
        }

        LineSeries {
            id: incrementalSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Infected ppl")
            color: "gold"
            pointsVisible: rangeCombo.currentValue > 0
            width: rangeCombo.currentValue > 0 ? 3 : 2
            onHovered: handleHovered(point, state, incrementalSeries)
        }
    }

    ComboBox {
        id: rangeCombo
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5
        width: 200
        model: ListModel {
            ListElement {
                name: qsTr("Everything")
                range: -1
            }
            ListElement {
                name: qsTr("Last Month")
                range: 30
            }
            ListElement {
                name: qsTr("Last 14 Days")
                range: 14
            }
            ListElement {
                name: qsTr("Last Week")
                range: 7
            }
        }
        textRole: "name"
        valueRole: "range"
        onActivated: {
            parseData(currentValue);
        }
    }
}
