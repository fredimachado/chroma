import QtQuick
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        Text {
            Layout.fillWidth: true
            text: "KEYS"
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

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Repeater {
                model: [
                    { key: "Return", action: "Terminal", live: "", accented: false },
                    { key: "Space", action: "Launcher", live: "", accented: false },
                    { key: "T", action: "Theme", live: "theme", accented: true },
                    { key: "Q", action: "Close window", live: "", accented: false },
                    { key: "V", action: "Clipboard", live: "", accented: false },
                    { key: "Escape", action: "Omarchy menu", live: "", accented: false },
                    { key: "L", action: "Lock screen", live: "", accented: false },
                    { key: "Print", action: "Screenshot", live: "", accented: false },
                    { key: "B", action: "Browser", live: "", accented: false },
                    { key: "E", action: "Files", live: "", accented: false }
                ]

                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 16

                    RowLayout {
                        spacing: 6

                        Rectangle {
                            implicitWidth: superLabel.implicitWidth + 16
                            implicitHeight: 28
                            color: Theme.darkBackground
                            radius: page.radius
                            border.width: 1
                            border.color: Theme.muted

                            Text {
                                id: superLabel
                                anchors.centerIn: parent
                                text: "Super"
                                color: Theme.foreground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        Text {
                            text: "+"
                            color: Theme.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                        }

                        Rectangle {
                            implicitWidth: chordLabel.implicitWidth + 16
                            implicitHeight: 28
                            color: modelData.accented ? Theme.accent : Theme.darkBackground
                            radius: page.radius
                            border.width: 1
                            border.color: Theme.muted

                            Text {
                                id: chordLabel
                                anchors.centerIn: parent
                                text: modelData.key
                                color: modelData.accented ? Theme.darkerBackground : Theme.foreground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.live === "theme"
                            ? (App.themeName.length > 0 ? App.themeName : Theme.mode)
                            : modelData.action
                        color: Theme.foreground
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
