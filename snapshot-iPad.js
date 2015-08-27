#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3);

captureLocalizedScreenshot("Accounts"); // Accounts

target.frontMostApp().mainWindow().tableViews()[0].cells()["Allowance"].tap();
captureLocalizedScreenshot("Transactions"); // Transactions

target.frontMostApp().toolbar().buttons()["Filter"].tap();
captureLocalizedScreenshot("Filter"); // Filter
