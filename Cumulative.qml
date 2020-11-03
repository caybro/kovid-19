import QtQuick 2.12
import QtQuick.Controls 2.12
import QtCharts 2.3

Page {
    id: root
    title: qsTr("Cumulative numbers of infected people")

    function downloadData() {
        infectedSeries.clear();
        curedSeries.clear();
        deceasedSeries.clear();

        const xhr = new XMLHttpRequest;
        xhr.open("GET", "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/nakazeni-vyleceni-umrti-testy.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                const a = JSON.parse(xhr.responseText);
                parseData(a);
            }
        }
        xhr.send();
    }

    function parseData(jsonData) {
        var infArr = Array();
        var curedArr = Array();
        var decArr = Array();

        for (var i in jsonData.data) {
            const datapoint = jsonData.data[i];
            const datum = Date.parse(datapoint.datum);
            const inf = datapoint.kumulativni_pocet_nakazenych;
            const cured = datapoint.kumulativni_pocet_vylecenych;
            const dec = datapoint.kumulativni_pocet_umrti;

            infArr.push(inf);
            infectedSeries.append(datum, inf);
            curedArr.push(cured);
            curedSeries.append(datum, cured);
            decArr.push(dec);
            deceasedSeries.append(datum, dec);
        }

        // set min/max values for the date (x) axis
        xAxis.min = jsonData.data[0].datum;
        xAxis.max = jsonData.data[jsonData.data.length - 1].datum;

        // set min/max for the values (y) axis
        yAxis.min = Math.min(...infArr, ...curedArr, ...decArr);
        yAxis.max = Math.max(...infArr, ...curedArr, ...decArr);
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

        DateTimeAxis {
            id: xAxis
            titleText: qsTr("Date")
            tickCount: 12 // ~~12 months
            format: "d.M."
        }

        ValueAxis {
            id: yAxis
            titleText: qsTr("Number of ppl")
            labelFormat: "%.0d"
        }

        LineSeries {
            id: infectedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Infected")
            color: "gold"
            width: 3
            onHovered: handleHovered(point, state, infectedSeries)
        }

        LineSeries {
            id: curedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Cured")
            color: "forestgreen"
            width: 3
            onHovered: handleHovered(point, state, curedSeries)
        }

        LineSeries {
            id: deceasedSeries
            axisX: xAxis
            axisY: yAxis
            name: qsTr("Deceased")
            color: "#000001"
            width: 3
            onHovered: handleHovered(point, state, deceasedSeries)
        }
    }
}
