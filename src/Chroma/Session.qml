import QtQuick

Rectangle {
    color: Palette.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    Column {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        Text {
            text: "SESSION"
            color: Palette.muted
            font.pixelSize: 12
            font.letterSpacing: 2
            font.bold: true
        }

        Text {
            text: App.hookInstalled ? "theme-set hook installed" : "hook missing"
            color: App.hookInstalled ? Palette.green : Palette.yellow
            font.pixelSize: 22
        }

        Rectangle {
            width: parent.width
            height: ruleWidth
            color: Palette.accent
        }

        Repeater {
            model: [
                { label: "Icon theme", value: App.iconTheme },
                { label: "Font", value: App.fontName },
                { label: "QtDir", value: App.qtDir },
                { label: "colors.toml", value: App.colorsTomlPath }
            ]

            Column {
                required property var modelData
                spacing: 4
                width: parent.width

                Text {
                    text: modelData.label.toUpperCase()
                    color: Palette.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                }

                Text {
                    text: modelData.value.length > 0 ? modelData.value : "-"
                    color: Palette.foreground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    wrapMode: Text.WrapAnywhere
                    width: parent.width
                }
            }
        }

        Text {
            visible: App.lastError.length > 0
            width: parent.width
            text: App.lastError
            color: Palette.red
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }

        Row {
            spacing: 12

            Rectangle {
                width: 140
                height: 36
                color: Palette.accent
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: "Install hook"
                    color: Palette.darkerBackground
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
                color: Palette.lighterBackground
                border.width: 1
                border.color: Palette.muted
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: "Reload"
                    color: Palette.foreground
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Palette.reload()
                        App.refreshSession()
                    }
                }
            }
        }
    }
}
