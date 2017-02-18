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

    public static function parseJson(input:String):Tree {
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

        return loop(haxe.Json.parse(input));
    }

    public static function vis(uri:String, tree:Tree, currentPos:Int):String {
        inline function posStr(t:{start:Int, end:Int}):String {
            return '[${t.start}..${t.end})';
        }

        inline function isUnderCursor(t:{start:Int, end:Int}) {
            return currentPos >= t.start && currentPos < t.end;
        }

        inline function mkLink(start:Int, end:Int) {
            return 'command:hxparservis.reveal?${haxe.Json.stringify([uri, start, end])}';
        }

        inline function addSelectedClass(t:{start:Int, end:Int})
            return if (isUnderCursor(t)) " selected" else "";

        function toHtml(tree:Tree, indent:String) {
            return switch (tree.kind) {
                case Token(token, trivia):
                    var link = mkLink(tree.start, tree.end);
                    var parts = [indent + '<a class="token${addSelectedClass(tree)}" href="${encodeUri(link)}">' + token.htmlEscape() + " " + posStr(tree) + "</a><br>"];
                    if (trivia.length > 0) {
                        parts.push(indent + "<ul>");
                        for (trivia in trivia) {
                            var link = mkLink(trivia.start, trivia.end);
                            parts.push(indent + '\t<li>\n<a href="${encodeUri(link)}"><pre class="trivia${addSelectedClass(trivia)}">${haxe.Json.stringify(trivia.text).htmlEscape()} ${posStr(trivia)}</pre></a>\n$indent</li>');
                        }
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
                case Node(name, children):
                    var link = mkLink(tree.start, tree.end);
                    var parts = [indent + '<a class="node" href="${encodeUri(link)}">' + name.htmlEscape() + " " + ${posStr(tree)} +  "</a><br>"];
                    if (children.length > 0) {
                        parts.push(indent + "<ul class='collapsibleList'>");
                        for (child in children)
                            parts.push(indent + '\t<li><span class="button"><span/>\n${toHtml(child, indent + "\t\t")}\n$indent</li>');
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
            }
        }

        return
            '<html>
                <header>
                    <style>
                        ${getFile("src/style.css")}
                    </style>
                    <script>
                        ${getFile("src/CollapsibleLists.js")}
                        window.addEventListener("message", function(e) {
                            const pos = e.data.pos;
                            console.log(pos);
                        })
                    </script>
                </header>
                <body>
                    ${toHtml(tree, "")}
                </body>
            </html>';
    }

    macro static function getFile(file:String):haxe.macro.Expr {
        return macro $v{sys.io.File.getContent(file)};
    }
}
