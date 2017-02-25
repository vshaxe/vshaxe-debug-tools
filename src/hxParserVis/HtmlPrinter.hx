package hxParserVis;

import hxParser.JsonParser.JResult;
import hxParser.Printer;
import hxParser.Tree;
using StringTools;

@:enum abstract OutputKind(String) to String from String {
    var SyntaxTree = "Syntax Tree";
    var Haxe = "Haxe";
    var Json = "JSON";
}

class HtmlPrinter {
    inline static function encodeUri(s:String):String return untyped __js__("encodeURI")(s);

    static var highlightJs = getResource("highlight.pack.js");
    static var theme = getResource("theme.css");

    #if !macro

    public static function print(uri:String, unparsedData:JResult, tree:Tree, currentPos:Int, output:OutputKind):String {
        return switch (output) {
            case SyntaxTree: printSyntaxTree(uri, tree, currentPos);
            case Haxe: printHaxe(tree);
            case Json: printJson(unparsedData);
        }
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

        function toHtml(tree:Tree, indent:String, prefix:Array<String>, inTrivia:Bool) {
            inline function getName(name:String) {
                return prefix.length == 0 ? name : prefix.join(" ") + " " + name;
            }
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
                case Node(name, [child = {kind: Node(_,_)}]):
                    toHtml(child, indent, prefix.concat([name]), inTrivia);
                case Node(name, children):
                    var link = mkLink(tree.start, tree.end);
                    var parts = [indent + '<a class="node" href="${encodeUri(link)}">' + getName(name).htmlEscape() + " " + ${posStr(tree)} +  "</a><br>"];
                    if (children.length > 0) {
                        parts.push(indent + "<ul class='collapsibleList'>");
                        for (child in children)
                            parts.push(indent + '\t<li>\n${toHtml(child, indent + "\t\t", [], false)}\n$indent</li>');
                        parts.push(indent + "</ul>");
                    }
                    return parts.join("\n");
            }
        }

        return buildHtml(
            [getResource("style.css")],
            [getResource("CollapsibleLists.js"), 'var posMap = ${posMap};', getResource("script.js")],
            ["<div class='collapseButton overlayElement' title='Collapse All' onclick='collapseAll();'></div>"],
            toHtml(tree, "", [], false),
            SyntaxTree
        );
    }

    static function printHaxe(tree:Tree):String {
        var haxeCode = Printer.print(tree, function(s) { return s.htmlEscape(); });
        haxeCode = haxeCode.replace("\t", "    ");
        return buildHtmlWithHighlighting(haxeCode, Haxe);
    }

    static function printJson(unparsedData:JResult):String {
        var json = haxe.Json.stringify(unparsedData, null, "  ");
        return buildHtmlWithHighlighting(json, Json);
    }

    static function buildHtmlWithHighlighting(body:String, outputKind:OutputKind):String {
        var codeBlock = '<pre><code class="$outputKind">$body</code></pre>';
        return buildHtml([theme], [highlightJs, "hljs.initHighlightingOnLoad();"], [], codeBlock, outputKind);
    }

    static function buildHtml(styles:Array<String>, scripts:Array<String>, overlayElements:Array<String>, body:String, outputKind:OutputKind) {
        inline function makeAnchor(outputKind:OutputKind):String {
            var link = 'command:hxparservis.switchOutput?${haxe.Json.stringify([Std.string(outputKind)])}';
            return '<a class="outputSelector overlayElement" href=\'$link\'>$outputKind</a>';
        }

        var links = [];
        inline function maybeAdd(kind:OutputKind) {
            if (outputKind != kind)
                links.push(makeAnchor(kind));
        }
        maybeAdd(Haxe);
        maybeAdd(SyntaxTree);
        maybeAdd(Json);

        return
            '<html>
                <header>
                    <style>
                        ${styles.join("\n")}
                        ${getResource("overlay.css")}
                    </style>
                    <script>
                        ${scripts.join("\n")}
                    </script>
                </header>
                <body>
                    <div class="overlay">
                        ${overlayElements.join("\n")}
                        ${links.join("\n")}
                    </div>
                    $body
                </body>
            </html>';
    }

    #end

    macro static function getResource(file:String):haxe.macro.Expr {
        return macro $v{sys.io.File.getContent("resources/" + file)};
    }
}