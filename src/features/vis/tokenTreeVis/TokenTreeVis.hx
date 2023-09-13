package features.vis.tokenTreeVis;

import sys.io.File;
import sys.FileSystem;
import haxe.display.FsPath;
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
			final path = uriToFsPath(uri).toString();
			if (FileSystem.exists(path)) {
				final content = File.getContent(path);
				start = utf8Offset(content, start, 1);
				end = utf8Offset(content, end, 1);
			}
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
		// @formatter:off
		var parts = [
			'<a id=\"' + id + '\" href=\"' + link + '\" class=\"tokentree $colorClass' + (if (selected) " selected" else "") + '\">' + s +
				' <span class="tokenPos">' + renderPosition(start, end) + "</span></a>"
		];
		// @formatter:on
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

	function utf8Offset(string:String, offset:Int, direction:Int):Int {
		var ret = offset;
		var i = 0, j = 0;
		while (j < string.length && i < offset) {
			var ch = string.charCodeAt(j);
			if (ch >= 0x0000 && ch <= 0x007F) {
				// 1
			} else if (ch >= 0x0080 && ch <= 0x07FF) {
				// 2
				ret -= direction;
			} else if (ch >= 0xD800 && ch < 0xDC00) {
				// surrogate pair
				ret -= direction * 2;
				j++;
			} else if (ch >= 0x0800 && ch <= 0xFFFF) {
				// 3
				ret -= direction * 2;
			} else if (ch >= 0x10000 && ch <= 0x10FFFF) {
				// 4
				ret -= direction * 3;
			} else {} // invalid char
			i++;
			j++;
		}
		return ret;
	}

	final driveLetterPathRe = ~/^\/[a-zA-Z]:/;
	final uriRe = ~/^(([^:\/?#]+?):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/;

	function uriToFsPath(uri:String):FsPath {
		if (!uriRe.match(uri) || uriRe.matched(2) != "file")
			throw 'Invalid uri: $uri';

		final path = uriRe.matched(5).urlDecode();
		if (driveLetterPathRe.match(path))
			return new FsPath(path.charAt(1).toLowerCase() + path.substr(2));
		else
			return new FsPath(path);
	}

	function getTokenColor(t:TokenTree):String {
		return switch (t.tok) {
			case null: "";
			case Kwd(KwdIf), Kwd(KwdElse), Kwd(KwdFor), Kwd(KwdWhile), Kwd(KwdDo), Kwd(KwdSwitch), Kwd(KwdCase), Kwd(KwdDefault), Kwd(KwdReturn), Kwd(KwdTry),
				Kwd(KwdCatch), Kwd(KwdThrow), Kwd(KwdBreak), Kwd(KwdContinue):
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
