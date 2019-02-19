package features.vis.hxParserVis;

import hxParser.HxParser;
import hxParser.HxParserCli;
import hxParser.JResult;
import hxParser.Converter;
import js.Promise;
import util.Result;
import features.vis.ContentProviderBase;

class HxParserContentProvider extends ContentProviderBase<HxParserContentData> {
	var outputKind:OutputKind = SyntaxTree;

	public function switchOutputKind(outputKind:OutputKind) {
		this.outputKind = outputKind;
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
