package features.vis;

import Vscode.*;
import vscode.*;

class VisFeatureBase<T:ContentProviderBase<Dynamic>> {
	final viewType:String;
	final title:String;
	final provider:T;
	var panel:Null<WebviewPanel>;

	public function new(context:ExtensionContext, provider:T, viewType:String, title:String, visualizeCommand:String) {
		this.viewType = "vshaxeDebugTools." + viewType;
		this.title = title;
		this.provider = provider;

		var highlightDecoration = window.createTextEditorDecorationType({
			borderWidth: "1px",
			borderStyle: "solid",
			borderColor: "rgba(255,255,0,0.3)",
			backgroundColor: "rgba(255,255,0,0.3)"
		});
		context.subscriptions.push(highlightDecoration);

		context.subscriptions.push(commands.registerCommand(visualizeCommand, function() {
			if (panel != null) {
				panel.reveal(ViewColumn.Two);
			} else {
				panel = Vscode.window.createWebviewPanel(viewType, title, {viewColumn: ViewColumn.Two}, {
					enableFindWidget: true,
					enableCommandUris: true,
					retainContextWhenHidden: true,
					enableScripts: true
				});
				panel.onDidDispose(function(_) {
					forEditorWithUri(provider.previousEditor.document.uri.toString(), function(editor) {
						editor.setDecorations(highlightDecoration, []);
					});
					panel = null;
				});
			}
			update();
		}));

		context.subscriptions.push(workspace.onDidChangeTextDocument(function(e) {
			var activeEditor = window.activeTextEditor;
			if (activeEditor != null && e.document == activeEditor.document) {
				activeEditor.setDecorations(highlightDecoration, []);
				provider.invalidate();
			}
			update();
		}));

		context.subscriptions.push(window.onDidChangeTextEditorSelection(function(e) {
			if (panel != null && e.textEditor == window.activeTextEditor) {
				panel.webview.postMessage(e.textEditor.document.offsetAt(e.textEditor.selection.anchor));
			}
		}));

		context.subscriptions.push(commands.registerCommand('$viewType.reveal', function(uri:String, start:Int, end:Int) {
			forEditorWithUri(uri, function(editor) {
				var range = new Range(editor.document.positionAt(start), editor.document.positionAt(end));
				editor.revealRange(range, InCenter);
				editor.setDecorations(highlightDecoration, [range]);
			});
		}));
	}

	function forEditorWithUri(uri:String, callback:TextEditor->Void) {
		for (editor in window.visibleTextEditors) {
			if (editor.document.uri.toString(true) == uri) {
				callback(editor);
			}
		}
	}

	function update() {
		if (panel != null) {
			provider.provideHtml().then(html -> panel.webview.html = html);
		}
	}
}
