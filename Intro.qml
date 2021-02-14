import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    id: root
    title: qsTr("COVID-19 CZ Overview")

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
        content.append(qsTr("Last updated: %1").arg(new Date(jsonData.modified).toLocaleString(Qt.locale(), Locale.LongFormat)));
        for (var i in jsonData.data) {
            const datapoint = jsonData.data[i];
            content.append(qsTr("Total number of tests to date: %L1").arg(datapoint.provedene_testy_celkem));
            content.append(qsTr("Total number of confirmed cases: %L1").arg(datapoint.potvrzene_pripady_celkem));
            content.append(qsTr("Active cases: %L1").arg(datapoint.aktivni_pripady));
            content.append(qsTr("Total number of healed patients: %L1").arg(datapoint.vyleceni));
            content.append(qsTr("Total number of deceased people: %L1").arg(datapoint.umrti));
            content.append(qsTr("Currently in hospital: %L1").arg(datapoint.aktualne_hospitalizovani));
            content.append(qsTr("Tests yesterday: %L1").arg(datapoint.provedene_testy_vcerejsi_den));
            content.append(qsTr("Confirmed cases yesterday: %L1").arg(datapoint.potvrzene_pripady_vcerejsi_den));
            content.append(qsTr("Confirmed cases today: %L1").arg(datapoint.potvrzene_pripady_dnesni_den));
            content.append(qsTr("Vaccinated yesterday: %L1").arg(datapoint.vykazana_ockovani_vcerejsi_den));
            content.append(qsTr("Vaccinated total: %L1").arg(datapoint.vykazana_ockovani_celkem));
        }
    }

    Component.onCompleted: downloadData()

    Column {
        anchors.fill: parent
        anchors.margins: 10

        TextEdit {
            id: content
            readOnly: true
            selectByMouse: true
        }

        Label {
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("Dataset by %1").arg("<a href='https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19'>MZCR</a>")
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
