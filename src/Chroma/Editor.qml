import QtQuick
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0
    readonly property int gutterWidth: 28
    readonly property int currentLine: 3

    readonly property var specimen: [
        { tokens: [
            { text: "# colors.toml", tone: "comment" }
        ]},
        { tokens: [] },
        { tokens: [
            { text: "[", tone: "punct" },
            { text: "colors", tone: "key" },
            { text: "]", tone: "punct" }
        ]},
        { tokens: [
            { text: "accent", tone: "key" },
            { text: " = ", tone: "punct" },
            { text: "\"", tone: "punct" },
            { bind: "accent", tone: "string" },
            { text: "\"", tone: "punct" }
        ]},
        { tokens: [
            { text: "background", tone: "key" },
            { text: " = ", tone: "punct" },
            { text: "\"", tone: "punct" },
            { bind: "background", tone: "string" },
            { text: "\"", tone: "punct" }
        ]},
        { tokens: [
            { text: "foreground", tone: "key" },
            { text: " = ", tone: "punct" },
            { text: "\"", tone: "punct" },
            { bind: "foreground", tone: "string" },
            { text: "\"", tone: "punct" }
        ]},
        { tokens: [] },
        { tokens: [
            { text: "[", tone: "punct" },
            { text: "colors.normal", tone: "key" },
            { text: "]", tone: "punct" }
        ]},
        { tokens: [
            { text: "red", tone: "key" },
            { text: " = ", tone: "punct" },
            { text: "\"", tone: "punct" },
            { bind: "red", tone: "string" },
            { text: "\"", tone: "punct" }
        ]},
        { tokens: [
            { text: "green", tone: "key" },
            { text: " = ", tone: "punct" },
            { text: "\"", tone: "punct" },
            { bind: "green", tone: "string" },
            { text: "\"", tone: "punct" }
        ]},
        { tokens: [] },
        { tokens: [
            { text: "alpha", tone: "key" },
            { text: " = ", tone: "punct" },
            { text: "100", tone: "number" }
        ]}
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        Text {
            Layout.fillWidth: true
            text: "EDITOR"
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

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.darkerBackground
            radius: page.radius
            border.width: page.ruleWidth
            border.color: Theme.muted
            clip: true

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: page.ruleWidth
                color: Theme.accent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: page.ruleWidth + 16
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 16
                spacing: 0

                Repeater {
                    model: page.specimen

                    Rectangle {
                        required property int index
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: line.implicitHeight + 4
                        color: index === page.currentLine ? Theme.selection : "transparent"
                        radius: page.radius

                        RowLayout {
                            id: line
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 16

                            Text {
                                Layout.preferredWidth: page.gutterWidth
                                text: index + 1
                                color: Theme.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignRight
                            }

                            Row {
                                Layout.fillWidth: true

                                Repeater {
                                    model: modelData.tokens

                                    Text {
                                        required property var modelData

                                        text: modelData.bind === "accent" ? Theme.accent
                                            : modelData.bind === "background" ? Theme.background
                                            : modelData.bind === "foreground" ? Theme.foreground
                                            : modelData.bind === "red" ? Theme.red
                                            : modelData.bind === "green" ? Theme.green
                                            : modelData.text
                                        color: modelData.tone === "key" ? Theme.cyan
                                             : modelData.tone === "string" ? Theme.green
                                             : modelData.tone === "number" ? Theme.orange
                                             : Theme.muted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: App.themeName.length > 0 ? App.themeName : "unnamed"
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: Theme.mode
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }
        }
    }
}
