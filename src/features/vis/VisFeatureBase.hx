package features.vis;

import Vscode.*;
import vscode.*;

class VisFeatureBase {
	public function new(context:ExtensionContext) {}

	function initSubscriptions<T>(context:ExtensionContext, provider:ContentProviderBase<T>, name:String) {
		var highlightDecoration = window.createTextEditorDecorationType({
			borderWidth: "1px",
			borderStyle: "solid",
			borderColor: "rgba(255,255,0,0.3)",
			backgroundColor: "rgba(255,255,0,0.3)"
		});

		context.subscriptions.push(highlightDecoration);

		context.subscriptions.push(workspace.registerTextDocumentContentProvider(name, provider));

		context.subscriptions.push(window.onDidChangeActiveTextEditor(function(editor) {
			provider.updateText();
		}));

		// TODO: figure out what to do with regular updates as we can now receive the language server's incremental parsing results
		context.subscriptions.push(workspace.onDidChangeTextDocument(function(e) {
			var activeEditor = window.activeTextEditor;
			if (activeEditor != null && e.document == activeEditor.document) {
				activeEditor.setDecorations(highlightDecoration, []);
				provider.updateText();
			}
		}));

		context.subscriptions.push(commands.registerCommand('$name.updateParseTree', function(uri:String, parseTree:String) {
			if (provider.previousEditor != null && uri == provider.previousEditor.document.uri.toString()) {
				provider.updateText(haxe.Unserializer.run(parseTree));
			}
		}));

		context.subscriptions.push(window.onDidChangeTextEditorSelection(function(e) {
			if (e.textEditor == window.activeTextEditor) {
				provider.highlightNode(e.textEditor.document.offsetAt(e.textEditor.selection.anchor));
			}
		}));

		context.subscriptions.push(workspace.onDidCloseTextDocument(function(e) {
			if (e.fileName != '\\$name') {
				return;
			}
			forEditorWithUri(provider.previousEditor.document.uri.toString(), function(editor) {
				editor.setDecorations(highlightDecoration, []);
			});
		}));

		context.subscriptions.push(commands.registerCommand('$name.reveal', function(uri:String, start:Int, end:Int) {
			forEditorWithUri(uri, function(editor) {
				var range = new Range(editor.document.positionAt(start), editor.document.positionAt(end));
				editor.revealRange(range, InCenter);
				editor.setDecorations(highlightDecoration, [range]);
			});
		}));
	}

	function forEditorWithUri(uri:String, callback:TextEditor->Void) {
		for (editor in window.visibleTextEditors) {
			if (editor.document.uri.toString() == uri) {
				callback(editor);
			}
		}
	}
}
