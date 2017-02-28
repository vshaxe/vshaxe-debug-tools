package hxParserVis;

import hxParser.ParseTree;

using StringTools;

class Vis {
	var ctx : SyntaxTreePrinter;
	var offset : Int;
	public function new(ctx) {
		this.ctx = ctx;
		offset = 0;
	}
	static public var none = '<span class=\"none\">&lt;none&gt;</span>';
	public function visToken(t:Token):String {
		function inline_renderPosition(start:Int, end:Int) {
			return "[" + start + "-" + end + ")";
		};
		function inline_renderTrivia(t:Trivia, prefix:String) {
			var s = t.toString().htmlEscape();
			var start = offset;
			var end = offset += t.text.length;
			var id = ctx.registerPos(start, end);
			var link = ctx.makeLink(start, end);
			return '<li><a id=\"' + id + '\" href=\"' + link + '\" class=\"trivia\">' + prefix + ': ' + s + " " + renderPosition(start, end) + '</a></li>';
		};
		var trivias = [];
		if (t.leadingTrivia != null) {
			for (t in t.leadingTrivia) trivias.push(renderTrivia(t, "LEAD"));
		};
		var start = offset;
		var end = !t.appearsInSource() ? start : offset += t.text.length;
		var link = ctx.makeLink(start, end);
		var id = ctx.registerPos(start, end);
		var selected = ctx.isUnderCursor(start, end);
		var s = t.toString().htmlEscape();
		var parts = ['<a id=\"' + id + '\" href=\"' + link + '\" class=\"token' + (if (selected) " selected" else "") + '\">' + s + " " + renderPosition(start, end) + '</a>'];
		if (t.inserted) parts.push('<span class=\"missing\">(missing)</span>');
		if (t.implicit) parts.push('<span class=\"implicit\">(implicit)</span>');
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
	public function visCatch(v:Catch):String {
		return "<span class=\"node\">Catch</span>" + "<ul>" + "<li>" + "catchKeyword: " + visToken(v.catchKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "ident: " + visToken(v.ident) + "</li>" + "<li>" + "typeHint: " + visTypeHint(v.typeHint) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "<li>" + "expr: " + visExpr(v.expr) + "</li>" + "</ul>";
	}
	public function visCallArgs(v:CallArgs):String {
		return "<span class=\"node\">CallArgs</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visExpr(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
	public function visAnonymousStructureFields(v:AnonymousStructureFields):String {
		return switch v {
			case ClassNotation(fields):"<span class=\"node\">ClassNotation</span>" + "<ul>" + "<li>" + "fields: " + visArray(fields, function(el) return visClassField(el)) + "</li>" + "</ul>";
			case ShortNotation(fields):"<span class=\"node\">ShortNotation</span>" + "<ul>" + "<li>" + "fields: " + (if (fields != null) visCommaSeparatedTrailing(fields, function(el) return visAnonymousStructureField(el)) else none) + "</li>" + "</ul>";
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
	public function visBlockElement(v:BlockElement):String {
		return switch v {
			case Expr(expr, semicolon):"<span class=\"node\">Expr</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case InlineFunction(inlineKeyword, functionKeyword, fun, semicolon):"<span class=\"node\">InlineFunction</span>" + "<ul>" + "<li>" + "inlineKeyword: " + visToken(inlineKeyword) + "</li>" + "<li>" + "functionKeyword: " + visToken(functionKeyword) + "</li>" + "<li>" + "fun: " + visFunction(fun) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case Var(varKeyword, decls, semicolon):"<span class=\"node\">Var</span>" + "<ul>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "decls: " + visCommaSeparated(decls, function(el) return visVarDecl(el)) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
		};
	}
	public function visAbstractRelation(v:AbstractRelation):String {
		return switch v {
			case To(toKeyword, type):"<span class=\"node\">To</span>" + "<ul>" + "<li>" + "toKeyword: " + visToken(toKeyword) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
			case From(fromKeyword, type):"<span class=\"node\">From</span>" + "<ul>" + "<li>" + "fromKeyword: " + visToken(fromKeyword) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visComplexType(v:ComplexType):String {
		return switch v {
			case Parenthesis(parenOpen, type, parenClose):"<span class=\"node\">Parenthesis</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case StructuralExtension(braceOpen, types, fields, braceClose):"<span class=\"node\">StructuralExtension</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "types: " + visArray(types, function(el) return visStructuralExtension(el)) + "</li>" + "<li>" + "fields: " + visAnonymousStructureFields(fields) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case AnonymousStructure(braceOpen, fields, braceClose):"<span class=\"node\">AnonymousStructure</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visAnonymousStructureFields(fields) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case Optional(questionMark, type):"<span class=\"node\">Optional</span>" + "<ul>" + "<li>" + "questionMark: " + visToken(questionMark) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
			case Function(typeLeft, arrow, typeRight):"<span class=\"node\">Function</span>" + "<ul>" + "<li>" + "typeLeft: " + visComplexType(typeLeft) + "</li>" + "<li>" + "arrow: " + visToken(arrow) + "</li>" + "<li>" + "typeRight: " + visComplexType(typeRight) + "</li>" + "</ul>";
			case TypePath(path):"<span class=\"node\">TypePath</span>" + "<ul>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "</ul>";
		};
	}
	public function visTypeHint(v:TypeHint):String {
		return "<span class=\"node\">TypeHint</span>" + "<ul>" + "<li>" + "colon: " + visToken(v.colon) + "</li>" + "<li>" + "type: " + visComplexType(v.type) + "</li>" + "</ul>";
	}
	public function visMacroExpr(v:MacroExpr):String {
		return switch v {
			case Class(classDecl):"<span class=\"node\">Class</span>" + "<ul>" + "<li>" + "classDecl: " + visClassDecl(classDecl) + "</li>" + "</ul>";
			case TypeHint(typeHint):"<span class=\"node\">TypeHint</span>" + "<ul>" + "<li>" + "typeHint: " + visTypeHint(typeHint) + "</li>" + "</ul>";
			case Expr(expr):"<span class=\"node\">Expr</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
			case Var(varKeyword, decls):"<span class=\"node\">Var</span>" + "<ul>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "decls: " + visCommaSeparated(decls, function(el) return visVarDecl(el)) + "</li>" + "</ul>";
		};
	}
	public function visFunctionArgument(v:FunctionArgument):String {
		return "<span class=\"node\">FunctionArgument</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "questionMark: " + (if (v.questionMark != null) visToken(v.questionMark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visTypeHint(v.typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visAssignment(v.assignment) else none) + "</li>" + "</ul>";
	}
	public function visTypeDeclParameter(v:TypeDeclParameter):String {
		return "<span class=\"node\">TypeDeclParameter</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "constraints: " + visConstraints(v.constraints) + "</li>" + "</ul>";
	}
	public function visLiteral(v:Literal):String {
		return switch v {
			case PLiteralString(s):"<span class=\"node\">PLiteralString</span>" + "<ul>" + "<li>" + "s: " + visStringToken(s) + "</li>" + "</ul>";
			case PLiteralFloat(token):"<span class=\"node\">PLiteralFloat</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PLiteralRegex(token):"<span class=\"node\">PLiteralRegex</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PLiteralInt(token):"<span class=\"node\">PLiteralInt</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
		};
	}
	public function visNConst(v:NConst):String {
		return switch v {
			case PConstLiteral(literal):"<span class=\"node\">PConstLiteral</span>" + "<ul>" + "<li>" + "literal: " + visLiteral(literal) + "</li>" + "</ul>";
			case PConstIdent(ident):"<span class=\"node\">PConstIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
		};
	}
	public function visExprElse(v:ExprElse):String {
		return "<span class=\"node\">ExprElse</span>" + "<ul>" + "<li>" + "elseKeyword: " + visToken(v.elseKeyword) + "</li>" + "<li>" + "expr: " + visExpr(v.expr) + "</li>" + "</ul>";
	}
	public function visAssignment(v:Assignment):String {
		return "<span class=\"node\">Assignment</span>" + "<ul>" + "<li>" + "assign: " + visToken(v.assign) + "</li>" + "<li>" + "expr: " + visExpr(v.expr) + "</li>" + "</ul>";
	}
	public function visConstraints(v:Constraints):String {
		return switch v {
			case None:"None";
			case Multiple(colon, parenOpen, types, parenClose):"<span class=\"node\">Multiple</span>" + "<ul>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "types: " + visCommaSeparated(types, function(el) return visComplexType(el)) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case Single(colon, type):"<span class=\"node\">Single</span>" + "<ul>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visObjectField(v:ObjectField):String {
		return "<span class=\"node\">ObjectField</span>" + "<ul>" + "<li>" + "name: " + visObjectFieldName(v.name) + "</li>" + "<li>" + "colon: " + visToken(v.colon) + "</li>" + "<li>" + "expr: " + visExpr(v.expr) + "</li>" + "</ul>";
	}
	public function visTypePathParameters(v:TypePathParameters):String {
		return "<span class=\"node\">TypePathParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(v.lt) + "</li>" + "<li>" + "params: " + visCommaSeparated(v.params, function(el) return visTypePathParameter(el)) + "</li>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "</ul>";
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
	public function visAnonymousStructureField(v:AnonymousStructureField):String {
		return "<span class=\"node\">AnonymousStructureField</span>" + "<ul>" + "<li>" + "questionMark: " + (if (v.questionMark != null) visToken(v.questionMark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + visTypeHint(v.typeHint) + "</li>" + "</ul>";
	}
	public function visDecl(v:Decl):String {
		return switch v {
			case ClassDecl(annotations, flags, classDecl):"<span class=\"node\">ClassDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "classDecl: " + visClassDecl(classDecl) + "</li>" + "</ul>";
			case TypedefDecl(annotations, flags, typedefKeyword, name, params, assign, type, semicolon):"<span class=\"node\">TypedefDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "typedefKeyword: " + visToken(typedefKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visTypeDeclParameters(params) else none) + "</li>" + "<li>" + "assign: " + visToken(assign) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "<li>" + "semicolon: " + (if (semicolon != null) visToken(semicolon) else none) + "</li>" + "</ul>";
			case EnumDecl(annotations, flags, enumKeyword, name, params, braceOpen, fields, braceClose):"<span class=\"node\">EnumDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "enumKeyword: " + visToken(enumKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visTypeDeclParameters(params) else none) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visArray(fields, function(el) return visNEnumField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case UsingDecl(usingKeyword, path, semicolon):"<span class=\"node\">UsingDecl</span>" + "<ul>" + "<li>" + "usingKeyword: " + visToken(usingKeyword) + "</li>" + "<li>" + "path: " + visNPath(path) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case AbstractDecl(annotations, flags, abstractKeyword, name, params, underlyingType, relations, braceOpen, fields, braceClose):"<span class=\"node\">AbstractDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "abstractKeyword: " + visToken(abstractKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visTypeDeclParameters(params) else none) + "</li>" + "<li>" + "underlyingType: " + (if (underlyingType != null) visUnderlyingType(underlyingType) else none) + "</li>" + "<li>" + "relations: " + visArray(relations, function(el) return visAbstractRelation(el)) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visArray(fields, function(el) return visClassField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case ImportDecl(importKeyword, path, mode, semicolon):"<span class=\"node\">ImportDecl</span>" + "<ul>" + "<li>" + "importKeyword: " + visToken(importKeyword) + "</li>" + "<li>" + "path: " + visNPath(path) + "</li>" + "<li>" + "mode: " + visImportMode(mode) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
		};
	}
	public function visClassDecl(v:ClassDecl):String {
		return "<span class=\"node\">ClassDecl</span>" + "<ul>" + "<li>" + "kind: " + visToken(v.kind) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "relations: " + visArray(v.relations, function(el) return visClassRelation(el)) + "</li>" + "<li>" + "braceOpen: " + visToken(v.braceOpen) + "</li>" + "<li>" + "fields: " + visArray(v.fields, function(el) return visClassField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(v.braceClose) + "</li>" + "</ul>";
	}
	public function visNEnumField(v:NEnumField):String {
		return "<span class=\"node\">NEnumField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "args: " + (if (v.args != null) visNEnumFieldArgs(v.args) else none) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visTypeHint(v.typeHint) else none) + "</li>" + "<li>" + "semicolon: " + visToken(v.semicolon) + "</li>" + "</ul>";
	}
	public function visImportMode(v:ImportMode):String {
		return switch v {
			case IIn(inKeyword, ident):"<span class=\"node\">IIn</span>" + "<ul>" + "<li>" + "inKeyword: " + visToken(inKeyword) + "</li>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case INormal:"INormal";
			case IAll(dotStar):"<span class=\"node\">IAll</span>" + "<ul>" + "<li>" + "dotStar: " + visToken(dotStar) + "</li>" + "</ul>";
			case IAs(asKeyword, ident):"<span class=\"node\">IAs</span>" + "<ul>" + "<li>" + "asKeyword: " + visToken(asKeyword) + "</li>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
		};
	}
	public function visNPath(v:NPath):String {
		return "<span class=\"node\">NPath</span>" + "<ul>" + "<li>" + "ident: " + visToken(v.ident) + "</li>" + "<li>" + "idents: " + visArray(v.idents, function(el) return visNDotIdent(el)) + "</li>" + "</ul>";
	}
	public function visFile(v:File):String {
		return "<span class=\"node\">File</span>" + "<ul>" + "<li>" + "pack: " + (if (v.pack != null) visPackage(v.pack) else none) + "</li>" + "<li>" + "decls: " + visArray(v.decls, function(el) return visDecl(el)) + "</li>" + "<li>" + "eof: " + visToken(v.eof) + "</li>" + "</ul>";
	}
	public function visMethodExpr(v:MethodExpr):String {
		return switch v {
			case None(semicolon):"<span class=\"node\">None</span>" + "<ul>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case Expr(expr, semicolon):"<span class=\"node\">Expr</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case Block(expr):"<span class=\"node\">Block</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
		};
	}
	public function visNEnumFieldArg(v:NEnumFieldArg):String {
		return "<span class=\"node\">NEnumFieldArg</span>" + "<ul>" + "<li>" + "questionMark: " + (if (v.questionMark != null) visToken(v.questionMark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + visTypeHint(v.typeHint) + "</li>" + "</ul>";
	}
	public function visClassRelation(v:ClassRelation):String {
		return switch v {
			case Extends(extendsKeyword, path):"<span class=\"node\">Extends</span>" + "<ul>" + "<li>" + "extendsKeyword: " + visToken(extendsKeyword) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "</ul>";
			case Implements(implementsKeyword, path):"<span class=\"node\">Implements</span>" + "<ul>" + "<li>" + "implementsKeyword: " + visToken(implementsKeyword) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "</ul>";
		};
	}
	public function visStringToken(v:StringToken):String {
		return switch v {
			case SingleQuote(token):"<span class=\"node\">SingleQuote</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case DoubleQuote(token):"<span class=\"node\">DoubleQuote</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
		};
	}
	public function visStructuralExtension(v:StructuralExtension):String {
		return "<span class=\"node\">StructuralExtension</span>" + "<ul>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "<li>" + "path: " + visTypePath(v.path) + "</li>" + "<li>" + "comma: " + visToken(v.comma) + "</li>" + "</ul>";
	}
	public function visVarDecl(v:VarDecl):String {
		return "<span class=\"node\">VarDecl</span>" + "<ul>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visTypeHint(v.typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visAssignment(v.assignment) else none) + "</li>" + "</ul>";
	}
	public function visNAnnotations(v:NAnnotations):String {
		return "<span class=\"node\">NAnnotations</span>" + "<ul>" + "<li>" + "doc: " + (if (v.doc != null) visToken(v.doc) else none) + "</li>" + "<li>" + "metadata: " + visArray(v.metadata, function(el) return visMetadata(el)) + "</li>" + "</ul>";
	}
	public function visUnderlyingType(v:UnderlyingType):String {
		return "<span class=\"node\">UnderlyingType</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "type: " + visComplexType(v.type) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
	public function visPackage(v:Package):String {
		return "<span class=\"node\">Package</span>" + "<ul>" + "<li>" + "packageKeyword: " + visToken(v.packageKeyword) + "</li>" + "<li>" + "path: " + (if (v.path != null) visNPath(v.path) else none) + "</li>" + "<li>" + "semicolon: " + visToken(v.semicolon) + "</li>" + "</ul>";
	}
	public function visNDotIdent(v:NDotIdent):String {
		return switch v {
			case PDotIdent(name):"<span class=\"node\">PDotIdent</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "</ul>";
			case PDot(dot):"<span class=\"node\">PDot</span>" + "<ul>" + "<li>" + "dot: " + visToken(dot) + "</li>" + "</ul>";
		};
	}
	public function visCase(v:Case):String {
		return switch v {
			case Default(defaultKeyword, colon, body):"<span class=\"node\">Default</span>" + "<ul>" + "<li>" + "defaultKeyword: " + visToken(defaultKeyword) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "body: " + visArray(body, function(el) return visBlockElement(el)) + "</li>" + "</ul>";
			case Case(caseKeyword, patterns, guard, colon, body):"<span class=\"node\">Case</span>" + "<ul>" + "<li>" + "caseKeyword: " + visToken(caseKeyword) + "</li>" + "<li>" + "patterns: " + visCommaSeparated(patterns, function(el) return visExpr(el)) + "</li>" + "<li>" + "guard: " + (if (guard != null) visGuard(guard) else none) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "body: " + visArray(body, function(el) return visBlockElement(el)) + "</li>" + "</ul>";
		};
	}
	public function visFunction(v:Function):String {
		return "<span class=\"node\">Function</span>" + "<ul>" + "<li>" + "name: " + (if (v.name != null) visToken(v.name) else none) + "</li>" + "<li>" + "params: " + (if (v.params != null) visTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visFunctionArgument(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visTypeHint(v.typeHint) else none) + "</li>" + "<li>" + "expr: " + visExpr(v.expr) + "</li>" + "</ul>";
	}
	public function visExpr(v:Expr):String {
		return switch v {
			case EIs(parenOpen, expr, isKeyword, path, parenClose):"<span class=\"node\">EIs</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "isKeyword: " + visToken(isKeyword) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case EMetadata(metadata, expr):"<span class=\"node\">EMetadata</span>" + "<ul>" + "<li>" + "metadata: " + visMetadata(metadata) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
			case EField(expr, ident):"<span class=\"node\">EField</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "ident: " + visNDotIdent(ident) + "</li>" + "</ul>";
			case EMacro(macroKeyword, expr):"<span class=\"node\">EMacro</span>" + "<ul>" + "<li>" + "macroKeyword: " + visToken(macroKeyword) + "</li>" + "<li>" + "expr: " + visMacroExpr(expr) + "</li>" + "</ul>";
			case ESwitch(switchKeyword, expr, braceOpen, cases, braceClose):"<span class=\"node\">ESwitch</span>" + "<ul>" + "<li>" + "switchKeyword: " + visToken(switchKeyword) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "cases: " + visArray(cases, function(el) return visCase(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case EReturnExpr(returnKeyword, expr):"<span class=\"node\">EReturnExpr</span>" + "<ul>" + "<li>" + "returnKeyword: " + visToken(returnKeyword) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
			case EUnsafeCast(castKeyword, expr):"<span class=\"node\">EUnsafeCast</span>" + "<ul>" + "<li>" + "castKeyword: " + visToken(castKeyword) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
			case EIn(exprLeft, inKeyword, exprRight):"<span class=\"node\">EIn</span>" + "<ul>" + "<li>" + "exprLeft: " + visExpr(exprLeft) + "</li>" + "<li>" + "inKeyword: " + visToken(inKeyword) + "</li>" + "<li>" + "exprRight: " + visExpr(exprRight) + "</li>" + "</ul>";
			case EParenthesis(parenOpen, expr, parenClose):"<span class=\"node\">EParenthesis</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case ESafeCast(castKeyword, parenOpen, expr, comma, type, parenClose):"<span class=\"node\">ESafeCast</span>" + "<ul>" + "<li>" + "castKeyword: " + visToken(castKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "comma: " + visToken(comma) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case EIf(ifKeyword, parenOpen, exprCond, parenClose, exprThen, exprElse):"<span class=\"node\">EIf</span>" + "<ul>" + "<li>" + "ifKeyword: " + visToken(ifKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "exprCond: " + visExpr(exprCond) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "exprThen: " + visExpr(exprThen) + "</li>" + "<li>" + "exprElse: " + (if (exprElse != null) visExprElse(exprElse) else none) + "</li>" + "</ul>";
			case EBlock(braceOpen, elems, braceClose):"<span class=\"node\">EBlock</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "elems: " + visArray(elems, function(el) return visBlockElement(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case EUnaryPrefix(op, expr):"<span class=\"node\">EUnaryPrefix</span>" + "<ul>" + "<li>" + "op: " + visToken(op) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
			case EBinop(exprLeft, op, exprRight):"<span class=\"node\">EBinop</span>" + "<ul>" + "<li>" + "exprLeft: " + visExpr(exprLeft) + "</li>" + "<li>" + "op: " + visToken(op) + "</li>" + "<li>" + "exprRight: " + visExpr(exprRight) + "</li>" + "</ul>";
			case ETry(tryKeyword, expr, catches):"<span class=\"node\">ETry</span>" + "<ul>" + "<li>" + "tryKeyword: " + visToken(tryKeyword) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "catches: " + visArray(catches, function(el) return visCatch(el)) + "</li>" + "</ul>";
			case EObjectDecl(braceOpen, fields, braceClose):"<span class=\"node\">EObjectDecl</span>" + "<ul>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "fields: " + visCommaSeparatedTrailing(fields, function(el) return visObjectField(el)) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case EVar(varKeyword, decl):"<span class=\"node\">EVar</span>" + "<ul>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "decl: " + visVarDecl(decl) + "</li>" + "</ul>";
			case EBreak(breakKeyword):"<span class=\"node\">EBreak</span>" + "<ul>" + "<li>" + "breakKeyword: " + visToken(breakKeyword) + "</li>" + "</ul>";
			case EFor(forKeyword, parenOpen, exprIter, parenClose, exprBody):"<span class=\"node\">EFor</span>" + "<ul>" + "<li>" + "forKeyword: " + visToken(forKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "exprIter: " + visExpr(exprIter) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "exprBody: " + visExpr(exprBody) + "</li>" + "</ul>";
			case ENew(newKeyword, path, args):"<span class=\"node\">ENew</span>" + "<ul>" + "<li>" + "newKeyword: " + visToken(newKeyword) + "</li>" + "<li>" + "path: " + visTypePath(path) + "</li>" + "<li>" + "args: " + visCallArgs(args) + "</li>" + "</ul>";
			case ECall(expr, args):"<span class=\"node\">ECall</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "args: " + visCallArgs(args) + "</li>" + "</ul>";
			case ECheckType(parenOpen, expr, colon, type, parenClose):"<span class=\"node\">ECheckType</span>" + "<ul>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case EContinue(continueKeyword):"<span class=\"node\">EContinue</span>" + "<ul>" + "<li>" + "continueKeyword: " + visToken(continueKeyword) + "</li>" + "</ul>";
			case EUnaryPostfix(expr, op):"<span class=\"node\">EUnaryPostfix</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "op: " + visToken(op) + "</li>" + "</ul>";
			case EArrayAccess(expr, bracketOpen, exprKey, bracketClose):"<span class=\"node\">EArrayAccess</span>" + "<ul>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "bracketOpen: " + visToken(bracketOpen) + "</li>" + "<li>" + "exprKey: " + visExpr(exprKey) + "</li>" + "<li>" + "bracketClose: " + visToken(bracketClose) + "</li>" + "</ul>";
			case ETernary(exprCond, questionMark, exprThen, colon, exprElse):"<span class=\"node\">ETernary</span>" + "<ul>" + "<li>" + "exprCond: " + visExpr(exprCond) + "</li>" + "<li>" + "questionMark: " + visToken(questionMark) + "</li>" + "<li>" + "exprThen: " + visExpr(exprThen) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "exprElse: " + visExpr(exprElse) + "</li>" + "</ul>";
			case EDo(doKeyword, exprBody, whileKeyword, parenOpen, exprCond, parenClose):"<span class=\"node\">EDo</span>" + "<ul>" + "<li>" + "doKeyword: " + visToken(doKeyword) + "</li>" + "<li>" + "exprBody: " + visExpr(exprBody) + "</li>" + "<li>" + "whileKeyword: " + visToken(whileKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "exprCond: " + visExpr(exprCond) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case EMacroEscape(ident, braceOpen, expr, braceClose):"<span class=\"node\">EMacroEscape</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "<li>" + "braceOpen: " + visToken(braceOpen) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "<li>" + "braceClose: " + visToken(braceClose) + "</li>" + "</ul>";
			case EConst(const):"<span class=\"node\">EConst</span>" + "<ul>" + "<li>" + "const: " + visNConst(const) + "</li>" + "</ul>";
			case EDollarIdent(ident):"<span class=\"node\">EDollarIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case EFunction(functionKeyword, fun):"<span class=\"node\">EFunction</span>" + "<ul>" + "<li>" + "functionKeyword: " + visToken(functionKeyword) + "</li>" + "<li>" + "fun: " + visFunction(fun) + "</li>" + "</ul>";
			case EReturn(returnKeyword):"<span class=\"node\">EReturn</span>" + "<ul>" + "<li>" + "returnKeyword: " + visToken(returnKeyword) + "</li>" + "</ul>";
			case EWhile(whileKeyword, parenOpen, exprCond, parenClose, exprBody):"<span class=\"node\">EWhile</span>" + "<ul>" + "<li>" + "whileKeyword: " + visToken(whileKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "exprCond: " + visExpr(exprCond) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "exprBody: " + visExpr(exprBody) + "</li>" + "</ul>";
			case EArrayDecl(bracketOpen, elems, bracketClose):"<span class=\"node\">EArrayDecl</span>" + "<ul>" + "<li>" + "bracketOpen: " + visToken(bracketOpen) + "</li>" + "<li>" + "elems: " + (if (elems != null) visCommaSeparatedTrailing(elems, function(el) return visExpr(el)) else none) + "</li>" + "<li>" + "bracketClose: " + visToken(bracketClose) + "</li>" + "</ul>";
			case EIntDot(int, dot):"<span class=\"node\">EIntDot</span>" + "<ul>" + "<li>" + "int: " + visToken(int) + "</li>" + "<li>" + "dot: " + visToken(dot) + "</li>" + "</ul>";
			case EThrow(throwKeyword, expr):"<span class=\"node\">EThrow</span>" + "<ul>" + "<li>" + "throwKeyword: " + visToken(throwKeyword) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
			case EUntyped(untypedKeyword, expr):"<span class=\"node\">EUntyped</span>" + "<ul>" + "<li>" + "untypedKeyword: " + visToken(untypedKeyword) + "</li>" + "<li>" + "expr: " + visExpr(expr) + "</li>" + "</ul>";
		};
	}
	public function visTypePath(v:TypePath):String {
		return "<span class=\"node\">TypePath</span>" + "<ul>" + "<li>" + "path: " + visNPath(v.path) + "</li>" + "<li>" + "params: " + (if (v.params != null) visTypePathParameters(v.params) else none) + "</li>" + "</ul>";
	}
	public function visObjectFieldName(v:ObjectFieldName):String {
		return switch v {
			case NString(string):"<span class=\"node\">NString</span>" + "<ul>" + "<li>" + "string: " + visStringToken(string) + "</li>" + "</ul>";
			case NIdent(ident):"<span class=\"node\">NIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
		};
	}
	public function visClassField(v:ClassField):String {
		return switch v {
			case Property(annotations, modifiers, varKeyword, name, parenOpen, read, comma, write, parenClose, typeHint, assignment, semicolon):"<span class=\"node\">Property</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visFieldModifier(el)) + "</li>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "read: " + visToken(read) + "</li>" + "<li>" + "comma: " + visToken(comma) + "</li>" + "<li>" + "write: " + visToken(write) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visTypeHint(typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visAssignment(assignment) else none) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case Variable(annotations, modifiers, varKeyword, name, typeHint, assignment, semicolon):"<span class=\"node\">Variable</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visFieldModifier(el)) + "</li>" + "<li>" + "varKeyword: " + visToken(varKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visTypeHint(typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visAssignment(assignment) else none) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case Function(annotations, modifiers, functionKeyword, name, params, parenOpen, args, parenClose, typeHint, expr):"<span class=\"node\">Function</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visFieldModifier(el)) + "</li>" + "<li>" + "functionKeyword: " + visToken(functionKeyword) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visTypeDeclParameters(params) else none) + "</li>" + "<li>" + "parenOpen: " + visToken(parenOpen) + "</li>" + "<li>" + "args: " + (if (args != null) visCommaSeparated(args, function(el) return visFunctionArgument(el)) else none) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visTypeHint(typeHint) else none) + "</li>" + "<li>" + "expr: " + visMethodExpr(expr) + "</li>" + "</ul>";
		};
	}
	public function visMetadata(v:Metadata):String {
		return switch v {
			case WithArgs(name, args, parenClose):"<span class=\"node\">WithArgs</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "args: " + visCommaSeparated(args, function(el) return visExpr(el)) + "</li>" + "<li>" + "parenClose: " + visToken(parenClose) + "</li>" + "</ul>";
			case Simple(name):"<span class=\"node\">Simple</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "</ul>";
		};
	}
	public function visTypeDeclParameters(v:TypeDeclParameters):String {
		return "<span class=\"node\">TypeDeclParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(v.lt) + "</li>" + "<li>" + "params: " + visCommaSeparated(v.params, function(el) return visTypeDeclParameter(el)) + "</li>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "</ul>";
	}
	public function visTypePathParameter(v:TypePathParameter):String {
		return switch v {
			case Type(type):"<span class=\"node\">Type</span>" + "<ul>" + "<li>" + "type: " + visComplexType(type) + "</li>" + "</ul>";
			case Literal(literal):"<span class=\"node\">Literal</span>" + "<ul>" + "<li>" + "literal: " + visLiteral(literal) + "</li>" + "</ul>";
			case ArrayExpr(bracketOpen, elems, bracketClose):"<span class=\"node\">ArrayExpr</span>" + "<ul>" + "<li>" + "bracketOpen: " + visToken(bracketOpen) + "</li>" + "<li>" + "elems: " + (if (elems != null) visCommaSeparatedTrailing(elems, function(el) return visExpr(el)) else none) + "</li>" + "<li>" + "bracketClose: " + visToken(bracketClose) + "</li>" + "</ul>";
		};
	}
	public function visGuard(v:Guard):String {
		return "<span class=\"node\">Guard</span>" + "<ul>" + "<li>" + "ifKeyword: " + visToken(v.ifKeyword) + "</li>" + "<li>" + "parenOpen: " + visToken(v.parenOpen) + "</li>" + "<li>" + "expr: " + visExpr(v.expr) + "</li>" + "<li>" + "parenClose: " + visToken(v.parenClose) + "</li>" + "</ul>";
	}
}