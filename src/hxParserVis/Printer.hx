package hxParserVis;

import hxParser.ParseTree;

class Printer {
    public static function print(file:NFile, ?printToken:String->String):String {
        var buf = new StringBuf();

        inline function add(token:String) buf.add(if (printToken == null) token else printToken(token));

        TokenWalker.walk_NFile(file, function(token) {
            if (token.leadingTrivia != null) for (trivia in token.leadingTrivia) add(trivia.text);
            add(token.text);
            if (token.trailingTrivia != null) for (trivia in token.trailingTrivia) add(trivia.text);
        });

        return buf.toString();
    }
}
