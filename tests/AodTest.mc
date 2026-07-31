import Toybox.Lang;
import Toybox.Test;

// The always-on frame cannot be tested by looking at it -- it appears only
// after the wrist drops, which no screenshot catches by default. What CAN be
// pinned is the arithmetic underneath it: the shift never leaves the pixel
// budget's premise (small, bounded, moving) and never repeats too soon.
module AodTest {

    (:test)
    function theShiftIsBoundedInBothAxes(logger as Logger) as Boolean {
        // An unbounded shift walks the hands off the glass, and the failure
        // only shows on a watch, an hour after install.
        for (var m = 0; m < 60; m += 1) {
            var dx = Aod.shiftX(m);
            var dy = Aod.shiftY(m);
            if (dx < -3 || dx > 3) { return false; }
            if (dy < -2 || dy > 2) { return false; }
        }
        return true;
    }

    (:test)
    function theShiftActuallyMoves(logger as Logger) as Boolean {
        // A shift function that returned a constant would pass every bound
        // check above while protecting nothing.
        var seenX = false;
        var seenY = false;
        for (var m = 1; m < 60; m += 1) {
            if (Aod.shiftX(m) != Aod.shiftX(0)) { seenX = true; }
            if (Aod.shiftY(m) != Aod.shiftY(0)) { seenY = true; }
        }
        return seenX && seenY;
    }

    (:test)
    function thePairRepeatsEvery35MinutesNotEvery7(logger as Logger) as Boolean {
        // Coprime periods are the whole reason there are two of them. If the
        // pair returned to its starting position after 7 minutes, a hand edge
        // would sit on the same pixels eight times an hour, which is burn-in
        // with extra steps.
        var x0 = Aod.shiftX(0);
        var y0 = Aod.shiftY(0);
        var firstRepeat = -1;
        for (var m = 1; m <= 35; m += 1) {
            if (Aod.shiftX(m) == x0 && Aod.shiftY(m) == y0) {
                firstRepeat = m;
                break;
            }
        }
        return firstRepeat == 35;
    }

    (:test)
    function everyMinuteVisitsADistinctPosition(logger as Logger) as Boolean {
        // 35 minutes must yield 35 distinct (dx, dy) pairs -- not merely a
        // late first repeat with duplicates in between.
        var seen = {} as Dictionary<Number, Boolean>;
        for (var m = 0; m < 35; m += 1) {
            var key = (Aod.shiftX(m) * 100) + Aod.shiftY(m);
            if (seen.hasKey(key)) { return false; }
            seen.put(key, true);
        }
        return seen.size() == 35;
    }
}
