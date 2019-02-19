package features.vis;

import js.Promise;
import vscode.*;

class ContentProviderBase<T> {
	var content:T;
	var currentNodePos:Int;

	public var previousEditor(default, null):TextEditor;

	public function new() {
		currentNodePos = -1;
	}

	function getActiveEditor() {
		var editor = Vscode.window.activeTextEditor;
		if (editor == null || editor.document.languageId != "haxe")
			return previousEditor;
		return editor;
	}

	public function provideHtml():Promise<String> {
		previousEditor = getActiveEditor();
		return if (content == null) reparse() else new Promise((resolve, reject) -> resolve(rerender()));
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
