package features.vis.hxParserVis;

import hxParser.JResult;
import hxParser.ParseTree.File;

typedef HxParserContentData = {
    var unparsedData:JResult;
    var parsedTree:File;
}
