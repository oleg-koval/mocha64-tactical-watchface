import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class MochaFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Palette.VALUE, Palette.BG);
        dc.clear();

        // Every Y below is derived from the real glyph heights. Writing these
        // down as constants is what put the goal bar through the STEPS label,
        // the rule through STRESS, and -- with COL_STEP_Y at 25 against a 32px
        // font -- every recovery row through the one below it.
        var labelH = dc.getFontHeight(Graphics.FONT_XTINY);
        var metricH = dc.getFontHeight(Graphics.FONT_TINY);
        var timeH = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);

        // Left column: weekday, DD.MM, then the two-line time block. The second
        // time line sits at reduced pitch (see Layout.timeLinePitch) -- at full
        // font height the block alone is 148px of a 260px face.
        var dayY = Layout.STATUS_Y;
        var dateY = dayY + labelH;
        var timeTop = dateY + labelH + Layout.GAP_DATE_TO_TIME;
        var pitch = Layout.timeLinePitch(timeH);
        var leftBottom = timeTop + pitch + timeH;

        // Right column spans exactly the height of the left one, so the two
        // halves end level and the row pitch can never be tighter than a glyph.
        var step = Layout.columnStep(leftBottom - Layout.COL_TOP_Y);
        var columnBottom = Layout.columnY(Layout.COL_ROWS - 1, step) + metricH;

        var ruleY = Layout.clampRuleY(
            (columnBottom > leftBottom ? columnBottom : leftBottom)
                + Layout.GAP_ABOVE_RULE,
            labelH);
        var row1Y = ruleY + Layout.GAP_BELOW_RULE;
        var row2Y = row1Y + labelH + Layout.GAP_BETWEEN_ROWS;

        drawDate(dc, dayY, dateY);
        drawTime(dc, timeTop, timeH, pitch);
        Hud.verticalRule(dc, Layout.DIVIDER_X, Layout.DIVIDER_TOP, ruleY);
        drawRecoveryColumn(dc, step);
        Hud.horizontalRule(dc, ruleY, Layout.RULE_FROM, Layout.RULE_TO);
        drawActivity(dc, row1Y, row2Y, labelH);
    }

    // Weekday on top, numeric date under it -- two short lines instead of one
    // long "SUN 26 JUL" that ran into the divider. Days-of-charge sits on the
    // weekday line, opposite it, in the otherwise empty top-right corner.
    private function drawDate(dc as Dc, dayY as Number, dateY as Number) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var battery = System.getSystemStats().battery;

        dc.setColor(Fields.batteryColor(battery), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STATUS_BATTERY_X, dayY, Graphics.FONT_XTINY,
            Fields.formatBattery(battery),
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STATUS_DATE_X, dayY, Graphics.FONT_XTINY,
            Fields.formatDayName(now.day_of_week as Number),
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STATUS_DATE_X, dateY, Graphics.FONT_XTINY,
            Fields.formatDayMonth(now.day as Number, now.month as Number),
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    private function drawTime(
        dc as Dc, top as Number, timeH as Number, pitch as Number
    ) as Void {
        var clock = System.getClockTime();
        var firstCenter = top + (timeH / 2);

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.TIME_X, firstCenter,
            Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatHour(clock.hour),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            Layout.TIME_X, firstCenter + pitch,
            Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatMinute(clock.min),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawRecoveryColumn(dc as Dc, step as Number) as Void {
        var bodyBattery = Sensors.bodyBattery();
        var stressLevel = Sensors.stress();
        var heartRate = Sensors.currentHeartRate();
        var resting = Sensors.restingHeartRate();

        Hud.metricRow(dc, Layout.columnY(0, step), "BODY", Fields.formatMetric(bodyBattery),
            bodyBattery == null ? Palette.RULE : Fields.bodyBatteryColor(bodyBattery));

        Hud.metricRow(dc, Layout.columnY(1, step), "HR", Fields.formatMetric(heartRate),
            heartRate == null ? Palette.RULE : Palette.DATA);

        // Resting HR is a reference line, not a live state, so it stays plain.
        Hud.metricRow(dc, Layout.columnY(2, step), "REST", Fields.formatMetric(resting),
            resting == null ? Palette.RULE : Palette.VALUE);

        Hud.metricRow(dc, Layout.columnY(3, step), "STRESS", Fields.formatMetric(stressLevel),
            stressLevel == null ? Palette.RULE : Fields.stressColor(stressLevel));
    }

    private function drawActivity(
        dc as Dc, row1Y as Number, row2Y as Number, footerH as Number
    ) as Void {
        var info = ActivityMonitor.getInfo();

        var steps = 0;
        var goal = 0;
        if (info.steps != null) {
            steps = info.steps as Number;
        }
        if (info.stepGoal != null) {
            goal = info.stepGoal as Number;
        }

        var stepMid = Hud.footerRow(dc, row1Y,
            Layout.ROW_1_LABEL_X, Layout.ROW_1_VALUE_X,
            "STEPS", Fields.formatCount(steps));

        Hud.inlineBar(dc, stepMid,
            Layout.STEP_BAR_X, Layout.STEP_BAR_W, Layout.STEP_BAR_H,
            Fields.goalPercent(steps, goal));

        var row2Bounds = Layout.footerRowXBounds(row2Y + footerH);
        Hud.footerRow(dc, row2Y,
            row2Bounds[0], row2Bounds[1],
            "KCAL", Fields.formatCount(info.calories));
    }
}
