package features;

import Vscode.*;
import vscode.*;
import util.HtmlPrinter;

class HaxeMethodResultsViewFeature {
    var webviewPanel:WebviewPanel;
    var trackedMethod:String;
    var mostRecentMethod:String;
    var results = new Map<String, Response>();

    public function new(context:ExtensionContext) {
        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.methodResultsView.update", function(results:{method:String, response:Response}) {
            mostRecentMethod = results.method;
            results.response.timers = null;
            this.results[results.method] = results.response;
            update();
        }));

        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.methodResultsView.open", function() {
            if (webviewPanel == null) {
                webviewPanel = window.createWebviewPanel("vshaxeDebugTools.haxeMethodResults",
                    "Haxe Method Results", ViewColumn.Two, {enableFindWidget: true, enableScripts: true});
            }
            update();
        }));

        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.methodResultsView.track", function(method:String) {
            this.trackedMethod = method;
            update();
        }));
    }

    function update() {
        var method = if (trackedMethod != null) trackedMethod else mostRecentMethod;
        if (webviewPanel != null) {
            webviewPanel.title = method;
            webviewPanel.webview.html = HtmlPrinter.printJson(results[method], false);
        }
    }
}

// This is now duplicated in three places, it's getting ridicolous

typedef Timer = {
    final name:String;
    final path:String;
    final info:String;
    final time:Float;
    final calls:Int;
    final percentTotal:Float;
    final percentParent:Float;
    @:optional final children:Array<Timer>;
}

typedef Response = {
    final result:Dynamic;
    /** Only sent if `--times` is enabled. **/
    @:optional var timers:Timer;
}
