package features.vis.tokenTreeVis;

import features.vis.TreePrinterBase;

import tokentree.TokenTree;

using StringTools;

class TokenTreeVis extends TreePrinterBase<TokenTree> {
    public function new() {
        super("tokentreevis");
    }

    override function makeHtml(t:TokenTree):String {
        function inline_renderPosition(start:Int, end:Int):String {
            return "[" + start + "-" + end + ")";
        };
        var start = 0;
        var end = 0;
        if (t.pos != null) {
            start = t.pos.min;
            end = t.pos.max;
        }
        var link = makeLink(start, end);
        var id = registerPos(start, end);
        var selected = isUnderCursor(start, end);
        var tokName:String = "";
        if (t.tok == null) {
            tokName = "(root)";
        } else {
            tokName = '${t.tok}';
        }
        var s = tokName.htmlEscape();
        var parts = ['<a id=\"' + id + '\" href=\"' + link + '\" class=\"tokentree' + (if (selected) " selected" else "") + '\">' + s +
            ' <span class="tokenPos">' + renderPosition(start, end) + "</span></a>"];
        if (t.inserted) parts.push('<span class=\"missing\">(missing)</span>');
        if (t.children != null) {
            var childTexts:Array<String> = [];
            for (child in t.children) {
                childTexts.push("<li>" + makeHtml(child) + "</li>");
            }
            parts.push("<ul>" + childTexts.join("") + "</ul>");
        }
        return parts.join(" ");
    }
}
