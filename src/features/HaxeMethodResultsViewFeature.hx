package features;

import Vscode.*;
import vscode.*;

class HaxeMethodResultsViewFeature {
    static final uri = Uri.parse("haxe://methods/Haxe Methods.json");

    var webviewPanel:WebviewPanel;
    var trackedMethod:String;
    var mostRecentMethod:String;
    var results = new Map<String, Response>();
    var document:TextDocument;

    public var onDidChange(default,null):Event<Uri>;
    var _onDidChange:EventEmitter<Uri>;

    public function new(context:ExtensionContext) {
        _onDidChange = new EventEmitter();
        onDidChange = _onDidChange.event;

        workspace.registerTextDocumentContentProvider("haxe", this);

        commands.registerCommand("vshaxeDebugTools.methodResultsView.update", function(results:{method:String, response:Response}) {
            mostRecentMethod = results.method;
            Reflect.deleteField(results.response, "timers");
            this.results[results.method] = results.response;
            update();
        });

        commands.registerCommand("vshaxeDebugTools.methodResultsView.open", function() {
            window.showTextDocument(uri, {viewColumn: Two, preserveFocus: true});
            update();
        });

       commands.registerCommand("vshaxeDebugTools.methodResultsView.track", function(method:String) {
            this.trackedMethod = method;
            update();
        });
    }

    function update() {
        _onDidChange.fire(uri);
    }

    public function provideTextDocumentContent(uri:Uri, token:CancellationToken):ProviderResult<String> {
        var method = if (trackedMethod == null) mostRecentMethod else trackedMethod;
        var data = results[method];
        if (data == null) {
            return "null";
        }
        data.method = method;
        return haxe.Json.stringify(data, null, "    ");
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
    var method:String;
    final result:Dynamic;
    /** Only sent if `--times` is enabled. **/
    @:optional var timers:Timer;
}
