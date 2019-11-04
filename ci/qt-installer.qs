function Controller() {
    installer.autoRejectMessageBoxes();
    installer.setMessageBoxAutomaticAnswer("installationError", QMessageBox.Retry);
    installer.setMessageBoxAutomaticAnswer("installationErrorWithRetry", QMessageBox.Retry);
    installer.setMessageBoxAutomaticAnswer("DownloadError", QMessageBox.Retry);
    installer.setMessageBoxAutomaticAnswer("archiveDownloadError", QMessageBox.Retry);
    installer.installationFinished.connect(function() {
        gui.clickButton(buttons.NextButton);
    })
}

Controller.prototype.WelcomePageCallback = function() {
    gui.clickButton(buttons.NextButton, 5000);
}

Controller.prototype.DynamicTelemetryPluginFormCallback = function() {
    gui.currentPageWidget().TelemetryPluginForm.statisticGroupBox.disableStatisticRadioButton.checked = true;
    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.CredentialsPageCallback = function() {
    var page = gui.pageWidgetByObjectName("CredentialsPage");
    page.EmailLineEdit.setText("{{ qt_email }}");
    page.PasswordLineEdit.setText("{{ qt_password }}");
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
    gui.currentPageWidget().TargetDirectoryLineEdit.setText(installer.value("InstallerDirPath") + "/Qt");
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.PerformInstallationPageCallback = function() {
    gui.clickButton(buttons.CommitButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    var selection = gui.pageWidgetByObjectName("ComponentSelectionPage");
    gui.findChild(selection, "Latest releases").checked = false;
    gui.findChild(selection, "LTS").checked = true;
    gui.findChild(selection, "FetchCategoryButton").click();

    var widget = gui.currentPageWidget();
    widget.deselectAll();

    if (installer.value("os") === "win") {
        widget.selectComponent("qt.qt59.win64_msvc2017_64");
    } else if (installer.value("os") === "x11") {
        widget.selectComponent("qt.qt59.gcc_64");
    } else if (installer.value("os") === "macos") {
        widget.selectComponent("qt.qt59.clang_64");
    }

    widget.selectComponent("qt.59.qtwebengine");
    widget.selectComponent("qt.59.qtgamepad");
    widget.selectComponent("qt.59.qtscxml");
    widget.selectComponent("qt.59.qtserialbus");
    widget.selectComponent("qt.enterpriseaddons");

    widget.deselectComponent("qt.license");
    widget.deselectComponent("qt.installer");

    gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function() {
    var checkBoxForm = gui.currentPageWidget().LaunchQtCreatorCheckBoxForm
    if (checkBoxForm && checkBoxForm.launchQtCreatorCheckBox) {
        checkBoxForm.launchQtCreatorCheckBox.checked = false;
    }
    gui.clickButton(buttons.FinishButton);
}
