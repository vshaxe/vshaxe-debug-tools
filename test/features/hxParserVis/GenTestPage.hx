package features.hxParserVis;

import util.HtmlPrinter;
import hxParser.Converter;
import hxParser.HxParser.HxParser;
import sys.io.File;
using StringTools;

class GenTestPage {
    public static function main() {
        var src = File.getContent("src/util/HtmlPrinter.hx");
        switch (HxParser.parse(src)) {
             case Success(data):
                var parsed = new Converter(data).convertResultToFile();
                var html = HtmlPrinter.print("", data, parsed, 0, SyntaxTree, "Segoe UI", "13");
                html = html.replace("<body>", "<body style='background-color: rgb(30, 30, 30); color: white;'>");
                File.saveContent("bin/TestPage.html", html);
            case _:
                Sys.exit(1);
        }
    }
}
