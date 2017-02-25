package hxParserVis;

import hxParser.HxParser.HxParser;
import hxParser.Converter;
import hxParserVis.HtmlPrinter;
import sys.io.File;
using StringTools;

class Test {
    public static function main() {
        var src = File.getContent("src/hxParserVis/HtmlPrinter.hx");
        switch (HxParser.parse(src)) {
             case Success(data):
                var parsed = Converter.convertResult(data);
                var html = HtmlPrinter.print("", data, parsed, 0, SyntaxTree);
                html = html.replace("<body>", "<body style='background-color: rgb(30, 30, 30); font-family: \"Segoe UI\"; font-size: 13; color: white;'>");
                File.saveContent("bin/TestPage.html", html);
            case _:
                Sys.exit(1);
        }
    }
}
