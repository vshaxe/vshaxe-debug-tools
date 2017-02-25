package hxParserVis;

import hxParser.ParseTree;
using StringTools;

class VisBase {
    public static var none = '<span class="none">${"<none>".htmlEscape()}</span>';

    public static function visToken(t:Token):String {
        inline function renderTrivia(t:Trivia) {
            return t.toString().htmlEscape().replace(" ", "&nbsp;");
        }
        var s = t.toString().htmlEscape();
        var parts = ['<span class="token">$s</span>'];
        if (t.inserted) parts.push('<span class="missing">(missing)</span>');
        if (t.implicit) parts.push('<span class="implicit">(implicit)</span>');
        var trivias = [];
        if (t.leadingTrivia != null) {
            for (t in t.leadingTrivia)
                trivias.push("<li>LEAD: " + renderTrivia(t) + "</li>");
        }
        if (t.trailingTrivia != null) {
            for (t in t.trailingTrivia)
                trivias.push("<li>TAIL: " + renderTrivia(t) + "</li>");
        }
        if (trivias.length > 0)
            parts.push('<ul class="trivia">' + trivias.join("") + "</ul>");
        return parts.join(" ");
    }

    public static function visArray<T>(c:Array<T>, vis:T->String):String {
        var parts = [for (el in c) "<li>" + vis(el) + "</li>"];
        return if (parts.length == 0) none else "<ul>" + parts.join("") + "</ul>";
    }

    public static function visCommaSeparated<T>(c:NCommaSeparated<T>, vis:T->String):String {
        var parts = [vis(c.arg)];
        for (el in c.args) {
            parts.push(visToken(el.comma));
            parts.push(vis(el.arg));
        }
        return "<ul>" + [for (s in parts) '<li>$s</li>'].join("") + "</ul>";
    }

    public static function visCommaSeparatedTrailing<T>(c:NCommaSeparatedAllowTrailing<T>, vis:T->String):String {
        var parts = [vis(c.arg)];
        for (el in c.args) {
            parts.push(visToken(el.comma));
            parts.push(vis(el.arg));
        }
        if (c.comma != null)
            parts.push(visToken(c.comma));
        return "<ul>" + [for (s in parts) '<li>$s</li>'].join("") + "</ul>";
    }
}
