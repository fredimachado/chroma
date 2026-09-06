import QtQuick
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    readonly property var toasts: [
        { tone: "info", title: "Theme reload", bind: "theme", body: "", stamp: "09:41" },
        { tone: "ok", title: "Hook accepted", bind: "", body: "chroma.sock took the theme-set stamp.", stamp: "09:42" },
        { tone: "warn", title: "Accent skipped", bind: "", body: "gsettings accent stayed on the previous color.", stamp: "09:43" },
        { tone: "fail", title: "Socket bind lost", bind: "", body: "leftover chroma.sock blocked the first listen.", stamp: "09:44" }
    ]

    property var dismissed: ({})

    function toneColor(tone) {
        if (tone === "ok")
            return Theme.green
        if (tone === "warn")
            return Theme.yellow
        if (tone === "fail")
            return Theme.red
        return Theme.accent
    }

    function isDismissed(tone) {
        return page.dismissed[tone] === true
    }

    function dismiss(tone) {
        // Reassign so Repeater bindings see the flag. In-place writes stay silent.
        const next = Object.assign({}, page.dismissed)
        next[tone] = true
        page.dismissed = next
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        Text {
            Layout.fillWidth: true
            text: "NOTIFY"
            color: Theme.muted
            font.pixelSize: 12
            font.letterSpacing: 2
            font.bold: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: page.ruleWidth
            color: Theme.accent
        }

        Repeater {
            model: page.toasts

            Rectangle {
                required property var modelData
                readonly property bool shown: !page.isDismissed(modelData.tone)

                Layout.fillWidth: true
                implicitHeight: toastCol.implicitHeight + 24
                Layout.preferredHeight: shown ? implicitHeight : 0
                Layout.maximumHeight: shown ? implicitHeight : 0
                visible: shown
                color: Theme.darkBackground
                radius: page.radius
                clip: true

                Rectangle {
                    width: page.ruleWidth
                    height: parent.height
                    color: page.toneColor(modelData.tone)
                }

                Column {
                    id: toastCol
                    x: 16
                    y: 12
                    width: parent.width - 28
                    spacing: 6

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: modelData.title
                            color: Theme.foreground
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: parent.width - stamp.implicitWidth - parent.spacing
                        }

                        Text {
                            id: stamp
                            text: modelData.stamp
                            color: Theme.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        width: parent.width
                        text: modelData.bind === "theme"
                            ? ((App.themeName.length > 0 ? App.themeName : "unnamed") + " applied across terminals and the bar.")
                            : modelData.body
                        color: Theme.darkForeground
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.dismiss(modelData.tone)
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
