package features.vis.tokenTreeVis;

import Vscode.*;
import vscode.*;

import features.vis.VisFeatureBase;

class TokenTreeVisFeature extends VisFeatureBase {
    public function new(context:ExtensionContext) {
        super(context);
        initSubscriptions(context, new TokenTreeContentProvider(), "tokentreevis");

        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.visualizeTokenTree", function() {
            return commands.executeCommand('vscode.previewHtml', TokenTreeContentProvider.visUri, ViewColumn.Two, 'Token Tree')
                .then(null, function(error) window.showErrorMessage(error));
        }));
    }
}
