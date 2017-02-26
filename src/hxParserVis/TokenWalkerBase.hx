package hxParserVis;

import hxParser.ParseTree;

class TokenWalkerBase {
    public static function walkArray<T>(c:Array<T>, walk:T->Void) {
        for (el in c) walk(el);
    }

    public static function walkCommaSeparated<T>(c:NCommaSeparated<T>, walk:T->Void, callback:Token->Void) {
        walk(c.arg);
        for (el in c.args) {
            callback(el.comma);
            walk(el.arg);
        }
    }

    public static function walkCommaSeparatedTrailing<T>(c:NCommaSeparatedAllowTrailing<T>, walk:T->Void, callback:Token->Void) {
        walk(c.arg);
        for (el in c.args) {
            callback(el.comma);
            walk(el.arg);
        }
        if (c.comma != null)
            callback(c.comma);
    }
}
