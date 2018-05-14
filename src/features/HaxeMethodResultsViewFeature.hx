package features;

import Vscode.*;
import vscode.*;
import util.HtmlPrinter;

class HaxeMethodResultsViewFeature {
    var webviewPanel:WebviewPanel;
    var results:Any;

    public function new(context:ExtensionContext) {
        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.updateHaxeMethodResults", function(results:Any) {
            this.results = results;
            update();
        }));

        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.visualizeHaxeMethodResults", function() {
            if (webviewPanel == null) {
                webviewPanel = window.createWebviewPanel("vshaxeDebugTools.haxeMethodResults",
                    "Haxe Method Results", ViewColumn.Two, {enableFindWidget: true, enableScripts: true});
            }
            update();
        }));
    }

    function update() {
        if (webviewPanel != null) {
            webviewPanel.webview.html = HtmlPrinter.printJson(results);
        }
    }
}
