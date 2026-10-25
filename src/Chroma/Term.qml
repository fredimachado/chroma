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
            text: "TERM"
            color: Theme.muted
            font.pixelSize: 12
            font.letterSpacing: 2
            font.bold: true
            wrapMode: Text.WordWrap
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
                spacing: 4

                Repeater {
                    model: [
                        { bind: "", tone: "prompt", text: "fredi@omarchy ~ % omarchy-theme-color accent" },
                        { bind: "accent", tone: "accent", text: "" },
                        { bind: "", tone: "prompt", text: "fredi@omarchy ~ % omarchy-theme-color background" },
                        { bind: "background", tone: "out", text: "" },
                        { bind: "", tone: "prompt", text: "fredi@omarchy ~ % omarchy-theme-color mode" },
                        { bind: "mode", tone: "out", text: "" },
                        { bind: "", tone: "prompt", text: "fredi@omarchy ~ % omarchy-theme-color wallpaper" },
                        { bind: "", tone: "red", text: "omarchy-theme-color: unknown key 'wallpaper'" },
                        { bind: "", tone: "prompt", text: "fredi@omarchy ~ % omarchy-theme-current" },
                        { bind: "theme", tone: "green", text: "" }
                    ]

                    MonoText {
                        required property var modelData
                        Layout.fillWidth: true
                        text: modelData.bind === "accent" ? Theme.accent
                            : modelData.bind === "background" ? Theme.background
                            : modelData.bind === "mode" ? Theme.mode
                            : modelData.bind === "theme" ? (App.themeName.length > 0 ? App.themeName : "unnamed")
                            : modelData.text
                        color: modelData.tone === "accent" ? Theme.accent
                             : modelData.tone === "red" ? Theme.red
                             : modelData.tone === "green" ? Theme.green
                             : modelData.tone === "prompt" ? Theme.cyan
                             : Theme.foreground
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
