import qbs

Project {
    name: "My App"
    minimumQbsVersion: "1.12.1"

    property string major: "3"
    property string minor: "2"
    property string patch: "2"

    property string version: major + '.' + minor + "." + patch
    property string shortVersion: major

    property string packageSuffix: ""

    qbsSearchPaths: "custom"

    references: [
        "app/app.qbs",
        "counter_plugin/counter_plugin.qbs",
        "dist/archive.qbs",
        "dist/distribute.qbs",
        "dist/win/installer.qbs",
    ]
}
