package hxParserVis;

import hxParser.ParseTree;

using StringTools;

class Vis {
	var ctx : SyntaxTreePrinter;
	public function new(ctx) {
		this.ctx = ctx;
	}
	static public var none = '<span class=\"none\">&lt;none&gt;</span>';
	public function visToken(t:Token):String {
		var link = ctx.makeLink(t.start, t.end);
		var id = ctx.registerPos(t.start, t.end);
		var selected = ctx.isUnderCursor(t.start, t.end);
		var s = t.toString().htmlEscape();
		var parts = ['<a id=\"' + id + '\" href=\"' + link + '\" class=\"token' + (if (selected) " selected" else "") + '\">' + s + '</a>'];
		if (t.inserted) parts.push('<span class=\"missing\">(missing)</span>');
		if (t.implicit) parts.push('<span class=\"implicit\">(implicit)</span>');
		function inline_renderTrivia(t:Trivia, prefix:String) {
			var s = t.toString().htmlEscape();
			var id = ctx.registerPos(t.start, t.end);
			var link = ctx.makeLink(t.start, t.end);
			return '<li><a id=\"' + id + '\" href=\"' + link + '\" class=\"trivia\">' + prefix + ': ' + s + '</a></li>';
		};
		var trivias = [];
		if (t.leadingTrivia != null) {
			for (t in t.leadingTrivia) trivias.push(renderTrivia(t, "LEAD"));
		};
		if (t.trailingTrivia != null) {
			for (t in t.trailingTrivia) trivias.push(renderTrivia(t, "TAIL"));
		};
		if (trivias.length > 0) parts.push('<ul class=\"trivia\">' + trivias.join("") + "</ul>");
		return parts.join(" ");
	}
	public function visArray<T>(c:Array<T>, vis:T -> String):String {
		var parts = [for (el in c) "<li>" + vis(el) + "</li>"];
		return if (parts.length == 0) none else "<ul>" + parts.join("") + "</ul>";
	}
	public function visCommaSeparated<T>(c:CommaSeparated<T>, vis:T -> String):String {
		var parts = [vis(c.arg)];
		for (el in c.args) {
			parts.push(visToken(el.comma));
			parts.push(vis(el.arg));
		};
		return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
	}
	public function visCommaSeparatedTrailing<T>(c:CommaSeparatedAllowTrailing<T>, vis:T -> String):String {
		var parts = [vis(c.arg)];
		for (el in c.args) {
			parts.push(visToken(el.comma));
			parts.push(vis(el.arg));
		};
		if (c.comma != null) parts.push(visToken(c.comma));
		return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
	}
	public function visNLiteral(v:NLiteral):String {
		return switch v {
			case PLiteralString(s):"<span class=\"node\">PLiteralString</span>" + "<ul>" + "<li>" + "s: " + visNString(s) + "</li>" + "</ul>";
			case PLiteralFloat(token):"<span class=\"node\">PLiteralFloat</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PLiteralRegex(token):"<span class=\"node\">PLiteralRegex</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PLiteralInt(token):"<span class=\"node\">PLiteralInt</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
		};
	}
	public function visFieldModifier(v:FieldModifier):String {
		return switch v {
			case Dynamic(keyword):"<span class=\"node\">Dynamic</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
			case Inline(keyword):"<span class=\"node\">Inline</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
			case Macro(keyword):"<span class=\"node\">Macro</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
			case Override(keyword):"<span class=\"node\">Override</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
			case Private(keyword):"<span class=\"node\">Private</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
			case Public(keyword):"<span class=\"node\">Public</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
			case Static(keyword):"<span class=\"node\">Static</span>" + "<ul>" + "<li>" + "keyword: " + visToken(keyword) + "</li>" + "</ul>";
		};
	}
	public function visNAssignment(v:NAssignment):String {
		return "<span class=\"node\">NAssignment</span>" + "<ul>" + "<li>" + "assign: " + visToken(v.assign) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
	public function visNObjectFieldName(v:NObjectFieldName):String {
		return switch v {
			case PString(string):"<span class=\"node\">PString</span>" + "<ul>" + "<li>" + "string: " + visNString(string) + "</li>" + "</ul>";
			case PIdent(ident):"<span class=\"node\">PIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
		};
	}
	public function visNTypeHint(v:NTypeHint):String {
		return "<span class=\"node\">NTypeHint</span>" + "<ul>" + "<li>" + "colon: " + visToken(v.colon) + "</li>" + "<li>" + "type: " + visComplexType(v.type) + "</li>" + "</ul>";
	}
	public function visAbstractRelation(v:AbstractRelation):String {
		return switch v {
			case To(toKeyword, type):"<span class=\"node\">To</span>" + "<ul>" + "<li>" + "toKeyword: " + visToken(toKeyword) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
			case From(fromKeyword, type):"<span class=\"node\">From</span>" + "<ul>" + "<li>" + "fromKeyword: " + visToken(fromKeyword) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visComplexType(v:ComplexType):String {
		return switch v {
			case PFunctionType(type1, arrow, type2):"<span class=\"node\">PFunctionType</span>" + "<ul>" + "<li>" + "type1: " + visComplexType(type1) + "</li>" + "<li>" + "arrow: " + visToken(arrow) + "</li>" + "<li>" + "type2: " + visComplexType(type2) + "</li>" + "</ul>";
			case PStructuralExtension(braceOpen, types, fields, braceClose):"<span class=\"node\">PStructuralExtension</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "types: " + visArray(types, function(el) return visNStructuralExtension(el)) + "</li>" + "<li>" + "fields: " + visNAnonymousTypeFields(fields) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case PParenthesisType(parenOpen, ct, parenClose):"<span class=\"node\">PParenthesisType</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "ct: " + visComplexType(ct) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PAnonymousStructure(braceOpen, fields, braceClose):"<span class=\"node\">PAnonymousStructure</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visNAnonymousTypeFields(fields) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case PTypePath(path):"<span class=\"node\">PTypePath</span>" + "<ul>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "</ul>";
			case POptionalType(questionmark, type):"<span class=\"node\">POptionalType</span>" + "<ul>" + "<li>" + "questionmark: " + visToken(questionmark) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visNCatch(v:NCatch):String {
		return "<span class=\"node\">NCatch</span>" + "<ul>" + "<li>" + "_catch: " + visToken(v._catch) + "</li>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "ident: " + visToken(v.ident) + "</li>" + "<li>" + "type: " + visNTypeHint(v.type) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
	public function visNTypeDeclParameter(v:NTypeDeclParameter):String {
		return "<span class=\"node\">NTypeDeclParameter</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "constraints: " + visNConstraints(v.constraints) + "</li>" + "</ul>";
	}
	public function visNConst(v:NConst):String {
		return switch v {
			case PConstLiteral(literal):"<span class=\"node\">PConstLiteral</span>" + "<ul>" + "<li>" + "literal: " + visNLiteral(literal) + "</li>" + "</ul>";
			case PConstIdent(ident):"<span class=\"node\">PConstIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
		};
	}
	public function visNTypePathParameters(v:NTypePathParameters):String {
		return "<span class=\"node\">NTypePathParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(v.lt) + "</li>" + "<li>" + "parameters: " + visCommaSeparated(v.parameters, function(el) return visNTypePathParameter(el)) + "</li>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "</ul>";
	}
	public function visNFieldExpr(v:NFieldExpr):String {
		return switch v {
			case PNoFieldExpr(semicolon):"<span class=\"node\">PNoFieldExpr</span>" + "<ul>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case PBlockFieldExpr(e):"<span class=\"node\">PBlockFieldExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PExprFieldExpr(e, semicolon):"<span class=\"node\">PExprFieldExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
		};
	}
	public function visNCommonFlag(v:NCommonFlag):String {
		return switch v {
			case PExtern(token):"<span class=\"node\">PExtern</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PPrivate(token):"<span class=\"node\">PPrivate</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
		};
	}
	public function visNEnumFieldArgs(v:NEnumFieldArgs):String {
		return "<span class=\"node\">NEnumFieldArgs</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visNEnumFieldArg(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
	public function visNFunctionArgument(v:NFunctionArgument):String {
		return "<span class=\"node\">NFunctionArgument</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visNTypeHint(v.typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visNAssignment(v.assignment) else none) + "</li>" + "</ul>";
	}
	public function visNAnonymousTypeField(v:NAnonymousTypeField):String {
		return "<span class=\"node\">NAnonymousTypeField</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + visNTypeHint(v.typeHint) + "</li>" + "</ul>";
	}
	public function visNUnderlyingType(v:NUnderlyingType):String {
		return "<span class=\"node\">NUnderlyingType</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "type: " + visComplexType(v.type) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
	public function visDecl(v:Decl):String {
		return switch v {
			case ClassDecl(annotations, flags, classDecl):"<span class=\"node\">ClassDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "classDecl: " + visClassDecl(classDecl) + "</li>" + "</ul>";
			case TypedefDecl(annotations, flags, typedefKeyword, name, params, assign, type, semicolon):"<span class=\"node\">TypedefDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "typedefKeyword: " + visToken(typedefKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "assign: " + visToken(assign) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "<li>" + "semicolon: " + (if (semicolon != null) visToken(semicolon) else none) + "</li>" + "</ul>";
			case EnumDecl(annotations, flags, enumKeyword, name, params, braceOpen, fields, braceClose):"<span class=\"node\">EnumDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "enumKeyword: " + visToken(enumKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visArray(fields, function(el) return visNEnumField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case UsingDecl(usingKeyword, path, semicolon):"<span class=\"node\">UsingDecl</span>" + "<ul>" + "<li>" + "usingKeyword: " + visToken(usingKeyword) + "</li>" + "<li>" + "path: " + visNPath(path) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case AbstractDecl(annotations, flags, abstractKeyword, name, params, underlyingType, relations, braceOpen, fields, braceClose):"<span class=\"node\">AbstractDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "abstractKeyword: " + visToken(abstractKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "underlyingType: " + (if (underlyingType != null) visNUnderlyingType(underlyingType) else none) + "</li>" + "<li>" + "relations: " + visArray(relations, function(el) return visAbstractRelation(el)) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visArray(fields, function(el) return visClassField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case ImportDecl(importKeyword, path, mode, semicolon):"<span class=\"node\">ImportDecl</span>" + "<ul>" + "<li>" + "importKeyword: " + visToken(importKeyword) + "</li>" + "<li>" + "path: " + visNPath(path) + "</li>" + "<li>" + "mode: " + visImportMode(mode) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
		};
	}
	public function visNTypePathParameter(v:NTypePathParameter):String {
		return switch v {
			case PArrayExprTypePathParameter(bracketOpen, el, bracketClose):"<span class=\"node\">PArrayExprTypePathParameter</span>" + "<ul>" + "<li>" + "bracketOpen: " + visToken(bracketOpen) + "</li>" + "<li>" + "el: " + (if (el != null) visCommaSeparatedTrailing(el, function(el) return visNExpr(el)) else none) + "</li>" + "<li>" + "bracketClose: " + visToken(bracketClose) + "</li>" + "</ul>";
			case PConstantTypePathParameter(constant):"<span class=\"node\">PConstantTypePathParameter</span>" + "<ul>" + "<li>" + "constant: " + visNLiteral(constant) + "</li>" + "</ul>";
			case PTypeTypePathParameter(type):"<span class=\"node\">PTypeTypePathParameter</span>" + "<ul>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visNTypeDeclParameters(v:NTypeDeclParameters):String {
		return "<span class=\"node\">NTypeDeclParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(v.lt) + "</li>" + "<li>" + "params: " + visCommaSeparated(v.params, function(el) return visNTypeDeclParameter(el)) + "</li>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "</ul>";
	}
	public function visNGuard(v:NGuard):String {
		return "<span class=\"node\">NGuard</span>" + "<ul>" + "<li>" + "_if: " + visToken(v._if) + "</li>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
	public function visNMacroExpr(v:NMacroExpr):String {
		return switch v {
			case PVar(_var, v):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(_var) + "</li>" + "<li>" + "v: " + visCommaSeparated(v, function(el) return visNVarDeclaration(el)) + "</li>" + "</ul>";
			case PTypeHint(type):"<span class=\"node\">PTypeHint</span>" + "<ul>" + "<li>" + "type: " + visNTypeHint(type) + "</li>" + "</ul>";
			case PClass(c):"<span class=\"node\">PClass</span>" + "<ul>" + "<li>" + "c: " + visClassDecl(c) + "</li>" + "</ul>";
			case PExpr(e):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
		};
	}
	public function visClassDecl(v:ClassDecl):String {
		return "<span class=\"node\">ClassDecl</span>" + "<ul>" + "<li>" + "kind: " + visToken(v.kind) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "relations: " + visArray(v.relations, function(el) return visClassRelation(el)) + "</li>" + "<li>" + "braceOpen: " + visToken(v.braceOpen) + "</li>" + "<li>" + "fields: " + visArray(v.fields, function(el) return visClassField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(v.braceClose) + "</li>" + "</ul>";
	}
	public function visNEnumField(v:NEnumField):String {
		return "<span class=\"node\">NEnumField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "args: " + (if (v.args != null) visNEnumFieldArgs(v.args) else none) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(v.type) else none) + "</li>" + "<li>" + "semicolon: " + visToken(v.semicolon) + "</li>" + "</ul>";
	}
	public function visImportMode(v:ImportMode):String {
		return switch v {
			case IIn(inKeyword, ident):"<span class=\"node\">IIn</span>" + "<ul>" + "<li>" + "inKeyword: " + visToken(inKeyword) + "</li>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case INormal:"INormal";
			case IAll(dotstar):"<span class=\"node\">IAll</span>" + "<ul>" + "<li>" + "dotstar: " + visToken(dotstar) + "</li>" + "</ul>";
			case IAs(asKeyword, ident):"<span class=\"node\">IAs</span>" + "<ul>" + "<li>" + "asKeyword: " + visToken(asKeyword) + "</li>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
		};
	}
	public function visNPath(v:NPath):String {
		return "<span class=\"node\">NPath</span>" + "<ul>" + "<li>" + "ident: " + visToken(v.ident) + "</li>" + "<li>" + "idents: " + visArray(v.idents, function(el) return visNDotIdent(el)) + "</li>" + "</ul>";
	}
	public function visNConstraints(v:NConstraints):String {
		return switch v {
			case PMultipleConstraints(colon, parenOpen, types, parenClose):"<span class=\"node\">PMultipleConstraints</span>" + "<ul>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "types: " + visCommaSeparated(types, function(el) return visComplexType(el)) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PSingleConstraint(colon, type):"<span class=\"node\">PSingleConstraint</span>" + "<ul>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
			case PNoConstraints:"PNoConstraints";
		};
	}
	public function visNBlockElement(v:NBlockElement):String {
		return switch v {
			case PVar(_var, vl, semicolon):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(_var) + "</li>" + "<li>" + "vl: " + visCommaSeparated(vl, function(el) return visNVarDeclaration(el)) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case PExpr(e, semicolon):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case PInlineFunction(_inline, _function, f, semicolon):"<span class=\"node\">PInlineFunction</span>" + "<ul>" + "<li>" + "_inline: " + visToken(_inline) + "</li>" + "<li>" + "_function: " + visToken(_function) + "</li>" + "<li>" + "f: " + visNFunction(f) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
		};
	}
	public function visFile(v:File):String {
		return "<span class=\"node\">File</span>" + "<ul>" + "<li>" + "pack: " + (if (v.pack != null) visPackage(v.pack) else none) + "</li>" + "<li>" + "decls: " + visArray(v.decls, function(el) return visDecl(el)) + "</li>" + "<li>" + "eof: " + visToken(v.eof) + "</li>" + "</ul>";
	}
	public function visNCase(v:NCase):String {
		return switch v {
			case PCase(_case, patterns, guard, colon, el):"<span class=\"node\">PCase</span>" + "<ul>" + "<li>" + "_case: " + visToken(_case) + "</li>" + "<li>" + "patterns: " + visCommaSeparated(patterns, function(el) return visNExpr(el)) + "</li>" + "<li>" + "guard: " + (if (guard != null) visNGuard(guard) else none) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "el: " + visArray(el, function(el) return visNBlockElement(el)) + "</li>" + "</ul>";
			case PDefault(_default, colon, el):"<span class=\"node\">PDefault</span>" + "<ul>" + "<li>" + "_default: " + visToken(_default) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "el: " + visArray(el, function(el) return visNBlockElement(el)) + "</li>" + "</ul>";
		};
	}
	public function visNStructuralExtension(v:NStructuralExtension):String {
		return "<span class=\"node\">NStructuralExtension</span>" + "<ul>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "<li>" + "path: " + visTypePath(v.path) + "</li>" + "<li>" + "comma: " + visToken(v.comma) + "</li>" + "</ul>";
	}
	public function visNEnumFieldArg(v:NEnumFieldArg):String {
		return "<span class=\"node\">NEnumFieldArg</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + visNTypeHint(v.typeHint) + "</li>" + "</ul>";
	}
	public function visNMetadata(v:NMetadata):String {
		return switch v {
			case PMetadata(name):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "</ul>";
			case PMetadataWithArgs(name, el, parenClose):"<span class=\"node\">PMetadataWithArgs</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "el: " + visCommaSeparated(el, function(el) return visNExpr(el)) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
		};
	}
	public function visClassRelation(v:ClassRelation):String {
		return switch v {
			case Extends(extendsKeyword, path):"<span class=\"node\">Extends</span>" + "<ul>" + "<li>" + "extendsKeyword: " + visToken(extendsKeyword) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "</ul>";
			case Implements(implementsKeyword, path):"<span class=\"node\">Implements</span>" + "<ul>" + "<li>" + "implementsKeyword: " + visToken(implementsKeyword) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "</ul>";
		};
	}
	public function visNVarDeclaration(v:NVarDeclaration):String {
		return "<span class=\"node\">NVarDeclaration</span>" + "<ul>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(v.type) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visNAssignment(v.assignment) else none) + "</li>" + "</ul>";
	}
	public function visNString(v:NString):String {
		return switch v {
			case PString(s):"<span class=\"node\">PString</span>" + "<ul>" + "<li>" + "s: " + visToken(s) + "</li>" + "</ul>";
			case PString2(s):"<span class=\"node\">PString2</span>" + "<ul>" + "<li>" + "s: " + visToken(s) + "</li>" + "</ul>";
		};
	}
	public function visNAnnotations(v:NAnnotations):String {
		return "<span class=\"node\">NAnnotations</span>" + "<ul>" + "<li>" + "doc: " + (if (v.doc != null) visToken(v.doc) else none) + "</li>" + "<li>" + "meta: " + visArray(v.meta, function(el) return visNMetadata(el)) + "</li>" + "</ul>";
	}
	public function visNExpr(v:NExpr):String {
		return switch v {
			case PVar(_var, d):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(_var) + "</li>" + "<li>" + "d: " + visNVarDeclaration(d) + "</li>" + "</ul>";
			case PConst(const):"<span class=\"node\">PConst</span>" + "<ul>" + "<li>" + "const: " + visNConst(const) + "</li>" + "</ul>";
			case PDo(_do, e1, _while, parenOpen, e2, parenClose):"<span class=\"node\">PDo</span>" + "<ul>" + "<li>" + "_do: " + visToken(_do) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "_while: " + visToken(_while) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PMacro(_macro, e):"<span class=\"node\">PMacro</span>" + "<ul>" + "<li>" + "_macro: " + visToken(_macro) + "</li>" + "<li>" + "e: " + visNMacroExpr(e) + "</li>" + "</ul>";
			case PWhile(_while, parenOpen, e1, parenClose, e2):"<span class=\"node\">PWhile</span>" + "<ul>" + "<li>" + "_while: " + visToken(_while) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
			case PIntDot(int, dot):"<span class=\"node\">PIntDot</span>" + "<ul>" + "<li>" + "int: " + visToken(int) + "</li>" + "<li>" + "dot: " + visToken(dot) + "</li>" + "</ul>";
			case PBlock(braceOpen, elems, braceClose):"<span class=\"node\">PBlock</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "elems: " + visArray(elems, function(el) return visNBlockElement(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case PFunction(_function, f):"<span class=\"node\">PFunction</span>" + "<ul>" + "<li>" + "_function: " + visToken(_function) + "</li>" + "<li>" + "f: " + visNFunction(f) + "</li>" + "</ul>";
			case PSwitch(_switch, e, braceOpen, cases, braceClose):"<span class=\"node\">PSwitch</span>" + "<ul>" + "<li>" + "_switch: " + visToken(_switch) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "cases: " + visArray(cases, function(el) return visNCase(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case PReturn(_return):"<span class=\"node\">PReturn</span>" + "<ul>" + "<li>" + "_return: " + visToken(_return) + "</li>" + "</ul>";
			case PArrayDecl(bracketOpen, el, bracketClose):"<span class=\"node\">PArrayDecl</span>" + "<ul>" + "<li>" + "bracketOpen: " + visToken(bracketOpen) + "</li>" + "<li>" + "el: " + (if (el != null) visCommaSeparatedTrailing(el, function(el) return visNExpr(el)) else none) + "</li>" + "<li>" + "bracketClose: " + visToken(bracketClose) + "</li>" + "</ul>";
			case PDollarIdent(ident):"<span class=\"node\">PDollarIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case PIf(_if, parenOpen, e1, parenClose, e2, elseExpr):"<span class=\"node\">PIf</span>" + "<ul>" + "<li>" + "_if: " + visToken(_if) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "elseExpr: " + (if (elseExpr != null) visNExprElse(elseExpr) else none) + "</li>" + "</ul>";
			case PReturnExpr(_return, e):"<span class=\"node\">PReturnExpr</span>" + "<ul>" + "<li>" + "_return: " + visToken(_return) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PArray(e1, bracketOpen, e2, bracketClose):"<span class=\"node\">PArray</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "bracketOpen: " + visToken(bracketOpen) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "bracketClose: " + visToken(bracketClose) + "</li>" + "</ul>";
			case PContinue(_continue):"<span class=\"node\">PContinue</span>" + "<ul>" + "<li>" + "_continue: " + visToken(_continue) + "</li>" + "</ul>";
			case PParenthesis(parenOpen, e, parenClose):"<span class=\"node\">PParenthesis</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PTry(_try, e, catches):"<span class=\"node\">PTry</span>" + "<ul>" + "<li>" + "_try: " + visToken(_try) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "catches: " + visArray(catches, function(el) return visNCatch(el)) + "</li>" + "</ul>";
			case PBreak(_break):"<span class=\"node\">PBreak</span>" + "<ul>" + "<li>" + "_break: " + visToken(_break) + "</li>" + "</ul>";
			case PCall(e, el):"<span class=\"node\">PCall</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "el: " + visNCallArgs(el) + "</li>" + "</ul>";
			case PUnaryPostfix(e, op):"<span class=\"node\">PUnaryPostfix</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "op: " + visToken(op) + "</li>" + "</ul>";
			case PBinop(e1, op, e2):"<span class=\"node\">PBinop</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "op: " + visToken(op) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
			case PSafeCast(_cast, parenOpen, e, comma, ct, parenClose):"<span class=\"node\">PSafeCast</span>" + "<ul>" + "<li>" + "_cast: " + visToken(_cast) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "comma: " + visToken(comma) + "</li>" + "<li>" + "ct: " + visComplexType(ct) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PUnaryPrefix(op, e):"<span class=\"node\">PUnaryPrefix</span>" + "<ul>" + "<li>" + "op: " + visToken(op) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PMacroEscape(ident, braceOpen, e, braceClose):"<span class=\"node\">PMacroEscape</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case PIn(e1, _in, e2):"<span class=\"node\">PIn</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "_in: " + visToken(_in) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
			case PMetadata(metadata, e):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "metadata: " + visNMetadata(metadata) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PUnsafeCast(_cast, e):"<span class=\"node\">PUnsafeCast</span>" + "<ul>" + "<li>" + "_cast: " + visToken(_cast) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PCheckType(parenOpen, e, colon, type, parenClose):"<span class=\"node\">PCheckType</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PUntyped(_untyped, e):"<span class=\"node\">PUntyped</span>" + "<ul>" + "<li>" + "_untyped: " + visToken(_untyped) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PField(e, ident):"<span class=\"node\">PField</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "ident: " + visNDotIdent(ident) + "</li>" + "</ul>";
			case PIs(parenOpen, e, _is, path, parenClose):"<span class=\"node\">PIs</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "_is: " + visToken(_is) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case PTernary(e1, questionmark, e2, colon, e3):"<span class=\"node\">PTernary</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "questionmark: " + visToken(questionmark) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "e3: " + visNExpr(e3) + "</li>" + "</ul>";
			case PObjectDecl(braceOpen, fl, braceClose):"<span class=\"node\">PObjectDecl</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fl: " + visCommaSeparatedTrailing(fl, function(el) return visNObjectField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case PNew(_new, path, el):"<span class=\"node\">PNew</span>" + "<ul>" + "<li>" + "_new: " + visToken(_new) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "<li>" + "el: " + visNCallArgs(el) + "</li>" + "</ul>";
			case PThrow(_throw, e):"<span class=\"node\">PThrow</span>" + "<ul>" + "<li>" + "_throw: " + visToken(_throw) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PFor(_for, parenOpen, e1, parenClose, e2):"<span class=\"node\">PFor</span>" + "<ul>" + "<li>" + "_for: " + visToken(_for) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
		};
	}
	public function visNAnonymousTypeFields(v:NAnonymousTypeFields):String {
		return switch v {
			case PAnonymousClassFields(fields):"<span class=\"node\">PAnonymousClassFields</span>" + "<ul>" + "<li>" + "fields: " + visArray(fields, function(el) return visClassField(el)) + "</li>" + "</ul>";
			case PAnonymousShortFields(fields):"<span class=\"node\">PAnonymousShortFields</span>" + "<ul>" + "<li>" + "fields: " + (if (fields != null) visCommaSeparatedTrailing(fields, function(el) return visNAnonymousTypeField(el)) else none) + "</li>" + "</ul>";
		};
	}
	public function visNCallArgs(v:NCallArgs):String {
		return "<span class=\"node\">NCallArgs</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visNExpr(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
	public function visPackage(v:Package):String {
		return "<span class=\"node\">Package</span>" + "<ul>" + "<li>" + "packageKeyword: " + visToken(v.packageKeyword) + "</li>" + "<li>" + "path: " + (if (v.path != null) visNPath(v.path) else none) + "</li>" + "<li>" + "semicolon: " + visToken(v.semicolon) + "</li>" + "</ul>";
	}
	public function visNDotIdent(v:NDotIdent):String {
		return switch v {
			case PDotIdent(name):"<span class=\"node\">PDotIdent</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "</ul>";
			case PDot(_dot):"<span class=\"node\">PDot</span>" + "<ul>" + "<li>" + "_dot: " + visToken(_dot) + "</li>" + "</ul>";
		};
	}
	public function visNObjectField(v:NObjectField):String {
		return "<span class=\"node\">NObjectField</span>" + "<ul>" + "<li>" + "name: " + visNObjectFieldName(v.name) + "</li>" + "<li>" + "colon: " + visToken(v.colon) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
	public function visTypePath(v:TypePath):String {
		return "<span class=\"node\">TypePath</span>" + "<ul>" + "<li>" + "path: " + visNPath(v.path) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypePathParameters(v.params) else none) + "</li>" + "</ul>";
	}
	public function visNFunction(v:NFunction):String {
		return "<span class=\"node\">NFunction</span>" + "<ul>" + "<li>" + "ident: " + (if (v.ident != null) visToken(v.ident) else none) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visNFunctionArgument(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(v.type) else none) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
	public function visClassField(v:ClassField):String {
		return switch v {
			case Property(annotations, modifiers, varKeyword, name, parenOpen, read, comma, write, parenClose, typeHint, assignment):"<span class=\"node\">Property</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visFieldModifier(el)) + "</li>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "read: " + visToken(read) + "</li>" + "<li>" + "comma: " + visToken(comma) + "</li>" + "<li>" + "write: " + visToken(write) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visNAssignment(assignment) else none) + "</li>" + "</ul>";
			case Variable(annotations, modifiers, varKeyword, name, typeHint, assignment, semicolon):"<span class=\"node\">Variable</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visFieldModifier(el)) + "</li>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visNAssignment(assignment) else none) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case Function(annotations, modifiers, functionKeyword, name, params, parenOpen, args, parenClose, typeHint, expr):"<span class=\"node\">Function</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visFieldModifier(el)) + "</li>" + "<li>" + "functionKeyword: " + visToken(functionKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "args: " + (if (args != null) visCommaSeparated(args, function(el) return visNFunctionArgument(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(typeHint) else none) + "</li>" + "<li>" + "expr: " + (if (expr != null) visNFieldExpr(expr) else none) + "</li>" + "</ul>";
		};
	}
	public function visNExprElse(v:NExprElse):String {
		return "<span class=\"node\">NExprElse</span>" + "<ul>" + "<li>" + "_else: " + visToken(v._else) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
}