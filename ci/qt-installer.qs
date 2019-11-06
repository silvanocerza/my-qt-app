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

    var username = installer.environmentVariable("QT_ACCOUNT_USERNAME");
    var password = installer.environmentVariable("QT_ACCOUNT_PASSWORD");
    page.loginWidget.EmailLineEdit.setText(username);
    page.loginWidget.PasswordLineEdit.setText(password);

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
        widget.selectComponent("qt.qt5.598.win64_msvc2017_64");
    } else if (installer.value("os") === "x11") {
        widget.selectComponent("qt.qt5.598.gcc_64");
    } else if (installer.value("os") === "macos") {
        widget.selectComponent("qt.qt5.598.clang_64");
    }

    widget.selectComponent("qt.qt5.598.qtwebengine");
    widget.selectComponent("qt.qt5.598.qtgamepad");
    widget.selectComponent("qt.qt5.598.qtscxml");
    widget.selectComponent("qt.qt5.598.qtserialbus");
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
