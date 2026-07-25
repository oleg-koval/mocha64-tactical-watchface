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

        Hud.cornerTicks(dc);
        drawStatusBar(dc);
        drawTime(dc);
        Hud.verticalRule(dc, Layout.DIVIDER_X, Layout.DIVIDER_TOP, Layout.RULE_Y);
        drawRecoveryColumn(dc);
        Hud.horizontalRule(dc, Layout.RULE_Y, Layout.STEP_LABEL_X, Layout.STEP_VALUE_X);
        drawActivity(dc);
        drawFooter(dc);
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
            Layout.TIME_X,
            Layout.TIME_HH_Y,
            Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatHour(clock.hour),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            Layout.TIME_X,
            Layout.TIME_MM_Y,
            Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatMinute(clock.min),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawRecoveryColumn(dc as Dc) as Void {
        var bodyBattery = Sensors.bodyBattery();
        var heartRate = Sensors.currentHeartRate();
        var restingHr = Sensors.restingHeartRate();
        var stressLevel = Sensors.stress();

        Hud.labelValue(
            dc, Layout.COL_LABEL_X, Layout.COL_VALUE_X, Layout.columnY(0),
            "BB", Fields.formatMetric(bodyBattery),
            bodyBattery == null ? Palette.LABEL : Fields.bodyBatteryColor(bodyBattery)
        );
        if (bodyBattery != null) {
            Hud.bar(
                dc, Layout.BB_BAR_X, Layout.columnY(0) + 6,
                Layout.BB_BAR_W, Layout.BB_BAR_H,
                bodyBattery, Palette.FILL_OK
            );
        }

        Hud.labelValue(
            dc, Layout.COL_LABEL_X, Layout.COL_VALUE_X, Layout.columnY(1),
            "HR", Fields.formatMetric(heartRate),
            heartRate == null ? Palette.LABEL : Palette.DATA
        );

        Hud.labelValue(
            dc, Layout.COL_LABEL_X, Layout.COL_VALUE_X, Layout.columnY(2),
            "RHR", Fields.formatMetric(restingHr), Palette.LABEL
        );

        Hud.labelValue(
            dc, Layout.COL_LABEL_X, Layout.COL_VALUE_X, Layout.columnY(3),
            "STR", Fields.formatMetric(stressLevel),
            stressLevel == null ? Palette.LABEL : Fields.stressColor(stressLevel)
        );
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
        var percent = Fields.goalPercent(steps, goal);

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STEP_LABEL_X,
            Layout.STEP_Y,
            Graphics.FONT_XTINY,
            "STEP",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        Hud.bar(
            dc, Layout.STEP_BAR_X, Layout.STEP_Y + 6,
            Layout.STEP_BAR_W, Layout.STEP_BAR_H,
            percent, Fields.goalColor(percent)
        );

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.STEP_VALUE_X,
            Layout.STEP_Y,
            Graphics.FONT_XTINY,
            Fields.formatCount(steps),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    // One baseline for the whole footer: the sparkline is centred against the
    // text rather than sharing its top edge, which is what made the two read as
    // unrelated elements.
    private function drawFooter(dc as Dc) as Void {
        var fontHeight = dc.getFontHeight(Graphics.FONT_XTINY);
        var textMid = Layout.FOOTER_Y + (fontHeight / 2);
        var sparkY = textMid - (Layout.SPARK_H / 2);

        var series = Sensors.heartRateSeries(Layout.SPARK_BUCKETS);
        Hud.sparkline(
            dc, Layout.SPARK_X, sparkY,
            Layout.SPARK_W, Layout.SPARK_H, series
        );

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.FOOTER_HR_X,
            Layout.FOOTER_Y,
            Graphics.FONT_XTINY,
            "HR",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            Layout.FOOTER_TICK_X, textMid - 6,
            Layout.FOOTER_TICK_X, textMid + 6
        );

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.FOOTER_LABEL_X,
            Layout.FOOTER_Y,
            Graphics.FONT_XTINY,
            "KCAL",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        var info = ActivityMonitor.getInfo();
        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.FOOTER_VALUE_X,
            Layout.FOOTER_Y,
            Graphics.FONT_XTINY,
            Fields.formatCount(info.calories),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }
}
