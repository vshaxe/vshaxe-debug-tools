package features;

import Vscode.*;
import vscode.*;

class HaxeMethodResultsViewFeature {
	static final uri = Uri.parse("haxe://methods/Haxe Methods.json");

	var trackedMethod:String;
	var mostRecentMethod:String;
	var results = new Map<String, Response>();
	var document:TextDocument;

	public var onDidChange(default, null):Event<Uri>;

	var _onDidChange:EventEmitter<Uri>;

	public function new(context:ExtensionContext) {
		_onDidChange = new EventEmitter();
		onDidChange = _onDidChange.event;

		workspace.registerTextDocumentContentProvider("haxe", this);

		commands.registerCommand("vshaxeDebugTools.methodResultsView.update", function(results:{method:String, response:Response}) {
			mostRecentMethod = results.method;
			Reflect.deleteField(results.response, "timers");
			Reflect.deleteField(results.response, "timestamp");
			this.results[results.method] = results.response;
			update();
		});

		commands.registerCommand("vshaxeDebugTools.methodResultsView.open", function() {
			open();
			update();
		});

		commands.registerCommand("vshaxeDebugTools.methodResultsView.track", function(method:String) {
			this.trackedMethod = method;
			open();
			update();
		});
	}

	function open() {
		window.showTextDocument(uri, {viewColumn: Two, preserveFocus: true});
	}

	function update() {
		_onDidChange.fire(uri);
	}

	public function provideTextDocumentContent(uri:Uri, token:CancellationToken):ProviderResult<String> {
		var method = if (trackedMethod == null) mostRecentMethod else trackedMethod;
		var data = results[method];
		if (data == null) {
			return "null";
		}
		var json = haxe.Json.stringify(data, null, "    ");
		// hack to make sure "method" is at the top... :/
		json = ~/^{/.replace(json, '{\n    "method": "$method",');
		return json;
	}
}

typedef Response = {
	final result:Dynamic;
}
