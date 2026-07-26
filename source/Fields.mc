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

    // The date is stacked: weekday on its own line, then a numeric DD.MM under
    // it. Two short lines fit the narrow left column without the month name
    // pushing into the divider the way "SUN 26 JUL" did.
    function formatDayName(dayOfWeek as Number) as String {
        return DAYS[dayOfWeek - 1];
    }

    function formatDayMonth(day as Number, month as Number) as String {
        return Lang.format("$1$.$2$", [day.format("%02d"), month.format("%02d")]);
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

    // A saturated fill shouts on a large area (see Palette.FILL_OK), so the
    // bar stays plain white in progress and only shifts to the pale green
    // completion tint once the goal is actually hit.
    function goalColor(percent as Number) as Number {
        return percent >= 100 ? Palette.FILL_OK : Palette.VALUE;
    }

    // "50%" is an abstraction you have to convert before it means anything.
    // Days-remaining is the number you actually act on, so the percentage is
    // converted here against the fenix 6 Pro's ~14-day smartwatch-mode runtime.
    // Rounds down: a watch that says 6d must not die on day 6.
    const BATTERY_FULL_DAYS = 14;

    function batteryDays(percent as Float) as Number {
        var days = (percent * BATTERY_FULL_DAYS) / 100.0;
        return days.toNumber();
    }

    function formatBattery(percent as Float) as String {
        return batteryDays(percent).toString() + "d";
    }

    // Healthy battery stays plain: colour is reserved for the states worth
    // interrupting a glance for. A green "50%" is decoration that costs
    // luminance on a reflective panel and teaches the eye to ignore colour.
    function batteryColor(percent as Float) as Number {
        if (percent <= BATTERY_LOW) {
            return Palette.STRAIN;
        }
        if (percent <= BATTERY_MID) {
            return Palette.CAUTION;
        }
        return Palette.LABEL;
    }

    function goalPercent(current as Number, goal as Number) as Number {
        if (goal <= 0) {
            return 0;
        }
        var pct = (current * 100) / goal;
        return pct > 100 ? 100 : pct;
    }
}
