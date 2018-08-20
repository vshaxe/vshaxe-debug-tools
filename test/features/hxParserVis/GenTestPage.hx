package features.hxParserVis;

import features.vis.hxParserVis.HxParserHtmlPrinter;
import hxParser.Converter;
import hxParser.HxParser.HxParser;
import sys.io.File;

using StringTools;

class GenTestPage {
	public static function main() {
		var src = File.getContent("src/features/vis/hxParserVis/HxParserHtmlPrinter.hx");
		switch (HxParser.parse(src)) {
			case Success(data):
				var content = {
					unparsedData: data,
					parsedTree: new Converter(data).convertResultToFile()
				}
				var html = new HxParserHtmlPrinter().print("", content, 0, SyntaxTree, "Segoe UI", "13");
				html = html.replace("<body>", "<body style='background-color: rgb(30, 30, 30); color: white;'>");
				File.saveContent("bin/TestPage.html", html);
			case _:
				Sys.exit(1);
		}
	}
}
