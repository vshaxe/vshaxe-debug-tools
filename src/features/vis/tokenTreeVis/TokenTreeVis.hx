package features.vis.tokenTreeVis;

import features.vis.TreePrinterBase;
import tokentree.TokenTree;

using tokentree.TokenTreeAccessHelper;
using StringTools;

class TokenTreeVis extends TreePrinterBase<TokenTree> {
	public function new() {
		super("tokenTree");
	}

	override function makeHtml(t:TokenTree):String {
		inline function renderPosition(start:Int, end:Int):String {
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
		var colorClass = getTokenColor(t);
		var parts = [
			'<a id=\"' + id + '\" href=\"' + link + '\" class=\"tokentree $colorClass' + (if (selected) " selected" else "") + '\">' + s +
				' <span class="tokenPos">' + renderPosition(start, end) + "</span></a>"
		];
		if (t.inserted)
			parts.push('<span class=\"missing\">(missing)</span>');
		if (t.children != null) {
			var childTexts:Array<String> = [];
			for (child in t.children) {
				childTexts.push("<li>" + makeHtml(child) + "</li>");
			}
			parts.push("<ul>" + childTexts.join("") + "</ul>");
		}
		return parts.join(" ");
	}

	function getTokenColor(t:TokenTree):String {
		return switch (t.tok) {
			case null: "";
			case Kwd(KwdIf), Kwd(KwdElse), Kwd(KwdFor), Kwd(KwdWhile), Kwd(KwdDo), Kwd(KwdSwitch), Kwd(KwdCase), Kwd(KwdDefault), Kwd(KwdReturn), Kwd(KwdTry), Kwd(KwdCatch), Kwd(KwdThrow), Kwd(KwdBreak), Kwd(KwdContinue):
				"keyword-control";
			case Kwd(_):
				"keyword";
			case Const(CIdent(s)):
				if (~/^[A-Z]/.match(s)) {
					"type";
				} else if (t.access().firstOf(POpen).exists()) {
					"function";
				} else {
					"ident";
				}
			case Const(CString(_)):
				"string";
			case Const(CRegexp(_)):
				"regex";
			case Const(CInt(_)), Const(CFloat(_)):
				"number";
			case Comment(_), CommentLine(_):
				"comment";
			case Sharp(_):
				"sharp";
			case _: "";
		}
	}
}
