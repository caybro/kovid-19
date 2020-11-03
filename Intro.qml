import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    id: root
    title: qsTr("COVID-19 Overview")

    function downloadData() {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/zakladni-prehled.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var a = JSON.parse(xhr.responseText);
                parseData(a);
            }
        }
        xhr.send();
    }

    function parseData(jsonData) {
        date.text = qsTr("Last updated: %1").arg(new Date(jsonData.modified).toLocaleString(Qt.locale(), Locale.LongFormat));
        for (var i in jsonData.data) {
            const datapoint = jsonData.data[i];
            numberOfTotalTests.text = qsTr("Total number of tests to date: %L1").arg(datapoint.provedene_testy_celkem);
            confirmedTotalCases.text = qsTr("Total number of confirmed cases: %L1").arg(datapoint.potvrzene_pripady_celkem);
            activeCases.text = qsTr("Active cases: %L1").arg(datapoint.aktivni_pripady);
            healedNumber.text = qsTr("Total number of healed patients: %L1").arg(datapoint.vyleceni);
            deceasedNumber.text = qsTr("Total number of deceased people: %L1").arg(datapoint.umrti);
            inHospital.text = qsTr("Currently in hospital: %L1").arg(datapoint.aktualne_hospitalizovani);
            testsYesterday.text = qsTr("Tests yesterday: %L1").arg(datapoint.provedene_testy_vcerejsi_den);
            casesYesterday.text = qsTr("Confirmed cases yesterday: %L1").arg(datapoint.potvrzene_pripady_vcerejsi_den);
            casesToday.text = qsTr("Confirmed cases today: %L1").arg(datapoint.potvrzene_pripady_dnesni_den);
        }
    }

    Component.onCompleted: downloadData()

    Column {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            id: date
        }

        Label {
            id: numberOfTotalTests
        }

        Label {
            id: confirmedTotalCases
        }

        Label {
            id: activeCases
        }

        Label {
            id: healedNumber
        }

        Label {
            id: deceasedNumber
        }

        Label {
            id: inHospital
        }

        Label {
            id: testsYesterday
        }

        Label {
            id: casesYesterday
        }

        Label {
            id: casesToday
        }

        Label {
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("Dataset by %1").arg("<a href='https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19'>MZCR</a>")
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
