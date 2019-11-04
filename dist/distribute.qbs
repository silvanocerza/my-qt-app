import qbs
import qbs.File
import qbs.FileInfo


// Installs several files that might be useful for a Qt application
Product {
    name: "distribute"
    type: ["installable", "launcher", "qtlibs"]
    builtByDefault: false

    Depends { productTypes: "application" }
    Depends { name: "cpp" }
    Depends { name: "Qt.core" }
    Depends { name: "Qt.qml" }
    Depends {
        // We depend on these Qt modules only on Linux because on Windows they don't expose
        // their dynamic libraries files as targets, so use two different approaches to install
        name: "Qt"
        condition: qbs.targetOS.contains("linux")
        submodules: [
            "svg",
            "concurrent",
            "opengl",
            "printsupport",
            "widgets",
            "quicktemplates2-private",
            "quickcontrols2",
            "sql",
            "dbus",
            "xcb_qpa_lib-private"
        ]
    }

    Group {
        // Qt libraries to be installed on Windows only
        name: "Qt libraries"
        condition: qbs.targetOS.contains("windows")
        prefix: Qt.core.binPath + "/"

        fileTags: ["qt-libs-input"]

        property string postfix: {
            var suffix = "";
            if (qbs.debugInformation) {
                suffix += "d";
            }
            return suffix + cpp.dynamicLibrarySuffix;
        }

        files: {
            var list = [];
            if (!Qt.core.frameworkBuild) {
                list.push(
                    "Qt5Concurrent" + postfix,
                    "Qt5Core" + postfix,
                    "Qt5Gui" + postfix,
                    "Qt5Network" + postfix,
                    "Qt5OpenGL" + postfix,
                    "Qt5PrintSupport" + postfix,
                    "Qt5Qml" + postfix,
                    "Qt5Quick" + postfix,
                    "Qt5QuickControls2" + postfix,
                    "Qt5QuickTemplates2" + postfix,
                    "Qt5Sql" + postfix,
                    "Qt5Svg" + postfix,
                    "Qt5Widgets" + postfix
                );
            }
            return list;
        }
        qbs.install: false
    }

    Group {
        name: "Qt extra libraries"
        prefix: {
            if (qbs.targetOS.contains("windows")) {
                return Qt.core.binPath + "/"
            } else {
                return Qt.core.libPath + "/lib"
            }
        }

        fileTags: ["dynamiclibrary"]

        property string postfix: {
            var suffix = "";
            if (qbs.targetOS.contains("windows") && qbs.debugInformation)
                suffix += "d";
            return suffix + cpp.dynamicLibrarySuffix;
        }

        files: {
            var list = [];

            if (qbs.targetOS.contains("windows")) {
                list.push(
                    "libEGL" + postfix,
                    "libGLESv2" + postfix,
                    "d3dcompiler_47.dll"
                );
            } else if (qbs.targetOS.contains("linux")) {
                if (File.exists(prefix + "icudata.so.56")) {
                    list.push("icudata.so.56", "icudata.so.56.1");
                    list.push("icui18n.so.56", "icui18n.so.56.1");
                    list.push("icuuc.so.56", "icuuc.so.56.1");
                }
            }

            return list;
        }
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: qbs.targetOS.contains("windows") ? "" : "lib"
    }

    Group {
        name: "Launcher scripts"
        condition: qbs.targetOS.contains("linux")
        fileTagsFilter: "launcher"
        qbs.install: true
        qbs.installPrefix: ""
    }

    Rule {
        condition: qbs.targetOS.contains("linux")
        inputsFromDependencies: ["application"]

        Artifact {
            filePath: input.baseName + ".sh"
            fileTags: ["launcher"]
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = input.fileName + "->" + output.fileName;
            cmd.sourceCode = function() {
                var launcherScript = FileInfo.joinPaths(product.sourceDirectory, "linux", "launcher.sh");
                File.copy(launcherScript, output.filePath);
            }
            return [cmd];
        }
    }

    Group {
        // Installs all necessary Qt libraries
        fileTags: "qtlibs"
        fileTagsFilter: ["qt-libs-output"]
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: qbs.targetOS.contains("windows") ? "" : "lib"
    }

    Rule {
        // Copies Qt libraries on Windows
        condition: qbs.targetOS.contains("windows")
        inputs: ["qt-libs-input"]

        Artifact {
            filePath: input.fileName
            fileTags: ["qt-libs-output"]
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Copying Qt " + input.fileName;
            cmd.sourceCode = function() {
                File.copy(input.filePath, output.filePath);
            }
            return [cmd];
        }
    }

    Rule {
        // Copies Qt libraries on Linux
        condition: qbs.targetOS.contains("linux")
        alwaysRun: true
        multiplex: true
        inputsFromDependencies: ["dynamiclibrary"]

        outputArtifacts: {
            // There must be one output Artifact for each input file,
            // duplicates are ignored
            var artifacts = [];
            for (var i = 0; i < inputs["dynamiclibrary"].length; i++) {
                // The input files are named like so "libQt5Core.so.5.9.7"
                // but binaries link "libQt5Core.so.5" so save those as output
                var patch = inputs["dynamiclibrary"][i].fileName;
                var minor = patch.substring(0, patch.lastIndexOf("."));
                var major = minor.substring(0, minor.lastIndexOf("."));
                artifacts.push({ filePath: major, fileTags: ["qt-libs-output"] });
            }
            return artifacts;
        }

        outputFileTags: ["qt-libs-output"]

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Copying Qt libraries";
            cmd.sourceCode = function() {
                // The same library might be repeated so filter those out
                var uniqueInputs = [];
                var uniqueNames = [];
                for (var i = 0; i < inputs["dynamiclibrary"].length; i++) {
                    var input = inputs["dynamiclibrary"][i];
                    if (uniqueNames.indexOf(input.filePath) === -1) {
                        uniqueInputs.push(input);
                        uniqueNames.push(input.filePath);
                    }
                }

                inputs["dynamiclibrary"] = uniqueInputs;

                // Copy each input file to its output destination
                // THIS ASSUMES THAT INPUT AND OUTPUT HAVE SAME SIZE AND ORDER!
                // It's not giving issues as of now but I think it's good if
                // I let you know
                for (var i = 0; i < inputs["dynamiclibrary"].length; i++) {
                    var input = inputs["dynamiclibrary"][i];
                    var output = outputs["qtlibs"][i];
                    File.copy(input.filePath, output.filePath);
                }
            }
            return [cmd];
        }
    }

    property var pluginFiles: {
        if (qbs.targetOS.contains("windows")) {
            if (qbs.debugInformation)
                return ["*d.dll"];
            else
                return ["*.dll"];
        } else if (qbs.targetOS.contains("linux")) {
            return ["*.so"];
        }
        return ["*"];
    }

    property var pluginExcludeFiles: {
        var files = ["*.pdb"];
        if (!(qbs.targetOS.contains("windows") && qbs.debugInformation)) {
            // Exclude debug DLLs.
            //
            // This also excludes the qdirect2d.dll platform plugin, but I'm
            // not sure when it would be preferable over the qwindows.dll. In
            // testing it, it seems to have severe issues with HiDpi screens
            // (as of Qt 5.8.0).
            files.push("*d.dll");
        }
        return files;
    }

    Group {
        name: "Qt Platform Plugins"
        prefix: FileInfo.joinPaths(Qt.core.pluginPath, "/platforms/")
        files: pluginFiles
        excludeFiles: pluginExcludeFiles
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: "plugins/platforms"
    }

    Group {
        name: "Qt SQL Plugins"
        prefix: FileInfo.joinPaths(Qt.core.pluginPath, "/sqldrivers/")
        files: pluginFiles
        excludeFiles: pluginExcludeFiles
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: "plugins/sqldrivers"
    }

    Group {
        name: "Qt Image Format Plugins"
        prefix: FileInfo.joinPaths(Qt.core.pluginPath, "/imageformats/")
        files: pluginFiles
        excludeFiles: pluginExcludeFiles
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: "plugins/imageformats"
    }

    Group {
        name: "Qt XCB GL Integration Plugins"
        condition: qbs.targetOS.contains("linux")
        prefix: FileInfo.joinPaths(Qt.core.pluginPath, "/xcbglintegrations/")
        files: pluginFiles
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: "plugins/xcbglintegrations"
    }

    Group {
        name: "Qt QML"
        prefix: Qt.qml.qmlPath + "/"
        files: [
            "QtQml/**",
            "QtQuick/**",
            "QtQuick.2/**",
            "QtGraphicalEffects/**",
            "Qt/labs/folderlistmodel/**",
            "Qt/labs/settings/**",
        ]
        excludeFiles: {
            var files = ["**/*.pdb"];
            if (!(qbs.targetOS.contains("windows") && qbs.debugInformation)) {
                // Exclude debug DLLs.
                files.push("**/*d.dll");
            }
            return files;
        }
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: "qml"
        qbs.installSourceBase: prefix
    }

    Group {
        name: "Runtime DLLs"
        condition: qbs.targetOS.contains("windows")

        prefix: {
            if (qbs.architecture === "x86_64")
                return "C:/windows/system32/";
            else
                return "C:/windows/SysWOW64/";
        }
        files: {
            return [
                "vccorlib140.dll",
                "vcruntime140.dll",
                "msvcp140.dll",
            ]
        }
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: ""
    }

    Group {
        name: "Misc Files"
        files: {
            var list = [];

            if (qbs.targetOS.contains("windows"))
                list.push("win/qt.conf");
            else if (qbs.targetOS.contains("linux"))
                list.push("linux/qt.conf");

            return list;
        }
        qbs.install: true
        qbs.installPrefix: ""
        qbs.installDir: ""
    }
}

