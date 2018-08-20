package features.vis.hxParserVis;

import hxParser.ParseTree.File;
import hxParser.Printer;
import features.vis.HtmlPrinterBase;
import features.vis.TreePrinterBase.TreePrinterResult;

using StringTools;

class HxParserHtmlPrinter extends HtmlPrinterBase<HxParserContentData> {
	public function print(uri:String, content:HxParserContentData, currentPos:Int, output:OutputKind, fontFamily:String, fontSize:String):String {
		return switch (output) {
			case SyntaxTree: printSyntaxTree(uri, content, currentPos, fontFamily, fontSize, makeLinks(output, true));
			case Haxe: printHaxe(content.parsedTree);
			case Json: printJson(content.unparsedData, true);
		}
	}

	override function printTree(uri:String, content:HxParserContentData, currentPos:Int):TreePrinterResult {
		return new SyntaxTreePrinter().print(uri, content.parsedTree, currentPos);
	}

	function makeLinks(outputKind:OutputKind, addButtons:Bool):Array<String> {
		if (!addButtons) {
			return [];
		}

		inline function makeAnchor(outputKind:OutputKind):String {
			var link = 'command:hxparservis.switchOutput?${haxe.Json.stringify([Std.string(outputKind)])}';
			return '<a class="outputSelector overlayElement" href=\'$link\'>$outputKind</a>';
		}

		var links = [];
		inline function maybeAdd(kind:OutputKind) {
			if (outputKind != kind)
				links.push(makeAnchor(kind));
		}
		maybeAdd(Haxe);
		maybeAdd(SyntaxTree);
		maybeAdd(Json);
		return links;
	}

	function printHaxe(tree:File):String {
		var haxeCode = Printer.print(tree, function(s) return s.htmlEscape());
		return buildHtmlWithHighlighting(haxeCode, Haxe, true);
	}

	function printJson(data:Any, addButtons:Bool):String {
		var json = haxe.Json.stringify(data, null, "  ");
		return buildHtmlWithHighlighting(json, Json, addButtons);
	}

	function buildHtmlWithHighlighting(body:String, outputKind:OutputKind, addButtons:Bool):String {
		var codeBlock = '<pre><code class="$outputKind">$body</code></pre>';
		return buildHtml([HtmlPrinterBase.themeCss], [HtmlPrinterBase.highlightJs, "hljs.initHighlightingOnLoad();"], [], codeBlock, makeLinks(outputKind,
			addButtons));
	}
}
