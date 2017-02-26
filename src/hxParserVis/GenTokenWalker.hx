package hxParserVis;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class GenTokenWalker {
    static function gen() {
        var root = Context.getType("hxParser.ParseTree.NFile");
        var fields = new Map();
        genWalk(macro v, root, root, fields, null);
        // Context.defineModule("hxParserVis.Vis", Lambda.array(types));
        var printer = new haxe.macro.Printer();
        var parts = [
            "package hxParserVis;",
            "import hxParser.ParseTree;"
        ];
        parts.push(printer.printTypeDefinition({
            pos: null,
            pack: [],
            name: "TokenWalker",
            kind: TDClass(),
            fields: Lambda.array(fields),
        }));
        sys.io.File.saveContent("src/hxParserVis/TokenWalker.hx", parts.join("\n\n"));
    }

    static function genWalk(expr:Expr, type:Type, origType, types:Map<String,Field>, name:Null<String>):Expr {
        switch (type) {
            case TInst(_.get() => {pack: ["hxParser"], name: "Token"}, _):
                return macro __callback($expr);

            case TInst(_.get() => {pack: [], name: "Array"}, [elemT]) if (name != null):
                var visExpr = genWalk(macro el, elemT, elemT, types, name + "_elem");
                return macro TokenWalkerBase.walkArray($expr, function(el) return $visExpr);

            case TType(_.get() => dt, params):
                switch [dt, params] {
                    case [{pack: ["hxParser"], name: "NCommaSeparated"}, [elemT]] if (name != null):
                        var visExpr = genWalk(macro el, elemT, elemT, types, name + "_elem");
                        return macro TokenWalkerBase.walkCommaSeparated($expr, function(el) return $visExpr, __callback);

                    case [{pack: ["hxParser"], name: "NCommaSeparatedAllowTrailing"}, [elemT]] if (name != null):
                        var visExpr = genWalk(macro el, elemT, elemT, types, name + "_elem");
                        return macro TokenWalkerBase.walkCommaSeparatedTrailing($expr, function(el) return $visExpr, __callback);

                    case [{pack: [], name: "Null"}, [realType]]:
                        var walkExpr = genWalk(expr, realType, realType, types, name);
                        return macro if ($expr != null) $walkExpr;
                    default:
                        return genWalk(expr, dt.type.applyTypeParameters(dt.params, params), origType, types, dt.name);
                }

            case TEnum(_.get() => en, _):
                return genEnumWalk(expr, en, origType, types);

            case TAnonymous(_.get() => anon) if (name != null):
                return genAnonWalk(expr, anon, origType, types, name);

            default:
        }
        throw 'TODO: ${type.toString()}';
    }

    static function genEnumWalk(expr:Expr, en:EnumType, origType:Type, fields:Map<String,Field>):Expr {
        var visName = "walk_" + en.name;
        if (!fields.exists(en.name)) {
            fields.set(en.name, null); // TODO: this sucks

            var cases = [];
            for (ctor in en.constructs) {
                switch (ctor.type) {
                    case TFun(args, _):
                        var patternArgs = [];
                        var exprs = [];
                        for (arg in args) {
                            var local = macro $i{arg.name};
                            patternArgs.push(local);
                            exprs.push(genWalk(local, arg.t, arg.t, fields, en.name + "_" + ctor.name + "_" + arg.name));
                        }

                        cases.push({
                            values: [macro $i{ctor.name}($a{patternArgs})],
                            expr: macro $b{exprs},
                        });

                    case TEnum(_):
                        cases.push({
                            values: [macro $i{ctor.name}],
                            expr: macro {},
                        });

                    default: throw false;
                }
            }

            var expr = {expr: ESwitch(macro __value, cases, null), pos: en.pos};

            fields.set(en.name, {
                pos: en.pos,
                name: visName,
                access: [AStatic,APublic],
                kind: FFun({
                    args: [
                        {name: "__value", type: extractTypeName(origType) },
                        {name: "__callback", type: macro : Token->Void}
                    ],
                    ret: null,
                    expr: macro { $expr; },
                })
            });
        }
        return macro $i{visName}($expr, __callback);
    }

    static function genAnonWalk(expr:Expr, anon:AnonType, origType:Type, fields:Map<String,Field>, name:String):Expr {
        var visName = 'walk_$name';
        if (!fields.exists(name)) {
            fields.set(name, null); // TODO: this sucks

            var exprs = [];
            anon.fields.sort(function(a,b) return Context.getPosInfos(a.pos).min - Context.getPosInfos(b.pos).min);
            for (field in anon.fields) {
                var fname = field.name;
                exprs.push(genWalk(macro __value.$fname, field.type, field.type, fields, name + "_" + fname));
            }

            fields.set(name, {
                pos: Context.currentPos(),
                name: visName,
                access: [AStatic,APublic],
                kind: FFun({
                    args: [
                        {name: "__value", type: extractTypeName(origType)},
                        {name: "__callback", type: macro : Token->Void}
                    ],
                    ret: null,
                    expr: macro $b{exprs},
                })
            });
        }
        return macro $i{visName}($expr, __callback);
    }

    static function extractTypeName(t:Type) {
        return switch (t.toComplexType()) {
            case TPath({pack:["hxParser"], name:"ParseTree", sub:sub, params:params}):
                TPath({pack:[], name:sub, params:params});
            case ct: ct;
        }
    }
}
#end
