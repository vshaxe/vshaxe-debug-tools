package features;

import Vscode.*;
import vscode.*;
import sys.io.File;
import haxe.io.Path;

class ExpectedActualJsonFeature {
	public function new(context:ExtensionContext) {
		commands.registerCommand("vshaxeDebugTools.updateExpectedJson", function(uri:Uri) {
			var directory = Path.directory(uri.fsPath);
			File.saveContent(directory + "/Expected.json", File.getContent(directory + "/Actual.json"));
		});

		commands.registerCommand("vshaxeDebugTools.diffExpectedActualJson", function(uri:Uri) {
			var directory = Path.directory(uri.fsPath);
			var leftUri = Uri.file(directory + "/Expected.json");
			var rightUri = Uri.file(directory + "/Actual.json");
			commands.executeCommand("vscode.diff", leftUri, rightUri);
		});
	}
}
