import QtQuick

Text {
    property bool pageTitle: false

    color: Theme.muted
    font.pixelSize: pageTitle ? 12 : 11
    font.letterSpacing: pageTitle ? 2 : 1.5
    font.bold: pageTitle
    textFormat: Text.PlainText
}
