package features.vis;

import js.Promise;
import vscode.*;

class ContentProviderBase<T> {
	var uri:Uri;
	var content:T;
	var currentNodePos:Int;
	var _onDidChange = new vscode.EventEmitter<Uri>();

	public var previousEditor(default, null):TextEditor;
	public var onDidChange(default, null):Event<Uri>;

	public function new(uri:Uri) {
		this.uri = uri;
		currentNodePos = -1;
		onDidChange = _onDidChange.event;
	}

	public function updateText(?newContent:T) {
		content = newContent;
		_onDidChange.fire(uri);
	}

	public function highlightNode(pos) {
		if (currentNodePos != pos) {
			currentNodePos = pos;
			Vscode.commands.executeCommand("_workbench.htmlPreview.postMessage", uri, {pos: pos});
		}
	}

	function getActiveEditor() {
		var editor = Vscode.window.activeTextEditor;
		if (editor == null)
			return previousEditor;
		return editor;
	}

	public function provideTextDocumentContent(_, _):ProviderResult<String> {
		var editor = getActiveEditor();
		if (editor != null && editor.document.languageId != "haxe")
			return "Not a Haxe source file";
		previousEditor = editor;
		return if (content == null) reparse() else rerender();
	}

	function rerender() {
		var editor = getActiveEditor();
		if (editor == null)
			return "";
		var fontFamily = Vscode.workspace.getConfiguration("editor").get("fontFamily", "monospace");
		var fontSize = Vscode.workspace.getConfiguration("editor").get("fontSize", "14");
		return printHtml(editor.document.uri.toString(), fontFamily, fontSize);
	}

	function printHtml(editor:String, fontFamily:String, fontSize:String):String {
		return "";
	}

	function reparse():Promise<String> {
		return null;
	}
}
