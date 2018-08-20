package features.vis.hxParserVis;

@:enum abstract OutputKind(String) to String from String {
	var SyntaxTree = "Syntax Tree";
	var Haxe = "Haxe";
	var Json = "JSON";
}
