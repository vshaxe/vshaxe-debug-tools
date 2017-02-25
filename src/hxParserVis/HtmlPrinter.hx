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
        var result = new SyntaxTreeBuilder().build(uri, tree, currentPos);
        return buildHtml(
            [getResource("style.css")],
            [getResource("CollapsibleLists.js"), 'var posMap = ${result.posMap};', getResource("script.js")],
            ["<div class='collapseButton overlayElement' title='Collapse All' onclick='collapseAll();'></div>"],
            result.html,
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