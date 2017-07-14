package;

import features.CursorOffsetFeature;
import features.FormatterTestDiffFeature;
import features.HxTestSeparatorFeature;
import features.ClearHaxeMementosFeature;
import features.hxParserVis.HxParserVisFeature;
import vscode.*;

class Main {
    @:keep
    @:expose("activate")
    static function activate(context:ExtensionContext) {
        new HxParserVisFeature(context);
        new CursorOffsetFeature(context);
        new HxTestSeparatorFeature(context);
        new FormatterTestDiffFeature(context);
        new ClearHaxeMementosFeature(context);
    }
}
