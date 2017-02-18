import js.Promise;
import js.node.ChildProcess;
import js.node.stream.Readable;
import js.node.child_process.ChildProcess.ChildProcessEvent;
import vscode.ProviderResult;
import vscode.CancellationToken;
import vscode.Event;
import vscode.Uri;
import vscode.Position;

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

    public function highlightNode(pos:Int) {
        trace("TODO: look for node at " + pos);
    }

    public function provideTextDocumentContent(uri:Uri, token:CancellationToken):ProviderResult<String> {
        var editor = Vscode.window.activeTextEditor;
        if (editor.document.languageId != "haxe")
            return "Not a Haxe source file";

        return new Promise(function(resolve, reject) {
            var src = editor.document.getText();
            var data = "";
            var cp = ChildProcess.spawn(hxparserPath, ["--json", "<stdin>"]);
            cp.stdin.end(src);
            cp.stderr.on(ReadableEvent.Data, function(s:String) data += s);
            cp.on(ChildProcessEvent.Close, function(code, _) {
                if (code != 0)
                    return reject('hxparser exited with code $code');

                var html =
                    try Vis.vis(editor.document.uri.toString(), data)
                    catch (e:Any) {
                        '<p>Error while visualizing: ${Std.string(e)}</p><pre>${StringTools.htmlEscape(data)}</pre>';
                    }
                resolve(html);
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

        var highlightDecoration = Vscode.window.createTextEditorDecorationType({
            borderWidth: '1px',
            borderStyle: 'solid',
            borderColor: 'rgba(255,255,0,0.3)',
            backgroundColor: 'rgba(255,255,0,0.3)'
        });
        context.subscriptions.push(highlightDecoration);

        context.subscriptions.push(Vscode.workspace.registerTextDocumentContentProvider('hxparservis', provider));

        context.subscriptions.push(Vscode.workspace.onDidChangeTextDocument(function(e) {
            if (e.document == Vscode.window.activeTextEditor.document) {
                Vscode.window.activeTextEditor.setDecorations(highlightDecoration, []);
                provider.update(visUri);
            }
        }));

        context.subscriptions.push(Vscode.window.onDidChangeTextEditorSelection(function(e) {
            if (e.textEditor == Vscode.window.activeTextEditor) {
                provider.highlightNode(e.textEditor.document.offsetAt(e.textEditor.selection.anchor));
            }
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.visualize", function() {
            return Vscode.commands.executeCommand('vscode.previewHtml', visUri, vscode.ViewColumn.Two, 'hxparser visualization').then(null, function(error) Vscode.window.showErrorMessage(error));
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.reveal", function(uri:String, start:Int, end:Int) {
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
