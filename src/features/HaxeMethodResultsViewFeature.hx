package features;

import Vscode.*;
import vscode.*;
import util.HtmlPrinter;

class HaxeMethodResultsViewFeature {
    var webviewPanel:WebviewPanel;
    var results:{method:String, response:Response};

    public function new(context:ExtensionContext) {
        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.updateHaxeMethodResults", function(results:{method:String, response:Response}) {
            if (results.method != "completionItem/resolve") {
                this.results = results;
                update();
            }
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
            webviewPanel.title = results.method;
            webviewPanel.webview.html = HtmlPrinter.printJson(results.response.result);
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
    @:optional final timers:Timer;
}
