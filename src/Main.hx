import vscode.DecorationRenderOptions;
import js.Promise;
import js.node.Os;
import js.node.ChildProcess;
import js.node.stream.Readable;
import js.node.child_process.ChildProcess.ChildProcessEvent;
import js.node.Fs;
import vscode.ProviderResult;
import vscode.CancellationToken;
import vscode.Event;
import vscode.Uri;
import vscode.Selection;

class VisContentProvider {
    var hxparserPath:String;
    var _onDidChange = new vscode.EventEmitter<Uri>();
    public var onDidChange(default,null):Event<Uri>;


    public function new(hxparserPath) {
        this.hxparserPath = hxparserPath;
        onDidChange = _onDidChange.event;
    }

    public function update(uri) {
        _onDidChange.fire(uri);
    }

    public function provideTextDocumentContent(uri:Uri, token:CancellationToken):ProviderResult<String> {
        var editor = Vscode.window.activeTextEditor;
        if (editor.document.languageId != "haxe")
            return "Not a Haxe source file";

        return new Promise(function(resolve, reject) {
            var tmpFile = Os.tmpdir() + "/hxparservis";
            Fs.writeFile(tmpFile, editor.document.getText(), function(err) {
                if (err != null)
                    return reject(err);
                var data = "";
                var cp = ChildProcess.spawn(hxparserPath, ["--json", tmpFile]);
                cp.stdout.on(ReadableEvent.Data, function(s:String) data += s);
                cp.on(ChildProcessEvent.Close, function(code, _) {
                    if (code != 0)
                        return reject('hxparser exited with code $code');

                    // meh
                    data = data.substring(0, data.indexOf("]\r\nParsed") + 1);

                    var html =
                        try Vis.vis(editor.document.uri.toString(), data)
                        catch (e:Any) {
                            '<p>Error while visualizing: ${Std.string(e)}</p><pre>${StringTools.htmlEscape(data)}</pre>';
                        }
                    resolve(html);
                });
            });
        });
    }
}

class Main {
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
        var visUri = Uri.parse("hxparservis://authority/hxparservis");

        var hxparserPath = Vscode.workspace.getConfiguration("hxparservis").get("path", "hxparser");

        var provider = new VisContentProvider(hxparserPath);

        context.subscriptions.push(Vscode.workspace.registerTextDocumentContentProvider('hxparservis', provider));

        context.subscriptions.push(Vscode.workspace.onDidChangeTextDocument(function(e) {
            if (e.document == Vscode.window.activeTextEditor.document)
                provider.update(visUri);
        }));

        context.subscriptions.push(Vscode.window.onDidChangeTextEditorSelection(function(e) {
            if (e.textEditor == Vscode.window.activeTextEditor)
                provider.update(visUri);
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.visualize", function() {
            return Vscode.commands.executeCommand('vscode.previewHtml', visUri, vscode.ViewColumn.Two, 'hxparser visualization').then(null, function(error) Vscode.window.showErrorMessage(error));
        }));

        var highlightDecoration = Vscode.window.createTextEditorDecorationType({
            backgroundColor: 'rgba(255,255,0,0.3)'
        });

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.reveal", function(uri:String, start:Int, end:Int) {
            trace(uri, start, end);
            for (editor in Vscode.window.visibleTextEditors) {
                if (editor.document.uri.toString() == uri) {
                    var range = new vscode.Range(editor.document.positionAt(start), editor.document.positionAt(end));
                    editor.revealRange(range, InCenter);
                    editor.setDecorations(highlightDecoration, [range]);
                }
            }
        }));
    }
}
