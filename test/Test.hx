import sys.io.File;
using StringTools;

class Test {
    public static function main() {
        var src = File.getContent("src/Vis.hx");
        HxParser.parse("hxparser", src, function(data) switch(data) {
            case Success(data):
                var parsed = JsonParser.parse(data);
                var html = Vis.vis("", parsed, 0);
                html = html.replace("<body>", "<body style='background-color: rgb(30, 30, 30); font-family: Consolas; font-size: 12'>");
                File.saveContent("bin/TestPage.html", html);
            case _:
        });
    }
}