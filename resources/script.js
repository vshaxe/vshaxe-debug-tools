var curHighlight;
window.addEventListener("message", function (e) {
    const pos = e.data.pos;
    if (curHighlight != null) {
        curHighlight.classList.remove("selected");
        curHighlight = null;
    }
    for (var id in posMap) {
        var range = posMap[id];
        if (pos >= range.start && pos < range.end) {
            curHighlight = document.getElementById(id);
            curHighlight.classList.add("selected");

            const r = curHighlight.getBoundingClientRect();
            const top = r.top + window.pageYOffset;
            const left = r.left + window.pageXOffset;
            const midX = left - (window.innerWidth / 2);
            const midY = top - (window.innerHeight / 2);
            window.scrollTo(midX, midY);
        }
    }
});

window.onload = function () {
    CollapsibleLists.apply();
};