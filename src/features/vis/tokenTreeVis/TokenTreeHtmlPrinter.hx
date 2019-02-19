package features.vis.tokenTreeVis;

#if !macro
import tokentree.TokenTree;
import features.vis.TreePrinterBase.TreePrinterResult;
import features.vis.HtmlPrinterBase;

class TokenTreeHtmlPrinter extends HtmlPrinterBase<TokenTree> {
	public function print(uri:String, tree:TokenTree, currentPos:Int, fontFamily:String, fontSize:String):String {
		return printSyntaxTree(uri, tree, currentPos, fontFamily, fontSize, []);
	}

	override function printTree(uri:String, tree:TokenTree, currentPos:Int):TreePrinterResult {
		return new TokenTreeVis().print(uri, tree, currentPos);
	}
}
#end