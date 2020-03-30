package features.vis;

import haxe.DynamicAccess;

typedef TreePositionInfo = {
	var start:Int;
	var end:Int;
}

typedef TreePrinterResult = {
	var html:String;
	var posMap:DynamicAccess<TreePositionInfo>;
}

class TreePrinterBase<T> {
	var uri:String;
	var currentPos:Int;
	var nextId:Int;
	var posMap:DynamicAccess<TreePositionInfo>;
	var commandNameBase:String;

	public function new(commandNameBase:String) {
		this.commandNameBase = commandNameBase;
	}

	public inline function registerPos(start:Int, end:Int) {
		var id = nextId++;
		posMap[Std.string(id)] = {start: start, end: end};
		return id;
	}

	public inline function isUnderCursor(start:Int, end:Int) {
		return currentPos >= start && currentPos < end;
	}

	public inline function makeLink(start:Int, end:Int) {
		return 'command:$commandNameBase.reveal?${StringTools.urlEncode(haxe.Json.stringify([uri, start, end]))}';
	}

	public function print(uri:String, tree:T, currentPos:Int):TreePrinterResult {
		this.uri = uri;
		this.currentPos = currentPos;
		nextId = 0;
		posMap = new DynamicAccess();
		return {
			html: makeHtml(tree),
			posMap: posMap
		};
	}

	function makeHtml(tree:T):String {
		return "";
	}
}
