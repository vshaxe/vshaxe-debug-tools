package features.hxParserVis;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;
import util.GenWalker.extractTypeName;
import util.GenWalker.getNullType;

class GenVis {
    static function gen() {
        var root = Context.getType("hxParser.ParseTree.File");
        var fields = new Map();

        genVis(macro v, root, root, fields, null);

        // Context.defineModule("hxParserVis.Vis", Lambda.array(fields));

        var printer = new haxe.macro.Printer();
        var parts = [
            "package features.hxParserVis;",
            "import hxParser.ParseTree;",
            "import util.SyntaxTreePrinter;",
            "using StringTools;",
        ];

        var td = macro class Vis {
            var ctx:SyntaxTreePrinter;
            var offset:Int;
            public function new(ctx) {
                this.ctx = ctx;
                offset = 0;
            }

            public static var none = '<span class="none">&lt;none&gt;</span>';

            public function visToken(t:Token):String {
                inline function renderPosition(start:Int, end:Int) {
                    return "[" + start + "-" + end + ")";
                }

                inline function renderTrivia(t:Trivia, prefix:String) {
                    var s = t.toString().htmlEscape();
                    var start = offset;
                    var end = offset += t.text.length;
                    var id = ctx.registerPos(start, end);
                    var link = ctx.makeLink(start, end);
                    return '<li><a id="' + id + '" href="' + link + '" class="trivia">' + prefix + ': ' + s + " " +renderPosition(start, end) + '</a></li>';
                }

                var trivias = [];
                if (t.leadingTrivia != null) {
                    for (t in t.leadingTrivia)
                        trivias.push(renderTrivia(t, "LEAD"));
                }

                var start = offset;
                var end = !t.appearsInSource() ? start : offset += t.text.length;
                var link = ctx.makeLink(start, end);
                var id = ctx.registerPos(start, end);
                var selected = ctx.isUnderCursor(start, end);

                var s = t.toString().htmlEscape();
                var parts = ['<a id="'+ id +'" href="' + link + '" class="token' + (if (selected) " selected" else "") + '">' + s + " " + renderPosition(start, end) + '</a>'];

                if (t.inserted) parts.push('<span class="missing">(missing)</span>');
                if (t.implicit) parts.push('<span class="implicit">(implicit)</span>');


                if (t.trailingTrivia != null) {
                    for (t in t.trailingTrivia)
                        trivias.push(renderTrivia(t, "TAIL"));
                }
                if (trivias.length > 0)
                    parts.push('<ul class="trivia">' + trivias.join("") + "</ul>");

                return parts.join(" ");
            }

            public function visArray<T>(c:Array<T>, vis:T->String):String {
                var parts = [for (el in c) "<li>" + vis(el) + "</li>"];
                return if (parts.length == 0) none else "<ul>" + parts.join("") + "</ul>";
            }

            public function visCommaSeparated<T>(c:CommaSeparated<T>, vis:T->String):String {
                var parts = [vis(c.arg)];
                for (el in c.args) {
                    parts.push(visToken(el.comma));
                    parts.push(vis(el.arg));
                }
                return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
            }

            public function visCommaSeparatedTrailing<T>(c:CommaSeparatedAllowTrailing<T>, vis:T->String):String {
                var parts = [vis(c.arg)];
                for (el in c.args) {
                    parts.push(visToken(el.comma));
                    parts.push(vis(el.arg));
                }
                if (c.comma != null)
                    parts.push(visToken(c.comma));
                return "<ul>" + [for (s in parts) '<li>' + s + '</li>'].join("") + "</ul>";
            }
        }
        for (field in fields)
            td.fields.push(field);

        parts.push(printer.printTypeDefinition(td));
        sys.io.File.saveContent("src/features/hxParserVis/Vis.hx", parts.join("\n\n"));
    }

    static function genVis(expr:Expr, type:Type, origType, fields:Map<String,Field>, name:Null<String>):Expr {
        switch (type) {
            case TInst(_.get() => {pack: ["hxParser"], name: "Token"}, _):
                return macro visToken($expr);

            case TInst(_.get() => {pack: [], name: "Array"}, [elemT]) if (name != null):
                var visExpr = genVis(macro el, elemT, elemT, fields, name + "_elem");
                return macro visArray($expr, function(el) return $visExpr);

            case TType(_.get() => dt, params):
                switch [dt, params] {
                    case [{pack: ["hxParser"], name: "CommaSeparated"}, [elemT]] if (name != null):
                        var visExpr = genVis(macro el, elemT, elemT, fields, name + "_elem");
                        return macro visCommaSeparated($expr, function(el) return $visExpr);

                    case [{pack: ["hxParser"], name: "CommaSeparatedAllowTrailing"}, [elemT]] if (name != null):
                        var visExpr = genVis(macro el, elemT, elemT, fields, name + "_elem");
                        return macro visCommaSeparatedTrailing($expr, function(el) return $visExpr);

                    case [{pack: [], name: "Null"}, _]:
                        throw "Null<T> should be handled elsewhere.";

                    default:
                        return genVis(expr, dt.type.applyTypeParameters(dt.params, params), origType, fields, dt.name);
                }

            case TEnum(_.get() => en, _):
                return genEnumVis(expr, en, origType, fields);

            case TAnonymous(_.get() => anon) if (name != null):
                return genAnonVis(expr, anon, origType, fields, name);

            default:
        }
        throw 'TODO: ${type.toString()}';
    }

    static function genEnumVis(expr:Expr, en:EnumType, origType:Type, fields:Map<String,Field>):Expr {
        var visName = "vis" + en.name;
        if (!fields.exists(en.name)) {
            fields.set(en.name, null); // TODO: this sucks

            var cases = [];
            for (ctor in en.constructs) {
                switch (ctor.type) {
                    case TFun(args, _):
                        var patternArgs = [];
                        var exprs = [];
                        for (arg in args) {
                            var name = arg.name;
                            patternArgs.push(macro var $name);
                            var local = macro $i{name};

                            var visExpr = switch (getNullType(arg.t)) {
                                case None:
                                    genVis(local, arg.t, arg.t, fields, en.name + "_" + ctor.name + "_" + arg.name);
                                case Some(realT):
                                    var e = genVis(local, realT, realT, fields, en.name + "_" + ctor.name + "_" + arg.name);
                                    macro (if ($local != null) $e else none);
                            }

                            exprs.push(macro $v{arg.name + ": "} + $visExpr);
                        }

                        var argList = macro ${Lambda.fold(exprs, function(e, acc) return macro $acc + "<li>" + $e + "</li>", macro "<ul>")} + "</ul>";

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

            var ct = extractTypeName(origType);
            var field = (macro class {
                public function $visName(v:$ct):String {
                    return $expr;
                }
            }).fields[0];

            fields.set(en.name, field);
        }
        return macro $i{visName}($expr);
    }

    static function genAnonVis(expr:Expr, anon:AnonType, origType:Type, fields:Map<String,Field>, name:String):Expr {
        var visName = 'vis$name';
        if (!fields.exists(name)) {
            fields.set(name, null); // TODO: this sucks

            var exprs = [];
            anon.fields.sort(function(a,b) return Context.getPosInfos(a.pos).min - Context.getPosInfos(b.pos).min);
            for (field in anon.fields) {
                var fname = field.name;

                var visExpr = switch (getNullType(field.type)) {
                    case None:
                        genVis(macro v.$fname, field.type, field.type, fields, name + "_" + fname);
                    case Some(realT):
                        var e = genVis(macro v.$fname, realT, realT, fields, name + "_" + fname);
                        macro (if (v.$fname != null) $e else none);
                }

                exprs.push(macro $v{fname + ": "} + $visExpr);
            }

            var expr = macro ${Lambda.fold(exprs, function(el, acc) return macro $acc + "<li>" + $el + "</li>", macro "<ul>")} + "</ul>";

            var ct = extractTypeName(origType);
            var field = (macro class {
                public function $visName(v:$ct):String {
                    return $v{'<span class="node">${name}</span>'} + $expr;
                }
            }).fields[0];

            fields.set(name, field);
        }
        return macro $i{visName}($expr);
    }
}
#end
