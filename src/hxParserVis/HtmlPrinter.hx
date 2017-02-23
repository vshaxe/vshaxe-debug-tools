package hxParserVis;

import hxParser.Printer;
import hxParser.Tree;
using StringTools;

enum OutputKind {
    Haxe;    
    SyntaxTree;
}

class HtmlPrinter {
    inline static function encodeUri(s:String):String return untyped __js__("encodeURI")(s);

    #if !macro

    public static function print(uri:String, tree:Tree, currentPos:Int, output:OutputKind):String {
        return switch (output) {
            case Haxe: printHaxe(tree);
            case SyntaxTree: printSyntaxTree(uri, tree, currentPos);
        }
    }

    static function printHaxe(tree:Tree):String {
        return '<pre>${Printer.print(tree, function(s) { return s.htmlEscape(); })}</pre>';
    }

    static function printSyntaxTree(uri:String, tree:Tree, currentPos:Int):String {
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
            return switch (tree.kind) {
                case Token(token, trivia):
                    var parts = [];
                    inline function add(token:String, pos:{start:Int, end:Int}, inTrivia:Bool) {
                        var id = nextId++;
                        addToPosMap(id, pos);
                        var link = mkLink(pos.start, pos.end);
                        parts.push(indent + '<a id="$id" class="token${addSelectedClass(pos)}${if (inTrivia) " trivia" else ""}" href="${encodeUri(link)}">' +
                            haxe.Json.stringify(token).htmlEscape() + " " + posStr(pos) + "</a><br>");
                    }
                    add(token, tree, false);
                    if (trivia != null) {
                        parts.push(indent + "<ul>");
                        if (trivia.leading != null) {
                            parts.push(indent + '\t<li><span>Leading</span><ul>');
                            for (trivia in trivia.leading) {
                                add(trivia.token, trivia, true);
                            }
                            parts.push(indent + '\t</ul></li>');
                        }
                        if (trivia.trailing != null) {
                            parts.push(indent + '\t<li><span>Trailing</span><ul>');
                            for (trivia in trivia.trailing) {
                                add(trivia.token, trivia, true);
                            }
                            parts.push(indent + '\t</ul></li>');
                        }
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

        return
            '<html>
                <header>
                    <style>
                        ${getResource("style.css")}
                    </style>
                    <script>
                        ${getResource("CollapsibleLists.js")}
                        var posMap = ${posMap};
                        ${getResource("script.js")}
                    </script>
                </header>
                <body>
                    ${toHtml(tree, "", false)}
                </body>
            </html>';
    }

    #end

    macro static function getResource(file:String):haxe.macro.Expr {
        return macro $v{sys.io.File.getContent("resources/" + file)};
    }
}