package hxParserVis;

class Vis_NFile {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NFile):String {
		return "<span class=\"node\">NFile</span>" + "<ul>" + "<li>" + "pack: " + (if (v.pack != null) Vis_NPackage.vis(ctx, v.pack) else VisBase.none) + "</li>" + "<li>" + "decls: " + VisBase.visArray(ctx, v.decls, function(el) return Vis_NDecl.vis(ctx, el)) + "</li>" + "<li>" + "eof: " + VisBase.visToken(ctx, v.eof) + "</li>" + "</ul>";
	}
}

class Vis_NPackage {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NPackage):String {
		return "<span class=\"node\">NPackage</span>" + "<ul>" + "<li>" + "_package: " + VisBase.visToken(ctx, v._package) + "</li>" + "<li>" + "path: " + (if (v.path != null) Vis_NPath.vis(ctx, v.path) else VisBase.none) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, v.semicolon) + "</li>" + "</ul>";
	}
}

class Vis_NImportMode {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NImportMode):String {
		return switch v {
			case PAsMode(_as, ident):"<span class=\"node\">PAsMode</span>" + "<ul>" + "<li>" + "_as: " + VisBase.visToken(ctx, _as) + "</li>" + "<li>" + "ident: " + VisBase.visToken(ctx, ident) + "</li>" + "</ul>";
			case PNormalMode:"PNormalMode";
			case PInMode(_in, ident):"<span class=\"node\">PInMode</span>" + "<ul>" + "<li>" + "_in: " + VisBase.visToken(ctx, _in) + "</li>" + "<li>" + "ident: " + VisBase.visToken(ctx, ident) + "</li>" + "</ul>";
			case PAllMode(dotstar):"<span class=\"node\">PAllMode</span>" + "<ul>" + "<li>" + "dotstar: " + VisBase.visToken(ctx, dotstar) + "</li>" + "</ul>";
		};
	}
}

class Vis_NLiteral {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NLiteral):String {
		return switch v {
			case PLiteralString(s):"<span class=\"node\">PLiteralString</span>" + "<ul>" + "<li>" + "s: " + Vis_NString.vis(ctx, s) + "</li>" + "</ul>";
			case PLiteralFloat(token):"<span class=\"node\">PLiteralFloat</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PLiteralRegex(token):"<span class=\"node\">PLiteralRegex</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PLiteralInt(token):"<span class=\"node\">PLiteralInt</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
		};
	}
}

class Vis_NAssignment {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NAssignment):String {
		return "<span class=\"node\">NAssignment</span>" + "<ul>" + "<li>" + "assign: " + VisBase.visToken(ctx, v.assign) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, v.e) + "</li>" + "</ul>";
	}
}

class Vis_NObjectFieldName {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NObjectFieldName):String {
		return switch v {
			case PString(string):"<span class=\"node\">PString</span>" + "<ul>" + "<li>" + "string: " + Vis_NString.vis(ctx, string) + "</li>" + "</ul>";
			case PIdent(ident):"<span class=\"node\">PIdent</span>" + "<ul>" + "<li>" + "ident: " + VisBase.visToken(ctx, ident) + "</li>" + "</ul>";
		};
	}
}

class Vis_NAbstractRelation {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NAbstractRelation):String {
		return switch v {
			case PFrom(_from, type):"<span class=\"node\">PFrom</span>" + "<ul>" + "<li>" + "_from: " + VisBase.visToken(ctx, _from) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "</ul>";
			case PTo(_to, type):"<span class=\"node\">PTo</span>" + "<ul>" + "<li>" + "_to: " + VisBase.visToken(ctx, _to) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "</ul>";
		};
	}
}

class Vis_NTypeHint {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NTypeHint):String {
		return "<span class=\"node\">NTypeHint</span>" + "<ul>" + "<li>" + "colon: " + VisBase.visToken(ctx, v.colon) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, v.type) + "</li>" + "</ul>";
	}
}

class Vis_NClassDecl {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NClassDecl):String {
		return "<span class=\"node\">NClassDecl</span>" + "<ul>" + "<li>" + "kind: " + VisBase.visToken(ctx, v.kind) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) Vis_NTypeDeclParameters.vis(ctx, v.params) else VisBase.none) + "</li>" + "<li>" + "relations: " + VisBase.visArray(ctx, v.relations, function(el) return Vis_NClassRelation.vis(ctx, el)) + "</li>" + "<li>" + "bropen: " + VisBase.visToken(ctx, v.bropen) + "</li>" + "<li>" + "fields: " + VisBase.visArray(ctx, v.fields, function(el) return Vis_NClassField.vis(ctx, el)) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, v.brclose) + "</li>" + "</ul>";
	}
}

class Vis_NCatch {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NCatch):String {
		return "<span class=\"node\">NCatch</span>" + "<ul>" + "<li>" + "_catch: " + VisBase.visToken(ctx, v._catch) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, v.popen) + "</li>" + "<li>" + "ident: " + VisBase.visToken(ctx, v.ident) + "</li>" + "<li>" + "type: " + Vis_NTypeHint.vis(ctx, v.type) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, v.pclose) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, v.e) + "</li>" + "</ul>";
	}
}

class Vis_NTypeDeclParameter {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NTypeDeclParameter):String {
		return "<span class=\"node\">NTypeDeclParameter</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, v.annotations) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "constraints: " + Vis_NConstraints.vis(ctx, v.constraints) + "</li>" + "</ul>";
	}
}

class Vis_NConst {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NConst):String {
		return switch v {
			case PConstLiteral(literal):"<span class=\"node\">PConstLiteral</span>" + "<ul>" + "<li>" + "literal: " + Vis_NLiteral.vis(ctx, literal) + "</li>" + "</ul>";
			case PConstIdent(ident):"<span class=\"node\">PConstIdent</span>" + "<ul>" + "<li>" + "ident: " + VisBase.visToken(ctx, ident) + "</li>" + "</ul>";
		};
	}
}

class Vis_NTypePathParameters {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NTypePathParameters):String {
		return "<span class=\"node\">NTypePathParameters</span>" + "<ul>" + "<li>" + "lt: " + VisBase.visToken(ctx, v.lt) + "</li>" + "<li>" + "parameters: " + VisBase.visCommaSeparated(ctx, v.parameters, function(el) return Vis_NTypePathParameter.vis(ctx, el)) + "</li>" + "<li>" + "gt: " + VisBase.visToken(ctx, v.gt) + "</li>" + "</ul>";
	}
}

class Vis_NModifier {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NModifier):String {
		return switch v {
			case PModifierStatic(token):"<span class=\"node\">PModifierStatic</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierOverride(token):"<span class=\"node\">PModifierOverride</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierMacro(token):"<span class=\"node\">PModifierMacro</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierDynamic(token):"<span class=\"node\">PModifierDynamic</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierInline(token):"<span class=\"node\">PModifierInline</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierPrivate(token):"<span class=\"node\">PModifierPrivate</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PModifierPublic(token):"<span class=\"node\">PModifierPublic</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
		};
	}
}

class Vis_NFieldExpr {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NFieldExpr):String {
		return switch v {
			case PNoFieldExpr(semicolon):"<span class=\"node\">PNoFieldExpr</span>" + "<ul>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PBlockFieldExpr(e):"<span class=\"node\">PBlockFieldExpr</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PExprFieldExpr(e, semicolon):"<span class=\"node\">PExprFieldExpr</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
		};
	}
}

class Vis_NCommonFlag {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NCommonFlag):String {
		return switch v {
			case PExtern(token):"<span class=\"node\">PExtern</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
			case PPrivate(token):"<span class=\"node\">PPrivate</span>" + "<ul>" + "<li>" + "token: " + VisBase.visToken(ctx, token) + "</li>" + "</ul>";
		};
	}
}

class Vis_NEnumFieldArgs {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NEnumFieldArgs):String {
		return "<span class=\"node\">NEnumFieldArgs</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) VisBase.visCommaSeparated(ctx, v.args, function(el) return Vis_NEnumFieldArg.vis(ctx, el)) else VisBase.none) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
}

class Vis_NFunctionArgument {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NFunctionArgument):String {
		return "<span class=\"node\">NFunctionArgument</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, v.annotations) + "</li>" + "<li>" + "questionmark: " + (if (v.questionmark != null) VisBase.visToken(ctx, v.questionmark) else VisBase.none) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "typeHint: " + (if (v.typeHint != null) Vis_NTypeHint.vis(ctx, v.typeHint) else VisBase.none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) Vis_NAssignment.vis(ctx, v.assignment) else VisBase.none) + "</li>" + "</ul>";
	}
}

class Vis_NAnonymousTypeField {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NAnonymousTypeField):String {
		return "<span class=\"node\">NAnonymousTypeField</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) VisBase.visToken(ctx, v.questionmark) else VisBase.none) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "typeHint: " + Vis_NTypeHint.vis(ctx, v.typeHint) + "</li>" + "</ul>";
	}
}

class Vis_NUnderlyingType {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NUnderlyingType):String {
		return "<span class=\"node\">NUnderlyingType</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, v.popen) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, v.type) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
}

class Vis_NTypePathParameter {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NTypePathParameter):String {
		return switch v {
			case PArrayExprTypePathParameter(bkopen, el, bkclose):"<span class=\"node\">PArrayExprTypePathParameter</span>" + "<ul>" + "<li>" + "bkopen: " + VisBase.visToken(ctx, bkopen) + "</li>" + "<li>" + "el: " + (if (el != null) VisBase.visCommaSeparatedTrailing(ctx, el, function(el) return Vis_NExpr.vis(ctx, el)) else VisBase.none) + "</li>" + "<li>" + "bkclose: " + VisBase.visToken(ctx, bkclose) + "</li>" + "</ul>";
			case PConstantTypePathParameter(constant):"<span class=\"node\">PConstantTypePathParameter</span>" + "<ul>" + "<li>" + "constant: " + Vis_NLiteral.vis(ctx, constant) + "</li>" + "</ul>";
			case PTypeTypePathParameter(type):"<span class=\"node\">PTypeTypePathParameter</span>" + "<ul>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "</ul>";
		};
	}
}

class Vis_NTypeDeclParameters {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NTypeDeclParameters):String {
		return "<span class=\"node\">NTypeDeclParameters</span>" + "<ul>" + "<li>" + "lt: " + VisBase.visToken(ctx, v.lt) + "</li>" + "<li>" + "params: " + VisBase.visCommaSeparated(ctx, v.params, function(el) return Vis_NTypeDeclParameter.vis(ctx, el)) + "</li>" + "<li>" + "gt: " + VisBase.visToken(ctx, v.gt) + "</li>" + "</ul>";
	}
}

class Vis_NGuard {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NGuard):String {
		return "<span class=\"node\">NGuard</span>" + "<ul>" + "<li>" + "_if: " + VisBase.visToken(ctx, v._if) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, v.popen) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, v.e) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
}

class Vis_NMacroExpr {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NMacroExpr):String {
		return switch v {
			case PVar(_var, v):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + VisBase.visToken(ctx, _var) + "</li>" + "<li>" + "v: " + VisBase.visCommaSeparated(ctx, v, function(el) return Vis_NVarDeclaration.vis(ctx, el)) + "</li>" + "</ul>";
			case PTypeHint(type):"<span class=\"node\">PTypeHint</span>" + "<ul>" + "<li>" + "type: " + Vis_NTypeHint.vis(ctx, type) + "</li>" + "</ul>";
			case PClass(c):"<span class=\"node\">PClass</span>" + "<ul>" + "<li>" + "c: " + Vis_NClassDecl.vis(ctx, c) + "</li>" + "</ul>";
			case PExpr(e):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
		};
	}
}

class Vis_NEnumField {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NEnumField):String {
		return "<span class=\"node\">NEnumField</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, v.annotations) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "params: " + (if (v.params != null) Vis_NTypeDeclParameters.vis(ctx, v.params) else VisBase.none) + "</li>" + "<li>" + "args: " + (if (v.args != null) Vis_NEnumFieldArgs.vis(ctx, v.args) else VisBase.none) + "</li>" + "<li>" + "type: " + (if (v.type != null) Vis_NTypeHint.vis(ctx, v.type) else VisBase.none) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, v.semicolon) + "</li>" + "</ul>";
	}
}

class Vis_NPath {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NPath):String {
		return "<span class=\"node\">NPath</span>" + "<ul>" + "<li>" + "ident: " + VisBase.visToken(ctx, v.ident) + "</li>" + "<li>" + "idents: " + VisBase.visArray(ctx, v.idents, function(el) return Vis_NDotIdent.vis(ctx, el)) + "</li>" + "</ul>";
	}
}

class Vis_NDecl {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NDecl):String {
		return switch v {
			case PClassDecl(annotations, flags, c):"<span class=\"node\">PClassDecl</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "flags: " + VisBase.visArray(ctx, flags, function(el) return Vis_NCommonFlag.vis(ctx, el)) + "</li>" + "<li>" + "c: " + Vis_NClassDecl.vis(ctx, c) + "</li>" + "</ul>";
			case PTypedefDecl(annotations, flags, _typedef, name, params, assign, type, semicolon):"<span class=\"node\">PTypedefDecl</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "flags: " + VisBase.visArray(ctx, flags, function(el) return Vis_NCommonFlag.vis(ctx, el)) + "</li>" + "<li>" + "_typedef: " + VisBase.visToken(ctx, _typedef) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) Vis_NTypeDeclParameters.vis(ctx, params) else VisBase.none) + "</li>" + "<li>" + "assign: " + VisBase.visToken(ctx, assign) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "<li>" + "semicolon: " + (if (semicolon != null) VisBase.visToken(ctx, semicolon) else VisBase.none) + "</li>" + "</ul>";
			case PUsingDecl(_using, path, semicolon):"<span class=\"node\">PUsingDecl</span>" + "<ul>" + "<li>" + "_using: " + VisBase.visToken(ctx, _using) + "</li>" + "<li>" + "path: " + Vis_NPath.vis(ctx, path) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PImportDecl(_import, importPath, semicolon):"<span class=\"node\">PImportDecl</span>" + "<ul>" + "<li>" + "_import: " + VisBase.visToken(ctx, _import) + "</li>" + "<li>" + "importPath: " + Vis_NImport.vis(ctx, importPath) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PAbstractDecl(annotations, flags, _abstract, name, params, underlyingType, relations, bropen, fields, brclose):"<span class=\"node\">PAbstractDecl</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "flags: " + VisBase.visArray(ctx, flags, function(el) return Vis_NCommonFlag.vis(ctx, el)) + "</li>" + "<li>" + "_abstract: " + VisBase.visToken(ctx, _abstract) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) Vis_NTypeDeclParameters.vis(ctx, params) else VisBase.none) + "</li>" + "<li>" + "underlyingType: " + (if (underlyingType != null) Vis_NUnderlyingType.vis(ctx, underlyingType) else VisBase.none) + "</li>" + "<li>" + "relations: " + VisBase.visArray(ctx, relations, function(el) return Vis_NAbstractRelation.vis(ctx, el)) + "</li>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "fields: " + VisBase.visArray(ctx, fields, function(el) return Vis_NClassField.vis(ctx, el)) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PEnumDecl(annotations, flags, _enum, name, params, bropen, fields, brclose):"<span class=\"node\">PEnumDecl</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "flags: " + VisBase.visArray(ctx, flags, function(el) return Vis_NCommonFlag.vis(ctx, el)) + "</li>" + "<li>" + "_enum: " + VisBase.visToken(ctx, _enum) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) Vis_NTypeDeclParameters.vis(ctx, params) else VisBase.none) + "</li>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "fields: " + VisBase.visArray(ctx, fields, function(el) return Vis_NEnumField.vis(ctx, el)) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
		};
	}
}

class Vis_NConstraints {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NConstraints):String {
		return switch v {
			case PMultipleConstraints(colon, popen, types, pclose):"<span class=\"node\">PMultipleConstraints</span>" + "<ul>" + "<li>" + "colon: " + VisBase.visToken(ctx, colon) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "types: " + VisBase.visCommaSeparated(ctx, types, function(el) return Vis_NComplexType.vis(ctx, el)) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PSingleConstraint(colon, type):"<span class=\"node\">PSingleConstraint</span>" + "<ul>" + "<li>" + "colon: " + VisBase.visToken(ctx, colon) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "</ul>";
			case PNoConstraints:"PNoConstraints";
		};
	}
}

class Vis_NBlockElement {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NBlockElement):String {
		return switch v {
			case PVar(_var, vl, semicolon):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + VisBase.visToken(ctx, _var) + "</li>" + "<li>" + "vl: " + VisBase.visCommaSeparated(ctx, vl, function(el) return Vis_NVarDeclaration.vis(ctx, el)) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PExpr(e, semicolon):"<span class=\"node\">PExpr</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PInlineFunction(_inline, _function, f, semicolon):"<span class=\"node\">PInlineFunction</span>" + "<ul>" + "<li>" + "_inline: " + VisBase.visToken(ctx, _inline) + "</li>" + "<li>" + "_function: " + VisBase.visToken(ctx, _function) + "</li>" + "<li>" + "f: " + Vis_NFunction.vis(ctx, f) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
		};
	}
}

class Vis_NClassField {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NClassField):String {
		return switch v {
			case PPropertyField(annotations, modifiers, _var, name, popen, get, comma, set, pclose, typeHint, assignment):"<span class=\"node\">PPropertyField</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "modifiers: " + VisBase.visArray(ctx, modifiers, function(el) return Vis_NModifier.vis(ctx, el)) + "</li>" + "<li>" + "_var: " + VisBase.visToken(ctx, _var) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "get: " + VisBase.visToken(ctx, get) + "</li>" + "<li>" + "comma: " + VisBase.visToken(ctx, comma) + "</li>" + "<li>" + "set: " + VisBase.visToken(ctx, set) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) Vis_NTypeHint.vis(ctx, typeHint) else VisBase.none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) Vis_NAssignment.vis(ctx, assignment) else VisBase.none) + "</li>" + "</ul>";
			case PVariableField(annotations, modifiers, _var, name, typeHint, assignment, semicolon):"<span class=\"node\">PVariableField</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "modifiers: " + VisBase.visArray(ctx, modifiers, function(el) return Vis_NModifier.vis(ctx, el)) + "</li>" + "<li>" + "_var: " + VisBase.visToken(ctx, _var) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) Vis_NTypeHint.vis(ctx, typeHint) else VisBase.none) + "</li>" + "<li>" + "assignment: " + (if (assignment != null) Vis_NAssignment.vis(ctx, assignment) else VisBase.none) + "</li>" + "<li>" + "semicolon: " + VisBase.visToken(ctx, semicolon) + "</li>" + "</ul>";
			case PFunctionField(annotations, modifiers, _function, name, params, popen, args, pclose, typeHint, e):"<span class=\"node\">PFunctionField</span>" + "<ul>" + "<li>" + "annotations: " + Vis_NAnnotations.vis(ctx, annotations) + "</li>" + "<li>" + "modifiers: " + VisBase.visArray(ctx, modifiers, function(el) return Vis_NModifier.vis(ctx, el)) + "</li>" + "<li>" + "_function: " + VisBase.visToken(ctx, _function) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "params: " + (if (params != null) Vis_NTypeDeclParameters.vis(ctx, params) else VisBase.none) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "args: " + (if (args != null) VisBase.visCommaSeparated(ctx, args, function(el) return Vis_NFunctionArgument.vis(ctx, el)) else VisBase.none) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "<li>" + "typeHint: " + (if (typeHint != null) Vis_NTypeHint.vis(ctx, typeHint) else VisBase.none) + "</li>" + "<li>" + "e: " + (if (e != null) Vis_NFieldExpr.vis(ctx, e) else VisBase.none) + "</li>" + "</ul>";
		};
	}
}

class Vis_NClassRelation {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NClassRelation):String {
		return switch v {
			case PExtends(_extends, path):"<span class=\"node\">PExtends</span>" + "<ul>" + "<li>" + "_extends: " + VisBase.visToken(ctx, _extends) + "</li>" + "<li>" + "path: " + Vis_NTypePath.vis(ctx, path) + "</li>" + "</ul>";
			case PImplements(_implements, path):"<span class=\"node\">PImplements</span>" + "<ul>" + "<li>" + "_implements: " + VisBase.visToken(ctx, _implements) + "</li>" + "<li>" + "path: " + Vis_NTypePath.vis(ctx, path) + "</li>" + "</ul>";
		};
	}
}

class Vis_NCase {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NCase):String {
		return switch v {
			case PCase(_case, patterns, guard, colon, el):"<span class=\"node\">PCase</span>" + "<ul>" + "<li>" + "_case: " + VisBase.visToken(ctx, _case) + "</li>" + "<li>" + "patterns: " + VisBase.visCommaSeparated(ctx, patterns, function(el) return Vis_NExpr.vis(ctx, el)) + "</li>" + "<li>" + "guard: " + (if (guard != null) Vis_NGuard.vis(ctx, guard) else VisBase.none) + "</li>" + "<li>" + "colon: " + VisBase.visToken(ctx, colon) + "</li>" + "<li>" + "el: " + VisBase.visArray(ctx, el, function(el) return Vis_NBlockElement.vis(ctx, el)) + "</li>" + "</ul>";
			case PDefault(_default, colon, el):"<span class=\"node\">PDefault</span>" + "<ul>" + "<li>" + "_default: " + VisBase.visToken(ctx, _default) + "</li>" + "<li>" + "colon: " + VisBase.visToken(ctx, colon) + "</li>" + "<li>" + "el: " + VisBase.visArray(ctx, el, function(el) return Vis_NBlockElement.vis(ctx, el)) + "</li>" + "</ul>";
		};
	}
}

class Vis_NStructuralExtension {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NStructuralExtension):String {
		return "<span class=\"node\">NStructuralExtension</span>" + "<ul>" + "<li>" + "gt: " + VisBase.visToken(ctx, v.gt) + "</li>" + "<li>" + "path: " + Vis_NTypePath.vis(ctx, v.path) + "</li>" + "<li>" + "comma: " + VisBase.visToken(ctx, v.comma) + "</li>" + "</ul>";
	}
}

class Vis_NEnumFieldArg {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NEnumFieldArg):String {
		return "<span class=\"node\">NEnumFieldArg</span>" + "<ul>" + "<li>" + "questionmark: " + (if (v.questionmark != null) VisBase.visToken(ctx, v.questionmark) else VisBase.none) + "</li>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "typeHint: " + Vis_NTypeHint.vis(ctx, v.typeHint) + "</li>" + "</ul>";
	}
}

class Vis_NMetadata {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NMetadata):String {
		return switch v {
			case PMetadata(name):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "</ul>";
			case PMetadataWithArgs(name, el, pclose):"<span class=\"node\">PMetadataWithArgs</span>" + "<ul>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "<li>" + "el: " + VisBase.visCommaSeparated(ctx, el, function(el) return Vis_NExpr.vis(ctx, el)) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
		};
	}
}

class Vis_NVarDeclaration {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NVarDeclaration):String {
		return "<span class=\"node\">NVarDeclaration</span>" + "<ul>" + "<li>" + "name: " + VisBase.visToken(ctx, v.name) + "</li>" + "<li>" + "type: " + (if (v.type != null) Vis_NTypeHint.vis(ctx, v.type) else VisBase.none) + "</li>" + "<li>" + "assignment: " + (if (v.assignment != null) Vis_NAssignment.vis(ctx, v.assignment) else VisBase.none) + "</li>" + "</ul>";
	}
}

class Vis_NTypePath {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NTypePath):String {
		return "<span class=\"node\">NTypePath</span>" + "<ul>" + "<li>" + "path: " + Vis_NPath.vis(ctx, v.path) + "</li>" + "<li>" + "params: " + (if (v.params != null) Vis_NTypePathParameters.vis(ctx, v.params) else VisBase.none) + "</li>" + "</ul>";
	}
}

class Vis_NString {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NString):String {
		return switch v {
			case PString(s):"<span class=\"node\">PString</span>" + "<ul>" + "<li>" + "s: " + VisBase.visToken(ctx, s) + "</li>" + "</ul>";
			case PString2(s):"<span class=\"node\">PString2</span>" + "<ul>" + "<li>" + "s: " + VisBase.visToken(ctx, s) + "</li>" + "</ul>";
		};
	}
}

class Vis_NAnnotations {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NAnnotations):String {
		return "<span class=\"node\">NAnnotations</span>" + "<ul>" + "<li>" + "doc: " + (if (v.doc != null) VisBase.visToken(ctx, v.doc) else VisBase.none) + "</li>" + "<li>" + "meta: " + VisBase.visArray(ctx, v.meta, function(el) return Vis_NMetadata.vis(ctx, el)) + "</li>" + "</ul>";
	}
}

class Vis_NExpr {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NExpr):String {
		return switch v {
			case PVar(_var, d):"<span class=\"node\">PVar</span>" + "<ul>" + "<li>" + "_var: " + VisBase.visToken(ctx, _var) + "</li>" + "<li>" + "d: " + Vis_NVarDeclaration.vis(ctx, d) + "</li>" + "</ul>";
			case PConst(const):"<span class=\"node\">PConst</span>" + "<ul>" + "<li>" + "const: " + Vis_NConst.vis(ctx, const) + "</li>" + "</ul>";
			case PDo(_do, e1, _while, popen, e2, pclose):"<span class=\"node\">PDo</span>" + "<ul>" + "<li>" + "_do: " + VisBase.visToken(ctx, _do) + "</li>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "_while: " + VisBase.visToken(ctx, _while) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PMacro(_macro, e):"<span class=\"node\">PMacro</span>" + "<ul>" + "<li>" + "_macro: " + VisBase.visToken(ctx, _macro) + "</li>" + "<li>" + "e: " + Vis_NMacroExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PWhile(_while, popen, e1, pclose, e2):"<span class=\"node\">PWhile</span>" + "<ul>" + "<li>" + "_while: " + VisBase.visToken(ctx, _while) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "</ul>";
			case PIntDot(int, dot):"<span class=\"node\">PIntDot</span>" + "<ul>" + "<li>" + "int: " + VisBase.visToken(ctx, int) + "</li>" + "<li>" + "dot: " + VisBase.visToken(ctx, dot) + "</li>" + "</ul>";
			case PBlock(bropen, elems, brclose):"<span class=\"node\">PBlock</span>" + "<ul>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "elems: " + VisBase.visArray(ctx, elems, function(el) return Vis_NBlockElement.vis(ctx, el)) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PFunction(_function, f):"<span class=\"node\">PFunction</span>" + "<ul>" + "<li>" + "_function: " + VisBase.visToken(ctx, _function) + "</li>" + "<li>" + "f: " + Vis_NFunction.vis(ctx, f) + "</li>" + "</ul>";
			case PSwitch(_switch, e, bropen, cases, brclose):"<span class=\"node\">PSwitch</span>" + "<ul>" + "<li>" + "_switch: " + VisBase.visToken(ctx, _switch) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "cases: " + VisBase.visArray(ctx, cases, function(el) return Vis_NCase.vis(ctx, el)) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PReturn(_return):"<span class=\"node\">PReturn</span>" + "<ul>" + "<li>" + "_return: " + VisBase.visToken(ctx, _return) + "</li>" + "</ul>";
			case PArrayDecl(bkopen, el, bkclose):"<span class=\"node\">PArrayDecl</span>" + "<ul>" + "<li>" + "bkopen: " + VisBase.visToken(ctx, bkopen) + "</li>" + "<li>" + "el: " + (if (el != null) VisBase.visCommaSeparatedTrailing(ctx, el, function(el) return Vis_NExpr.vis(ctx, el)) else VisBase.none) + "</li>" + "<li>" + "bkclose: " + VisBase.visToken(ctx, bkclose) + "</li>" + "</ul>";
			case PIf(_if, popen, e1, pclose, e2, elseExpr):"<span class=\"node\">PIf</span>" + "<ul>" + "<li>" + "_if: " + VisBase.visToken(ctx, _if) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "<li>" + "elseExpr: " + (if (elseExpr != null) Vis_NExprElse.vis(ctx, elseExpr) else VisBase.none) + "</li>" + "</ul>";
			case PReturnExpr(_return, e):"<span class=\"node\">PReturnExpr</span>" + "<ul>" + "<li>" + "_return: " + VisBase.visToken(ctx, _return) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PArray(e1, bkopen, e2, bkclose):"<span class=\"node\">PArray</span>" + "<ul>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "bkopen: " + VisBase.visToken(ctx, bkopen) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "<li>" + "bkclose: " + VisBase.visToken(ctx, bkclose) + "</li>" + "</ul>";
			case PContinue(_continue):"<span class=\"node\">PContinue</span>" + "<ul>" + "<li>" + "_continue: " + VisBase.visToken(ctx, _continue) + "</li>" + "</ul>";
			case PParenthesis(popen, e, pclose):"<span class=\"node\">PParenthesis</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PTry(_try, e, catches):"<span class=\"node\">PTry</span>" + "<ul>" + "<li>" + "_try: " + VisBase.visToken(ctx, _try) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "catches: " + VisBase.visArray(ctx, catches, function(el) return Vis_NCatch.vis(ctx, el)) + "</li>" + "</ul>";
			case PBreak(_break):"<span class=\"node\">PBreak</span>" + "<ul>" + "<li>" + "_break: " + VisBase.visToken(ctx, _break) + "</li>" + "</ul>";
			case PCall(e, el):"<span class=\"node\">PCall</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "el: " + Vis_NCallArgs.vis(ctx, el) + "</li>" + "</ul>";
			case PUnaryPostfix(e, op):"<span class=\"node\">PUnaryPostfix</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "op: " + VisBase.visToken(ctx, op) + "</li>" + "</ul>";
			case PBinop(e1, op, e2):"<span class=\"node\">PBinop</span>" + "<ul>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "op: " + VisBase.visToken(ctx, op) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "</ul>";
			case PSafeCast(_cast, popen, e, comma, ct, pclose):"<span class=\"node\">PSafeCast</span>" + "<ul>" + "<li>" + "_cast: " + VisBase.visToken(ctx, _cast) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "comma: " + VisBase.visToken(ctx, comma) + "</li>" + "<li>" + "ct: " + Vis_NComplexType.vis(ctx, ct) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PUnaryPrefix(op, e):"<span class=\"node\">PUnaryPrefix</span>" + "<ul>" + "<li>" + "op: " + VisBase.visToken(ctx, op) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PMacroEscape(ident, bropen, e, brclose):"<span class=\"node\">PMacroEscape</span>" + "<ul>" + "<li>" + "ident: " + VisBase.visToken(ctx, ident) + "</li>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PIn(e1, _in, e2):"<span class=\"node\">PIn</span>" + "<ul>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "_in: " + VisBase.visToken(ctx, _in) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "</ul>";
			case PMetadata(metadata, e):"<span class=\"node\">PMetadata</span>" + "<ul>" + "<li>" + "metadata: " + Vis_NMetadata.vis(ctx, metadata) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PUnsafeCast(_cast, e):"<span class=\"node\">PUnsafeCast</span>" + "<ul>" + "<li>" + "_cast: " + VisBase.visToken(ctx, _cast) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PCheckType(popen, e, colon, type, pclose):"<span class=\"node\">PCheckType</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "colon: " + VisBase.visToken(ctx, colon) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PUntyped(_untyped, e):"<span class=\"node\">PUntyped</span>" + "<ul>" + "<li>" + "_untyped: " + VisBase.visToken(ctx, _untyped) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PField(e, ident):"<span class=\"node\">PField</span>" + "<ul>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "ident: " + Vis_NDotIdent.vis(ctx, ident) + "</li>" + "</ul>";
			case PIs(popen, e, _is, path, pclose):"<span class=\"node\">PIs</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "<li>" + "_is: " + VisBase.visToken(ctx, _is) + "</li>" + "<li>" + "path: " + Vis_NTypePath.vis(ctx, path) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PTernary(e1, questionmark, e2, colon, e3):"<span class=\"node\">PTernary</span>" + "<ul>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "questionmark: " + VisBase.visToken(ctx, questionmark) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "<li>" + "colon: " + VisBase.visToken(ctx, colon) + "</li>" + "<li>" + "e3: " + Vis_NExpr.vis(ctx, e3) + "</li>" + "</ul>";
			case PObjectDecl(bropen, fl, brclose):"<span class=\"node\">PObjectDecl</span>" + "<ul>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "fl: " + VisBase.visCommaSeparatedTrailing(ctx, fl, function(el) return Vis_NObjectField.vis(ctx, el)) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PNew(_new, path, el):"<span class=\"node\">PNew</span>" + "<ul>" + "<li>" + "_new: " + VisBase.visToken(ctx, _new) + "</li>" + "<li>" + "path: " + Vis_NTypePath.vis(ctx, path) + "</li>" + "<li>" + "el: " + Vis_NCallArgs.vis(ctx, el) + "</li>" + "</ul>";
			case PThrow(_throw, e):"<span class=\"node\">PThrow</span>" + "<ul>" + "<li>" + "_throw: " + VisBase.visToken(ctx, _throw) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, e) + "</li>" + "</ul>";
			case PFor(_for, popen, e1, pclose, e2):"<span class=\"node\">PFor</span>" + "<ul>" + "<li>" + "_for: " + VisBase.visToken(ctx, _for) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "e1: " + Vis_NExpr.vis(ctx, e1) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "<li>" + "e2: " + Vis_NExpr.vis(ctx, e2) + "</li>" + "</ul>";
		};
	}
}

class Vis_NAnonymousTypeFields {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NAnonymousTypeFields):String {
		return switch v {
			case PAnonymousClassFields(fields):"<span class=\"node\">PAnonymousClassFields</span>" + "<ul>" + "<li>" + "fields: " + VisBase.visArray(ctx, fields, function(el) return Vis_NClassField.vis(ctx, el)) + "</li>" + "</ul>";
			case PAnonymousShortFields(fields):"<span class=\"node\">PAnonymousShortFields</span>" + "<ul>" + "<li>" + "fields: " + (if (fields != null) VisBase.visCommaSeparatedTrailing(ctx, fields, function(el) return Vis_NAnonymousTypeField.vis(ctx, el)) else VisBase.none) + "</li>" + "</ul>";
		};
	}
}

class Vis_NCallArgs {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NCallArgs):String {
		return "<span class=\"node\">NCallArgs</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) VisBase.visCommaSeparated(ctx, v.args, function(el) return Vis_NExpr.vis(ctx, el)) else VisBase.none) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, v.pclose) + "</li>" + "</ul>";
	}
}

class Vis_NDotIdent {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NDotIdent):String {
		return switch v {
			case PDotIdent(name):"<span class=\"node\">PDotIdent</span>" + "<ul>" + "<li>" + "name: " + VisBase.visToken(ctx, name) + "</li>" + "</ul>";
			case PDot(_dot):"<span class=\"node\">PDot</span>" + "<ul>" + "<li>" + "_dot: " + VisBase.visToken(ctx, _dot) + "</li>" + "</ul>";
		};
	}
}

class Vis_NObjectField {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NObjectField):String {
		return "<span class=\"node\">NObjectField</span>" + "<ul>" + "<li>" + "name: " + Vis_NObjectFieldName.vis(ctx, v.name) + "</li>" + "<li>" + "colon: " + VisBase.visToken(ctx, v.colon) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, v.e) + "</li>" + "</ul>";
	}
}

class Vis_NFunction {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NFunction):String {
		return "<span class=\"node\">NFunction</span>" + "<ul>" + "<li>" + "ident: " + (if (v.ident != null) VisBase.visToken(ctx, v.ident) else VisBase.none) + "</li>" + "<li>" + "params: " + (if (v.params != null) Vis_NTypeDeclParameters.vis(ctx, v.params) else VisBase.none) + "</li>" + "<li>" + "popen: " + VisBase.visToken(ctx, v.popen) + "</li>" + "<li>" + "args: " + (if (v.args != null) VisBase.visCommaSeparated(ctx, v.args, function(el) return Vis_NFunctionArgument.vis(ctx, el)) else VisBase.none) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, v.pclose) + "</li>" + "<li>" + "type: " + (if (v.type != null) Vis_NTypeHint.vis(ctx, v.type) else VisBase.none) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, v.e) + "</li>" + "</ul>";
	}
}

class Vis_NImport {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NImport):String {
		return "<span class=\"node\">NImport</span>" + "<ul>" + "<li>" + "path: " + Vis_NPath.vis(ctx, v.path) + "</li>" + "<li>" + "mode: " + Vis_NImportMode.vis(ctx, v.mode) + "</li>" + "</ul>";
	}
}

class Vis_NComplexType {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NComplexType):String {
		return switch v {
			case PFunctionType(type1, arrow, type2):"<span class=\"node\">PFunctionType</span>" + "<ul>" + "<li>" + "type1: " + Vis_NComplexType.vis(ctx, type1) + "</li>" + "<li>" + "arrow: " + VisBase.visToken(ctx, arrow) + "</li>" + "<li>" + "type2: " + Vis_NComplexType.vis(ctx, type2) + "</li>" + "</ul>";
			case PStructuralExtension(bropen, types, fields, brclose):"<span class=\"node\">PStructuralExtension</span>" + "<ul>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "types: " + VisBase.visArray(ctx, types, function(el) return Vis_NStructuralExtension.vis(ctx, el)) + "</li>" + "<li>" + "fields: " + Vis_NAnonymousTypeFields.vis(ctx, fields) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PParenthesisType(popen, ct, pclose):"<span class=\"node\">PParenthesisType</span>" + "<ul>" + "<li>" + "popen: " + VisBase.visToken(ctx, popen) + "</li>" + "<li>" + "ct: " + Vis_NComplexType.vis(ctx, ct) + "</li>" + "<li>" + "pclose: " + VisBase.visToken(ctx, pclose) + "</li>" + "</ul>";
			case PAnoymousStructure(bropen, fields, brclose):"<span class=\"node\">PAnoymousStructure</span>" + "<ul>" + "<li>" + "bropen: " + VisBase.visToken(ctx, bropen) + "</li>" + "<li>" + "fields: " + Vis_NAnonymousTypeFields.vis(ctx, fields) + "</li>" + "<li>" + "brclose: " + VisBase.visToken(ctx, brclose) + "</li>" + "</ul>";
			case PTypePath(path):"<span class=\"node\">PTypePath</span>" + "<ul>" + "<li>" + "path: " + Vis_NTypePath.vis(ctx, path) + "</li>" + "</ul>";
			case POptionalType(questionmark, type):"<span class=\"node\">POptionalType</span>" + "<ul>" + "<li>" + "questionmark: " + VisBase.visToken(ctx, questionmark) + "</li>" + "<li>" + "type: " + Vis_NComplexType.vis(ctx, type) + "</li>" + "</ul>";
		};
	}
}

class Vis_NExprElse {
	static public function vis(ctx:SyntaxTreePrinter, v:hxParser.ParseTree.NExprElse):String {
		return "<span class=\"node\">NExprElse</span>" + "<ul>" + "<li>" + "_else: " + VisBase.visToken(ctx, v._else) + "</li>" + "<li>" + "e: " + Vis_NExpr.vis(ctx, v.e) + "</li>" + "</ul>";
	}
}