import QtQuick
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0
    readonly property int sidebarWidth: 220

    property int selectedIndex: 1

    readonly property var inbox: [
        { title: "Theme set finished", body: "tokyo-night applied across terminals and the bar.", stamp: "09:12", status: "ready" },
        { title: "Hook ping dropped", body: "chroma.sock was missing. Stamp file used instead.", stamp: "09:18", status: "failed" },
        { title: "Wallpaper swapped", body: "background symlink now points at winding-road.", stamp: "09:21", status: "ready" },
        { title: "Font refresh queued", body: "JetBrainsMono Nerd Font still matches fc-match.", stamp: "09:24", status: "pending" },
        { title: "Accent preview", body: "Studio hero should track Theme.accent live.", stamp: "09:30", status: "ready" }
    ]

    readonly property var logs: [
        { tone: "green", line: "palette reload coalesced (watch + hook)" },
        { tone: "yellow", line: "gsettings accent stayed blue, ignored" },
        { tone: "red", line: "first socket bind lost a leftover chroma.sock" },
        { tone: "muted", line: "watching ~/.local/state/omarchy/current/" }
    ]

    function badgeColor(status) {
        if (status === "failed")
            return Theme.red
        if (status === "pending")
            return Theme.yellow
        return Theme.green
    }

    function badgeLabel(status) {
        if (status === "failed")
            return "Failed"
        if (status === "pending")
            return "Pending"
        return "Ready"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: page.sidebarWidth
            Layout.minimumWidth: 160
            Layout.fillHeight: true
            color: Theme.darkBackground

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Text {
                    text: "MAIL"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 2
                    font.bold: true
                }

                Repeater {
                    model: ["Inbox", "Sent", "Drafts", "Archive"]

                    Rectangle {
                        required property int index
                        required property string modelData
                        width: parent.width
                        height: 32
                        color: index === 0 ? Theme.selection : "transparent"
                        radius: page.radius

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: modelData
                            color: index === 0 ? Theme.accent : Theme.foreground
                            font.pixelSize: 13
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            text: index === 0 ? String(page.inbox.length) : "0"
                            color: Theme.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                    }
                }

                Item { height: 12; width: 1 }

                Text {
                    text: "STATUS"
                    color: Theme.muted
                    font.pixelSize: 11
                    font.letterSpacing: 2
                    font.bold: true
                }

                Text { text: "Failed"; color: Theme.red; font.pixelSize: 13 }
                Text { text: "Ready"; color: Theme.green; font.pixelSize: 13 }
                Text { text: "Pending"; color: Theme.yellow; font.pixelSize: 13 }
            }
        }

        Rectangle {
            Layout.preferredWidth: page.ruleWidth
            Layout.fillHeight: true
            color: Theme.muted
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: 16

            Text {
                text: "SURFACES"
                color: Theme.muted
                font.pixelSize: 12
                font.letterSpacing: 2
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.minimumWidth: 180
                    Layout.fillHeight: true
                    color: Theme.darkerBackground
                    radius: page.radius
                    border.width: 1
                    border.color: Theme.muted
                    clip: true

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Repeater {
                            model: page.inbox

                            Rectangle {
                                required property int index
                                required property var modelData
                                width: parent.width
                                height: 64
                                color: page.selectedIndex === index ? Theme.selection : "transparent"
                                radius: page.radius

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 4

                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Text {
                                            text: modelData.title
                                            color: Theme.foreground
                                            font.pixelSize: 13
                                            elide: Text.ElideRight
                                            width: parent.width - 70
                                        }

                                        Text {
                                            text: modelData.stamp
                                            color: Theme.muted
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                        }
                                    }

                                    Text {
                                        text: modelData.body
                                        color: Theme.darkForeground
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: page.selectedIndex = index
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 160
                    color: Theme.lighterBackground
                    radius: page.radius
                    border.width: 1
                    border.color: Theme.muted
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 22
                                color: page.badgeColor(page.inbox[page.selectedIndex].status)
                                radius: page.radius

                                Text {
                                    anchors.centerIn: parent
                                    text: page.badgeLabel(page.inbox[page.selectedIndex].status)
                                    color: Theme.darkerBackground
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Text {
                                text: page.inbox[page.selectedIndex].stamp
                                color: Theme.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: page.inbox[page.selectedIndex].title
                            color: Theme.brightForeground
                            font.pixelSize: 22
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: page.ruleWidth
                            color: Theme.accent
                        }

                        Text {
                            Layout.fillWidth: true
                            text: page.inbox[page.selectedIndex].body
                            color: Theme.foreground
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: Theme.background
                            border.width: 1
                            border.color: Theme.muted
                            radius: page.radius

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                text: "Reply to this event…"
                                color: Theme.muted
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 168
                color: Theme.darkBackground
                radius: page.radius
                border.width: 1
                border.color: Theme.muted
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    Text {
                        text: "EVENT LOG"
                        color: Theme.muted
                        font.pixelSize: 11
                        font.letterSpacing: 1.5
                        font.bold: true
                    }

                    Repeater {
                        model: page.logs

                        RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 8
                                Layout.preferredHeight: 8
                                color: modelData.tone === "green" ? Theme.green
                                     : modelData.tone === "yellow" ? Theme.yellow
                                     : modelData.tone === "red" ? Theme.red
                                     : Theme.muted
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.line
                                color: Theme.foreground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
