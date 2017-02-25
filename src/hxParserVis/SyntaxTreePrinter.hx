package hxParserVis;

import haxe.DynamicAccess;
import hxParser.ParseTree;
using hxParserVis.Vis;

typedef SyntaxTreePrinterResult = {
    var html:String;
    var posMap:DynamicAccess<Dynamic>;
}

class SyntaxTreePrinter {
    var uri:String;
    var currentPos:Int;

    public function new() {}

    public function print(uri:String, tree:NFile, currentPos:Int):SyntaxTreePrinterResult {
        this.uri = uri;
        this.currentPos = currentPos;
        return {
            html: tree.vis(),
            posMap: {}
        };
    }
}
