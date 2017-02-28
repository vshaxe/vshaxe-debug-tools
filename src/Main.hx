package;

import features.CursorOffsetFeature;
import features.hxParserVis.HxParserVisFeature;
import vscode.*;

class Main {
    function new(context:ExtensionContext) {
        new HxParserVisFeature(context);
        new CursorOffsetFeature(context);
    }

    @:expose("activate")
    static function activate(context:ExtensionContext) {
        new Main(context);
    }
}
