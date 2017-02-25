package hxParserVis;

import hxParser.ParseTree;
using StringTools;

class VisBase {
    public static var none = '<span class="none">${"<none>".htmlEscape()}</span>';

    public static inline function encodeUri(s:String):String {
        return untyped __js__("encodeURI")(s);
    }

    public static function visToken(ctx:SyntaxTreePrinter, t:Token):String {
        inline function renderTrivia(t:Trivia, prefix:String) {
            var s = t.toString().htmlEscape();
            var link = ctx.makeLink(t.start, t.end);
            return '<li><a href="${encodeUri(link)}" class="trivia">$prefix: $s</a></li>';
        }
        var s = t.toString().htmlEscape();
        var link = ctx.makeLink(t.start, t.end);
        var parts = ['<a href="${encodeUri(link)}" class="token">$s</a>'];
        if (t.inserted) parts.push('<span class="missing">(missing)</span>');
        if (t.implicit) parts.push('<span class="implicit">(implicit)</span>');
        var trivias = [];
        if (t.leadingTrivia != null) {
            for (t in t.leadingTrivia)
                trivias.push(renderTrivia(t, "LEAD"));
        }
        if (t.trailingTrivia != null) {
            for (t in t.trailingTrivia)
                trivias.push(renderTrivia(t, "TAIL"));
        }
        if (trivias.length > 0)
            parts.push('<ul class="trivia">' + trivias.join("") + "</ul>");
        return parts.join(" ");
    }

    public static function visArray<T>(ctx:SyntaxTreePrinter, c:Array<T>, vis:T->String):String {
        var parts = [for (el in c) "<li>" + vis(el) + "</li>"];
        return if (parts.length == 0) none else "<ul>" + parts.join("") + "</ul>";
    }

    public static function visCommaSeparated<T>(ctx:SyntaxTreePrinter, c:NCommaSeparated<T>, vis:T->String):String {
        var parts = [vis(c.arg)];
        for (el in c.args) {
            parts.push(visToken(ctx, el.comma));
            parts.push(vis(el.arg));
        }
        return "<ul>" + [for (s in parts) '<li>$s</li>'].join("") + "</ul>";
    }

    public static function visCommaSeparatedTrailing<T>(ctx:SyntaxTreePrinter, c:NCommaSeparatedAllowTrailing<T>, vis:T->String):String {
        var parts = [vis(c.arg)];
        for (el in c.args) {
            parts.push(visToken(ctx, el.comma));
            parts.push(vis(el.arg));
        }
        if (c.comma != null)
            parts.push(visToken(ctx, c.comma));
        return "<ul>" + [for (s in parts) '<li>$s</li>'].join("") + "</ul>";
    }
}
