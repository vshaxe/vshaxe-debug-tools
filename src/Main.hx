import js.Promise;
import vscode.ProviderResult;
import vscode.Event;
import vscode.Uri;
import JsonParser.Tree;

class VisContentProvider {
    public static var visUri = Uri.parse("hxparservis://authority/hxparservis");

    var hxparserPath:String;
    var parsedTree:Tree;
    var currentNodePos:Int;
    var _onDidChange = new vscode.EventEmitter<Uri>();
    public var onDidChange(default,null):Event<Uri>;


    public function new(hxparserPath) {
        this.hxparserPath = hxparserPath;
        currentNodePos = -1;
        onDidChange = _onDidChange.event;
    }

    public function updateText() {
        parsedTree = null;
        _onDidChange.fire(visUri);
    }

    public function highlightNode(pos) {
        if (currentNodePos != pos) {
            currentNodePos = pos;
            Vscode.commands.executeCommand('_workbench.htmlPreview.postMessage', visUri, {pos: pos});
        }
    }

    public function provideTextDocumentContent(_, _):ProviderResult<String> {
        var editor = Vscode.window.activeTextEditor;
        if (editor != null && editor.document.languageId != "haxe")
            return "Not a Haxe source file";
        return if (parsedTree == null) reparse() else rerender();
    }

    function rerender() {
        var editor = Vscode.window.activeTextEditor;
        if (editor != null)
            return Vis.vis(editor.document.uri.toString(), parsedTree, currentNodePos);
        return "";
    }

    function reparse() {
        return new Promise(function(resolve, reject) {
            var editor = Vscode.window.activeTextEditor;
            if (editor == null)
                return;

            var src = editor.document.getText();
            HxParser.parse(hxparserPath, src, function(result) switch (result) {
                case Success(data):
                    parsedTree = JsonParser.parse(data);
                    resolve(rerender());
                case Failure(code):
                    reject('hxparser exited with code $code');
            });
        });
    }
}

class Main {
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
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

        context.subscriptions.push(Vscode.window.onDidChangeActiveTextEditor(function(editor) {
            provider.updateText();
        }));

        context.subscriptions.push(Vscode.workspace.onDidChangeTextDocument(function(e) {
            var activeEditor = Vscode.window.activeTextEditor;
            if (activeEditor != null && e.document == activeEditor.document) {
                Vscode.window.activeTextEditor.setDecorations(highlightDecoration, []);
                provider.updateText();
            }
        }));

        context.subscriptions.push(Vscode.window.onDidChangeTextEditorSelection(function(e) {
            if (e.textEditor == Vscode.window.activeTextEditor) {
                provider.highlightNode(e.textEditor.document.offsetAt(e.textEditor.selection.anchor));
            }
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.visualize", function() {
            return Vscode.commands.executeCommand('vscode.previewHtml', VisContentProvider.visUri, vscode.ViewColumn.Two, 'hxparser visualization')
                .then(null, function(error) Vscode.window.showErrorMessage(error));
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
