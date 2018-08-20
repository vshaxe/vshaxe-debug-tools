package features;

import Vscode.*;
import js.node.Buffer;
import vscode.*;

using StringTools;

/** Useful for debugging Haxe display requests, since the cursor offset is needed there. **/
class CursorOffsetFeature {
	public function new(context:ExtensionContext) {
		var cursorOffset = window.createStatusBarItem(Right, 100);
		cursorOffset.tooltip = "Cursor Byte Offset";
		context.subscriptions.push(cursorOffset);

		function updateItem() {
			var editor = window.activeTextEditor;
			if (editor == null || (editor.document.languageId != "haxe" && !editor.document.fileName.endsWith(".mtt"))) {
				cursorOffset.hide();
				return;
			}
			var pos = editor.selection.start;
			var textUntilCursor = editor.document.getText(new Range(0, 0, pos.line, pos.character));
			cursorOffset.text = "Offset: " + Buffer.byteLength(textUntilCursor);
			cursorOffset.show();
		}

		context.subscriptions.push(window.onDidChangeTextEditorSelection(function(_) updateItem()));
		context.subscriptions.push(window.onDidChangeActiveTextEditor(function(_) updateItem()));
		updateItem();
	}
}
