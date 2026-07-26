import Toybox.Lang;
import Toybox.Test;

module LayoutTest {

    (:test)
    function recoveryRowsAreEvenlySpaced(logger as Logger) as Boolean {
        var step = Layout.columnStep(130);
        var gap = Layout.columnY(1, step) - Layout.columnY(0, step);
        for (var row = 1; row < Layout.COL_ROWS - 1; row += 1) {
            if (Layout.columnY(row + 1, step) - Layout.columnY(row, step) != gap) {
                return false;
            }
        }
        return true;
    }

    // COL_STEP_Y was a constant 25 while the value font measured 32px tall, so
    // every recovery row overlapped the one below it. The pitch is derived from
    // the available height now; this pins that it always clears a tall glyph.
    (:test)
    function recoveryRowPitchClearsTheValueGlyph(logger as Logger) as Boolean {
        var tallest = 26;
        var step = Layout.columnStep(130);
        return step >= tallest;
    }

    (:test)
    function recoveryColumnFillsTheHeightItIsGiven(logger as Logger) as Boolean {
        var available = 132;
        var step = Layout.columnStep(available);
        var lastTop = Layout.columnY(Layout.COL_ROWS - 1, step);
        return lastTop < Layout.COL_TOP_Y + available
            && lastTop >= Layout.COL_TOP_Y + (available * 3 / 4) - step;
    }

    (:test)
    function halfWidthShrinksTowardTheEdges(logger as Logger) as Boolean {
        return Layout.halfWidthAt(Layout.CENTER) == Layout.CENTER
            && Layout.halfWidthAt(30) < Layout.halfWidthAt(Layout.CENTER)
            && Layout.halfWidthAt(0) == 0;
    }

    // Every row must fit inside the circular boundary, not the 260x260 square.
    // This is what catches content clipped by the bezel curve.
    (:test)
    function statusRowFitsInsideTheBezelCurve(logger as Logger) as Boolean {
        var half = Layout.halfWidthAt(Layout.STATUS_Y);
        return (Layout.STATUS_DATE_X >= Layout.CENTER - half)
            && (Layout.STATUS_BATTERY_X <= Layout.CENTER + half);
    }

    // The recovery column lives entirely right of the divider; the chips that
    // used to sit in the gap are gone, but the corridor still has to hold.
    (:test)
    function recoveryColumnSitsRightOfTheDivider(logger as Logger) as Boolean {
        return Layout.DIVIDER_X < Layout.COL_LABEL_X
            && Layout.COL_LABEL_X < Layout.COL_VALUE_X;
    }

    // The date and the time block share one left edge; drifting apart is the
    // misalignment this pins shut.
    (:test)
    function dateAndTimeShareALeftEdge(logger as Logger) as Boolean {
        return Layout.TIME_X == Layout.STATUS_DATE_X;
    }

    // dividerMeetsTheHorizontalRule used to pin Layout.DIVIDER_BOTTOM ==
    // Layout.RULE_Y. Both constants were deleted when the vertical stack
    // moved to a single runtime-derived ruleY (see onUpdate in
    // MochaFaceView.mc) -- one value now feeds both the divider's bottom and
    // the rule's y by construction, so the invariant no longer needs a test.

    // The goal bar cut through the STEPS label and value on real hardware.
    // These pin the horizontal corridors so the bar physically cannot reach
    // either text column.
    // Row 1 keeps a fixed X corridor, so unlike row 2 it has to be checked
    // against the curve explicitly at the height it actually lands on.
    (:test)
    function footerRowOneCorridorClearsTheBezelCurve(logger as Logger) as Boolean {
        var ruleY = derivedRuleY(TALL_LABEL, TALL_METRIC, TALL_TIME);
        var bottomY = ruleY + Layout.GAP_BELOW_RULE + TALL_LABEL;
        var half = Layout.halfWidthAt(bottomY);
        return (Layout.ROW_1_LABEL_X >= Layout.CENTER - half)
            && (Layout.ROW_1_VALUE_X <= Layout.CENTER + half);
    }

    (:test)
    function goalBarSitsBetweenLabelAndValue(logger as Logger) as Boolean {
        var barEnd = Layout.STEP_BAR_X + Layout.STEP_BAR_W;
        return Layout.ROW_1_LABEL_X < Layout.STEP_BAR_X
            && barEnd < Layout.ROW_1_VALUE_X;
    }

    (:test)
    function goalBarClearsBothTextColumns(logger as Logger) as Boolean {
        var barEnd = Layout.STEP_BAR_X + Layout.STEP_BAR_W;
        var leftGap = Layout.STEP_BAR_X - Layout.ROW_1_LABEL_X;
        var rightGap = Layout.ROW_1_VALUE_X - barEnd;
        return leftGap >= 40 && rightGap >= 40;
    }

    // Mirrors the derivation in onUpdate exactly. The heights below are the
    // real measured ones on fenix 6 Pro plus headroom -- the earlier guesses
    // (NUMBER_MEDIUM ~54) were badly low against the actual 74px, which is how
    // the whole footer ended up drawn past the bottom of the screen.
    const REAL_LABEL = 19;
    const REAL_METRIC = 29;
    const REAL_TIME = 74;

    const TALL_LABEL = 22;
    const TALL_METRIC = 33;
    const TALL_TIME = 80;

    function derivedRuleY(labelH as Number, metricH as Number, timeH as Number) as Number {
        var timeTop = Layout.STATUS_Y + labelH + labelH + Layout.GAP_DATE_TO_TIME;
        var leftBottom = timeTop + Layout.timeLinePitch(timeH) + timeH;
        var step = Layout.columnStep(leftBottom - Layout.COL_TOP_Y);
        var columnBottom = Layout.columnY(Layout.COL_ROWS - 1, step) + metricH;
        var bottom = columnBottom > leftBottom ? columnBottom : leftBottom;
        return Layout.clampRuleY(bottom + Layout.GAP_ABOVE_RULE, labelH);
    }

    function footerBottom(labelH as Number, metricH as Number, timeH as Number) as Number {
        var ruleY = derivedRuleY(labelH, metricH, timeH);
        var row1 = ruleY + Layout.GAP_BELOW_RULE;
        var row2 = row1 + labelH + Layout.GAP_BETWEEN_ROWS;
        return row2 + labelH;
    }

    // The bug this pins: with the real 74px time font the second footer row
    // landed at y=265 on a 260px screen, so both the goal bar row and the KCAL
    // row were drawn off the face.
    (:test)
    function bothFooterRowsFitOnScreenAtRealFontHeights(logger as Logger) as Boolean {
        return footerBottom(REAL_LABEL, REAL_METRIC, REAL_TIME) < Layout.SCREEN;
    }

    (:test)
    function gapsSurviveATallFont(logger as Logger) as Boolean {
        var ruleY = derivedRuleY(TALL_LABEL, TALL_METRIC, TALL_TIME);
        var row1 = ruleY + Layout.GAP_BELOW_RULE;
        var row2 = row1 + TALL_LABEL + Layout.GAP_BETWEEN_ROWS;
        return row1 > ruleY
            && (row2 - row1) > TALL_LABEL
            && (row2 + TALL_LABEL) < Layout.SCREEN;
    }

    // Reducing the time pitch is what buys the footer its room, but it must not
    // reduce so far that the two lines of digits collide.
    // The clamp is the backstop for every font this face has not seen: however
    // tall the glyphs come back, the footer stays on the screen.
    (:test)
    function footerStaysOnScreenForAnyPlausibleFont(logger as Logger) as Boolean {
        for (var labelH = 14; labelH <= 40; labelH += 1) {
            for (var timeH = 40; timeH <= 120; timeH += 4) {
                if (footerBottom(labelH, timeH / 2, timeH) >= Layout.SCREEN) {
                    return false;
                }
            }
        }
        return true;
    }

    (:test)
    function timeLinePitchClearsTheDigitsButSavesRoom(logger as Logger) as Boolean {
        var pitch = Layout.timeLinePitch(REAL_TIME);
        return pitch < REAL_TIME && pitch > (REAL_TIME / 2);
    }

    // Footer row 2 is the lowest thing on the face, so it is where the bezel
    // curve bites hardest. It carries one label and one value, which still
    // needs real width -- not just a non-negative corridor. This is the test
    // that ruled out putting the battery down here as a second pair.
    (:test)
    function footerRowTwoKeepsEnoughWidthForItsPair(logger as Logger) as Boolean {
        var bounds = Layout.footerRowXBounds(
            footerBottom(REAL_LABEL, REAL_METRIC, REAL_TIME));
        return (bounds[1] - bounds[0]) >= 90;
    }

    // Row 2 sits low enough on the round face that a fixed X corridor
    // clipped the bezel curve on real hardware (confirmed: at the real
    // FONT_SMALL height the curve only has ~64px of half-width there, but
    // the old fixed corridor needed ~84px). footerRowXBounds() derives the
    // corridor from the curve itself, so it cannot clip by construction --
    // these pin that guarantee rather than a specific pixel value.
    (:test)
    function footerRowXBoundsStaysInsideTheBezelCurve(logger as Logger) as Boolean {
        var bottomY = footerBottom(TALL_LABEL, TALL_METRIC, TALL_TIME);
        var half = Layout.halfWidthAt(bottomY);
        var bounds = Layout.footerRowXBounds(bottomY);
        return (bounds[0] >= Layout.CENTER - half)
            && (bounds[1] <= Layout.CENTER + half)
            && (bounds[0] < bounds[1]);
    }

    (:test)
    function footerRowXBoundsNeverInvertsNearTheEdge(logger as Logger) as Boolean {
        var bounds = Layout.footerRowXBounds(Layout.SCREEN - 1);
        return bounds[0] <= bounds[1];
    }

    (:test)
    function barWidthClampsToTrack(logger as Logger) as Boolean {
        return Layout.barWidth(150, 100) == 100
            && Layout.barWidth(50, 100) == 50
            && Layout.barWidth(-10, 100) == 0;
    }
}
