package hxParserVis;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class GenVis {
    static function gen() {
        var root = Context.getType("hxParser.ParseTree.NFile");
        var types = new Map();
        genVis(macro v, root, root, types, null);
        Context.defineModule("hxParserVis.Vis", Lambda.array(types));
        // var printer = new haxe.macro.Printer();
        // var parts = [];
        // for (td in types)
        //     parts.push(printer.printTypeDefinition(td));
        // sys.io.File.saveContent("src/Vis.hx", parts.join("\n\n"));
    }

    static function genVis(expr:Expr, type:Type, origType, types:Map<String,TypeDefinition>, name:Null<String>):Expr {
        switch (type) {
            case TInst(_.get() => {pack: ["hxParser"], name: "Token"}, _):
                return macro VisBase.visToken($expr);

            case TInst(_.get() => {pack: [], name: "Array"}, [elemT]) if (name != null):
                var visExpr = genVis(macro el, elemT, elemT, types, name + "_elem");
                return macro VisBase.visArray($expr, function(el) return $visExpr);

            case TType(_.get() => dt, params):
                switch [dt, params] {
                    case [{pack: ["hxParser"], name: "NCommaSeparated"}, [elemT]] if (name != null):
                        var visExpr = genVis(macro el, elemT, elemT, types, name + "_elem");
                        return macro VisBase.visCommaSeparated($expr, function(el) return $visExpr);

                    case [{pack: ["hxParser"], name: "NCommaSeparatedAllowTrailing"}, [elemT]] if (name != null):
                        var visExpr = genVis(macro el, elemT, elemT, types, name + "_elem");
                        return macro VisBase.visCommaSeparatedTrailing($expr, function(el) return $visExpr);

                    case [{pack: [], name: "Null"}, [realType]]:
                        var visExpr = genVis(expr, realType, realType, types, name);
                        return macro (if ($expr != null) $visExpr else VisBase.none);
                    default:
                        return genVis(expr, dt.type.applyTypeParameters(dt.params, params), origType, types, dt.name);
                }

            case TEnum(_.get() => en, _):
                return genEnumVis(expr, en, origType, types);

            case TAnonymous(_.get() => anon) if (name != null):
                return genAnonVis(expr, anon, origType, types, name);

            default:
        }
        throw 'TODO: ${type.toString()}';
    }

    static function genEnumVis(expr:Expr, en:EnumType, origType:Type, types:Map<String,TypeDefinition>):Expr {
        var visName = "Vis_" + en.name;
        if (!types.exists(en.name)) {
            types.set(en.name, null); // TODO: this sucks

            var cases = [];
            for (ctor in en.constructs) {
                switch (ctor.type) {
                    case TFun(args, _):
                        var patternArgs = [];
                        var exprs = [];
                        for (arg in args) {
                            var local = macro $i{arg.name};
                            patternArgs.push(local);
                            var visExpr = genVis(local, arg.t, arg.t, types, en.name + "_" + ctor.name + "_" + arg.name);
                            exprs.push(macro $v{arg.name + ": "} + $visExpr);
                        }

                        var argList = macro ${Lambda.fold(exprs, function(e, acc) {
                            return macro $acc + "<li>" + $e + "</li>";
                        }, macro "<ul>")} + "</ul>";

                        cases.push({
                            values: [macro $i{ctor.name}($a{patternArgs})],
                            expr: macro $v{'<span class="node">${ctor.name}</span>'} + $argList,
                        });

                    case TEnum(_):
                        cases.push({
                            values: [macro $i{ctor.name}],
                            expr: macro $v{ctor.name},
                        });

                    default: throw false;
                }
            }

            var expr = {expr: ESwitch(macro v, cases, null), pos: en.pos};

            var ct = origType.toComplexType();
            var td = macro class $visName {
                public static function vis(v:$ct):String {
                    return $expr;
                }
            }

            types.set(en.name, td);
        }
        return macro $i{visName}.vis($expr);
    }

    static function genAnonVis(expr:Expr, anon:AnonType, origType:Type, types:Map<String,TypeDefinition>, name:String):Expr {
        var visName = 'Vis_$name';
        if (!types.exists(name)) {
            types.set(name, null); // TODO: this sucks

            var exprs = [];
            anon.fields.sort(function(a,b) return Context.getPosInfos(a.pos).min - Context.getPosInfos(b.pos).min);
            for (field in anon.fields) {
                var fname = field.name;
                var visExpr = genVis(macro v.$fname, field.type, field.type, types, name + "_" + fname);
                exprs.push(macro $v{fname + ": "} + $visExpr);
            }

            var expr = macro ${Lambda.fold(exprs, function(el, acc) {
                return macro $acc + "<li>" + $el + "</li>";
            }, macro "<ul>")} + "</ul>";

            var ct = origType.toComplexType();
            var td = macro class $visName {
                public static function vis(v:$ct):String {
                    return $v{'<span class="node">${name}</span>'} + $expr;
                }
            }

            types.set(name, td);
        }
        return macro $i{visName}.vis($expr);
    }
}
#end
