package features;

import Vscode.*;
import vscode.*;

/** adds a text decoration to nicely separate the different sections in hxtest files **/
class HxTestSeparatorFeature {
    var separatorDecoration = window.createTextEditorDecorationType({
        isWholeLine: true,
        color: "#2a2d2e",
        backgroundColor: "#2a2d2e"
    });

    public function new(context:ExtensionContext) {
        context.subscriptions.push(workspace.onDidOpenTextDocument(function(e) decorate()));
        context.subscriptions.push(workspace.onDidChangeTextDocument(function(e) decorate()));
    }

    function decorate() {
        var editor = window.activeTextEditor;
        if (editor == null || editor.document.languageId != "hxtest") {
            return;
        }

        var decorations = [];
        for (line in 0...editor.document.lineCount) {
            var line = editor.document.lineAt(line);
            if (line.text == "---") {
                decorations.push(line.range);
            }
        }
        editor.setDecorations(separatorDecoration, decorations);
    }
}