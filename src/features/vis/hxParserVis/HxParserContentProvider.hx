package features.vis.hxParserVis;

import hxParser.HxParser;
import hxParser.HxParserCli;
import hxParser.JResult;
import hxParser.Converter;
import js.Promise;
import util.Result;
import vscode.*;
import features.vis.ContentProviderBase;

class HxParserContentProvider extends ContentProviderBase<HxParserContentData> {
	public static var visUri = Uri.parse("hxparservis://authority/hxparservis.hx");

	var outputKind:OutputKind = SyntaxTree;

	public function new() {
		super(visUri);
	}

	public function switchOutputKind(outputKind:OutputKind) {
		this.outputKind = outputKind;
		updateText();
	}

	override function printHtml(editor:String, fontFamily:String, fontSize:String):String {
		return new HxParserHtmlPrinter().print(editor, content, currentNodePos, outputKind, fontFamily, fontSize);
	}

	override function reparse():Promise<String> {
		return new Promise(function(resolve, reject) {
			var editor = getActiveEditor();
			if (editor == null)
				return;

			var src = editor.document.getText();

			function handleResult(result:Result<JResult>)
				switch (result) {
					case Success(data):
						content = {
							unparsedData: data,
							parsedTree: new Converter(data).convertResultToFile()
						}
						resolve(rerender());
					case Failure(reason):
						reject('hxparser failed: $reason');
				};

			var hxparserPath = Vscode.workspace.getConfiguration("hxparservis").get("path");
			if (hxparserPath == null) {
				handleResult(HxParser.parse(src));
			} else {
				HxParserCli.parse(hxparserPath, src, handleResult);
			}
		});
	}
}
