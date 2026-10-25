import QtQuick

Rectangle {
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    Column {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        SectionLabel {
            pageTitle: true
            text: "SESSION"
        }

        Text {
            text: App.hookInstalled ? "theme-set hook installed" : "hook missing"
            color: App.hookInstalled ? Theme.green : Theme.yellow
            font.pixelSize: 22
        }

        Rectangle {
            width: parent.width
            height: ruleWidth
            color: Theme.accent
        }

        Repeater {
            model: [
                { label: "App id", value: "org.omarchy.chroma" },
                { label: "Icon theme", value: App.iconTheme },
                { label: "Font", value: App.fontName },
                { label: "QtDir", value: App.qtDir },
                { label: "colors.toml", value: App.colorsTomlPath }
            ]

            Column {
                required property var modelData
                spacing: 4
                width: parent.width

                SectionLabel { text: modelData.label.toUpperCase() }

                MonoText {
                    text: modelData.value.length > 0 ? modelData.value : "-"
                    color: Theme.foreground
                    font.pixelSize: 13
                    wrapMode: Text.WrapAnywhere
                    width: parent.width
                }
            }
        }

        MonoText {
            visible: App.lastError.length > 0
            width: parent.width
            text: App.lastError
            color: Theme.red
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }

        Row {
            spacing: 12

            Rectangle {
                width: 140
                height: 36
                color: Theme.accent
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: "Install hook"
                    color: Theme.darkerBackground
                    font.pixelSize: 13
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: App.installHook()
                }
            }

            Rectangle {
                width: 120
                height: 36
                color: Theme.lighterBackground
                border.width: 1
                border.color: Theme.muted
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: "Reload"
                    color: Theme.foreground
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: App.reloadTheme()
                }
            }
        }
    }
}
