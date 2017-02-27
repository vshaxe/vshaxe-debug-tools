package hxParserVis;

import hxParser.ParseTree;

using StringTools;

class Vis {
	static public var none = '<span class=\"none\">&lt;none&gt;</span>';
	static public function visToken(ctx:SyntaxTreePrinter, t:Token):String {
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
	static public function visArray<T>(ctx:SyntaxTreePrinter, c:Array<T>, vis:T -> String):String {
		var parts = [for (el in c) "<li>" + vis(el) + "</li>"];
		return if (parts.length == 0) none else "<ul>" + parts.join("") + "</ul>";
	}
	static public function visCommaSeparated<T>(ctx:SyntaxTreePrinter, c:NCommaSeparated<T>, vis:T -> String):String {
		var parts = [vis(c.arg)];
		for (el in c.args) {
			parts.push(visToken(ctx, el.comma));
			parts.push(vis(el.arg));
		};
		return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
	}
	static public function visCommaSeparatedTrailing<T>(ctx:SyntaxTreePrinter, c:NCommaSeparatedAllowTrailing<T>, vis:T -> String):String {
		var parts = [vis(c.arg)];
		for (el in c.args) {
			parts.push(visToken(ctx, el.comma));
			parts.push(vis(el.arg));
		};
		if (c.comma != null) parts.push(visToken(ctx, c.comma));
		return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
	}
	static public function visNFile(ctx:SyntaxTreePrinter, v:NFile):String {
		return "<span class=\"node\">NFile</span>" + "<ul>" + "<li>" + "pack: " + (if (v.pack != null) visNPackage(ctx, v.pack) else none) + "</li>" + "<li>" + "decls: " + visArray(ctx, v.decls, function(el) return visNDecl(ctx, el)) + "</li>" + "<li>" + "eof: " + visToken(ctx, v.eof) + "</li>" + "</ul>";
	}
	static public function visNPackage(ctx:SyntaxTreePrinter, v:NPackage):String {
		return "<span class=\"node\">NPackage</span>" + "<ul>" + "<li>" + "_package: " + visToken(ctx, v._package) + "</li>" + "<li>" + "path: " + (if (v.path != null) visNPath(ctx, v.path) else none) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, v.semicolon) + "</li>" + "</ul>";
	}
	static public function visNImportMode(ctx:SyntaxTreePrinter, v:NImportMode):String {
		return switch v {
			case PAsMode(_as, ident):"<span class=\"node\">PAsMode</span>" + "<ul>" + "<li>" + "_as: " + visToken(ctx, _as) + "</li>" + "<li>" + "ident: " + visToken(ctx, ident) + "</li>" + "</ul>";
			case PNormalMode:"PNormalMode";
			case PInMode(_in, ident):"<span class=\"node\">PInMode</span>" + "<ul>" + "<li>" + "_in: " + visToken(ctx, _in) + "</li>" + "<li>" + "ident: " + visToken(ctx, ident) + "</li>" + "</ul>";
			case PAllMode(dotstar):"<span class=\"node\">PAllMode</span>" + "<ul>" + "<li>" + "dotstar: " + visToken(ctx, dotstar) + "</li>" + "</ul>";
		};
	}
	static public function visNLiteral(ctx:SyntaxTreePrinter, v:NLiteral):String {
		return switch v {
			case PLiteralString(s):"<span class=\"node\">PLiteralString</span>" + "<ul>" + "<li>" + "s: " + visNString(ctx, s) + "</li>" + "</ul>";
			case PLiteralFloat(token):"<span class=\"node\">PLiteralFloat</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PLiteralRegex(token):"<span class=\"node\">PLiteralRegex</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PLiteralInt(token):"<span class=\"node\">PLiteralInt</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
		};
	}
	static public function visNAssignment(ctx:SyntaxTreePrinter, v:NAssignment):String {
		return "<span class=\"node\">NAssignment</span>" + "<ul>" + "<li>" + "assign: " + visToken(ctx, v.assign) + "</li>" + "<li>" + "e: " + visNExpr(ctx, v.e) + "</li>" + "</ul>";
	}
	static public function visNObjectFieldName(ctx:SyntaxTreePrinter, v:NObjectFieldName):String {
		return switch v {
			case PString(string):"<span class=\"node\">PString</span>" + "<ul>" + "<li>" + "string: " + visNString(ctx, string) + "</li>" + "</ul>";
			case PIdent(ident):"<span class=\"node\">PIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ctx, ident) + "</li>" + "</ul>";
		};
	}
	static public function visNAbstractRelation(ctx:SyntaxTreePrinter, v:NAbstractRelation):String {
		return switch v {
			case PFrom(_from, type):"<span class=\"node\">PFrom</span>" + "<ul>" + "<li>" + "_from: " + visToken(ctx, _from) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "</ul>";
			case PTo(_to, type):"<span class=\"node\">PTo</span>" + "<ul>" + "<li>" + "_to: " + visToken(ctx, _to) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "</ul>";
		};
	}
	static public function visNTypeHint(ctx:SyntaxTreePrinter, v:NTypeHint):String {
		return "<span class=\"node\">NTypeHint</span>" + "<ul>" + "<li>" + "colon: " + visToken(ctx, v.colon) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, v.type) + "</li>" + "</ul>";
	}
	static public function visNClassDecl(ctx:SyntaxTreePrinter, v:NClassDecl):String {
		return "<span class=\"node\">NClassDecl</span>" + "<ul>" + "<li>" + "kind: " + visToken(ctx, v.kind) + "</li>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(ctx, v.params) else none) + "</li>" + "<li>" + "relations: " + visArray(ctx, v.relations, function(el) return visNClassRelation(ctx, el)) + "</li>" + "<li>" + "bropen: " + visToken(ctx, v.bropen) + "</li>" + "<li>" + "fields: " + visArray(ctx, v.fields, function(el) return visNClassField(ctx, el)) + "</li>" + "<li>" + "brclose: " + visToken(ctx, v.brclose) + "</li>" + "</ul>";
	}
	static public function visNCatch(ctx:SyntaxTreePrinter, v:NCatch):String {
		return "<span class=\"node\">NCatch</span>" + "<ul>" + "<li>" + "_catch: " + visToken(ctx, v._catch) + "</li>" + "<li>" + "popen: " + visToken(ctx, v.popen) + "</li>" + "<li>" + "ident: " + visToken(ctx, v.ident) + "</li>" + "<li>" + "type: " + visNTypeHint(ctx, v.type) + "</li>" + "<li>" + "pclose: " + visToken(ctx, v.pclose) + "</li>" + "<li>" + "e: " + visNExpr(ctx, v.e) + "</li>" + "</ul>";
	}
	static public function visNTypeDeclParameter(ctx:SyntaxTreePrinter, v:NTypeDeclParameter):String {
		return "<span class=\"node\">NTypeDeclParameter</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, v.annotations) + "</li>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "constraints: " + visNConstraints(ctx, v.constraints) + "</li>" + "</ul>";
	}
	static public function visNConst(ctx:SyntaxTreePrinter, v:NConst):String {
		return switch v {
			case PConstLiteral(literal):"<span class=\"node\">PConstLiteral</span>" + "<ul>" + "<li>" + "literal: " + visNLiteral(ctx, literal) + "</li>" + "</ul>";
			case PConstIdent(ident):"<span class=\"node\">PConstIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ctx, ident) + "</li>" + "</ul>";
		};
	}
	static public function visNTypePathParameters(ctx:SyntaxTreePrinter, v:NTypePathParameters):String {
		return "<span class=\"node\">NTypePathParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(ctx, v.lt) + "</li>" + "<li>" + "parameters: " + visCommaSeparated(ctx, v.parameters, function(el) return visNTypePathParameter(ctx, el)) + "</li>" + "<li>" + "gt: " + visToken(ctx, v.gt) + "</li>" + "</ul>";
	}
	static public function visNModifier(ctx:SyntaxTreePrinter, v:NModifier):String {
		return switch v {
			case PModifierStatic(token):"<span class=\"node\">PModifierStatic</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierOverride(token):"<span class=\"node\">PModifierOverride</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierMacro(token):"<span class=\"node\">PModifierMacro</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierDynamic(token):"<span class=\"node\">PModifierDynamic</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierInline(token):"<span class=\"node\">PModifierInline</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierPrivate(token):"<span class=\"node\">PModifierPrivate</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierPublic(token):"<span class=\"node\">PModifierPublic</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
		};
	}
	static public function visNFieldExpr(ctx:SyntaxTreePrinter, v:NFieldExpr):String {
		return switch v {
			case PNoFieldExpr(semicolon):"<span class=\"node\">PNoFieldExpr</span>" + "<ul>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PBlockFieldExpr(e):"<span class=\"node\">PBlockFieldExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PExprFieldExpr(e, semicolon):"<span class=\"node\">PExprFieldExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
		};
	}
	static public function visNCommonFlag(ctx:SyntaxTreePrinter, v:NCommonFlag):String {
		return switch v {
			case PExtern(token):"<span class=\"node\">PExtern</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
			case PPrivate(token):"<span class=\"node\">PPrivate</span>" + "<ul>" + "<li>" + "token: " + visToken(ctx, token) + "</li>" + "</ul>";
		};
	}
	static public function visNEnumFieldArgs(ctx:SyntaxTreePrinter, v:NEnumFieldArgs):String {
		return "<span class=\"node\">NEnumFieldArgs</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(ctx, v.args, function(el) return visNEnumFieldArg(ctx, el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
	static public function visNFunctionArgument(ctx:SyntaxTreePrinter, v:NFunctionArgument):String {
		return "<span class=\"node\">NFunctionArgument</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, v.annotations) + "</li>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(ctx, v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visNTypeHint(ctx, v.typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visNAssignment(ctx, v.assignment) else none) + "</li>" + "</ul>";
	}
	static public function visNAnonymousTypeField(ctx:SyntaxTreePrinter, v:NAnonymousTypeField):String {
		return "<span class=\"node\">NAnonymousTypeField</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(ctx, v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "typeHint: " + visNTypeHint(ctx, v.typeHint) + "</li>" + "</ul>";
	}
	static public function visNUnderlyingType(ctx:SyntaxTreePrinter, v:NUnderlyingType):String {
		return "<span class=\"node\">NUnderlyingType</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, v.popen) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, v.type) + "</li>" + "<li>" + "pclose: " + visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
	static public function visNTypePathParameter(ctx:SyntaxTreePrinter, v:NTypePathParameter):String {
		return switch v {
			case PArrayExprTypePathParameter(bkopen, el, bkclose):"<span class=\"node\">PArrayExprTypePathParameter</span>" + "<ul>" + "<li>" + "bkopen: " + visToken(ctx, bkopen) + "</li>" + "<li>" + "el: " + (if (el != null) visCommaSeparatedTrailing(ctx, el, function(el) return visNExpr(ctx, el)) else none) + "</li>" + "<li>" + "bkclose: " + visToken(ctx, bkclose) + "</li>" + "</ul>";
			case PConstantTypePathParameter(constant):"<span class=\"node\">PConstantTypePathParameter</span>" + "<ul>" + "<li>" + "constant: " + visNLiteral(ctx, constant) + "</li>" + "</ul>";
			case PTypeTypePathParameter(type):"<span class=\"node\">PTypeTypePathParameter</span>" + "<ul>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "</ul>";
		};
	}
	static public function visNTypeDeclParameters(ctx:SyntaxTreePrinter, v:NTypeDeclParameters):String {
		return "<span class=\"node\">NTypeDeclParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(ctx, v.lt) + "</li>" + "<li>" + "params: " + visCommaSeparated(ctx, v.params, function(el) return visNTypeDeclParameter(ctx, el)) + "</li>" + "<li>" + "gt: " + visToken(ctx, v.gt) + "</li>" + "</ul>";
	}
	static public function visNGuard(ctx:SyntaxTreePrinter, v:NGuard):String {
		return "<span class=\"node\">NGuard</span>" + "<ul>" + "<li>" + "_if: " + visToken(ctx, v._if) + "</li>" + "<li>" + "popen: " + visToken(ctx, v.popen) + "</li>" + "<li>" + "e: " + visNExpr(ctx, v.e) + "</li>" + "<li>" + "pclose: " + visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
	static public function visNMacroExpr(ctx:SyntaxTreePrinter, v:NMacroExpr):String {
		return switch v {
			case PVar(_var, v):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(ctx, _var) + "</li>" + "<li>" + "v: " + visCommaSeparated(ctx, v, function(el) return visNVarDeclaration(ctx, el)) + "</li>" + "</ul>";
			case PTypeHint(type):"<span class=\"node\">PTypeHint</span>" + "<ul>" + "<li>" + "type: " + visNTypeHint(ctx, type) + "</li>" + "</ul>";
			case PClass(c):"<span class=\"node\">PClass</span>" + "<ul>" + "<li>" + "c: " + visNClassDecl(ctx, c) + "</li>" + "</ul>";
			case PExpr(e):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
		};
	}
	static public function visNEnumField(ctx:SyntaxTreePrinter, v:NEnumField):String {
		return "<span class=\"node\">NEnumField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, v.annotations) + "</li>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(ctx, v.params) else none) + "</li>" + "<li>" + "args: " + (if (v.args != null) visNEnumFieldArgs(ctx, v.args) else none) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(ctx, v.type) else none) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, v.semicolon) + "</li>" + "</ul>";
	}
	static public function visNPath(ctx:SyntaxTreePrinter, v:NPath):String {
		return "<span class=\"node\">NPath</span>" + "<ul>" + "<li>" + "ident: " + visToken(ctx, v.ident) + "</li>" + "<li>" + "idents: " + visArray(ctx, v.idents, function(el) return visNDotIdent(ctx, el)) + "</li>" + "</ul>";
	}
	static public function visNDecl(ctx:SyntaxTreePrinter, v:NDecl):String {
		return switch v {
			case PClassDecl(annotations, flags, c):"<span class=\"node\">PClassDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "flags: " + visArray(ctx, flags, function(el) return visNCommonFlag(ctx, el)) + "</li>" + "<li>" + "c: " + visNClassDecl(ctx, c) + "</li>" + "</ul>";
			case PTypedefDecl(annotations, flags, _typedef, name, params, assign, type, semicolon):"<span class=\"node\">PTypedefDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "flags: " + visArray(ctx, flags, function(el) return visNCommonFlag(ctx, el)) + "</li>" + "<li>" + "_typedef: " + visToken(ctx, _typedef) + "</li>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(ctx, params) else none) + "</li>" + "<li>" + "assign: " + visToken(ctx, assign) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "<li>" + "semicolon: " + (if (semicolon != null) visToken(ctx, semicolon) else none) + "</li>" + "</ul>";
			case PUsingDecl(_using, path, semicolon):"<span class=\"node\">PUsingDecl</span>" + "<ul>" + "<li>" + "_using: " + visToken(ctx, _using) + "</li>" + "<li>" + "path: " + visNPath(ctx, path) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PImportDecl(_import, importPath, semicolon):"<span class=\"node\">PImportDecl</span>" + "<ul>" + "<li>" + "_import: " + visToken(ctx, _import) + "</li>" + "<li>" + "importPath: " + visNImport(ctx, importPath) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PAbstractDecl(annotations, flags, _abstract, name, params, underlyingType, relations, bropen, fields, brclose):"<span class=\"node\">PAbstractDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "flags: " + visArray(ctx, flags, function(el) return visNCommonFlag(ctx, el)) + "</li>" + "<li>" + "_abstract: " + visToken(ctx, _abstract) + "</li>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(ctx, params) else none) + "</li>" + "<li>" + "underlyingType: " + (if (underlyingType != null) visNUnderlyingType(ctx, underlyingType) else none) + "</li>" + "<li>" + "relations: " + visArray(ctx, relations, function(el) return visNAbstractRelation(ctx, el)) + "</li>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "fields: " + visArray(ctx, fields, function(el) return visNClassField(ctx, el)) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PEnumDecl(annotations, flags, _enum, name, params, bropen, fields, brclose):"<span class=\"node\">PEnumDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "flags: " + visArray(ctx, flags, function(el) return visNCommonFlag(ctx, el)) + "</li>" + "<li>" + "_enum: " + visToken(ctx, _enum) + "</li>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(ctx, params) else none) + "</li>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "fields: " + visArray(ctx, fields, function(el) return visNEnumField(ctx, el)) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
		};
	}
	static public function visNConstraints(ctx:SyntaxTreePrinter, v:NConstraints):String {
		return switch v {
			case PMultipleConstraints(colon, popen, types, pclose):"<span class=\"node\">PMultipleConstraints</span>" + "<ul>" + "<li>" + "colon: " + visToken(ctx, colon) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "types: " + visCommaSeparated(ctx, types, function(el) return visNComplexType(ctx, el)) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PSingleConstraint(colon, type):"<span class=\"node\">PSingleConstraint</span>" + "<ul>" + "<li>" + "colon: " + visToken(ctx, colon) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "</ul>";
			case PNoConstraints:"PNoConstraints";
		};
	}
	static public function visNBlockElement(ctx:SyntaxTreePrinter, v:NBlockElement):String {
		return switch v {
			case PVar(_var, vl, semicolon):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(ctx, _var) + "</li>" + "<li>" + "vl: " + visCommaSeparated(ctx, vl, function(el) return visNVarDeclaration(ctx, el)) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PExpr(e, semicolon):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PInlineFunction(_inline, _function, f, semicolon):"<span class=\"node\">PInlineFunction</span>" + "<ul>" + "<li>" + "_inline: " + visToken(ctx, _inline) + "</li>" + "<li>" + "_function: " + visToken(ctx, _function) + "</li>" + "<li>" + "f: " + visNFunction(ctx, f) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
		};
	}
	static public function visNClassField(ctx:SyntaxTreePrinter, v:NClassField):String {
		return switch v {
			case PPropertyField(annotations, modifiers, _var, name, popen, get, comma, set, pclose, typeHint, assignment):"<span class=\"node\">PPropertyField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "modifiers: " + visArray(ctx, modifiers, function(el) return visNModifier(ctx, el)) + "</li>" + "<li>" + "_var: " + visToken(ctx, _var) + "</li>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "get: " + visToken(ctx, get) + "</li>" + "<li>" + "comma: " + visToken(ctx, comma) + "</li>" + "<li>" + "set: " + visToken(ctx, set) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(ctx, typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visNAssignment(ctx, assignment) else none) + "</li>" + "</ul>";
			case PVariableField(annotations, modifiers, _var, name, typeHint, assignment, semicolon):"<span class=\"node\">PVariableField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "modifiers: " + visArray(ctx, modifiers, function(el) return visNModifier(ctx, el)) + "</li>" + "<li>" + "_var: " + visToken(ctx, _var) + "</li>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(ctx, typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visNAssignment(ctx, assignment) else none) + "</li>" + "<li>" + "semicolon: " + visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PFunctionField(annotations, modifiers, _function, name, params, popen, args, pclose, typeHint, e):"<span class=\"node\">PFunctionField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(ctx, annotations) + "</li>" + "<li>" + "modifiers: " + visArray(ctx, modifiers, function(el) return visNModifier(ctx, el)) + "</li>" + "<li>" + "_function: " + visToken(ctx, _function) + "</li>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(ctx, params) else none) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "args: " + (if (args != null) visCommaSeparated(ctx, args, function(el) return visNFunctionArgument(ctx, el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(ctx, typeHint) else none) + "</li>" + "<li>" + "e: " + (if (e != null) visNFieldExpr(ctx, e) else none) + "</li>" + "</ul>";
		};
	}
	static public function visNClassRelation(ctx:SyntaxTreePrinter, v:NClassRelation):String {
		return switch v {
			case PExtends(_extends, path):"<span class=\"node\">PExtends</span>" + "<ul>" + "<li>" + "_extends: " + visToken(ctx, _extends) + "</li>" + "<li>" + "path: " + visNTypePath(ctx, path) + "</li>" + "</ul>";
			case PImplements(_implements, path):"<span class=\"node\">PImplements</span>" + "<ul>" + "<li>" + "_implements: " + visToken(ctx, _implements) + "</li>" + "<li>" + "path: " + visNTypePath(ctx, path) + "</li>" + "</ul>";
		};
	}
	static public function visNCase(ctx:SyntaxTreePrinter, v:NCase):String {
		return switch v {
			case PCase(_case, patterns, guard, colon, el):"<span class=\"node\">PCase</span>" + "<ul>" + "<li>" + "_case: " + visToken(ctx, _case) + "</li>" + "<li>" + "patterns: " + visCommaSeparated(ctx, patterns, function(el) return visNExpr(ctx, el)) + "</li>" + "<li>" + "guard: " + (if (guard != null) visNGuard(ctx, guard) else none) + "</li>" + "<li>" + "colon: " + visToken(ctx, colon) + "</li>" + "<li>" + "el: " + visArray(ctx, el, function(el) return visNBlockElement(ctx, el)) + "</li>" + "</ul>";
			case PDefault(_default, colon, el):"<span class=\"node\">PDefault</span>" + "<ul>" + "<li>" + "_default: " + visToken(ctx, _default) + "</li>" + "<li>" + "colon: " + visToken(ctx, colon) + "</li>" + "<li>" + "el: " + visArray(ctx, el, function(el) return visNBlockElement(ctx, el)) + "</li>" + "</ul>";
		};
	}
	static public function visNStructuralExtension(ctx:SyntaxTreePrinter, v:NStructuralExtension):String {
		return "<span class=\"node\">NStructuralExtension</span>" + "<ul>" + "<li>" + "gt: " + visToken(ctx, v.gt) + "</li>" + "<li>" + "path: " + visNTypePath(ctx, v.path) + "</li>" + "<li>" + "comma: " + visToken(ctx, v.comma) + "</li>" + "</ul>";
	}
	static public function visNEnumFieldArg(ctx:SyntaxTreePrinter, v:NEnumFieldArg):String {
		return "<span class=\"node\">NEnumFieldArg</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(ctx, v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "typeHint: " + visNTypeHint(ctx, v.typeHint) + "</li>" + "</ul>";
	}
	static public function visNMetadata(ctx:SyntaxTreePrinter, v:NMetadata):String {
		return switch v {
			case PMetadata(name):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "</ul>";
			case PMetadataWithArgs(name, el, pclose):"<span class=\"node\">PMetadataWithArgs</span>" + "<ul>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "<li>" + "el: " + visCommaSeparated(ctx, el, function(el) return visNExpr(ctx, el)) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
		};
	}
	static public function visNVarDeclaration(ctx:SyntaxTreePrinter, v:NVarDeclaration):String {
		return "<span class=\"node\">NVarDeclaration</span>" + "<ul>" + "<li>" + "name: " + visToken(ctx, v.name) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(ctx, v.type) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visNAssignment(ctx, v.assignment) else none) + "</li>" + "</ul>";
	}
	static public function visNTypePath(ctx:SyntaxTreePrinter, v:NTypePath):String {
		return "<span class=\"node\">NTypePath</span>" + "<ul>" + "<li>" + "path: " + visNPath(ctx, v.path) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypePathParameters(ctx, v.params) else none) + "</li>" + "</ul>";
	}
	static public function visNString(ctx:SyntaxTreePrinter, v:NString):String {
		return switch v {
			case PString(s):"<span class=\"node\">PString</span>" + "<ul>" + "<li>" + "s: " + visToken(ctx, s) + "</li>" + "</ul>";
			case PString2(s):"<span class=\"node\">PString2</span>" + "<ul>" + "<li>" + "s: " + visToken(ctx, s) + "</li>" + "</ul>";
		};
	}
	static public function visNAnnotations(ctx:SyntaxTreePrinter, v:NAnnotations):String {
		return "<span class=\"node\">NAnnotations</span>" + "<ul>" + "<li>" + "doc: " + (if (v.doc != null) visToken(ctx, v.doc) else none) + "</li>" + "<li>" + "meta: " + visArray(ctx, v.meta, function(el) return visNMetadata(ctx, el)) + "</li>" + "</ul>";
	}
	static public function visNExpr(ctx:SyntaxTreePrinter, v:NExpr):String {
		return switch v {
			case PVar(_var, d):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(ctx, _var) + "</li>" + "<li>" + "d: " + visNVarDeclaration(ctx, d) + "</li>" + "</ul>";
			case PConst(const):"<span class=\"node\">PConst</span>" + "<ul>" + "<li>" + "const: " + visNConst(ctx, const) + "</li>" + "</ul>";
			case PDo(_do, e1, _while, popen, e2, pclose):"<span class=\"node\">PDo</span>" + "<ul>" + "<li>" + "_do: " + visToken(ctx, _do) + "</li>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "_while: " + visToken(ctx, _while) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PMacro(_macro, e):"<span class=\"node\">PMacro</span>" + "<ul>" + "<li>" + "_macro: " + visToken(ctx, _macro) + "</li>" + "<li>" + "e: " + visNMacroExpr(ctx, e) + "</li>" + "</ul>";
			case PWhile(_while, popen, e1, pclose, e2):"<span class=\"node\">PWhile</span>" + "<ul>" + "<li>" + "_while: " + visToken(ctx, _while) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "</ul>";
			case PIntDot(int, dot):"<span class=\"node\">PIntDot</span>" + "<ul>" + "<li>" + "int: " + visToken(ctx, int) + "</li>" + "<li>" + "dot: " + visToken(ctx, dot) + "</li>" + "</ul>";
			case PBlock(bropen, elems, brclose):"<span class=\"node\">PBlock</span>" + "<ul>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "elems: " + visArray(ctx, elems, function(el) return visNBlockElement(ctx, el)) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PFunction(_function, f):"<span class=\"node\">PFunction</span>" + "<ul>" + "<li>" + "_function: " + visToken(ctx, _function) + "</li>" + "<li>" + "f: " + visNFunction(ctx, f) + "</li>" + "</ul>";
			case PSwitch(_switch, e, bropen, cases, brclose):"<span class=\"node\">PSwitch</span>" + "<ul>" + "<li>" + "_switch: " + visToken(ctx, _switch) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "cases: " + visArray(ctx, cases, function(el) return visNCase(ctx, el)) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PReturn(_return):"<span class=\"node\">PReturn</span>" + "<ul>" + "<li>" + "_return: " + visToken(ctx, _return) + "</li>" + "</ul>";
			case PArrayDecl(bkopen, el, bkclose):"<span class=\"node\">PArrayDecl</span>" + "<ul>" + "<li>" + "bkopen: " + visToken(ctx, bkopen) + "</li>" + "<li>" + "el: " + (if (el != null) visCommaSeparatedTrailing(ctx, el, function(el) return visNExpr(ctx, el)) else none) + "</li>" + "<li>" + "bkclose: " + visToken(ctx, bkclose) + "</li>" + "</ul>";
			case PDollarIdent(ident):"<span class=\"node\">PDollarIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ctx, ident) + "</li>" + "</ul>";
			case PIf(_if, popen, e1, pclose, e2, elseExpr):"<span class=\"node\">PIf</span>" + "<ul>" + "<li>" + "_if: " + visToken(ctx, _if) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "<li>" + "elseExpr: " + (if (elseExpr != null) visNExprElse(ctx, elseExpr) else none) + "</li>" + "</ul>";
			case PReturnExpr(_return, e):"<span class=\"node\">PReturnExpr</span>" + "<ul>" + "<li>" + "_return: " + visToken(ctx, _return) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PArray(e1, bkopen, e2, bkclose):"<span class=\"node\">PArray</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "bkopen: " + visToken(ctx, bkopen) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "<li>" + "bkclose: " + visToken(ctx, bkclose) + "</li>" + "</ul>";
			case PContinue(_continue):"<span class=\"node\">PContinue</span>" + "<ul>" + "<li>" + "_continue: " + visToken(ctx, _continue) + "</li>" + "</ul>";
			case PParenthesis(popen, e, pclose):"<span class=\"node\">PParenthesis</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PTry(_try, e, catches):"<span class=\"node\">PTry</span>" + "<ul>" + "<li>" + "_try: " + visToken(ctx, _try) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "catches: " + visArray(ctx, catches, function(el) return visNCatch(ctx, el)) + "</li>" + "</ul>";
			case PBreak(_break):"<span class=\"node\">PBreak</span>" + "<ul>" + "<li>" + "_break: " + visToken(ctx, _break) + "</li>" + "</ul>";
			case PCall(e, el):"<span class=\"node\">PCall</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "el: " + visNCallArgs(ctx, el) + "</li>" + "</ul>";
			case PUnaryPostfix(e, op):"<span class=\"node\">PUnaryPostfix</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "op: " + visToken(ctx, op) + "</li>" + "</ul>";
			case PBinop(e1, op, e2):"<span class=\"node\">PBinop</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "op: " + visToken(ctx, op) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "</ul>";
			case PSafeCast(_cast, popen, e, comma, ct, pclose):"<span class=\"node\">PSafeCast</span>" + "<ul>" + "<li>" + "_cast: " + visToken(ctx, _cast) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "comma: " + visToken(ctx, comma) + "</li>" + "<li>" + "ct: " + visNComplexType(ctx, ct) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PUnaryPrefix(op, e):"<span class=\"node\">PUnaryPrefix</span>" + "<ul>" + "<li>" + "op: " + visToken(ctx, op) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PMacroEscape(ident, bropen, e, brclose):"<span class=\"node\">PMacroEscape</span>" + "<ul>" + "<li>" + "ident: " + visToken(ctx, ident) + "</li>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PIn(e1, _in, e2):"<span class=\"node\">PIn</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "_in: " + visToken(ctx, _in) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "</ul>";
			case PMetadata(metadata, e):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "metadata: " + visNMetadata(ctx, metadata) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PUnsafeCast(_cast, e):"<span class=\"node\">PUnsafeCast</span>" + "<ul>" + "<li>" + "_cast: " + visToken(ctx, _cast) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PCheckType(popen, e, colon, type, pclose):"<span class=\"node\">PCheckType</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "colon: " + visToken(ctx, colon) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PUntyped(_untyped, e):"<span class=\"node\">PUntyped</span>" + "<ul>" + "<li>" + "_untyped: " + visToken(ctx, _untyped) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PField(e, ident):"<span class=\"node\">PField</span>" + "<ul>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "ident: " + visNDotIdent(ctx, ident) + "</li>" + "</ul>";
			case PIs(popen, e, _is, path, pclose):"<span class=\"node\">PIs</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "<li>" + "_is: " + visToken(ctx, _is) + "</li>" + "<li>" + "path: " + visNTypePath(ctx, path) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PTernary(e1, questionmark, e2, colon, e3):"<span class=\"node\">PTernary</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "questionmark: " + visToken(ctx, questionmark) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "<li>" + "colon: " + visToken(ctx, colon) + "</li>" + "<li>" + "e3: " + visNExpr(ctx, e3) + "</li>" + "</ul>";
			case PObjectDecl(bropen, fl, brclose):"<span class=\"node\">PObjectDecl</span>" + "<ul>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "fl: " + visCommaSeparatedTrailing(ctx, fl, function(el) return visNObjectField(ctx, el)) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PNew(_new, path, el):"<span class=\"node\">PNew</span>" + "<ul>" + "<li>" + "_new: " + visToken(ctx, _new) + "</li>" + "<li>" + "path: " + visNTypePath(ctx, path) + "</li>" + "<li>" + "el: " + visNCallArgs(ctx, el) + "</li>" + "</ul>";
			case PThrow(_throw, e):"<span class=\"node\">PThrow</span>" + "<ul>" + "<li>" + "_throw: " + visToken(ctx, _throw) + "</li>" + "<li>" + "e: " + visNExpr(ctx, e) + "</li>" + "</ul>";
			case PFor(_for, popen, e1, pclose, e2):"<span class=\"node\">PFor</span>" + "<ul>" + "<li>" + "_for: " + visToken(ctx, _for) + "</li>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "e1: " + visNExpr(ctx, e1) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "<li>" + "e2: " + visNExpr(ctx, e2) + "</li>" + "</ul>";
		};
	}
	static public function visNAnonymousTypeFields(ctx:SyntaxTreePrinter, v:NAnonymousTypeFields):String {
		return switch v {
			case PAnonymousClassFields(fields):"<span class=\"node\">PAnonymousClassFields</span>" + "<ul>" + "<li>" + "fields: " + visArray(ctx, fields, function(el) return visNClassField(ctx, el)) + "</li>" + "</ul>";
			case PAnonymousShortFields(fields):"<span class=\"node\">PAnonymousShortFields</span>" + "<ul>" + "<li>" + "fields: " + (if (fields != null) visCommaSeparatedTrailing(ctx, fields, function(el) return visNAnonymousTypeField(ctx, el)) else none) + "</li>" + "</ul>";
		};
	}
	static public function visNCallArgs(ctx:SyntaxTreePrinter, v:NCallArgs):String {
		return "<span class=\"node\">NCallArgs</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(ctx, v.args, function(el) return visNExpr(ctx, el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
	static public function visNDotIdent(ctx:SyntaxTreePrinter, v:NDotIdent):String {
		return switch v {
			case PDotIdent(name):"<span class=\"node\">PDotIdent</span>" + "<ul>" + "<li>" + "name: " + visToken(ctx, name) + "</li>" + "</ul>";
			case PDot(_dot):"<span class=\"node\">PDot</span>" + "<ul>" + "<li>" + "_dot: " + visToken(ctx, _dot) + "</li>" + "</ul>";
		};
	}
	static public function visNObjectField(ctx:SyntaxTreePrinter, v:NObjectField):String {
		return "<span class=\"node\">NObjectField</span>" + "<ul>" + "<li>" + "name: " + visNObjectFieldName(ctx, v.name) + "</li>" + "<li>" + "colon: " + visToken(ctx, v.colon) + "</li>" + "<li>" + "e: " + visNExpr(ctx, v.e) + "</li>" + "</ul>";
	}
	static public function visNFunction(ctx:SyntaxTreePrinter, v:NFunction):String {
		return "<span class=\"node\">NFunction</span>" + "<ul>" + "<li>" + "ident: " + (if (v.ident != null) visToken(ctx, v.ident) else none) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(ctx, v.params) else none) + "</li>" + "<li>" + "popen: " + visToken(ctx, v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(ctx, v.args, function(el) return visNFunctionArgument(ctx, el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(ctx, v.pclose) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(ctx, v.type) else none) + "</li>" + "<li>" + "e: " + visNExpr(ctx, v.e) + "</li>" + "</ul>";
	}
	static public function visNImport(ctx:SyntaxTreePrinter, v:NImport):String {
		return "<span class=\"node\">NImport</span>" + "<ul>" + "<li>" + "path: " + visNPath(ctx, v.path) + "</li>" + "<li>" + "mode: " + visNImportMode(ctx, v.mode) + "</li>" + "</ul>";
	}
	static public function visNComplexType(ctx:SyntaxTreePrinter, v:NComplexType):String {
		return switch v {
			case PFunctionType(type1, arrow, type2):"<span class=\"node\">PFunctionType</span>" + "<ul>" + "<li>" + "type1: " + visNComplexType(ctx, type1) + "</li>" + "<li>" + "arrow: " + visToken(ctx, arrow) + "</li>" + "<li>" + "type2: " + visNComplexType(ctx, type2) + "</li>" + "</ul>";
			case PStructuralExtension(bropen, types, fields, brclose):"<span class=\"node\">PStructuralExtension</span>" + "<ul>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "types: " + visArray(ctx, types, function(el) return visNStructuralExtension(ctx, el)) + "</li>" + "<li>" + "fields: " + visNAnonymousTypeFields(ctx, fields) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PParenthesisType(popen, ct, pclose):"<span class=\"node\">PParenthesisType</span>" + "<ul>" + "<li>" + "popen: " + visToken(ctx, popen) + "</li>" + "<li>" + "ct: " + visNComplexType(ctx, ct) + "</li>" + "<li>" + "pclose: " + visToken(ctx, pclose) + "</li>" + "</ul>";
			case PAnonymousStructure(bropen, fields, brclose):"<span class=\"node\">PAnonymousStructure</span>" + "<ul>" + "<li>" + "bropen: " + visToken(ctx, bropen) + "</li>" + "<li>" + "fields: " + visNAnonymousTypeFields(ctx, fields) + "</li>" + "<li>" + "brclose: " + visToken(ctx, brclose) + "</li>" + "</ul>";
			case PTypePath(path):"<span class=\"node\">PTypePath</span>" + "<ul>" + "<li>" + "path: " + visNTypePath(ctx, path) + "</li>" + "</ul>";
			case POptionalType(questionmark, type):"<span class=\"node\">POptionalType</span>" + "<ul>" + "<li>" + "questionmark: " + visToken(ctx, questionmark) + "</li>" + "<li>" + "type: " + visNComplexType(ctx, type) + "</li>" + "</ul>";
		};
	}
	static public function visNExprElse(ctx:SyntaxTreePrinter, v:NExprElse):String {
		return "<span class=\"node\">NExprElse</span>" + "<ul>" + "<li>" + "_else: " + visToken(ctx, v._else) + "</li>" + "<li>" + "e: " + visNExpr(ctx, v.e) + "</li>" + "</ul>";
	}
}