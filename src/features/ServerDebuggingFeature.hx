package features;

import Vscode.*;
import vscode.*;

class ServerDebuggingFeature {
    public function new(context:ExtensionContext) {
        function runMethod(method:String) {
            commands.executeCommand("haxe.runMethod", method);
            commands.executeCommand("vshaxeDebugTools.methodResultsView.track", method);
        }

        commands.registerCommand("vshaxeDebugTools.runServerContexts", runMethod.bind("server/contexts"));
        commands.registerCommand("vshaxeDebugTools.runServerFiles", runMethod.bind("server/files"));
        commands.registerCommand("vshaxeDebugTools.runServerModules", runMethod.bind("server/modules"));
    }
}