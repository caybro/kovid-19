import QtQuick 2.12
import QtQuick.Controls 2.12
import QtCharts 2.3

Page {
    id: root
    title: qsTr("Number of people in hospital — %1").arg(rangeCombo.currentText)

    QtObject {
        id: priv
        property var dataCache
    }

    function downloadData() {
        const xhr = new XMLHttpRequest;
        xhr.open("GET", "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/hospitalizace.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                priv.dataCache = JSON.parse(xhr.responseText);
                parseData();
            }
        }
        xhr.send();
    }

    function parseData(range = -1) {
        barSeries.clear();
        var datesArr = Array();
        var bezPriznaku = Array();
        var lehky = Array();
        var stredni = Array();
        var tezky = Array();
        var hosp = Array();

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

            datesArr.push(new Date(datum).toLocaleString(Qt.locale(), "d.M."));
            bezPriznaku.push(datapoint.stav_bez_priznaku);
            lehky.push(datapoint.stav_lehky);
            stredni.push(datapoint.stav_stredni);
            tezky.push(datapoint.stav_tezky);
            hosp.push(datapoint.pocet_hosp);
        }

        // set max for the values (y) axis
        yAxis.max = Math.max(...hosp) + 10;

        xAxis.categories = datesArr;
        barSeries.append(qsTr("Without symptoms"), bezPriznaku);
        barSeries.append(qsTr("Light symptoms"), lehky);
        barSeries.append(qsTr("Medium symptoms"), stredni);
        barSeries.append(qsTr("Severe symptoms"), tezky);
    }

    Component.onCompleted: downloadData()

    ChartView {
        id: chart
        anchors.fill: parent
        legend.alignment: Qt.AlignTop
        antialiasing: true
        localizeNumbers: true
        theme: ChartView.ChartThemeBlueNcs
        animationOptions: ChartView.SeriesAnimations

        BarCategoryAxis {
            id: xAxis
            titleText: qsTr("Date")
        }

        ValueAxis {
            id: yAxis
            min: 0
            tickType: ValueAxis.TicksDynamic
            tickInterval: 1000
            tickAnchor: 0
            minorTickCount: 10
        }

        StackedBarSeries {
            id: barSeries
            axisX: xAxis
            axisY: yAxis
            labelsVisible: rangeCombo.currentIndex > 0
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
