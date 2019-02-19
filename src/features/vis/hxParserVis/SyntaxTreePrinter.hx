package features.vis.hxParserVis;

import features.vis.TreePrinterBase;
import hxParser.ParseTree.File;

class SyntaxTreePrinter extends TreePrinterBase<File> {
	public function new() {
		super("parseTree");
	}

	override function makeHtml(t:File):String {
		return new features.vis.hxParserVis.Vis(this).visFile(t);
	}
}
