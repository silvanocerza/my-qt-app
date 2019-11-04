import qbs


Project {
    DynamicLibrary {
        name: "counter_plugin"

        Depends { name: "cpp" }
        cpp.cxxLanguageVersion: "c++14"
        cpp.includePaths: [
            ".",
        ]

        Depends { name: "Qt.quick" }

        files: [
            "counter_plugin.h",
            "counter.h",
        ]

        Group {     // Properties for the produced executable
            fileTagsFilter: product.type
            qbs.install: true
            qbs.installDir: "MyCompany/Counter"
            qbs.installPrefix: ""
        }

        Group {
            files: ["qmldir"]
            qbs.install: true
            qbs.installDir: "MyCompany/Counter"
            qbs.installPrefix: ""
        }
    }
}
