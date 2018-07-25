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
    }
}
