import Toybox.Lang;

module Fields {

    // A fenix 6 Pro runs ~14 days, so 50% is a week of headroom -- not a
    // warning. Thresholds are set against that, not against phone habits.
    const BATTERY_LOW = 10.0;
    const BATTERY_MID = 25.0;

    const BODY_BATTERY_LOW = 25;
    const BODY_BATTERY_MID = 55;

    const STRESS_CALM = 25;
    const STRESS_ELEVATED = 50;

    const DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    const MONTHS = [
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];

    const NO_DATA = "--";

    function formatTime(hour as Number, minute as Number) as String {
        return Lang.format("$1$:$2$", [hour.format("%02d"), minute.format("%02d")]);
    }

    function formatHour(hour as Number) as String {
        return hour.format("%02d");
    }

    function formatMinute(minute as Number) as String {
        return minute.format("%02d");
    }

    function formatDate(dayOfWeek as Number, day as Number, month as Number) as String {
        return Lang.format("$1$ $2$ $3$", [
            DAYS[dayOfWeek - 1],
            day.format("%02d"),
            MONTHS[month - 1]
        ]);
    }

    function bodyBatteryColor(value as Number) as Number {
        if (value <= BODY_BATTERY_LOW) {
            return Palette.STRAIN;
        }
        if (value <= BODY_BATTERY_MID) {
            return Palette.CAUTION;
        }
        return Palette.READY;
    }

    function stressColor(value as Number) as Number {
        if (value >= STRESS_ELEVATED) {
            return Palette.STRAIN;
        }
        if (value >= STRESS_CALM) {
            return Palette.CAUTION;
        }
        return Palette.READY;
    }

    function formatMetric(value as Number?) as String {
        if (value == null) {
            return NO_DATA;
        }
        return value.toString();
    }

    function formatCount(value as Number?) as String {
        if (value == null) {
            return NO_DATA;
        }
        if (value < 10000) {
            return value.toString();
        }
        var thousands = value / 1000;
        var remainder = (value % 1000) / 100;
        return Lang.format("$1$.$2$K", [thousands.toString(), remainder.toString()]);
    }

    function goalColor(percent as Number) as Number {
        return percent >= 100 ? Palette.FILL_OK : Palette.DATA;
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
