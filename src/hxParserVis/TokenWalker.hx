package hxParserVis;

import hxParser.ParseTree;

class TokenWalker {
	static public function walk_NFile(__value:NFile, __callback:Token -> Void) {
		if (__value.pack != null) walk_NPackage(__value.pack, __callback);
		TokenWalkerBase.walkArray(__value.decls, function(el) return walk_NDecl(el, __callback));
		__callback(__value.eof);
	}
	static public function walk_NPackage(__value:NPackage, __callback:Token -> Void) {
		__callback(__value._package);
		if (__value.path != null) walk_NPath(__value.path, __callback);
		__callback(__value.semicolon);
	}
	static public function walk_NImportMode(__value:NImportMode, __callback:Token -> Void) {
		switch __value {
			case PAsMode(_as, ident):{
				__callback(_as);
				__callback(ident);
			};
			case PNormalMode:{ };
			case PInMode(_in, ident):{
				__callback(_in);
				__callback(ident);
			};
			case PAllMode(dotstar):{
				__callback(dotstar);
			};
		};
	}
	static public function walk_NLiteral(__value:NLiteral, __callback:Token -> Void) {
		switch __value {
			case PLiteralString(s):{
				walk_NString(s, __callback);
			};
			case PLiteralFloat(token):{
				__callback(token);
			};
			case PLiteralRegex(token):{
				__callback(token);
			};
			case PLiteralInt(token):{
				__callback(token);
			};
		};
	}
	static public function walk_NAssignment(__value:NAssignment, __callback:Token -> Void) {
		__callback(__value.assign);
		walk_NExpr(__value.e, __callback);
	}
	static public function walk_NObjectFieldName(__value:NObjectFieldName, __callback:Token -> Void) {
		switch __value {
			case PString(string):{
				walk_NString(string, __callback);
			};
			case PIdent(ident):{
				__callback(ident);
			};
		};
	}
	static public function walk_NAbstractRelation(__value:NAbstractRelation, __callback:Token -> Void) {
		switch __value {
			case PFrom(_from, type):{
				__callback(_from);
				walk_NComplexType(type, __callback);
			};
			case PTo(_to, type):{
				__callback(_to);
				walk_NComplexType(type, __callback);
			};
		};
	}
	static public function walk_NTypeHint(__value:NTypeHint, __callback:Token -> Void) {
		__callback(__value.colon);
		walk_NComplexType(__value.type, __callback);
	}
	static public function walk_NClassDecl(__value:NClassDecl, __callback:Token -> Void) {
		__callback(__value.kind);
		__callback(__value.name);
		if (__value.params != null) walk_NTypeDeclParameters(__value.params, __callback);
		TokenWalkerBase.walkArray(__value.relations, function(el) return walk_NClassRelation(el, __callback));
		__callback(__value.bropen);
		TokenWalkerBase.walkArray(__value.fields, function(el) return walk_NClassField(el, __callback));
		__callback(__value.brclose);
	}
	static public function walk_NCatch(__value:NCatch, __callback:Token -> Void) {
		__callback(__value._catch);
		__callback(__value.popen);
		__callback(__value.ident);
		walk_NTypeHint(__value.type, __callback);
		__callback(__value.pclose);
		walk_NExpr(__value.e, __callback);
	}
	static public function walk_NTypeDeclParameter(__value:NTypeDeclParameter, __callback:Token -> Void) {
		walk_NAnnotations(__value.annotations, __callback);
		__callback(__value.name);
		walk_NConstraints(__value.constraints, __callback);
	}
	static public function walk_NConst(__value:NConst, __callback:Token -> Void) {
		switch __value {
			case PConstLiteral(literal):{
				walk_NLiteral(literal, __callback);
			};
			case PConstIdent(ident):{
				__callback(ident);
			};
		};
	}
	static public function walk_NTypePathParameters(__value:NTypePathParameters, __callback:Token -> Void) {
		__callback(__value.lt);
		TokenWalkerBase.walkCommaSeparated(__value.parameters, function(el) return walk_NTypePathParameter(el, __callback), __callback);
		__callback(__value.gt);
	}
	static public function walk_NModifier(__value:NModifier, __callback:Token -> Void) {
		switch __value {
			case PModifierStatic(token):{
				__callback(token);
			};
			case PModifierOverride(token):{
				__callback(token);
			};
			case PModifierMacro(token):{
				__callback(token);
			};
			case PModifierDynamic(token):{
				__callback(token);
			};
			case PModifierInline(token):{
				__callback(token);
			};
			case PModifierPrivate(token):{
				__callback(token);
			};
			case PModifierPublic(token):{
				__callback(token);
			};
		};
	}
	static public function walk_NFieldExpr(__value:NFieldExpr, __callback:Token -> Void) {
		switch __value {
			case PNoFieldExpr(semicolon):{
				__callback(semicolon);
			};
			case PBlockFieldExpr(e):{
				walk_NExpr(e, __callback);
			};
			case PExprFieldExpr(e, semicolon):{
				walk_NExpr(e, __callback);
				__callback(semicolon);
			};
		};
	}
	static public function walk_NCommonFlag(__value:NCommonFlag, __callback:Token -> Void) {
		switch __value {
			case PExtern(token):{
				__callback(token);
			};
			case PPrivate(token):{
				__callback(token);
			};
		};
	}
	static public function walk_NEnumFieldArgs(__value:NEnumFieldArgs, __callback:Token -> Void) {
		__callback(__value.popen);
		if (__value.args != null) TokenWalkerBase.walkCommaSeparated(__value.args, function(el) return walk_NEnumFieldArg(el, __callback), __callback);
		__callback(__value.pclose);
	}
	static public function walk_NFunctionArgument(__value:NFunctionArgument, __callback:Token -> Void) {
		walk_NAnnotations(__value.annotations, __callback);
		if (__value.questionmark != null) __callback(__value.questionmark);
		__callback(__value.name);
		if (__value.typeHint != null) walk_NTypeHint(__value.typeHint, __callback);
		if (__value.assignment != null) walk_NAssignment(__value.assignment, __callback);
	}
	static public function walk_NAnonymousTypeField(__value:NAnonymousTypeField, __callback:Token -> Void) {
		if (__value.questionmark != null) __callback(__value.questionmark);
		__callback(__value.name);
		__callback(__value.colon);
		walk_NComplexType(__value.type, __callback);
	}
	static public function walk_NUnderlyingType(__value:NUnderlyingType, __callback:Token -> Void) {
		__callback(__value.popen);
		walk_NComplexType(__value.type, __callback);
		__callback(__value.pclose);
	}
	static public function walk_NTypePathParameter(__value:NTypePathParameter, __callback:Token -> Void) {
		switch __value {
			case PArrayExprTypePathParameter(bkopen, el, bkclose):{
				__callback(bkopen);
				if (el != null) TokenWalkerBase.walkCommaSeparatedTrailing(el, function(el) return walk_NExpr(el, __callback), __callback);
				__callback(bkclose);
			};
			case PConstantTypePathParameter(constant):{
				walk_NLiteral(constant, __callback);
			};
			case PTypeTypePathParameter(type):{
				walk_NComplexType(type, __callback);
			};
		};
	}
	static public function walk_NTypeDeclParameters(__value:NTypeDeclParameters, __callback:Token -> Void) {
		__callback(__value.lt);
		TokenWalkerBase.walkCommaSeparated(__value.params, function(el) return walk_NTypeDeclParameter(el, __callback), __callback);
		__callback(__value.gt);
	}
	static public function walk_NGuard(__value:NGuard, __callback:Token -> Void) {
		__callback(__value._if);
		__callback(__value.popen);
		walk_NExpr(__value.e, __callback);
		__callback(__value.pclose);
	}
	static public function walk_NMacroExpr(__value:NMacroExpr, __callback:Token -> Void) {
		switch __value {
			case PVar(_var, v):{
				__callback(_var);
				TokenWalkerBase.walkCommaSeparated(v, function(el) return walk_NVarDeclaration(el, __callback), __callback);
			};
			case PTypeHint(type):{
				walk_NTypeHint(type, __callback);
			};
			case PClass(c):{
				walk_NClassDecl(c, __callback);
			};
			case PExpr(e):{
				walk_NExpr(e, __callback);
			};
		};
	}
	static public function walk_NEnumField(__value:NEnumField, __callback:Token -> Void) {
		walk_NAnnotations(__value.annotations, __callback);
		__callback(__value.name);
		if (__value.params != null) walk_NTypeDeclParameters(__value.params, __callback);
		if (__value.args != null) walk_NEnumFieldArgs(__value.args, __callback);
		if (__value.type != null) walk_NTypeHint(__value.type, __callback);
		__callback(__value.semicolon);
	}
	static public function walk_NPath(__value:NPath, __callback:Token -> Void) {
		__callback(__value.ident);
		TokenWalkerBase.walkArray(__value.idents, function(el) return walk_NDotIdent(el, __callback));
	}
	static public function walk_NDecl(__value:NDecl, __callback:Token -> Void) {
		switch __value {
			case PClassDecl(annotations, flags, c):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(flags, function(el) return walk_NCommonFlag(el, __callback));
				walk_NClassDecl(c, __callback);
			};
			case PTypedefDecl(annotations, flags, _typedef, name, params, assign, type, semicolon):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(flags, function(el) return walk_NCommonFlag(el, __callback));
				__callback(_typedef);
				__callback(name);
				if (params != null) walk_NTypeDeclParameters(params, __callback);
				__callback(assign);
				walk_NComplexType(type, __callback);
				if (semicolon != null) __callback(semicolon);
			};
			case PUsingDecl(_using, path, semicolon):{
				__callback(_using);
				walk_NPath(path, __callback);
				__callback(semicolon);
			};
			case PImportDecl(_import, importPath, semicolon):{
				__callback(_import);
				walk_NImport(importPath, __callback);
				__callback(semicolon);
			};
			case PAbstractDecl(annotations, flags, _abstract, name, params, underlyingType, relations, bropen, fields, brclose):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(flags, function(el) return walk_NCommonFlag(el, __callback));
				__callback(_abstract);
				__callback(name);
				if (params != null) walk_NTypeDeclParameters(params, __callback);
				if (underlyingType != null) walk_NUnderlyingType(underlyingType, __callback);
				TokenWalkerBase.walkArray(relations, function(el) return walk_NAbstractRelation(el, __callback));
				__callback(bropen);
				TokenWalkerBase.walkArray(fields, function(el) return walk_NClassField(el, __callback));
				__callback(brclose);
			};
			case PEnumDecl(annotations, flags, _enum, name, params, bropen, fields, brclose):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(flags, function(el) return walk_NCommonFlag(el, __callback));
				__callback(_enum);
				__callback(name);
				if (params != null) walk_NTypeDeclParameters(params, __callback);
				__callback(bropen);
				TokenWalkerBase.walkArray(fields, function(el) return walk_NEnumField(el, __callback));
				__callback(brclose);
			};
		};
	}
	static public function walk_NConstraints(__value:NConstraints, __callback:Token -> Void) {
		switch __value {
			case PMultipleConstraints(colon, popen, types, pclose):{
				__callback(colon);
				__callback(popen);
				TokenWalkerBase.walkCommaSeparated(types, function(el) return walk_NComplexType(el, __callback), __callback);
				__callback(pclose);
			};
			case PSingleConstraint(colon, type):{
				__callback(colon);
				walk_NComplexType(type, __callback);
			};
			case PNoConstraints:{ };
		};
	}
	static public function walk_NBlockElement(__value:NBlockElement, __callback:Token -> Void) {
		switch __value {
			case PVar(_var, vl, semicolon):{
				__callback(_var);
				TokenWalkerBase.walkCommaSeparated(vl, function(el) return walk_NVarDeclaration(el, __callback), __callback);
				__callback(semicolon);
			};
			case PExpr(e, semicolon):{
				walk_NExpr(e, __callback);
				__callback(semicolon);
			};
			case PInlineFunction(_inline, _function, f, semicolon):{
				__callback(_inline);
				__callback(_function);
				walk_NFunction(f, __callback);
				__callback(semicolon);
			};
		};
	}
	static public function walk_NClassField(__value:NClassField, __callback:Token -> Void) {
		switch __value {
			case PPropertyField(annotations, modifiers, _var, name, popen, get, comma, set, pclose, typeHint, assignment):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(modifiers, function(el) return walk_NModifier(el, __callback));
				__callback(_var);
				__callback(name);
				__callback(popen);
				__callback(get);
				__callback(comma);
				__callback(set);
				__callback(pclose);
				if (typeHint != null) walk_NTypeHint(typeHint, __callback);
				if (assignment != null) walk_NAssignment(assignment, __callback);
			};
			case PVariableField(annotations, modifiers, _var, name, typeHint, assignment, semicolon):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(modifiers, function(el) return walk_NModifier(el, __callback));
				__callback(_var);
				__callback(name);
				if (typeHint != null) walk_NTypeHint(typeHint, __callback);
				if (assignment != null) walk_NAssignment(assignment, __callback);
				__callback(semicolon);
			};
			case PFunctionField(annotations, modifiers, _function, name, params, popen, args, pclose, typeHint, e):{
				walk_NAnnotations(annotations, __callback);
				TokenWalkerBase.walkArray(modifiers, function(el) return walk_NModifier(el, __callback));
				__callback(_function);
				__callback(name);
				if (params != null) walk_NTypeDeclParameters(params, __callback);
				__callback(popen);
				if (args != null) TokenWalkerBase.walkCommaSeparated(args, function(el) return walk_NFunctionArgument(el, __callback), __callback);
				__callback(pclose);
				if (typeHint != null) walk_NTypeHint(typeHint, __callback);
				if (e != null) walk_NFieldExpr(e, __callback);
			};
		};
	}
	static public function walk_NClassRelation(__value:NClassRelation, __callback:Token -> Void) {
		switch __value {
			case PExtends(_extends, path):{
				__callback(_extends);
				walk_NTypePath(path, __callback);
			};
			case PImplements(_implements, path):{
				__callback(_implements);
				walk_NTypePath(path, __callback);
			};
		};
	}
	static public function walk_NCase(__value:NCase, __callback:Token -> Void) {
		switch __value {
			case PCase(_case, patterns, guard, colon, el):{
				__callback(_case);
				TokenWalkerBase.walkCommaSeparated(patterns, function(el) return walk_NExpr(el, __callback), __callback);
				if (guard != null) walk_NGuard(guard, __callback);
				__callback(colon);
				TokenWalkerBase.walkArray(el, function(el) return walk_NBlockElement(el, __callback));
			};
			case PDefault(_default, colon, el):{
				__callback(_default);
				__callback(colon);
				TokenWalkerBase.walkArray(el, function(el) return walk_NBlockElement(el, __callback));
			};
		};
	}
	static public function walk_NStructuralExtension(__value:NStructuralExtension, __callback:Token -> Void) {
		__callback(__value.gt);
		walk_NTypePath(__value.path, __callback);
		__callback(__value.comma);
	}
	static public function walk_NEnumFieldArg(__value:NEnumFieldArg, __callback:Token -> Void) {
		if (__value.questionmark != null) __callback(__value.questionmark);
		__callback(__value.name);
		walk_NTypeHint(__value.typeHint, __callback);
	}
	static public function walk_NMetadata(__value:NMetadata, __callback:Token -> Void) {
		switch __value {
			case PMetadata(name):{
				__callback(name);
			};
			case PMetadataWithArgs(name, el, pclose):{
				__callback(name);
				TokenWalkerBase.walkCommaSeparated(el, function(el) return walk_NExpr(el, __callback), __callback);
				__callback(pclose);
			};
		};
	}
	static public function walk_NVarDeclaration(__value:NVarDeclaration, __callback:Token -> Void) {
		__callback(__value.name);
		if (__value.type != null) walk_NTypeHint(__value.type, __callback);
		if (__value.assignment != null) walk_NAssignment(__value.assignment, __callback);
	}
	static public function walk_NTypePath(__value:NTypePath, __callback:Token -> Void) {
		walk_NPath(__value.path, __callback);
		if (__value.params != null) walk_NTypePathParameters(__value.params, __callback);
	}
	static public function walk_NString(__value:NString, __callback:Token -> Void) {
		switch __value {
			case PString(s):{
				__callback(s);
			};
			case PString2(s):{
				__callback(s);
			};
		};
	}
	static public function walk_NAnnotations(__value:NAnnotations, __callback:Token -> Void) {
		if (__value.doc != null) __callback(__value.doc);
		TokenWalkerBase.walkArray(__value.meta, function(el) return walk_NMetadata(el, __callback));
	}
	static public function walk_NExpr(__value:NExpr, __callback:Token -> Void) {
		switch __value {
			case PVar(_var, d):{
				__callback(_var);
				walk_NVarDeclaration(d, __callback);
			};
			case PConst(const):{
				walk_NConst(const, __callback);
			};
			case PDo(_do, e1, _while, popen, e2, pclose):{
				__callback(_do);
				walk_NExpr(e1, __callback);
				__callback(_while);
				__callback(popen);
				walk_NExpr(e2, __callback);
				__callback(pclose);
			};
			case PMacro(_macro, e):{
				__callback(_macro);
				walk_NMacroExpr(e, __callback);
			};
			case PWhile(_while, popen, e1, pclose, e2):{
				__callback(_while);
				__callback(popen);
				walk_NExpr(e1, __callback);
				__callback(pclose);
				walk_NExpr(e2, __callback);
			};
			case PIntDot(int, dot):{
				__callback(int);
				__callback(dot);
			};
			case PBlock(bropen, elems, brclose):{
				__callback(bropen);
				TokenWalkerBase.walkArray(elems, function(el) return walk_NBlockElement(el, __callback));
				__callback(brclose);
			};
			case PFunction(_function, f):{
				__callback(_function);
				walk_NFunction(f, __callback);
			};
			case PSwitch(_switch, e, bropen, cases, brclose):{
				__callback(_switch);
				walk_NExpr(e, __callback);
				__callback(bropen);
				TokenWalkerBase.walkArray(cases, function(el) return walk_NCase(el, __callback));
				__callback(brclose);
			};
			case PReturn(_return):{
				__callback(_return);
			};
			case PArrayDecl(bkopen, el, bkclose):{
				__callback(bkopen);
				if (el != null) TokenWalkerBase.walkCommaSeparatedTrailing(el, function(el) return walk_NExpr(el, __callback), __callback);
				__callback(bkclose);
			};
			case PIf(_if, popen, e1, pclose, e2, elseExpr):{
				__callback(_if);
				__callback(popen);
				walk_NExpr(e1, __callback);
				__callback(pclose);
				walk_NExpr(e2, __callback);
				if (elseExpr != null) walk_NExprElse(elseExpr, __callback);
			};
			case PReturnExpr(_return, e):{
				__callback(_return);
				walk_NExpr(e, __callback);
			};
			case PArray(e1, bkopen, e2, bkclose):{
				walk_NExpr(e1, __callback);
				__callback(bkopen);
				walk_NExpr(e2, __callback);
				__callback(bkclose);
			};
			case PContinue(_continue):{
				__callback(_continue);
			};
			case PParenthesis(popen, e, pclose):{
				__callback(popen);
				walk_NExpr(e, __callback);
				__callback(pclose);
			};
			case PTry(_try, e, catches):{
				__callback(_try);
				walk_NExpr(e, __callback);
				TokenWalkerBase.walkArray(catches, function(el) return walk_NCatch(el, __callback));
			};
			case PBreak(_break):{
				__callback(_break);
			};
			case PCall(e, el):{
				walk_NExpr(e, __callback);
				walk_NCallArgs(el, __callback);
			};
			case PUnaryPostfix(e, op):{
				walk_NExpr(e, __callback);
				__callback(op);
			};
			case PBinop(e1, op, e2):{
				walk_NExpr(e1, __callback);
				__callback(op);
				walk_NExpr(e2, __callback);
			};
			case PSafeCast(_cast, popen, e, comma, ct, pclose):{
				__callback(_cast);
				__callback(popen);
				walk_NExpr(e, __callback);
				__callback(comma);
				walk_NComplexType(ct, __callback);
				__callback(pclose);
			};
			case PUnaryPrefix(op, e):{
				__callback(op);
				walk_NExpr(e, __callback);
			};
			case PMacroEscape(ident, bropen, e, brclose):{
				__callback(ident);
				__callback(bropen);
				walk_NExpr(e, __callback);
				__callback(brclose);
			};
			case PIn(e1, _in, e2):{
				walk_NExpr(e1, __callback);
				__callback(_in);
				walk_NExpr(e2, __callback);
			};
			case PMetadata(metadata, e):{
				walk_NMetadata(metadata, __callback);
				walk_NExpr(e, __callback);
			};
			case PUnsafeCast(_cast, e):{
				__callback(_cast);
				walk_NExpr(e, __callback);
			};
			case PCheckType(popen, e, colon, type, pclose):{
				__callback(popen);
				walk_NExpr(e, __callback);
				__callback(colon);
				walk_NComplexType(type, __callback);
				__callback(pclose);
			};
			case PUntyped(_untyped, e):{
				__callback(_untyped);
				walk_NExpr(e, __callback);
			};
			case PField(e, ident):{
				walk_NExpr(e, __callback);
				walk_NDotIdent(ident, __callback);
			};
			case PIs(popen, e, _is, path, pclose):{
				__callback(popen);
				walk_NExpr(e, __callback);
				__callback(_is);
				walk_NTypePath(path, __callback);
				__callback(pclose);
			};
			case PTernary(e1, questionmark, e2, colon, e3):{
				walk_NExpr(e1, __callback);
				__callback(questionmark);
				walk_NExpr(e2, __callback);
				__callback(colon);
				walk_NExpr(e3, __callback);
			};
			case PObjectDecl(bropen, fl, brclose):{
				__callback(bropen);
				TokenWalkerBase.walkCommaSeparatedTrailing(fl, function(el) return walk_NObjectField(el, __callback), __callback);
				__callback(brclose);
			};
			case PNew(_new, path, el):{
				__callback(_new);
				walk_NTypePath(path, __callback);
				walk_NCallArgs(el, __callback);
			};
			case PThrow(_throw, e):{
				__callback(_throw);
				walk_NExpr(e, __callback);
			};
			case PFor(_for, popen, e1, pclose, e2):{
				__callback(_for);
				__callback(popen);
				walk_NExpr(e1, __callback);
				__callback(pclose);
				walk_NExpr(e2, __callback);
			};
		};
	}
	static public function walk_NAnonymousTypeFields(__value:NAnonymousTypeFields, __callback:Token -> Void) {
		switch __value {
			case PAnonymousClassFields(fields):{
				TokenWalkerBase.walkArray(fields, function(el) return walk_NClassField(el, __callback));
			};
			case PAnonymousShortFields(fields):{
				if (fields != null) TokenWalkerBase.walkCommaSeparatedTrailing(fields, function(el) return walk_NAnonymousTypeField(el, __callback), __callback);
			};
		};
	}
	static public function walk_NCallArgs(__value:NCallArgs, __callback:Token -> Void) {
		__callback(__value.popen);
		if (__value.args != null) TokenWalkerBase.walkCommaSeparated(__value.args, function(el) return walk_NExpr(el, __callback), __callback);
		__callback(__value.pclose);
	}
	static public function walk_NDotIdent(__value:NDotIdent, __callback:Token -> Void) {
		switch __value {
			case PDotIdent(name):{
				__callback(name);
			};
			case PDot(_dot):{
				__callback(_dot);
			};
		};
	}
	static public function walk_NObjectField(__value:NObjectField, __callback:Token -> Void) {
		walk_NObjectFieldName(__value.name, __callback);
		__callback(__value.colon);
		walk_NExpr(__value.e, __callback);
	}
	static public function walk_NFunction(__value:NFunction, __callback:Token -> Void) {
		if (__value.ident != null) __callback(__value.ident);
		if (__value.params != null) walk_NTypeDeclParameters(__value.params, __callback);
		__callback(__value.popen);
		if (__value.args != null) TokenWalkerBase.walkCommaSeparated(__value.args, function(el) return walk_NFunctionArgument(el, __callback), __callback);
		__callback(__value.pclose);
		if (__value.type != null) walk_NTypeHint(__value.type, __callback);
		walk_NExpr(__value.e, __callback);
	}
	static public function walk_NImport(__value:NImport, __callback:Token -> Void) {
		walk_NPath(__value.path, __callback);
		walk_NImportMode(__value.mode, __callback);
	}
	static public function walk_NComplexType(__value:NComplexType, __callback:Token -> Void) {
		switch __value {
			case PFunctionType(type1, arrow, type2):{
				walk_NComplexType(type1, __callback);
				__callback(arrow);
				walk_NComplexType(type2, __callback);
			};
			case PStructuralExtension(bropen, types, fields, brclose):{
				__callback(bropen);
				TokenWalkerBase.walkArray(types, function(el) return walk_NStructuralExtension(el, __callback));
				walk_NAnonymousTypeFields(fields, __callback);
				__callback(brclose);
			};
			case PParenthesisType(popen, ct, pclose):{
				__callback(popen);
				walk_NComplexType(ct, __callback);
				__callback(pclose);
			};
			case PAnoymousStructure(bropen, fields, brclose):{
				__callback(bropen);
				walk_NAnonymousTypeFields(fields, __callback);
				__callback(brclose);
			};
			case PTypePath(path):{
				walk_NTypePath(path, __callback);
			};
			case POptionalType(questionmark, type):{
				__callback(questionmark);
				walk_NComplexType(type, __callback);
			};
		};
	}
	static public function walk_NExprElse(__value:NExprElse, __callback:Token -> Void) {
		__callback(__value._else);
		walk_NExpr(__value.e, __callback);
	}
}