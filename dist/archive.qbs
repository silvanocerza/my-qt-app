import qbs


InstallPackage {
    name: "archive"
    builtByDefault: false
    destinationDirectory: project.buildDirectory

    archiver.type: {
        if (qbs.targetOS.contains("windows")) {
            return "zip";
        } else {
            return "tar";
        }
    }

    Depends {
        productTypes: [
            "application",
        ]
    }

    targetName: {
        var baseName =  project.name.toLowerCase() + "-" +
                        project.version + "-" +
                        qbs.targetOS[0];

        if (qbs.architecture) {
            baseName += "-" + qbs.architecture
        }

        if (qbs.debugInformation) {
            baseName += "-" + qbs.buildVariant;
        }

        if (project.packageSuffix) {
            baseName += "-" + project.packageSuffix;
        }

        return baseName;
    }
}
