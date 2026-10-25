import QtQuick

Rectangle {
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    Column {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Column {
            spacing: 6

            SectionLabel {
                pageTitle: true
                text: "STUDIO"
            }

            Text {
                text: App.themeName.length > 0 ? App.themeName : "unnamed theme"
                color: Theme.foreground
                font.pixelSize: 36
                font.bold: true
            }

            MonoText {
                text: Theme.mode
                color: Theme.accent
                font.pixelSize: 14
            }
        }

        Rectangle {
            width: parent.width
            height: ruleWidth
            color: Theme.accent
        }

        Row {
            spacing: 32

            Rectangle {
                width: 160
                height: 160
                color: Theme.accent
                radius: 0

                MonoText {
                    anchors.centerIn: parent
                    text: "accent"
                    color: Theme.darkerBackground
                    font.pixelSize: 13
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Column {
                    spacing: 4
                    SectionLabel { text: "WALLPAPER" }
                    MonoText {
                        text: App.wallpaperPath.length > 0 ? App.wallpaperPath : "none"
                        color: Theme.darkForeground
                        font.pixelSize: 13
                        wrapMode: Text.WrapAnywhere
                        width: 640
                    }
                }

                Column {
                    spacing: 4
                    SectionLabel { text: "LAST RELOAD" }
                    MonoText {
                        text: Theme.lastReloaded.length > 0 ? Theme.lastReloaded : "not yet"
                        color: Theme.foreground
                        font.pixelSize: 13
                    }
                }

                Column {
                    spacing: 4
                    SectionLabel { text: "MODE" }
                    Text {
                        text: Theme.mode
                        color: Theme.brightForeground
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
