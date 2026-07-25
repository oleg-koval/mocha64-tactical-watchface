import Toybox.Lang;

module Fields {

    const BATTERY_LOW = 20.0;
    const BATTERY_MID = 50.0;

    function formatTime(hour as Number, minute as Number) as String {
        return Lang.format("$1$:$2$", [hour.format("%02d"), minute.format("%02d")]);
    }

    function formatBattery(percent as Float) as String {
        return percent.format("%d") + "%";
    }

    function batteryColor(percent as Float) as Number {
        if (percent <= BATTERY_LOW) {
            return Palette.STRAIN;
        }
        if (percent <= BATTERY_MID) {
            return Palette.CAUTION;
        }
        return Palette.READY;
    }

    function goalPercent(current as Number, goal as Number) as Number {
        if (goal <= 0) {
            return 0;
        }
        var pct = (current * 100) / goal;
        return pct > 100 ? 100 : pct;
    }
}
