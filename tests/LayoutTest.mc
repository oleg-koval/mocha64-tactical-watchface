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
        var half = Layout.halfWidthAt(Layout.STEP_Y + 20);
        return (Layout.STEP_LABEL_X >= Layout.CENTER - half)
            && (Layout.STEP_VALUE_X <= Layout.CENTER + half);
    }

    (:test)
    function footerRowFitsInsideTheBezelCurve(logger as Logger) as Boolean {
        var half = Layout.halfWidthAt(Layout.FOOTER_Y + 20);
        return (Layout.SPARK_X >= Layout.CENTER - half)
            && (Layout.FOOTER_VALUE_X <= Layout.CENTER + half);
    }

    (:test)
    function footerElementsDoNotOverlap(logger as Logger) as Boolean {
        return (Layout.SPARK_X + Layout.SPARK_W) <= Layout.FOOTER_HR_X
            && Layout.FOOTER_HR_X < Layout.FOOTER_TICK_X
            && Layout.FOOTER_TICK_X < Layout.FOOTER_LABEL_X
            && Layout.FOOTER_LABEL_X < Layout.FOOTER_VALUE_X;
    }

    // The date and the time block share one left edge; drifting apart is the
    // misalignment this pins shut.
    (:test)
    function dateAndTimeShareALeftEdge(logger as Logger) as Boolean {
        return Layout.TIME_X == Layout.STATUS_DATE_X;
    }

    (:test)
    function ruleSitsBetweenColumnAndStepRow(logger as Logger) as Boolean {
        return Layout.RULE_Y > Layout.columnY(Layout.COL_ROWS - 1)
            && Layout.RULE_Y < Layout.STEP_Y;
    }

    (:test)
    function barWidthClampsToTrack(logger as Logger) as Boolean {
        return Layout.barWidth(150, 100) == 100
            && Layout.barWidth(50, 100) == 50
            && Layout.barWidth(-10, 100) == 0;
    }
}
