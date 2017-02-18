import sys.io.File;

class Test {
    public static function main() {
        var src = File.getContent("src/Vis.hx");
        HxParser.parse("hxparser", src, function(data) switch(data) {
            case Success(data):
                var parsed = JsonParser.parse(data);
                var html = Vis.vis("", parsed, 0);
                File.saveContent("bin/TestPage.html", html);
            case _:
        });
    }
}