package hxParserVis;

import hxParser.ParseTree;

class Printer extends hxParser.Walker {
    var add:String->Void;
    var buf:StringBuf;

    function new(printToken) {
        this.add = if (printToken == null) function(s) buf.add(s) else function(s) buf.add(printToken(s));
    }

    inline function process(file) {
        buf = new StringBuf();
        walkNFile(file);
        return buf.toString();
    }

    override function walkToken(token:Token) {
        if (token.leadingTrivia != null) for (trivia in token.leadingTrivia) add(trivia.text);
        add(token.text);
        if (token.trailingTrivia != null) for (trivia in token.trailingTrivia) add(trivia.text);
    }

    public static inline function print(file:NFile, ?printToken:String->String):String {
        return new Printer(printToken).process(file);
    }
}
