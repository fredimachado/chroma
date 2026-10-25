import QtQuick

Rectangle {
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Row {
            width: parent.width
            spacing: 16

            SectionLabel {
                pageTitle: true
                text: "PALETTE"
                anchors.verticalCenter: parent.verticalCenter
            }

            MonoText {
                text: Theme.tokens.length + " tokens"
                color: Theme.darkForeground
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "click a row to copy"
                color: Theme.muted
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: ruleWidth
            color: Theme.accent
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
                    model: Theme.tokens

                    Rectangle {
                        required property var item
                        width: tokenColumn.width
                        height: 52
                        color: rowArea.containsMouse ? Theme.lighterBackground : Theme.darkBackground
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
                                border.color: Theme.muted
                            }

                            MonoText {
                                width: 200
                                anchors.verticalCenter: parent.verticalCenter
                                text: item.key
                                color: Theme.foreground
                                font.pixelSize: 13
                            }

                            MonoText {
                                width: 110
                                anchors.verticalCenter: parent.verticalCenter
                                text: item.hex
                                color: Theme.muted
                                font.pixelSize: 13
                            }

                            MonoText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Number(item.luminance).toFixed(3)
                                color: Theme.darkForeground
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
