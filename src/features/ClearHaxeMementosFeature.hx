package features;

import Vscode.*;
import vscode.*;

class ClearHaxeMementosFeature {
    public function new(context:ExtensionContext) {
        context.subscriptions.push(commands.registerCommand("vshaxeDebugTools.clearHaxeMementos", function() {
            commands.executeCommand("haxe.clearMementos");
        }));
    }
}