import js.node.ChildProcess;
import js.node.stream.Readable;
import js.node.child_process.ChildProcess.ChildProcessEvent;

enum HxParserResult {
    Failure(code:Int);
    Success(data:String);
}

class HxParser {
    public static function parse(hxparserPath:String, src:String, handler:HxParserResult->Void) {
        var data = "";
        var cp = ChildProcess.spawn(hxparserPath, ["--recover", "--json", "<stdin>"]);
        cp.stdin.end(src);
        cp.stderr.on(ReadableEvent.Data, function(s:String) data += s);
        cp.on(ChildProcessEvent.Close, function(code, _) {
            if (code != 0)
                handler(Failure(code));
            handler(Success(data));
        });
    }
}