package features.vis;

import features.vis.TreePrinterBase.TreePrinterResult;

using StringTools;

class HtmlPrinterBase<T> {
	static var highlightJs = getResource("highlight.pack.js");
	static var collapsibleListsJs = getResource("CollapsibleLists.js");
	static var scriptJs = getResource("script.js");
	static var themeCss = getResource("theme.css");
	static var styleCss = getResource("style.css");

	#if !macro
	public function new() {}

	function printSyntaxTree(uri:String, tree:T, currentPos:Int, fontFamily:String, fontSize:String, links:Array<String>):String {
		var result:TreePrinterResult = printTree(uri, tree, currentPos);
		return buildHtml([
			'body {
                    font-family: $fontFamily;
                    font-size: $fontSize;
                }',
			styleCss
		], [collapsibleListsJs, 'var posMap = ${result.posMap};', scriptJs], [
				"<div class='collapseAllButton overlayElement' title='Collapse All' onclick='collapseAll();'></div>"
			], result.html, links);
	}

	function printTree(uri:String, tree:T, currentPos:Int):TreePrinterResult {
		return {
			html: "",
			posMap: {}
		};
	}

	function buildHtml(styles:Array<String>, scripts:Array<String>, overlayElements:Array<String>, body:String, links:Array<String>) {
		return '<html>
                <header>
                    <style>
                        ${styles.join("\n")}
                        ${getResource("overlay.css")}
                    </style>
                    <script>
                        ${scripts.join("\n")}
                    </script>
                </header>
                <body>
                    <div class="overlay">
                        ${overlayElements.join("\n")}
                        ${links.join("\n")}
                    </div>
                    $body
                </body>
            </html>';
	}
	#end

	macro static function getResource(file:String):haxe.macro.Expr {
		return macro $v{sys.io.File.getContent("resources/" + file)};
	}
}
