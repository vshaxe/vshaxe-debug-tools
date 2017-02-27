package hxParserVis;

import haxe.DynamicAccess;
import hxParser.ParseTree;

typedef SyntaxTreePrinterResult = {
    var html:String;
    var posMap:DynamicAccess<Dynamic>;
}

class SyntaxTreePrinter {
    var uri:String;
    var currentPos:Int;
    var nextId:Int;
    var posMap:DynamicAccess<{start:Int, end:Int}>;

    public function new() {}

    public inline function registerPos(start:Int, end:Int) {
        var id = nextId++;
        posMap[Std.string(id)] = {start: start, end: end};
        return id;
    }

    public inline function isUnderCursor(start:Int, end:Int) {
        return currentPos >= start && currentPos < end;
    }

    public inline function makeLink(start:Int, end:Int) {
        return 'command:hxparservis.reveal?${StringTools.urlEncode(haxe.Json.stringify([uri, start, end]))}';
    }

    public function print(uri:String, tree:NFile, currentPos:Int):SyntaxTreePrinterResult {
        this.uri = uri;
        this.currentPos = currentPos;
        nextId = 0;
        posMap = new DynamicAccess();
        return {
            html: hxParserVis.Vis.visNFile(this, tree),
            posMap: posMap
        };
    }
}
