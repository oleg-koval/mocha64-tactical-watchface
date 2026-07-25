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

        drawStatusBar(dc);
        drawTime(dc);
        Hud.verticalRule(dc, Layout.DIVIDER_X, Layout.DIVIDER_TOP, Layout.DIVIDER_BOTTOM);
        drawRecoveryColumn(dc);
        Hud.horizontalRule(dc, Layout.RULE_Y, Layout.RULE_FROM, Layout.RULE_TO);
        drawActivity(dc);
    }

    private function drawStatusBar(dc as Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var battery = System.getSystemStats().battery;

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STATUS_DATE_X,
            Layout.STATUS_Y,
            Graphics.FONT_XTINY,
            Fields.formatDate(
                now.day_of_week as Number,
                now.day as Number,
                now.month as Number
            ),
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // Battery reads as plain text; it only takes a status colour once it
        // actually matters, so a healthy charge never costs legibility.
        dc.setColor(Fields.batteryColor(battery), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STATUS_BATTERY_X,
            Layout.STATUS_Y,
            Graphics.FONT_XTINY,
            Fields.formatBattery(battery),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    private function drawTime(dc as Dc) as Void {
        var clock = System.getClockTime();

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.TIME_X, Layout.TIME_HH_Y,
            Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatHour(clock.hour),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            Layout.TIME_X, Layout.TIME_MM_Y,
            Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatMinute(clock.min),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawRecoveryColumn(dc as Dc) as Void {
        var bodyBattery = Sensors.bodyBattery();
        var stressLevel = Sensors.stress();

        Hud.metricRow(dc, 0, "BODY", Fields.formatMetric(bodyBattery),
            bodyBattery == null ? Palette.RULE : Fields.bodyBatteryColor(bodyBattery));

        Hud.metricRow(dc, 1, "HR", Fields.formatMetric(Sensors.currentHeartRate()),
            Palette.DATA);

        Hud.metricRow(dc, 2, "REST", Fields.formatMetric(Sensors.restingHeartRate()),
            Palette.RULE);

        Hud.metricRow(dc, 3, "STRESS", Fields.formatMetric(stressLevel),
            stressLevel == null ? Palette.RULE : Fields.stressColor(stressLevel));
    }

    private function drawActivity(dc as Dc) as Void {
        var info = ActivityMonitor.getInfo();

        var steps = 0;
        var goal = 0;
        if (info.steps != null) {
            steps = info.steps as Number;
        }
        if (info.stepGoal != null) {
            goal = info.stepGoal as Number;
        }

        Hud.footerRow(dc, "STEPS", Fields.formatCount(steps),
            Layout.STEP_LABEL_Y, Layout.STEP_VALUE_Y,
            Layout.STEP_LABEL_X, Layout.STEP_VALUE_X);

        Hud.bar(dc, Layout.STEP_BAR_X, Layout.STEP_BAR_Y,
            Layout.STEP_BAR_W, Layout.STEP_BAR_H,
            Fields.goalPercent(steps, goal), Palette.VALUE);

        Hud.footerRow(dc, "KCAL", Fields.formatCount(info.calories),
            Layout.KCAL_LABEL_Y, Layout.KCAL_VALUE_Y,
            Layout.KCAL_LABEL_X, Layout.KCAL_VALUE_X);
    }
}
