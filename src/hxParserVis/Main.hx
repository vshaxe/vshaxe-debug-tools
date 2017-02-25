package hxParserVis;

class Main {
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
        var provider = new ContentProvider();

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

        context.subscriptions.push(Vscode.workspace.onDidCloseTextDocument(function(e) {
            if (e.fileName != "\\hxparservis")
                return;
            forEditorWithUri(provider.previousEditor.document.uri.toString(), function(editor) {
                editor.setDecorations(highlightDecoration, []);
            });
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.visualize", function() {
            return Vscode.commands.executeCommand('vscode.previewHtml', ContentProvider.visUri, vscode.ViewColumn.Two, 'hxparser visualization')
                .then(null, function(error) Vscode.window.showErrorMessage(error));
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.reveal", function(uri:String, start:Int, end:Int) {
            forEditorWithUri(uri, function(editor) {
                var range = new vscode.Range(editor.document.positionAt(start), editor.document.positionAt(end));
                editor.revealRange(range, InCenter);
                editor.setDecorations(highlightDecoration, [range]);
            });
        }));

        context.subscriptions.push(Vscode.commands.registerCommand("hxparservis.switchOutput", function(outputKind:String) {
            provider.switchOutputKind(outputKind);
        }));
    }

    static function forEditorWithUri(uri:String, callback:vscode.TextEditor->Void) {
        for (editor in Vscode.window.visibleTextEditors) {
            if (editor.document.uri.toString() == uri)
                callback(editor);
        }
    }
}
