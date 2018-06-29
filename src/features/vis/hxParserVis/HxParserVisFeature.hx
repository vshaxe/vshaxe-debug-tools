package features.vis.hxParserVis;

import Vscode.*;
import vscode.*;

import features.vis.VisFeatureBase;

class HxParserVisFeature extends VisFeatureBase {
    public function new(context:ExtensionContext) {
        super(context);
        var provider = new HxParserContentProvider();
        initSubscriptions(context, provider, "hxparservis");

        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.visualizeParseTree", function() {
            return commands.executeCommand('vscode.previewHtml', HxParserContentProvider.visUri, ViewColumn.Two, 'Parse Tree')
                .then(null, function(error) window.showErrorMessage(error));
        }));

        context.subscriptions.push(commands.registerCommand("hxparservis.switchOutput", function(outputKind:String) {
            provider.switchOutputKind(outputKind);
        }));
    }
}
