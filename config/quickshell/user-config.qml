// User Quickshell config - loads last, overrides Minflair defaults
// This file is sourced by Minflair's main config

import "Theme.qml" as Theme

// User preferences
PropertyChanges {
    target: Theme
    // Font preferences
    fontFamily: "JetBrains Mono"
    fontSize: 10
    materialIconFont: "Material Symbols Rounded"

    // Bar preferences
    barHeight: 36
    barPadding: 8
    barGap: 4

    // Animation preferences
    animationDuration: 150
    animationEasing: "OutExpo"

    // Color preferences (will be overridden by wallpaper theming)
    // accentColor: Theme.colors.accent
}

// Custom modules can be added here
// Example: Custom widget
/*
Item {
    id: customWidget
    width: 200
    height: 36

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        radius: 8
        border.color: Theme.colors.outline
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "F#ckIt!"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.colors.onSurface
        }
    }
}
*/