typedef JNodeBase = {
    var name:String;
}

typedef JNode = {
    >JNodeBase,
    @:optional var sub:Array<JNodeBase>;
}

typedef JToken = {
    >JNodeBase,
    var token:String;
    var start:Int;
    var end:Int;
    @:optional var trivia:Trivia<JNode>;
}

typedef Tree = {
    var kind:TreeKind;
    var start:Int;
    var end:Int;
}

enum TreeKind {
    Node(name:String, children:Array<Tree>);
    Token(token:String, trivia:Trivia<Tree>);
}

typedef Trivia<T> = {
    @:optional var leading:Array<T>;
    @:optional var trailing:Array<T>;
    @:optional var implicit:Bool; // Omitted as allowed by the grammar (semicolon after }) (good)
    @:optional var inserted:Bool; // Actually missing (bad)
    @:optional var skipped:Bool;  // Skipped as allowed by the grammar (semicolon before else) (good)
}

class JsonParser {
    public static function parse(input:String):Tree {

        function loop(t:JNodeBase):Tree {
            if (t.name == "token") {
                var tok:JToken = cast t;
                var trivia:Trivia<Tree> = {};
                if (tok.trivia != null) {
                    if (tok.trivia.leading != null) trivia.leading = tok.trivia.leading.map(loop);
                    if (tok.trivia.trailing != null) trivia.trailing = tok.trivia.trailing.map(loop);
                    trivia.implicit = tok.trivia.implicit;
                    trivia.skipped = tok.trivia.skipped;
                    trivia.inserted = tok.trivia.inserted;
                }
                return {
                    kind: Token(tok.token, trivia),
                    start: tok.start,
                    end: tok.end,
                };
            } else {
                var tok:JNode = cast t;
                var start = -1, end = -1;
                var children = [];
                if (tok.sub != null) {
                    for (elem in tok.sub) {
                        var t = loop(elem);
                        children.push(t);
                        if (start == -1 || t.start < start)
                            start = t.start;
                        if (end == -1 || t.end > end)
                            end = t.end;
                    }
                }
                return {
                    kind: Node(tok.name, children),
                    start: start,
                    end: end,
                };
            }
        }

        return loop(haxe.Json.parse(input));
    }
}