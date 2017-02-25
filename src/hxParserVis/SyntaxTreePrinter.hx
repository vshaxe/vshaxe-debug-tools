package hxParserVis;

import haxe.DynamicAccess;
import hxParser.Tree;
import hxParser.JResult;
using StringTools;

typedef SyntaxTreePrinterResult = {
    var html:String;
    var posMap:DynamicAccess<Dynamic>;
}

class SyntaxTreePrinter {
    var uri:String;
    var currentPos:Int;

    var posMap:DynamicAccess<Dynamic>;
    var nextId:Int;

    public function new() {}

    public function print(uri:String, tree:Tree, currentPos:Int):SyntaxTreePrinterResult {
        this.uri = uri;
        this.currentPos = currentPos;

        posMap = new DynamicAccess();
        nextId = 0;
        return {
            html: printHtml(tree, "", [], false),
            posMap: posMap
        }
    }

    function printHtml(tree:Tree, indent:String, prefix:Array<String>, inTrivia:Bool) {
        return switch (tree.kind) {
            case Token(token, trivia):
                printToken(tree, token, trivia, indent);
            case Node(name, [child = {kind: Node(_,_)}]):
                printHtml(child, indent, prefix.concat([name]), inTrivia);
            case Node(name, children):
                printNode(tree, name, children, prefix, indent);
        }
    }

    function printToken(tree:Tree, token:String, trivia:JTrivia, indent:String) {
        var parts = [];
        inline function add(token:String, pos:{start:Int, end:Int}, inTrivia:Bool, collapsible:Bool) {
            var id = nextId++;
            addToPosMap(id, pos);
            var link = mkLink(pos.start, pos.end);
            var classes = ['token${addSelectedClass(pos)}'];
            if (inTrivia) classes.push("trivia");
            if (collapsible) classes.push("collapseButton");
            parts.push(indent + '<a id="$id" class="${classes.join(" ")}" href="${encodeUri(link)}">' +
                haxe.Json.stringify(token).htmlEscape() + " " + posStr(pos) + "</a><br>");
        }
        var hasTrivia = trivia != null && (trivia.leading != null || trivia.trailing != null);
        add(token, tree, false, hasTrivia);
        if (hasTrivia) {
            parts.push(indent + "<ul class='collapsibleList'>");
            if (trivia.leading != null) {
                parts.push(indent + '\t<li><span class="collapseButton">Leading</span><ul class="collapsibleList">');
                for (trivia in trivia.leading) {
                    add(trivia.token, trivia, true, true);
                }
                parts.push(indent + '\t</ul></li>');
            }
            if (trivia.trailing != null) {
                parts.push(indent + '\t<li><span class="collapseButton">Trailing</span><ul class="collapsibleList">');
                for (trivia in trivia.trailing) {
                    add(trivia.token, trivia, true, true);
                }
                parts.push(indent + '\t</ul></li>');
            }
            if (trivia.implicit) parts.push(indent + '\t<li>implicit</li>');
            if (trivia.inserted) parts.push(indent + '\t<li>inserted</li>');
            parts.push(indent + "</ul>");
        }
        return parts.join("\n");
    }

    function printNode(tree:Tree, name:String, children:Array<Tree>, prefix:Array<String>, indent:String) {
        inline function getName(name:String) {
            return prefix.length == 0 ? name : prefix.join(" ") + " " + name;
        }
        var link = mkLink(tree.start, tree.end);
        var parts = [indent + '<a class="node collapseButton" href="${encodeUri(link)}">' + getName(name).htmlEscape() + " " + ${posStr(tree)} +  "</a><br>"];
        if (children.length > 0) {
            parts.push(indent + "<ul class='collapsibleList'>");
            for (child in children)
                parts.push(indent + '\t<li>\n${printHtml(child, indent + "\t\t", [], false)}\n$indent</li>');
            parts.push(indent + "</ul>");
        }
        return parts.join("\n");
    }

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

    inline function addToPosMap(id:Int, t:{start:Int, end:Int}) {
        posMap[Std.string(id)] = {start: t.start, end: t.end};
    }

    inline static function encodeUri(s:String):String {
        return untyped __js__("encodeURI")(s);
    }
}