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

    public function new() {}

    public inline function getNextId() return nextId++;

    public inline function makeLink(start:Int, end:Int) {
        return 'command:hxparservis.reveal?${haxe.Json.stringify([uri, start, end])}';
    }

    public function print(uri:String, tree:NFile, currentPos:Int):SyntaxTreePrinterResult {
        this.uri = uri;
        this.currentPos = currentPos;
        nextId = 0;
        return {
            html: hxParserVis.Vis.Vis_NFile.vis(this, tree),
            posMap: {}
        };
    }
}
