import JsonParser.JNodeBase;

enum HxParserResult {
    Failure(reason:String);
    Success(data:JNodeBase);
}

class HxParser {
    public static function parse(src:String):HxParserResult {
        return try Success(_parse("<stdin>", src)) catch (e:Any) Failure(Std.string(e));
    }

    static var _parse:String->String->JNodeBase = js.Lib.require("./hxparserjs.js").parse;
}
