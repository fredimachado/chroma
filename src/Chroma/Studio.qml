import QtQuick

Rectangle {
    color: Palette.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0

    Column {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Column {
            spacing: 6

            Text {
                text: "STUDIO"
                color: Palette.muted
                font.pixelSize: 12
                font.letterSpacing: 2
                font.bold: true
            }

            Text {
                text: App.themeName.length > 0 ? App.themeName : "unnamed theme"
                color: Palette.foreground
                font.pixelSize: 36
                font.bold: true
            }

            Text {
                text: Palette.mode
                color: Palette.accent
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Rectangle {
            width: parent.width
            height: ruleWidth
            color: Palette.accent
        }

        Row {
            spacing: 32

            Rectangle {
                width: 160
                height: 160
                color: Palette.accent
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: "accent"
                    color: Palette.darkerBackground
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Column {
                    spacing: 4
                    Text {
                        text: "WALLPAPER"
                        color: Palette.muted
                        font.pixelSize: 11
                        font.letterSpacing: 1.5
                    }
                    Text {
                        text: App.wallpaperPath.length > 0 ? App.wallpaperPath : "none"
                        color: Palette.darkForeground
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                        wrapMode: Text.WrapAnywhere
                        width: 640
                    }
                }

                Column {
                    spacing: 4
                    Text {
                        text: "LAST RELOAD"
                        color: Palette.muted
                        font.pixelSize: 11
                        font.letterSpacing: 1.5
                    }
                    Text {
                        text: Palette.lastReloaded.length > 0 ? Palette.lastReloaded : "not yet"
                        color: Palette.foreground
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Column {
                    spacing: 4
                    Text {
                        text: "MODE"
                        color: Palette.muted
                        font.pixelSize: 11
                        font.letterSpacing: 1.5
                    }
                    Text {
                        text: Palette.mode
                        color: Palette.brightForeground
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
