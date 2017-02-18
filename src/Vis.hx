using StringTools;

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
    @:optional var trivia:Array<JTrivia>;
}

typedef JTrivia = {
    >JNodeBase,
    var token:String;
    var start:Int;
    var end:Int;
}

typedef Tree = {
    var kind:TreeKind;
    var start:Int;
    var end:Int;
}

enum TreeKind {
    Node(name:String, children:Array<Tree>);
    Token(token:String, trivia:Array<Trivia>);
}

typedef Trivia = {
    var text:String;
    var start:Int;
    var end:Int;
}

class Vis {
    inline static function encodeUri(s:String):String return untyped __js__("encodeURI")(s);

    public static function vis(uri:String, input:String):String {
        function convertTrivia(t:JTrivia):Trivia return {text: t.token, start: t.start, end: t.end};

        function loop(t:JNodeBase):Tree {
            if (t.name == "token") {
                var tok:JToken = cast t;
                var trivia = if (tok.trivia == null) [] else tok.trivia.map(convertTrivia);
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

        var tree = loop(haxe.Json.parse(input)[0]);

        function posStr(t:{start:Int, end:Int}):String {
            return '[${t.start}..${t.end})';
        }

        function mkLink(start:Int, end:Int) {
            return 'command:hxparservis.reveal?${haxe.Json.stringify([uri, start, end])}';
        }

        function toHtml(tree:Tree, indent:String) {
            return switch (tree.kind) {
                case Token(token, trivia):
                    var link = mkLink(tree.start, tree.end);
                    var parts = [indent + '<a class="token" href="${encodeUri(link)}">' + token.htmlEscape() + " " + posStr(tree) + "</a><br>"];
                    trace(parts.join(""));
                    if (trivia.length > 0) {
                        parts.push(indent + "<ul>");
                        for (trivia in trivia) {
                            var link = mkLink(trivia.start, trivia.end);
                            parts.push(indent + '\t<li>\n<a href="${encodeUri(link)}"><pre class="trivia">${haxe.Json.stringify(trivia.text).htmlEscape()} ${posStr(trivia)}</pre></a>\n$indent</li>');
                        }
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
                case Node(name, children):
                    var link = mkLink(tree.start, tree.end);
                    var parts = [indent + '<a class="node" href="${encodeUri(link)}">' + name.htmlEscape() + " " + ${posStr(tree)} +  "</a><br>"];
                    if (children.length > 0) {
                        parts.push(indent + "<ul>");
                        for (child in children)
                            parts.push(indent + '\t<li>\n${toHtml(child, indent + "\t\t")}\n$indent</li>');
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
            }
        }

        var html = toHtml(tree, "");

        var style = "<style>
        a {
            text-decoration: none;
        }
        .node {
            color: green;
        }
        .token {
            color: dodgerblue;
        }
        .trivia {
            color: crimson;
        }
        ul {
            padding-left: 1.5em;
        }
        pre {
            margin: 0;
        }
        </style>";

        html = style + html;

        return html;
    }
}
