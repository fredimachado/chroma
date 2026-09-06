import QtQuick
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    property bool armed: false
    property alias query: queryInput.text
    property int level: 40
    property bool checked: true
    property int segment: 0

    readonly property var segments: ["Day", "Dusk", "Night"]

    Flickable {
        anchors.fill: parent
        anchors.margins: 32
        contentWidth: width
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: body
            width: parent.width
            spacing: 20

            Text {
                Layout.fillWidth: true
                text: "CONTROLS"
                color: Theme.muted
                font.pixelSize: 12
                font.letterSpacing: 2
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Widgets"
                color: Theme.foreground
                font.pixelSize: 22
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: page.ruleWidth
                color: Theme.accent
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "BUTTON"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 36
                        color: Theme.accent
                        radius: page.radius

                        Text {
                            anchors.centerIn: parent
                            text: page.armed ? "Armed" : "Primary"
                            color: Theme.darkerBackground
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.armed = !page.armed
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 36
                        color: Theme.lighterBackground
                        border.width: 1
                        border.color: Theme.muted
                        radius: page.radius

                        Text {
                            anchors.centerIn: parent
                            text: "Ghost"
                            color: Theme.foreground
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "FIELD"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: Theme.darkerBackground
                    border.width: 1
                    border.color: Theme.muted
                    radius: page.radius
                    clip: true

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        visible: queryInput.text.length === 0
                        text: "Filter tokens"
                        color: Theme.muted
                        font.pixelSize: 13
                    }

                    TextInput {
                        id: queryInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.foreground
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.darkerBackground
                        font.pixelSize: 13
                        clip: true
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "TOGGLE"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                    wrapMode: Text.WordWrap
                }

                Item {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 26

                    Rectangle {
                        id: track
                        property bool enabled: true
                        anchors.fill: parent
                        color: enabled ? Theme.selection : Theme.muted
                        radius: page.radius

                        Rectangle {
                            width: 20
                            height: 20
                            x: track.enabled ? parent.width - width - 3 : 3
                            y: 3
                            color: Theme.foreground
                            radius: page.radius
                        }
                    }

                    // Sibling so track.enabled can be the switch without disabling this hit target.
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: track.enabled = !track.enabled
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "SLIDER"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 4
                            color: Theme.muted
                            radius: page.radius

                            Rectangle {
                                width: parent.width * (page.level / 100)
                                height: parent.height
                                color: Theme.accent
                                radius: page.radius
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            function setLevel() {
                                page.level = Math.round(Math.max(0, Math.min(1, mouseX / Math.max(width, 1))) * 100)
                            }
                            onPressed: setLevel()
                            onPositionChanged: if (pressed) setLevel()
                        }
                    }

                    Text {
                        Layout.preferredWidth: 36
                        text: page.level
                        color: Theme.foreground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignRight
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "CHECKBOX"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        color: page.checked ? Theme.accent : Theme.darkerBackground
                        border.width: 1
                        border.color: page.checked ? Theme.accent : Theme.muted
                        radius: page.radius

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.checked = !page.checked
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: page.checked ? "Checked" : "Unchecked"
                        color: Theme.foreground
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "SEGMENT"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 1.5
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: page.segments

                        Rectangle {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: page.segment === index ? Theme.selection : Theme.lighterBackground
                            radius: page.radius

                            Rectangle {
                                width: parent.width
                                height: page.ruleWidth
                                color: page.segment === index ? Theme.accent : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: page.segment === index ? Theme.accent : Theme.foreground
                                font.pixelSize: 13
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: page.segment = index
                            }
                        }
                    }
                }
            }
        }
    }
}
