package features;

import Vscode.*;
import vscode.*;

class ServerDebuggingFeature {
	public function new(context:ExtensionContext) {
		function runMethod(method:String, ?params:Any) {
			commands.executeCommand("haxe.runMethod", method, params);
			commands.executeCommand("vshaxeDebugTools.methodResultsView.track", method);
		}

		commands.registerCommand("vshaxeDebugTools.runServerSelect", () -> {
			window.showInputBox({
				value: "0",
				prompt: "Index of the context to select",
				validateInput: value -> if (~/^[0-9]+$/.match(value))
					null
				else
					"Not a valid integer."
			}).then(value -> runMethod("server/select", {index: Std.parseInt(value)}));
		});
		commands.registerCommand("vshaxeDebugTools.runServerContexts", () -> runMethod("server/contexts"));
		commands.registerCommand("vshaxeDebugTools.runServerFiles", () -> runMethod("server/files"));
		commands.registerCommand("vshaxeDebugTools.runServerModules", () -> runMethod("server/modules"));
		commands.registerCommand("vshaxeDebugTools.runServerModule", () -> {
			window.showInputBox({
				value: "",
				prompt: "Name of the module"
			}).then(value -> runMethod("server/module", {path: value}));
		});
	}
}
