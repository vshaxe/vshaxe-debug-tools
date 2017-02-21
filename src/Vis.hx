import JsonParser.Tree;
using StringTools;

class Vis {
    inline static function encodeUri(s:String):String return untyped __js__("encodeURI")(s);

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

        var posMap = new haxe.DynamicAccess();
        var nextId = 0;

        inline function addToPosMap(id:Int, t:{start:Int, end:Int}) {
            posMap[Std.string(id)] = {start: t.start, end: t.end};
        }

        function toHtml(tree:Tree, indent:String, inTrivia:Bool) {
            var id = nextId++;
            return switch (tree.kind) {
                case Token(token, trivia):
                    var link = mkLink(tree.start, tree.end);
                    addToPosMap(id, tree);
                    var parts = [indent + '<a id="$id" class="token${addSelectedClass(tree)}${if (inTrivia) " trivia" else ""}" href="${encodeUri(link)}">' + haxe.Json.stringify(token).htmlEscape() + " " + posStr(tree) + "</a><br>"];
                    if (trivia != null) {
                        parts.push(indent + "<ul>");
                        if (trivia.leading != null) {
                            parts.push(indent + '\t<li><span>Leading</span><ul>');
                            for (trivia in trivia.leading) {
                                parts.push(indent + '\t\t<li><span/>\n${toHtml(trivia, indent + "\t\t\t", true)}\n$indent</li>');
                            }
                            parts.push(indent + '\t</ul></li>');
                        }
                     if (trivia.trailing != null) {
                            parts.push(indent + '\t<li><span>Trailing</span><ul>');
                            for (trivia in trivia.trailing) {
                                parts.push(indent + '\t\t<li><span/>\n${toHtml(trivia, indent + "\t\t\t", true)}\n$indent</li>');
                            }
                            parts.push(indent + '\t</ul></li>');
                        }
                        if (trivia.skipped) parts.push(indent + '\t<li>skipped</li>');
                        if (trivia.implicit) parts.push(indent + '\t<li>implicit</li>');
                        if (trivia.inserted) parts.push(indent + '\t<li>inserted</li>');
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
                case Node(name, children):
                    var link = mkLink(tree.start, tree.end);
                    var parts = [indent + '<a class="node" href="${encodeUri(link)}">' + name.htmlEscape() + " " + ${posStr(tree)} +  "</a><br>"];
                    if (children.length > 0) {
                        parts.push(indent + "<ul class='collapsibleList'>");
                        for (child in children)
                            parts.push(indent + '\t<li>\n${toHtml(child, indent + "\t\t", false)}\n$indent</li>');
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
            }
        }

        var body = toHtml(tree, "", false);

        return
            '<html>
                <header>
                    <style>
                        ${getFile("src/style.css")}
                    </style>
                    <script>
                        ${getFile("src/CollapsibleLists.js")}
                        var posMap = ${posMap};
                        ${getFile("src/script.js")}
                    </script>
                </header>
                <body>
                    $body
                </body>
            </html>';
    }

    macro static function getFile(file:String):haxe.macro.Expr {
        return macro $v{sys.io.File.getContent(file)};
    }
}
