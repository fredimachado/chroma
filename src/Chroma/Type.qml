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
            text: "TYPE"
            color: Theme.muted
            font.pixelSize: 12
            font.letterSpacing: 2
            font.bold: true
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: App.themeName.length > 0 ? App.themeName : "Aa"
            color: Theme.foreground
            font.pixelSize: 48
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
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "Display"
                color: Theme.foreground
                font.pixelSize: 36
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Title"
                color: Theme.foreground
                font.pixelSize: 22
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Body"
                color: Theme.foreground
                font.pixelSize: 14
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Caption"
                color: Theme.muted
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: Theme.accent
                color: Theme.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 88
            color: Theme.darkBackground
            radius: page.radius
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 96
                    color: Theme.background
                    radius: page.radius
                    border.width: page.ruleWidth
                    border.color: Theme.muted
                    clip: true

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "fg / bg"
                        color: Theme.foreground
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 96
                    color: Theme.background
                    radius: page.radius
                    border.width: page.ruleWidth
                    border.color: Theme.muted
                    clip: true

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "accent / bg"
                        color: Theme.accent
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 96
                    color: Theme.accent
                    radius: page.radius
                    clip: true

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "ink / accent"
                        color: Theme.darkerBackground
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
