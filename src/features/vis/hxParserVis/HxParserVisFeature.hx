package features.vis.hxParserVis;

import Vscode.*;
import vscode.*;
import features.vis.VisFeatureBase;
import features.vis.hxParserVis.HxParserContentProvider;

class HxParserVisFeature extends VisFeatureBase<HxParserContentProvider> {
	public function new(context:ExtensionContext) {
		super(context, new HxParserContentProvider(), "parseTree", "Parse Tree", "vshaxeDebugTools.visualizeParseTree");

		context.subscriptions.push(commands.registerCommand("hxparservis.switchOutput", function(outputKind:String) {
			provider.switchOutputKind(outputKind);
			update();
		}));
	}
}
