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
            const mid = top - (window.innerHeight / 2);
            window.scrollTo(0, mid);
        }
    }
});

window.onload = function () {
    CollapsibleLists.apply();
};