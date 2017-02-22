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
    @:optional var trivia:Trivia;
}

typedef Tree = {
    var kind:TreeKind;
    var start:Int;
    var end:Int;
}

enum TreeKind {
    Node(name:String, children:Array<Tree>);
    Token(token:String, trivia:Trivia);
}

typedef Trivia = {
    @:optional var leading:Array<PlacedToken>;
    @:optional var trailing:Array<PlacedToken>;
    @:optional var implicit:Bool; // Omitted as allowed by the grammar (semicolon after }) (good)
    @:optional var inserted:Bool; // Actually missing (bad)
}

typedef PlacedToken = {
    var token:String;
    var start:Int;
    var end:Int;
}

class JsonParser {
    public static function parse(input:JNodeBase):Tree {

        function loop(t:JNodeBase):Tree {
            if (t.name == "token") {
                var tok:JToken = cast t;
                return {
                    kind: Token(tok.token, tok.trivia),
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

        return loop(input);
    }
}