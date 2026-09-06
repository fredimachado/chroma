import QtQuick

Rectangle {
    color: Palette.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Row {
            width: parent.width
            spacing: 16

            Text {
                text: "PALETTE"
                color: Palette.muted
                font.pixelSize: 12
                font.letterSpacing: 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: Palette.tokens.length + " tokens"
                color: Palette.darkForeground
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "click a row to copy"
                color: Palette.muted
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: ruleWidth
            color: Palette.accent
        }

        Flickable {
            width: parent.width
            height: parent.height - 48
            clip: true
            contentHeight: tokenColumn.height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: tokenColumn
                width: parent.width
                spacing: 2

                Repeater {
                    model: Palette.tokens

                    Rectangle {
                        required property var item
                        width: tokenColumn.width
                        height: 52
                        color: rowArea.containsMouse ? Palette.lighterBackground : Palette.darkBackground
                        radius: 0

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 16
                            spacing: 16

                            Rectangle {
                                width: 36
                                height: 36
                                anchors.verticalCenter: parent.verticalCenter
                                color: item.hex
                                radius: 0
                                border.width: 1
                                border.color: Palette.muted
                            }

                            Text {
                                width: 200
                                anchors.verticalCenter: parent.verticalCenter
                                text: item.key
                                color: Palette.foreground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }

                            Text {
                                width: 110
                                anchors.verticalCenter: parent.verticalCenter
                                text: item.hex
                                color: Palette.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Number(item.luminance).toFixed(3)
                                color: Palette.darkForeground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: item.copy()
                        }
                    }
                }
            }
        }
    }
}
