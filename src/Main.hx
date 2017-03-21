package;

import features.CursorOffsetFeature;
import features.FormatterTestDiff;
import features.HxTestSeparatorFeature;
import features.hxParserVis.HxParserVisFeature;
import vscode.*;

class Main {
    @:keep
    @:expose("activate")
    static function activate(context:ExtensionContext) {
        new HxParserVisFeature(context);
        new CursorOffsetFeature(context);
        new HxTestSeparatorFeature(context);
        new FormatterTestDiff(context);
    }
}
