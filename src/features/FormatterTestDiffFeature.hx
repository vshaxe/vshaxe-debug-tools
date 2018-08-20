package features;

import Vscode.*;
import vscode.*;
import haxe.io.Path;
import js.Promise;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class FormatterTestDiffFeature {
	static inline var ResultFile = "test/formatter-result.txt";
	static inline var SingleRunFile = "test/single-run.txt";

	var leftUri = Uri.parse("v://v/l.hx");
	var rightUri = Uri.parse("v://v/r.hx");
	var leftContent:String;
	var rightContent:String;
	var _onDidChange = new EventEmitter<Uri>();

	public var onDidChange(default, null):Event<Uri>;

	public function new(context:ExtensionContext) {
		onDidChange = _onDidChange.event;

		workspace.registerTextDocumentContentProvider("v", this);

		var watcher = workspace.createFileSystemWatcher("**/formatter-result.txt", true, false, true);
		watcher.onDidChange(function(uri) loadResults());
		commands.registerCommand("vshaxeDebugTools.diffFormatterTests", diffFormatterTests);
		commands.registerCommand("vshaxeDebugTools.runFormatterTests", runFormatterTests.bind(null));
		commands.registerCommand("vshaxeDebugTools.runCurrentFormatterTest", runCurrentFormatterTest);
	}

	function diffFormatterTests() {
		loadResults();
		commands.executeCommand("vscode.diff", leftUri, rightUri);
	}

	function runFormatterTests(?onComplete:() -> Void) {
		tasks.fetchTasks({type: "hxml"}).then(fetchedTasks -> {
			for (task in fetchedTasks) {
				if (task.name == "buildTest.hxml") {
					tasks.executeTask(task);
					break;
				}
			}
		});
		var disposable = null;
		disposable = tasks.onDidEndTask(event -> {
			if (leftContent != "" || rightContent != "") {
				diffFormatterTests();
			}
			if (onComplete != null) {
				onComplete();
			}
			disposable.dispose();
		});
	}

	function runCurrentFormatterTest() {
		var editor = window.activeTextEditor;
		if (editor == null) {
			window.showErrorMessage("There is no active text editor.");
			return;
		}
		var path = editor.document.uri.fsPath;
		if (!path.endsWith(".hxtest")) {
			window.showErrorMessage("Active editor is not a .hxtest file.");
			return;
		}

		var singleRunFile = getAbsolutePath(SingleRunFile);
		File.saveContent(singleRunFile, path);
		runFormatterTests(() -> {
			FileSystem.deleteFile(singleRunFile);
		});
	}

	function loadResults() {
		var path = getAbsolutePath(ResultFile);
		if (!FileSystem.exists(path))
			return;

		var testResults = File.getContent(path).replace("\r", "").split("\n---\n");
		leftContent = testResults[0].trim();
		rightContent = testResults[1].trim();
		_onDidChange.fire(leftUri);
		_onDidChange.fire(rightUri);
	}

	public function provideTextDocumentContent(uri:Uri, _):ProviderResult<String> {
		return new Promise(function(resolve, reject) {
			if (uri.toString() == leftUri.toString())
				resolve(leftContent);
			else if (uri.toString() == rightUri.toString())
				resolve(rightContent);
			reject("invalid Uri " + uri.toString());
		});
	}

	function getAbsolutePath(relativePath:String) {
		return Path.join([workspace.workspaceFolders[0].uri.fsPath, relativePath]);
	}
}
