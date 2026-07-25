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
    function stepRowFitsInsideTheBezelCurve(logger as Logger) as Boolean {
        var half = Layout.halfWidthAt(Layout.STEP_LABEL_Y + 18);
        return (Layout.STEP_LABEL_X >= Layout.CENTER - half)
            && (Layout.STEP_VALUE_X <= Layout.CENTER + half);
    }

    (:test)
    function footerRowsFitInsideTheBezelCurve(logger as Logger) as Boolean {
        var stepHalf = Layout.halfWidthAt(Layout.STEP_BAR_Y + Layout.STEP_BAR_H);
        var kcalHalf = Layout.halfWidthAt(Layout.KCAL_LABEL_Y + 18);
        return (Layout.STEP_BAR_X >= Layout.CENTER - stepHalf)
            && (Layout.STEP_BAR_X + Layout.STEP_BAR_W <= Layout.CENTER + stepHalf)
            && (Layout.KCAL_LABEL_X >= Layout.CENTER - kcalHalf)
            && (Layout.KCAL_VALUE_X <= Layout.CENTER + kcalHalf);
    }

    // The label/value collision that produced "KCA2339" on real hardware:
    // a 4-digit value right-aligned into a label's space. Labels and values now
    // live on separate rows, so the only requirement is that each value column
    // stays right of its label.
    (:test)
    function footerLabelsNeverCollideWithValues(logger as Logger) as Boolean {
        return Layout.STEP_LABEL_X < Layout.STEP_VALUE_X
            && Layout.KCAL_LABEL_X < Layout.KCAL_VALUE_X
            && Layout.STEP_LABEL_Y != Layout.KCAL_LABEL_Y;
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

    (:test)
    function ruleSitsBetweenColumnAndStepRow(logger as Logger) as Boolean {
        return Layout.RULE_Y > Layout.columnY(Layout.COL_ROWS - 1)
            && Layout.RULE_Y < Layout.STEP_VALUE_Y;
    }

    (:test)
    function barWidthClampsToTrack(logger as Logger) as Boolean {
        return Layout.barWidth(150, 100) == 100
            && Layout.barWidth(50, 100) == 50
            && Layout.barWidth(-10, 100) == 0;
    }
}
