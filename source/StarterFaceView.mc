import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class StarterFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Palette.VALUE, Palette.BG);
        dc.clear();

        var clock = System.getClockTime();
        var stats = System.getSystemStats();

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - Layout.TIME_OFFSET_Y,
            Graphics.FONT_NUMBER_HOT,
            Fields.formatTime(clock.hour, clock.min),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Fields.batteryColor(stats.battery), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 + Layout.BATTERY_OFFSET_Y,
            Graphics.FONT_TINY,
            Fields.formatBattery(stats.battery),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
