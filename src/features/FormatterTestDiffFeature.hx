package features;

import Vscode.*;
import vscode.*;
import haxe.io.Path;
import js.Promise;
import sys.FileSystem;
import sys.io.File;
using StringTools;

class FormatterTestDiffFeature {
    static inline var ResultFile = "test/formatter-result.txt";

    var leftUri = Uri.parse("v://v/l.hx");
    var rightUri = Uri.parse("v://v/r.hx");

    var leftContent:String;
    var rightContent:String;
    var _onDidChange = new EventEmitter<Uri>();

    public var onDidChange(default, null):Event<Uri>;

    public function new(context:ExtensionContext) {
        onDidChange = _onDidChange.event;

        workspace.registerTextDocumentContentProvider("v", this);

        var watcher = workspace.createFileSystemWatcher("**/formatter-result.txt", true, false, true);
        context.subscriptions.push(watcher.onDidChange(function(uri) loadResults()));
        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.diffFormatterTests", function() {
            loadResults();
            commands.executeCommand("vscode.diff", leftUri, rightUri);
        }));
    }

    function loadResults() {
        var path = Path.join([workspace.workspaceFolders[0].uri.fsPath, ResultFile]);
        if (!FileSystem.exists(path)) return;

        var testResults = File.getContent(path).replace("\r", "").split("\n---\n");
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
