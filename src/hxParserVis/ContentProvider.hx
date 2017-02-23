package hxParserVis;

import hxParser.HxParser;
import hxParser.HxParserCli;
import hxParser.JsonParser;
import hxParser.Tree;
import hxParserVis.HtmlPrinter;
import js.Promise;
import util.Result;
import vscode.*;

class ContentProvider {
    public static var visUri = Uri.parse("hxparservis://authority/hxparservis");

    var previousEditor:TextEditor;
    var parsedTree:Tree;
    var currentNodePos:Int;
    var outputKind:OutputKind = SyntaxTree;
    var _onDidChange = new vscode.EventEmitter<Uri>();
    public var onDidChange(default,null):Event<Uri>;


    public function new() {
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

    public function switchOutputKind(outputKind:OutputKind) {
        this.outputKind = outputKind;
        updateText();
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
        return if (parsedTree == null) reparse() else rerender();
    }

    function rerender() {
        var editor = getActiveEditor();
        if (editor == null)
            return "";
        return HtmlPrinter.print(editor.document.uri.toString(), parsedTree, currentNodePos, outputKind);
    }

    function reparse() {
        return new Promise(function(resolve, reject) {
            var editor = getActiveEditor();
            if (editor == null)
                return;

            var src = editor.document.getText();

            function handleResult(result:Result<JResult>) switch (result) {
                case Success(data):
                    parsedTree = JsonParser.parse(data);
                    resolve(rerender());
                case Failure(reason):
                    reject('hxparser failed: $reason');
            };

            var hxparserPath = Vscode.workspace.getConfiguration("hxparservis").get("path");
            if (hxparserPath == null || hxparserPath == "") { // not sure why, but it can be an empty string when not specified
                handleResult(HxParser.parse(src));
            } else {
                HxParserCli.parse(hxparserPath, src, handleResult);
            }
        });
    }
}