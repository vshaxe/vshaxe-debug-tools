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
	public function visCommaSeparated<T>(c:NCommaSeparated<T>, vis:T -> String):String {
		var parts = [vis(c.arg)];
		for (el in c.args) {
			parts.push(visToken(el.comma));
			parts.push(vis(el.arg));
		};
		return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
	}
	public function visCommaSeparatedTrailing<T>(c:NCommaSeparatedAllowTrailing<T>, vis:T -> String):String {
		var parts = [vis(c.arg)];
		for (el in c.args) {
			parts.push(visToken(el.comma));
			parts.push(vis(el.arg));
		};
		if (c.comma != null) parts.push(visToken(c.comma));
		return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
	}
	public function visNFile(v:NFile):String {
		return "<span class=\"node\">NFile</span>" + "<ul>" + "<li>" + "pack: " + (if (v.pack != null) visNPackage(v.pack) else none) + "</li>" + "<li>" + "decls: " + visArray(v.decls, function(el) return visNDecl(el)) + "</li>" + "<li>" + "eof: " + visToken(v.eof) + "</li>" + "</ul>";
	}
	public function visNPackage(v:NPackage):String {
		return "<span class=\"node\">NPackage</span>" + "<ul>" + "<li>" + "_package: " + visToken(v._package) + "</li>" + "<li>" + "path: " + (if (v.path != null) visNPath(v.path) else none) + "</li>" + "<li>" + "semicolon: " + visToken(v.semicolon) + "</li>" + "</ul>";
	}
	public function visNImportMode(v:NImportMode):String {
		return switch v {
			case PAsMode(_as, ident):"<span class=\"node\">PAsMode</span>" + "<ul>" + "<li>" + "_as: " + visToken(_as) + "</li>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case PNormalMode:"PNormalMode";
			case PInMode(_in, ident):"<span class=\"node\">PInMode</span>" + "<ul>" + "<li>" + "_in: " + visToken(_in) + "</li>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case PAllMode(dotstar):"<span class=\"node\">PAllMode</span>" + "<ul>" + "<li>" + "dotstar: " + visToken(dotstar) + "</li>" + "</ul>";
		};
	}
	public function visNLiteral(v:NLiteral):String {
		return switch v {
			case PLiteralString(s):"<span class=\"node\">PLiteralString</span>" + "<ul>" + "<li>" + "s: " + visNString(s) + "</li>" + "</ul>";
			case PLiteralFloat(token):"<span class=\"node\">PLiteralFloat</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PLiteralRegex(token):"<span class=\"node\">PLiteralRegex</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PLiteralInt(token):"<span class=\"node\">PLiteralInt</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
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
	public function visNAbstractRelation(v:NAbstractRelation):String {
		return switch v {
			case PFrom(_from, type):"<span class=\"node\">PFrom</span>" + "<ul>" + "<li>" + "_from: " + visToken(_from) + "</li>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "</ul>";
			case PTo(_to, type):"<span class=\"node\">PTo</span>" + "<ul>" + "<li>" + "_to: " + visToken(_to) + "</li>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visNTypeHint(v:NTypeHint):String {
		return "<span class=\"node\">NTypeHint</span>" + "<ul>" + "<li>" + "colon: " + visToken(v.colon) + "</li>" + "<li>" + "type: " + visNComplexType(v.type) + "</li>" + "</ul>";
	}
	public function visNClassDecl(v:NClassDecl):String {
		return "<span class=\"node\">NClassDecl</span>" + "<ul>" + "<li>" + "kind: " + visToken(v.kind) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "relations: " + visArray(v.relations, function(el) return visNClassRelation(el)) + "</li>" + "<li>" + "bropen: " + visToken(v.bropen) + "</li>" + "<li>" + "fields: " + visArray(v.fields, function(el) return visNClassField(el)) + "</li>" + "<li>" + "brclose: " + visToken(v.brclose) + "</li>" + "</ul>";
	}
	public function visNCatch(v:NCatch):String {
		return "<span class=\"node\">NCatch</span>" + "<ul>" + "<li>" + "_catch: " + visToken(v._catch) + "</li>" + "<li>" + "popen: " + visToken(v.popen) + "</li>" + "<li>" + "ident: " + visToken(v.ident) + "</li>" + "<li>" + "type: " + visNTypeHint(v.type) + "</li>" + "<li>" + "pclose: " + visToken(v.pclose) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
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
	public function visNModifier(v:NModifier):String {
		return switch v {
			case PModifierStatic(token):"<span class=\"node\">PModifierStatic</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PModifierOverride(token):"<span class=\"node\">PModifierOverride</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PModifierMacro(token):"<span class=\"node\">PModifierMacro</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PModifierDynamic(token):"<span class=\"node\">PModifierDynamic</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PModifierInline(token):"<span class=\"node\">PModifierInline</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PModifierPrivate(token):"<span class=\"node\">PModifierPrivate</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
			case PModifierPublic(token):"<span class=\"node\">PModifierPublic</span>" + "<ul>" + "<li>" + "token: " + visToken(token) + "</li>" + "</ul>";
		};
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
		return "<span class=\"node\">NEnumFieldArgs</span>" + "<ul>" + "<li>" + "popen: " + visToken(v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visNEnumFieldArg(el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(v.pclose) + "</li>" + "</ul>";
	}
	public function visNFunctionArgument(v:NFunctionArgument):String {
		return "<span class=\"node\">NFunctionArgument</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) visNTypeHint(v.typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visNAssignment(v.assignment) else none) + "</li>" + "</ul>";
	}
	public function visNAnonymousTypeField(v:NAnonymousTypeField):String {
		return "<span class=\"node\">NAnonymousTypeField</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + visNTypeHint(v.typeHint) + "</li>" + "</ul>";
	}
	public function visNUnderlyingType(v:NUnderlyingType):String {
		return "<span class=\"node\">NUnderlyingType</span>" + "<ul>" + "<li>" + "popen: " + visToken(v.popen) + "</li>" + "<li>" + "type: " + visNComplexType(v.type) + "</li>" + "<li>" + "pclose: " + visToken(v.pclose) + "</li>" + "</ul>";
	}
	public function visNTypePathParameter(v:NTypePathParameter):String {
		return switch v {
			case PArrayExprTypePathParameter(bkopen, el, bkclose):"<span class=\"node\">PArrayExprTypePathParameter</span>" + "<ul>" + "<li>" + "bkopen: " + visToken(bkopen) + "</li>" + "<li>" + "el: " + (if (el != null) visCommaSeparatedTrailing(el, function(el) return visNExpr(el)) else none) + "</li>" + "<li>" + "bkclose: " + visToken(bkclose) + "</li>" + "</ul>";
			case PConstantTypePathParameter(constant):"<span class=\"node\">PConstantTypePathParameter</span>" + "<ul>" + "<li>" + "constant: " + visNLiteral(constant) + "</li>" + "</ul>";
			case PTypeTypePathParameter(type):"<span class=\"node\">PTypeTypePathParameter</span>" + "<ul>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visNTypeDeclParameters(v:NTypeDeclParameters):String {
		return "<span class=\"node\">NTypeDeclParameters</span>" + "<ul>" + "<li>" + "lt: " + visToken(v.lt) + "</li>" + "<li>" + "params: " + visCommaSeparated(v.params, function(el) return visNTypeDeclParameter(el)) + "</li>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "</ul>";
	}
	public function visNGuard(v:NGuard):String {
		return "<span class=\"node\">NGuard</span>" + "<ul>" + "<li>" + "_if: " + visToken(v._if) + "</li>" + "<li>" + "popen: " + visToken(v.popen) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "<li>" + "pclose: " + visToken(v.pclose) + "</li>" + "</ul>";
	}
	public function visNMacroExpr(v:NMacroExpr):String {
		return switch v {
			case PVar(_var, v):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + visToken(_var) + "</li>" + "<li>" + "v: " + visCommaSeparated(v, function(el) return visNVarDeclaration(el)) + "</li>" + "</ul>";
			case PTypeHint(type):"<span class=\"node\">PTypeHint</span>" + "<ul>" + "<li>" + "type: " + visNTypeHint(type) + "</li>" + "</ul>";
			case PClass(c):"<span class=\"node\">PClass</span>" + "<ul>" + "<li>" + "c: " + visNClassDecl(c) + "</li>" + "</ul>";
			case PExpr(e):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
		};
	}
	public function visNEnumField(v:NEnumField):String {
		return "<span class=\"node\">NEnumField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(v.annotations) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "args: " + (if (v.args != null) visNEnumFieldArgs(v.args) else none) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(v.type) else none) + "</li>" + "<li>" + "semicolon: " + visToken(v.semicolon) + "</li>" + "</ul>";
	}
	public function visNPath(v:NPath):String {
		return "<span class=\"node\">NPath</span>" + "<ul>" + "<li>" + "ident: " + visToken(v.ident) + "</li>" + "<li>" + "idents: " + visArray(v.idents, function(el) return visNDotIdent(el)) + "</li>" + "</ul>";
	}
	public function visNDecl(v:NDecl):String {
		return switch v {
			case PClassDecl(annotations, flags, c):"<span class=\"node\">PClassDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "c: " + visNClassDecl(c) + "</li>" + "</ul>";
			case PTypedefDecl(annotations, flags, _typedef, name, params, assign, type, semicolon):"<span class=\"node\">PTypedefDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "_typedef: " + visToken(_typedef) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "assign: " + visToken(assign) + "</li>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "<li>" + "semicolon: " + (if (semicolon != null) visToken(semicolon) else none) + "</li>" + "</ul>";
			case PUsingDecl(_using, path, semicolon):"<span class=\"node\">PUsingDecl</span>" + "<ul>" + "<li>" + "_using: " + visToken(_using) + "</li>" + "<li>" + "path: " + visNPath(path) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case PImportDecl(_import, importPath, semicolon):"<span class=\"node\">PImportDecl</span>" + "<ul>" + "<li>" + "_import: " + visToken(_import) + "</li>" + "<li>" + "importPath: " + visNImport(importPath) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case PAbstractDecl(annotations, flags, _abstract, name, params, underlyingType, relations, bropen, fields, brclose):"<span class=\"node\">PAbstractDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "_abstract: " + visToken(_abstract) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "underlyingType: " + (if (underlyingType != null) visNUnderlyingType(underlyingType) else none) + "</li>" + "<li>" + "relations: " + visArray(relations, function(el) return visNAbstractRelation(el)) + "</li>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "fields: " + visArray(fields, function(el) return visNClassField(el)) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PEnumDecl(annotations, flags, _enum, name, params, bropen, fields, brclose):"<span class=\"node\">PEnumDecl</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "flags: " + visArray(flags, function(el) return visNCommonFlag(el)) + "</li>" + "<li>" + "_enum: " + visToken(_enum) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "fields: " + visArray(fields, function(el) return visNEnumField(el)) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
		};
	}
	public function visNConstraints(v:NConstraints):String {
		return switch v {
			case PMultipleConstraints(colon, popen, types, pclose):"<span class=\"node\">PMultipleConstraints</span>" + "<ul>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "types: " + visCommaSeparated(types, function(el) return visNComplexType(el)) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PSingleConstraint(colon, type):"<span class=\"node\">PSingleConstraint</span>" + "<ul>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "</ul>";
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
	public function visNClassField(v:NClassField):String {
		return switch v {
			case PPropertyField(annotations, modifiers, _var, name, popen, get, comma, set, pclose, typeHint, assignment):"<span class=\"node\">PPropertyField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visNModifier(el)) + "</li>" + "<li>" + "_var: " + visToken(_var) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "get: " + visToken(get) + "</li>" + "<li>" + "comma: " + visToken(comma) + "</li>" + "<li>" + "set: " + visToken(set) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visNAssignment(assignment) else none) + "</li>" + "</ul>";
			case PVariableField(annotations, modifiers, _var, name, typeHint, assignment, semicolon):"<span class=\"node\">PVariableField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visNModifier(el)) + "</li>" + "<li>" + "_var: " + visToken(_var) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(typeHint) else none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) visNAssignment(assignment) else none) + "</li>" + "<li>" + "semicolon: " + visToken(semicolon) + "</li>" + "</ul>";
			case PFunctionField(annotations, modifiers, _function, name, params, popen, args, pclose, typeHint, e):"<span class=\"node\">PFunctionField</span>" + "<ul>" + "<li>" + "annotations: " + visNAnnotations(annotations) + "</li>" + "<li>" + "modifiers: " + visArray(modifiers, function(el) return visNModifier(el)) + "</li>" + "<li>" + "_function: " + visToken(_function) + "</li>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "params: " + (if (params != null) visNTypeDeclParameters(params) else none) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "args: " + (if (args != null) visCommaSeparated(args, function(el) return visNFunctionArgument(el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) visNTypeHint(typeHint) else none) + "</li>" + "<li>" + "e: " + (if (e != null) visNFieldExpr(e) else none) + "</li>" + "</ul>";
		};
	}
	public function visNClassRelation(v:NClassRelation):String {
		return switch v {
			case PExtends(_extends, path):"<span class=\"node\">PExtends</span>" + "<ul>" + "<li>" + "_extends: " + visToken(_extends) + "</li>" + "<li>" + "path: " + visNTypePath(path) + "</li>" + "</ul>";
			case PImplements(_implements, path):"<span class=\"node\">PImplements</span>" + "<ul>" + "<li>" + "_implements: " + visToken(_implements) + "</li>" + "<li>" + "path: " + visNTypePath(path) + "</li>" + "</ul>";
		};
	}
	public function visNCase(v:NCase):String {
		return switch v {
			case PCase(_case, patterns, guard, colon, el):"<span class=\"node\">PCase</span>" + "<ul>" + "<li>" + "_case: " + visToken(_case) + "</li>" + "<li>" + "patterns: " + visCommaSeparated(patterns, function(el) return visNExpr(el)) + "</li>" + "<li>" + "guard: " + (if (guard != null) visNGuard(guard) else none) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "el: " + visArray(el, function(el) return visNBlockElement(el)) + "</li>" + "</ul>";
			case PDefault(_default, colon, el):"<span class=\"node\">PDefault</span>" + "<ul>" + "<li>" + "_default: " + visToken(_default) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "el: " + visArray(el, function(el) return visNBlockElement(el)) + "</li>" + "</ul>";
		};
	}
	public function visNStructuralExtension(v:NStructuralExtension):String {
		return "<span class=\"node\">NStructuralExtension</span>" + "<ul>" + "<li>" + "gt: " + visToken(v.gt) + "</li>" + "<li>" + "path: " + visNTypePath(v.path) + "</li>" + "<li>" + "comma: " + visToken(v.comma) + "</li>" + "</ul>";
	}
	public function visNEnumFieldArg(v:NEnumFieldArg):String {
		return "<span class=\"node\">NEnumFieldArg</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) visToken(v.questionmark) else none) + "</li>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "typeHint: " + visNTypeHint(v.typeHint) + "</li>" + "</ul>";
	}
	public function visNMetadata(v:NMetadata):String {
		return switch v {
			case PMetadata(name):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "</ul>";
			case PMetadataWithArgs(name, el, pclose):"<span class=\"node\">PMetadataWithArgs</span>" + "<ul>" + "<li>" + "name: " + visToken(name) + "</li>" + "<li>" + "el: " + visCommaSeparated(el, function(el) return visNExpr(el)) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
		};
	}
	public function visNVarDeclaration(v:NVarDeclaration):String {
		return "<span class=\"node\">NVarDeclaration</span>" + "<ul>" + "<li>" + "name: " + visToken(v.name) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(v.type) else none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) visNAssignment(v.assignment) else none) + "</li>" + "</ul>";
	}
	public function visNTypePath(v:NTypePath):String {
		return "<span class=\"node\">NTypePath</span>" + "<ul>" + "<li>" + "path: " + visNPath(v.path) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypePathParameters(v.params) else none) + "</li>" + "</ul>";
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
			case PDo(_do, e1, _while, popen, e2, pclose):"<span class=\"node\">PDo</span>" + "<ul>" + "<li>" + "_do: " + visToken(_do) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "_while: " + visToken(_while) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PMacro(_macro, e):"<span class=\"node\">PMacro</span>" + "<ul>" + "<li>" + "_macro: " + visToken(_macro) + "</li>" + "<li>" + "e: " + visNMacroExpr(e) + "</li>" + "</ul>";
			case PWhile(_while, popen, e1, pclose, e2):"<span class=\"node\">PWhile</span>" + "<ul>" + "<li>" + "_while: " + visToken(_while) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
			case PIntDot(int, dot):"<span class=\"node\">PIntDot</span>" + "<ul>" + "<li>" + "int: " + visToken(int) + "</li>" + "<li>" + "dot: " + visToken(dot) + "</li>" + "</ul>";
			case PBlock(bropen, elems, brclose):"<span class=\"node\">PBlock</span>" + "<ul>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "elems: " + visArray(elems, function(el) return visNBlockElement(el)) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PFunction(_function, f):"<span class=\"node\">PFunction</span>" + "<ul>" + "<li>" + "_function: " + visToken(_function) + "</li>" + "<li>" + "f: " + visNFunction(f) + "</li>" + "</ul>";
			case PSwitch(_switch, e, bropen, cases, brclose):"<span class=\"node\">PSwitch</span>" + "<ul>" + "<li>" + "_switch: " + visToken(_switch) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "cases: " + visArray(cases, function(el) return visNCase(el)) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PReturn(_return):"<span class=\"node\">PReturn</span>" + "<ul>" + "<li>" + "_return: " + visToken(_return) + "</li>" + "</ul>";
			case PArrayDecl(bkopen, el, bkclose):"<span class=\"node\">PArrayDecl</span>" + "<ul>" + "<li>" + "bkopen: " + visToken(bkopen) + "</li>" + "<li>" + "el: " + (if (el != null) visCommaSeparatedTrailing(el, function(el) return visNExpr(el)) else none) + "</li>" + "<li>" + "bkclose: " + visToken(bkclose) + "</li>" + "</ul>";
			case PDollarIdent(ident):"<span class=\"node\">PDollarIdent</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "</ul>";
			case PIf(_if, popen, e1, pclose, e2, elseExpr):"<span class=\"node\">PIf</span>" + "<ul>" + "<li>" + "_if: " + visToken(_if) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "elseExpr: " + (if (elseExpr != null) visNExprElse(elseExpr) else none) + "</li>" + "</ul>";
			case PReturnExpr(_return, e):"<span class=\"node\">PReturnExpr</span>" + "<ul>" + "<li>" + "_return: " + visToken(_return) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PArray(e1, bkopen, e2, bkclose):"<span class=\"node\">PArray</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "bkopen: " + visToken(bkopen) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "bkclose: " + visToken(bkclose) + "</li>" + "</ul>";
			case PContinue(_continue):"<span class=\"node\">PContinue</span>" + "<ul>" + "<li>" + "_continue: " + visToken(_continue) + "</li>" + "</ul>";
			case PParenthesis(popen, e, pclose):"<span class=\"node\">PParenthesis</span>" + "<ul>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PTry(_try, e, catches):"<span class=\"node\">PTry</span>" + "<ul>" + "<li>" + "_try: " + visToken(_try) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "catches: " + visArray(catches, function(el) return visNCatch(el)) + "</li>" + "</ul>";
			case PBreak(_break):"<span class=\"node\">PBreak</span>" + "<ul>" + "<li>" + "_break: " + visToken(_break) + "</li>" + "</ul>";
			case PCall(e, el):"<span class=\"node\">PCall</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "el: " + visNCallArgs(el) + "</li>" + "</ul>";
			case PUnaryPostfix(e, op):"<span class=\"node\">PUnaryPostfix</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "op: " + visToken(op) + "</li>" + "</ul>";
			case PBinop(e1, op, e2):"<span class=\"node\">PBinop</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "op: " + visToken(op) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
			case PSafeCast(_cast, popen, e, comma, ct, pclose):"<span class=\"node\">PSafeCast</span>" + "<ul>" + "<li>" + "_cast: " + visToken(_cast) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "comma: " + visToken(comma) + "</li>" + "<li>" + "ct: " + visNComplexType(ct) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PUnaryPrefix(op, e):"<span class=\"node\">PUnaryPrefix</span>" + "<ul>" + "<li>" + "op: " + visToken(op) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PMacroEscape(ident, bropen, e, brclose):"<span class=\"node\">PMacroEscape</span>" + "<ul>" + "<li>" + "ident: " + visToken(ident) + "</li>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PIn(e1, _in, e2):"<span class=\"node\">PIn</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "_in: " + visToken(_in) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
			case PMetadata(metadata, e):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "metadata: " + visNMetadata(metadata) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PUnsafeCast(_cast, e):"<span class=\"node\">PUnsafeCast</span>" + "<ul>" + "<li>" + "_cast: " + visToken(_cast) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PCheckType(popen, e, colon, type, pclose):"<span class=\"node\">PCheckType</span>" + "<ul>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PUntyped(_untyped, e):"<span class=\"node\">PUntyped</span>" + "<ul>" + "<li>" + "_untyped: " + visToken(_untyped) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PField(e, ident):"<span class=\"node\">PField</span>" + "<ul>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "ident: " + visNDotIdent(ident) + "</li>" + "</ul>";
			case PIs(popen, e, _is, path, pclose):"<span class=\"node\">PIs</span>" + "<ul>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "<li>" + "_is: " + visToken(_is) + "</li>" + "<li>" + "path: " + visNTypePath(path) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PTernary(e1, questionmark, e2, colon, e3):"<span class=\"node\">PTernary</span>" + "<ul>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "questionmark: " + visToken(questionmark) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "<li>" + "colon: " + visToken(colon) + "</li>" + "<li>" + "e3: " + visNExpr(e3) + "</li>" + "</ul>";
			case PObjectDecl(bropen, fl, brclose):"<span class=\"node\">PObjectDecl</span>" + "<ul>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "fl: " + visCommaSeparatedTrailing(fl, function(el) return visNObjectField(el)) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PNew(_new, path, el):"<span class=\"node\">PNew</span>" + "<ul>" + "<li>" + "_new: " + visToken(_new) + "</li>" + "<li>" + "path: " + visNTypePath(path) + "</li>" + "<li>" + "el: " + visNCallArgs(el) + "</li>" + "</ul>";
			case PThrow(_throw, e):"<span class=\"node\">PThrow</span>" + "<ul>" + "<li>" + "_throw: " + visToken(_throw) + "</li>" + "<li>" + "e: " + visNExpr(e) + "</li>" + "</ul>";
			case PFor(_for, popen, e1, pclose, e2):"<span class=\"node\">PFor</span>" + "<ul>" + "<li>" + "_for: " + visToken(_for) + "</li>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "e1: " + visNExpr(e1) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "<li>" + "e2: " + visNExpr(e2) + "</li>" + "</ul>";
		};
	}
	public function visNAnonymousTypeFields(v:NAnonymousTypeFields):String {
		return switch v {
			case PAnonymousClassFields(fields):"<span class=\"node\">PAnonymousClassFields</span>" + "<ul>" + "<li>" + "fields: " + visArray(fields, function(el) return visNClassField(el)) + "</li>" + "</ul>";
			case PAnonymousShortFields(fields):"<span class=\"node\">PAnonymousShortFields</span>" + "<ul>" + "<li>" + "fields: " + (if (fields != null) visCommaSeparatedTrailing(fields, function(el) return visNAnonymousTypeField(el)) else none) + "</li>" + "</ul>";
		};
	}
	public function visNCallArgs(v:NCallArgs):String {
		return "<span class=\"node\">NCallArgs</span>" + "<ul>" + "<li>" + "popen: " + visToken(v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visNExpr(el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(v.pclose) + "</li>" + "</ul>";
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
	public function visNFunction(v:NFunction):String {
		return "<span class=\"node\">NFunction</span>" + "<ul>" + "<li>" + "ident: " + (if (v.ident != null) visToken(v.ident) else none) + "</li>" + "<li>" + "params: " + (if (v.params != null) visNTypeDeclParameters(v.params) else none) + "</li>" + "<li>" + "popen: " + visToken(v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) visCommaSeparated(v.args, function(el) return visNFunctionArgument(el)) else none) + "</li>" + "<li>" + "pclose: " + visToken(v.pclose) + "</li>" + "<li>" + "type: " + (if (v.type != null) visNTypeHint(v.type) else none) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
	public function visNImport(v:NImport):String {
		return "<span class=\"node\">NImport</span>" + "<ul>" + "<li>" + "path: " + visNPath(v.path) + "</li>" + "<li>" + "mode: " + visNImportMode(v.mode) + "</li>" + "</ul>";
	}
	public function visNComplexType(v:NComplexType):String {
		return switch v {
			case PFunctionType(type1, arrow, type2):"<span class=\"node\">PFunctionType</span>" + "<ul>" + "<li>" + "type1: " + visNComplexType(type1) + "</li>" + "<li>" + "arrow: " + visToken(arrow) + "</li>" + "<li>" + "type2: " + visNComplexType(type2) + "</li>" + "</ul>";
			case PStructuralExtension(bropen, types, fields, brclose):"<span class=\"node\">PStructuralExtension</span>" + "<ul>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "types: " + visArray(types, function(el) return visNStructuralExtension(el)) + "</li>" + "<li>" + "fields: " + visNAnonymousTypeFields(fields) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PParenthesisType(popen, ct, pclose):"<span class=\"node\">PParenthesisType</span>" + "<ul>" + "<li>" + "popen: " + visToken(popen) + "</li>" + "<li>" + "ct: " + visNComplexType(ct) + "</li>" + "<li>" + "pclose: " + visToken(pclose) + "</li>" + "</ul>";
			case PAnonymousStructure(bropen, fields, brclose):"<span class=\"node\">PAnonymousStructure</span>" + "<ul>" + "<li>" + "bropen: " + visToken(bropen) + "</li>" + "<li>" + "fields: " + visNAnonymousTypeFields(fields) + "</li>" + "<li>" + "brclose: " + visToken(brclose) + "</li>" + "</ul>";
			case PTypePath(path):"<span class=\"node\">PTypePath</span>" + "<ul>" + "<li>" + "path: " + visNTypePath(path) + "</li>" + "</ul>";
			case POptionalType(questionmark, type):"<span class=\"node\">POptionalType</span>" + "<ul>" + "<li>" + "questionmark: " + visToken(questionmark) + "</li>" + "<li>" + "type: " + visNComplexType(type) + "</li>" + "</ul>";
		};
	}
	public function visNExprElse(v:NExprElse):String {
		return "<span class=\"node\">NExprElse</span>" + "<ul>" + "<li>" + "_else: " + visToken(v._else) + "</li>" + "<li>" + "e: " + visNExpr(v.e) + "</li>" + "</ul>";
	}
}