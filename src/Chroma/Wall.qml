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
            text: "WALL"
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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Image {
                anchors.fill: parent
                visible: App.wallpaperPath.length > 0
                source: App.wallpaperPath.length > 0 ? ("file://" + App.wallpaperPath) : ""
                fillMode: Image.PreserveAspectCrop
                clip: true
            }

            Text {
                anchors.centerIn: parent
                visible: App.wallpaperPath.length === 0
                text: "no wallpaper"
                color: Theme.muted
                font.pixelSize: 14
                wrapMode: Text.WordWrap
            }
        }

        Text {
            Layout.fillWidth: true
            text: App.wallpaperPath
            color: Theme.darkForeground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            wrapMode: Text.WrapAnywhere
        }
    }
}
