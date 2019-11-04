import qbs
import qbs.FileInfo


WindowsInstallerPackage {
    name: "installer"
    builtByDefault: false
    condition: qbs.targetOS.contains("windows")

    targetName: {
        var baseName = project.name.toLowerCase() + "-" +
                       project.version + "-" +
                       qbs.targetOS[0];

        if (qbs.architecture) {
            baseName += "-" + qbs.architecture;
        }

        if (project.packageSuffix) {
            baseName += "-" + project.packageSuffix;
        }

        return baseName;
    }

    destinationDirectory: project.buildDirectory

    files: [
        "installer.wxs",
        "qml.wxs",
    ]

    Depends {
        productTypes: [
            "application",
            "dynamiclibrary",
            "installable"
        ]
    }

    Depends { name: "cpp" }
    Depends { name: "Qt.core" }

    wix.defines: {
        var vcInstallDir = FileInfo.cleanPath(FileInfo.joinPaths(cpp.toolchainInstallPath, "../../../../../.."));
        var defs = [
            "ProductName=" + project.name,
            "Version=" + project.version,
            "ShortVersion=" + project.shortVersion,
            "InstallRoot=" + qbs.installRoot,
            "QmlRoot=" + FileInfo.joinPaths(qbs.installRoot, "qml"),
            "RootDir=" + project.sourceDirectory,
            "VcInstallDir=" + vcInstallDir
        ];
        return defs;
    }

    wix.version: project.version
    wix.versionMajor: parseInt(project.major)
    wix.versionMinor: parseInt(project.minor)
    wix.versionPatch: parseInt(project.patch)

    wix.extensions: [ "WixUIExtension" ]
}
