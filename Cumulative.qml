import QtQuick 2.12
import QtQuick.Controls 2.12
import QtCharts 2.3

Page {
    id: root
    title: qsTr("Cumulative numbers of infected people — %1").arg(rangeCombo.currentText)

    QtObject {
        id: priv
        property var dataCache
    }

    function downloadData() {
        const xhr = new XMLHttpRequest;
        xhr.open("GET", "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/nakazeni-vyleceni-umrti-testy.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                priv.dataCache = JSON.parse(xhr.responseText);
                parseData();
            }
        }
        xhr.send();
    }

    function parseData(range = -1) {
        infectedSeries.clear();
        curedSeries.clear();
        deceasedSeries.clear();
        testedSeries.clear();
        var infArr = Array();
        var curedArr = Array();
        var decArr = Array();
        var testedArr = Array();
        var datesArr = Array();

        var yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const lastWeek = new Date().setDate(yesterday.getDate() - 7);
        const last2Weeks = new Date().setDate(yesterday.getDate() - 14);
        const lastMonth = new Date().setMonth(yesterday.getMonth() - 1);

        for (var i in priv.dataCache.data) {
            const datapoint = priv.dataCache.data[i];
            const datum = Date.parse(datapoint.datum);
            const inf = datapoint.kumulativni_pocet_nakazenych;
            const cured = datapoint.kumulativni_pocet_vylecenych;
            const dec = datapoint.kumulativni_pocet_umrti;
            const tested = datapoint.kumulativni_pocet_testu;

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

            datesArr.push(datum);
            infArr.push(inf);
            infectedSeries.append(datum, inf);
            curedArr.push(cured);
            curedSeries.append(datum, cured);
            decArr.push(dec);
            deceasedSeries.append(datum, dec);
            testedArr.push(tested);
            testedSeries.append(datum, tested);
        }

        // set min/max values for the date (x) axis
        xAxis.min = new Date(Math.min(...datesArr));
        xAxis.max = new Date(Math.max(...datesArr));

        // set min/max for the values (y) axis
        yAxis.min = Math.min(...infArr, ...curedArr, ...decArr, ...testedArr);
        yAxis.max = Math.max(...infArr, ...curedArr, ...decArr, ...testedArr);
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
        legend.markerShape: Legend.MarkerShapeFromSeries
        antialiasing: true
        localizeNumbers: true
        theme: ChartView.ChartThemeBlueNcs
        animationOptions: ChartView.SeriesAnimations

        DateTimeAxis {
            id: xAxis
            titleText: qsTr("Date")
            tickCount: rangeCombo.currentValue > 0 ? rangeCombo.currentValue : 12
            format: "d.M."
        }

        ValueAxis {
            id: yAxis
            titleText: qsTr("Number of ppl")
            labelFormat: "%.0d"
            tickCount: 9
        }

        LineSeries {
            id: infectedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Infected")
            color: "gold"
            width: 3
            onHovered: handleHovered(point, state, infectedSeries)
            pointsVisible: rangeCombo.currentValue > 0
            pointLabelsVisible: rangeCombo.currentValue === 7 || rangeCombo.currentValue === 14
            pointLabelsClipping: false
            pointLabelsFormat: "@yPoint"
            pointLabelsFont.pixelSize: Qt.application.font.pixelSize // hidpi oh yeah :D
        }

        LineSeries {
            id: curedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Cured")
            color: "forestgreen"
            width: 3
            onHovered: handleHovered(point, state, curedSeries)
            pointsVisible: rangeCombo.currentValue > 0
            pointLabelsVisible: rangeCombo.currentValue === 7 || rangeCombo.currentValue === 14
            pointLabelsClipping: false
            pointLabelsFormat: "@yPoint"
            pointLabelsFont.pixelSize: Qt.application.font.pixelSize // hidpi oh yeah :D
        }

        LineSeries {
            id: deceasedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Deceased")
            color: "#000001" // "black" not accepted here :o
            width: 3
            onHovered: handleHovered(point, state, deceasedSeries)
            pointsVisible: rangeCombo.currentValue > 0
            pointLabelsVisible: rangeCombo.currentValue === 7 || rangeCombo.currentValue === 14
            pointLabelsClipping: false
            pointLabelsFormat: "@yPoint"
            pointLabelsFont.pixelSize: Qt.application.font.pixelSize // hidpi oh yeah :D
        }

        LineSeries {
            id: testedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Tested")
            color: "blue"
            width: 3
            onHovered: handleHovered(point, state, testedSeries)
            pointsVisible: rangeCombo.currentValue > 0
            pointLabelsVisible: rangeCombo.currentValue === 7 || rangeCombo.currentValue === 14
            pointLabelsClipping: false
            pointLabelsFormat: "@yPoint"
            pointLabelsFont.pixelSize: Qt.application.font.pixelSize // hidpi oh yeah :D
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
