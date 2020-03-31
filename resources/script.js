var curHighlight;
window.addEventListener("message", function (e) {
    const pos = e.data;
    if (curHighlight != null) {
        curHighlight.classList.remove("selected");
        curHighlight = null;
    }
    for (var id in posMap) {
        var range = posMap[id];
        if (pos >= range.start && pos < range.end) {
            curHighlight = document.getElementById(id);
            curHighlight.classList.add("selected");
            scrollToCurHighlight();
        }
    }
});

function scrollToCurHighlight() {
    if (curHighlight == null) return;
    const r = curHighlight.getBoundingClientRect();
    const top = r.top + window.pageYOffset;
    const left = r.left + window.pageXOffset;
    const midX = left - (window.innerWidth / 2);
    const midY = top - (window.innerHeight / 2);
    window.scrollTo(midX, midY);
}

window.onload = function () {
    curHighlight = document.getElementsByClassName("selected")[0];
    scrollToCurHighlight(); // TODO: this doesn't work :(
    CollapsibleLists.apply();
};

function collapseAll() {
    var lis = document.getElementsByClassName("collapsibleListOpen");
    var i = lis.length;
    while (i-- > 1) {
        toggleNode(lis[i]);
    }
}