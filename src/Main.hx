package;

import features.CursorOffsetFeature;
import features.FormatterTestDiffFeature;
import features.HxTestSeparatorFeature;
import features.ClearHaxeMementosFeature;
import features.HaxeMethodResultsViewFeature;
import features.ServerDebuggingFeature;
import features.vis.hxParserVis.HxParserVisFeature;
import features.vis.tokenTreeVis.TokenTreeVisFeature;
import vscode.*;

class Main {
    @:keep
    @:expose("activate")
    static function activate(context:ExtensionContext) {
        Vscode.commands.executeCommand("setContext", "vshaxeDebugToolsActivated", true);

        new HxParserVisFeature(context);
        new CursorOffsetFeature(context);
        new HxTestSeparatorFeature(context);
        new FormatterTestDiffFeature(context);
        new ClearHaxeMementosFeature(context);
        new HaxeMethodResultsViewFeature(context);
        new ServerDebuggingFeature(context);
        new TokenTreeVisFeature(context);
    }
}
