import Toybox.Lang;
import Toybox.Test;

module LayoutTest {

    (:test)
    function recoveryRowsAreEvenlySpaced(logger as Logger) as Boolean {
        var gap = Layout.columnY(1) - Layout.columnY(0);
        for (var row = 1; row < Layout.COL_ROWS - 1; row += 1) {
            if (Layout.columnY(row + 1) - Layout.columnY(row) != gap) {
                return false;
            }
        }
        return true;
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

    (:test)
    function chipSitsLeftOfLabelAndValue(logger as Logger) as Boolean {
        return (Layout.CHIP_X + Layout.CHIP_W) <= Layout.COL_LABEL_X
            && Layout.COL_LABEL_X < Layout.COL_VALUE_X;
    }

    // The date and the time block share one left edge; drifting apart is the
    // misalignment this pins shut.
    (:test)
    function dateAndTimeShareALeftEdge(logger as Logger) as Boolean {
        return Layout.TIME_X == Layout.STATUS_DATE_X;
    }

    (:test)
    function dividerMeetsTheHorizontalRule(logger as Logger) as Boolean {
        return Layout.DIVIDER_BOTTOM == Layout.RULE_Y;
    }

    // The goal bar cut through the STEPS label and value on real hardware.
    // These pin the horizontal corridors so the bar physically cannot reach
    // either text column.
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

    // The vertical stack is derived at draw time, so these check the gaps are
    // large enough that no plausible glyph height can close them.
    (:test)
    function gapsSurviveATallFont(logger as Logger) as Boolean {
        var tallest = 34;
        var columnBottom = Layout.columnY(Layout.COL_ROWS - 1) + tallest;
        var ruleY = columnBottom + Layout.GAP_ABOVE_RULE;
        var row1 = ruleY + Layout.GAP_BELOW_RULE;
        var row2 = row1 + tallest + Layout.GAP_BETWEEN_ROWS;
        return ruleY > columnBottom
            && row1 > ruleY
            && (row2 - row1) > tallest
            && (row2 + tallest) < Layout.SCREEN;
    }

    (:test)
    function derivedFooterFitsInsideTheBezelCurve(logger as Logger) as Boolean {
        var tallest = 34;
        var ruleY = Layout.columnY(Layout.COL_ROWS - 1) + tallest + Layout.GAP_ABOVE_RULE;
        var row2 = ruleY + Layout.GAP_BELOW_RULE + tallest + Layout.GAP_BETWEEN_ROWS;
        var half = Layout.halfWidthAt(row2 + tallest);
        return (Layout.ROW_2_LABEL_X >= Layout.CENTER - half)
            && (Layout.ROW_2_VALUE_X <= Layout.CENTER + half);
    }

    (:test)
    function barWidthClampsToTrack(logger as Logger) as Boolean {
        return Layout.barWidth(150, 100) == 100
            && Layout.barWidth(50, 100) == 50
            && Layout.barWidth(-10, 100) == 0;
    }
}
