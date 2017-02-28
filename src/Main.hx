package;

import features.CursorOffsetFeature;
import features.HxTestSeparatorFeature;
import features.hxParserVis.HxParserVisFeature;
import vscode.*;

class Main {
    @:expose("activate")
    static function activate(context:ExtensionContext) {
        new HxParserVisFeature(context);
        new CursorOffsetFeature(context);
        new HxTestSeparatorFeature(context);
    }
}
