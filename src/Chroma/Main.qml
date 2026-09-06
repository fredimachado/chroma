import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    title: "Chroma"
    width: 1120
    height: 720
    minimumWidth: 880
    minimumHeight: 560
    color: Theme.background

    readonly property int ruleWidth: 2
    readonly property int radius: 0
    readonly property int navWidth: 168
    readonly property int pageStudio: 0
    readonly property int pagePalette: 1
    readonly property int pageSurfaces: 2
    readonly property int pageType: 3
    readonly property int pageTerm: 4
    readonly property int pageSession: 5

    readonly property var pages: [
        { page: root.pageStudio, label: "Studio" },
        { page: root.pagePalette, label: "Palette" },
        { page: root.pageSurfaces, label: "Surfaces" },
        { page: root.pageType, label: "Type" },
        { page: root.pageTerm, label: "Term" },
        { page: root.pageSession, label: "Session" }
    ]

    Rectangle {
        id: accentRule
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.ruleWidth
        color: Theme.accent
    }

    Row {
        anchors.top: accentRule.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        Rectangle {
            id: nav
            width: root.navWidth
            height: parent.height
            color: Theme.darkBackground

            Column {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 4

                Text {
                    text: "CHROMA"
                    color: Theme.accent
                    font.pixelSize: 12
                    font.letterSpacing: 2
                    font.bold: true
                }

                Text {
                    text: App.themeName.length > 0 ? App.themeName : "no theme"
                    color: Theme.muted
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width
                }

                Item { height: 16; width: 1 }

                Repeater {
                    model: root.pages

                    Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 36
                        color: App.page === modelData.page ? Theme.selection : "transparent"
                        radius: root.radius

                        Rectangle {
                            width: root.ruleWidth
                            height: parent.height
                            color: App.page === modelData.page ? Theme.accent : "transparent"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            text: modelData.label
                            color: App.page === modelData.page ? Theme.accent : Theme.foreground
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: App.go(modelData.page)
                        }
                    }
                }
            }
        }

        Rectangle {
            width: root.ruleWidth
            height: parent.height
            color: Theme.muted
        }

        Loader {
            width: parent.width - nav.width - root.ruleWidth
            height: parent.height
            sourceComponent: {
                if (App.page === root.pageStudio)
                    return studioPage
                if (App.page === root.pagePalette)
                    return palettePage
                if (App.page === root.pageSurfaces)
                    return surfacesPage
                if (App.page === root.pageType)
                    return typePage
                if (App.page === root.pageTerm)
                    return termPage
                if (App.page === root.pageSession)
                    return sessionPage
                return sessionPage
            }
        }
    }

    Component { id: studioPage; Studio {} }
    Component { id: palettePage; PaletteView {} }
    Component { id: surfacesPage; Surfaces {} }
    Component { id: typePage; Type {} }
    Component { id: termPage; Term {} }
    Component { id: sessionPage; Session {} }
}
