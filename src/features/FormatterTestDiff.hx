package features;

import Vscode.*;
import haxe.io.Path;
import js.Promise;
import sys.FileSystem;
import sys.io.File;
import vscode.*;
using StringTools;

class FormatterTestDiff {
    static inline var ResultFile = "server/formatter/test/formatter-result.txt";

    var leftUri = Uri.parse("v://v/l.hx");
    var rightUri = Uri.parse("v://v/r.hx");

    var leftContent:String;
    var rightContent:String;
    var _onDidChange = new EventEmitter<Uri>();

    public var onDidChange(default,null):Event<Uri>;

    public function new(context:ExtensionContext) {
        onDidChange = _onDidChange.event;

        workspace.registerTextDocumentContentProvider("v", this);

        var watcher = workspace.createFileSystemWatcher("**/formatter-result.txt", true, false, true);
        context.subscriptions.push(watcher.onDidChange(function(uri) loadResults()));
        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.formatterTestDiff", function() {
            loadResults();
            commands.executeCommand("vscode.diff", leftUri, rightUri);
        }));
    }

    function loadResults() {
        var path = Path.join([workspace.rootPath, ResultFile]);
        if (!FileSystem.exists(path)) return;

        var testResults = File.getContent(path).split("---");
        leftContent = testResults[0].trim();
        rightContent = testResults[1].trim();
        _onDidChange.fire(leftUri);
        _onDidChange.fire(rightUri);
    }

    public function provideTextDocumentContent(uri:Uri, _):ProviderResult<String> {
        return new Promise(function(resolve, reject) {
            if (uri.toString() == leftUri.toString())
                resolve(leftContent);
            else if (uri.toString() == rightUri.toString())
                resolve(rightContent);
            reject("invalid Uri " + uri.toString());
        });
    }
}