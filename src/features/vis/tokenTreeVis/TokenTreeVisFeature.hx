package features.vis.tokenTreeVis;

import vscode.*;
import features.vis.VisFeatureBase;

class TokenTreeVisFeature extends VisFeatureBase<TokenTreeContentProvider> {
	public function new(context:ExtensionContext) {
		super(context, new TokenTreeContentProvider(), "tokenTree", "Token Tree", "vshaxeDebugTools.visualizeTokenTree");
	}
}
