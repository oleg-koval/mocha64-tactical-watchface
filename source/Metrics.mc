import Toybox.Lang;
import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.Time.Gregorian;

// The set of things a configurable slot can show.
//
// One module, identical across every face in this family, so that "slot 2 is
// Body Battery" means the same thing everywhere and a metric added here reaches
// all of them. It deliberately does NOT depend on any face's Sensors module --
// dropping this file into a project is the whole integration.
//
// Everything here is available without asking for a permission the faces do not
// already hold (SensorHistory, UserProfile), and every read is guarded and
// null-safe: a metric the device cannot supply reports null, and a null metric
// draws as an empty slot rather than a zero. A zero is a lie; an empty slot is
// honest.
module Metrics {

    enum {
        NONE = 0,
        HEART_RATE = 1,
        STEPS = 2,
        BODY_BATTERY = 3,
        BATTERY = 4,
        CALORIES = 5,
        DISTANCE = 6,
        FLOORS = 7,
        ACTIVE_MINUTES = 8,
        STRESS = 9,
        RESTING_HR = 10,
        NOTIFICATIONS = 11,
        ALTITUDE = 12,
        BATTERY_DAYS = 13,
        SLEEP_SCORE = 14,
        DATE = 15
    }

    const COUNT = 16;

    // Short label, for the face. Four characters is the practical ceiling in a
    // subdial or a case row, and these are all read at a glance beside a number
    // rather than in isolation.
    const LABELS = ["OFF", "HR", "STEP", "BODY", "PWR", "KCAL", "DIST",
                    "FLR", "MIN", "STRS", "REST", "MSG", "ALT", "PWR",
                    "SLP", "DATE"];

    // Long label, for the settings menus, where there is room to be unambiguous.
    const TITLES = ["Off", "Heart rate", "Steps", "Body Battery", "Battery",
                    "Calories", "Distance", "Floors", "Active minutes",
                    "Stress", "Resting HR", "Notifications", "Altitude",
                    "Battery (days)", "Sleep score", "Date"];

    function label(id as Number) as String {
        return LABELS[normalize(id)];
    }

    function title(id as Number) as String {
        return TITLES[normalize(id)];
    }

    // A stored slot can be out of range after a downgrade or a bad write, and
    // must fall back rather than index off the end of the table.
    function normalize(id as Number) as Number {
        return (id < 0 || id >= COUNT) ? NONE : id;
    }

    // The formatted value, already fitted to a narrow slot, or null when the
    // metric has nothing to report.
    function text(id as Number) as String? {
        var m = normalize(id);
        if (m == NONE) { return null; }
        if (m == BATTERY) { return percent(battery()); }
        if (m == BATTERY_DAYS) { return batteryDaysText(); }
        if (m == DATE) { return dateText(); }
        if (m == SLEEP_SCORE) { return compactOrNull(SleepScore.value()); }
        if (m == DISTANCE) { return distanceText(); }
        var v = value(m);
        return v == null ? null : compact(v);
    }

    function value(id as Number) as Number? {
        var m = normalize(id);
        if (m == HEART_RATE) { return heartRate(); }
        if (m == STEPS) { return steps(); }
        if (m == BODY_BATTERY) { return bodyBattery(); }
        if (m == BATTERY) { return battery(); }
        if (m == CALORIES) { return calories(); }
        if (m == FLOORS) { return floors(); }
        if (m == ACTIVE_MINUTES) { return activeMinutes(); }
        if (m == STRESS) { return stress(); }
        if (m == RESTING_HR) { return restingHeartRate(); }
        if (m == NOTIFICATIONS) { return notifications(); }
        if (m == ALTITUDE) { return altitude(); }
        if (m == SLEEP_SCORE) { return SleepScore.value(); }
        return null;
    }

    // Whether the value warrants the alert colour. Only battery earns it, and
    // only when genuinely nearly flat -- a field that is permanently coloured
    // teaches the eye to ignore colour by the time it means something.
    function isCritical(id as Number) as Boolean {
        var m = normalize(id);
        if (m == BATTERY_DAYS) {
            var d = batteryDays();
            return (d != null) && (d <= 2);
        }
        if (m != BATTERY) { return false; }
        var b = battery();
        return (b != null) && (b < 10);
    }

    // Days of charge left, which is what a fortnight-lasting watch is actually
    // asked. batteryInDays arrived in API 3.3.0, so it is guarded: on anything
    // older this metric simply reports nothing rather than inventing a figure.
    function batteryDays() as Number? {
        var stats = System.getSystemStats();
        if (!(stats has :batteryInDays)) { return null; }
        // batteryInDays is declared non-nullable, so any null guard here is
        // dead code and the checker says so. The `has` guard above is the only
        // one that matters: the field arrived in API 3.3.0 and these faces
        // still build for 3.2.0.
        return stats.batteryInDays.toNumber();
    }

    function batteryDaysText() as String? {
        var d = batteryDays();
        return (d == null) ? null : d.format("%d") + "d";
    }

    // Whether this device can supply the metric at all.
    //
    // Sleep score is the only one that is device-dependent: it comes from the
    // Complications API, which arrived in 4.2.0. fenix 6 Pro tops out at 3.4.5
    // and will never have it; fenix 7, fenix 8 and the Forerunner 255/955 all
    // do. Pickers filter on this rather than offering a choice that would show
    // a permanently empty slot on half the supported devices.
    function isAvailable(id as Number) as Boolean {
        if (normalize(id) != SLEEP_SCORE) { return true; }
        return SleepScore.isSupported();
    }

    function dateText() as String? {
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        return WEEKDAYS[(now.day_of_week as Number) - 1] + " " + now.day.format("%d");
    }

    const WEEKDAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    function compactOrNull(v as Number?) as String? {
        return (v == null) ? null : compact(v);
    }

    // ---------------------------------------------------------------- reads --

    function heartRate() as Number? {
        var info = Activity.getActivityInfo();
        if (info != null && info.currentHeartRate != null) {
            return info.currentHeartRate;
        }
        return heartRateHistory();
    }

    function altitude() as Number? {
        // No null guard on getActivityInfo(): the checker proves it non-null on
        // this device and flags the guard as unreachable. The FIELD is genuinely
        // nullable, and has to be bound to a local -- the checker does not carry
        // a null guard on a field across to the call site.
        var a = Activity.getActivityInfo().altitude;
        return (a == null) ? null : a.toNumber();
    }

    function battery() as Number? {
        return System.getSystemStats().battery.toNumber();
    }

    function notifications() as Number? {
        // Returned straight through. The checker proves notificationCount
        // non-null on these devices and flags any guard as unreachable; the
        // declared Number? still holds if a future device disagrees.
        return System.getDeviceSettings().notificationCount;
    }

    function restingHeartRate() as Number? {
        if (!(Toybox has :UserProfile)) { return null; }
        var p = UserProfile.getProfile();
        if (p == null || p.restingHeartRate == null) { return null; }
        var r = p.restingHeartRate;
        // The profile reports 255 when it has never been established, which
        // would otherwise render as a plausible and completely wrong number.
        return (r == 255) ? null : r;
    }

    // Monkey C has no dynamic member dispatch -- neither info[:steps] nor
    // SensorHistory[getter](...) parses -- so every field is named explicitly
    // behind its own `has` guard. Verbose, and the only thing the language
    // allows.
    function steps() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info == null || !(info has :steps) || info.steps == null) { return null; }
        return info.steps;
    }

    function calories() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info == null || !(info has :calories) || info.calories == null) { return null; }
        return info.calories;
    }

    function floors() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info == null || !(info has :floorsClimbed) || info.floorsClimbed == null) {
            return null;
        }
        return info.floorsClimbed;
    }

    function distanceCm() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info == null || !(info has :distance) || info.distance == null) { return null; }
        return info.distance;
    }

    function activeMinutes() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info == null || !(info has :activeMinutesDay)) { return null; }
        var a = info.activeMinutesDay;
        return (a == null || a.total == null) ? null : a.total;
    }

    // The newest history bucket routinely EXISTS carrying null data, so asking
    // for a single sample loses the metric entirely. Ask for a window and take
    // the newest sample that actually holds something.
    const SCAN_DEPTH = 24;

    function bodyBattery() as Number? {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) {
            return null;
        }
        return newest(SensorHistory.getBodyBatteryHistory(
            {:period => SCAN_DEPTH, :order => SensorHistory.ORDER_NEWEST_FIRST}));
    }

    function stress() as Number? {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getStressHistory)) {
            return null;
        }
        return newest(SensorHistory.getStressHistory(
            {:period => SCAN_DEPTH, :order => SensorHistory.ORDER_NEWEST_FIRST}));
    }

    function heartRateHistory() as Number? {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getHeartRateHistory)) {
            return null;
        }
        return newest(SensorHistory.getHeartRateHistory(
            {:period => SCAN_DEPTH, :order => SensorHistory.ORDER_NEWEST_FIRST}));
    }

    function newest(iterator as SensorHistory.SensorHistoryIterator?) as Number? {
        if (iterator == null) { return null; }
        var scanned = 0;
        var sample = iterator.next();
        while (sample != null && scanned < SCAN_DEPTH) {
            var data = sample.data;
            if (data != null) {
                return data.toNumber();
            }
            sample = iterator.next();
            scanned += 1;
        }
        return null;
    }

    // ------------------------------------------------------------- scaling --
    //
    // A subdial arc needs a 0..SCALE_FULL fraction, which needs a range. Some
    // metrics genuinely have one; several do not.
    //
    // Calories, distance, floors and altitude have no honest full scale -- a
    // "goal" for them would be invented, and a gauge pointing somewhere implies
    // a scale the wearer can trust. Those return null, and the caller draws the
    // digits over an unfilled track. An empty arc says "no scale here", which
    // is true; a two-thirds-full arc against a number I made up is not.
    const SCALE_FULL = 1000;

    function fraction(id as Number) as Number? {
        var m = normalize(id);
        if (m == STEPS) { return goalFraction(); }
        if (m == HEART_RATE) { return ranged(heartRate(), 40, 200); }
        if (m == RESTING_HR) { return ranged(restingHeartRate(), 40, 100); }
        if (m == BODY_BATTERY) { return ranged(bodyBattery(), 0, 100); }
        if (m == STRESS) { return ranged(stress(), 0, 100); }
        if (m == BATTERY) { return ranged(battery(), 0, 100); }
        if (m == BATTERY_DAYS) { return ranged(batteryDays(), 0, 14); }
        if (m == ACTIVE_MINUTES) { return ranged(activeMinutes(), 0, 30); }
        if (m == SLEEP_SCORE) { return ranged(SleepScore.value(), 0, 100); }
        return null;
    }

    // Steps are scaled against the wearer's own goal rather than a fixed
    // ceiling, and report honestly past 100 -- only the needle clamps.
    function goalFraction() as Number? {
        // No null guard on getInfo(): the checker proves it non-null here and
        // flags the guard as unreachable. stepGoal genuinely is nullable.
        var s = steps();
        var goal = ActivityMonitor.getInfo().stepGoal;
        if (s == null || goal == null || goal <= 0) { return null; }
        var f = (s * SCALE_FULL) / goal;
        return f > SCALE_FULL ? SCALE_FULL : f;
    }

    // Whether this metric can be drawn as a gauge at all.
    //
    // A dial with digits can show an unscaled metric over bare track. A pure
    // bar gauge cannot: with no digits, "no scale" and "zero" look identical,
    // and an empty vessel reading would be indistinguishable from a flat one.
    // Callers with no digits use this to leave unscalable metrics OUT of the
    // picker rather than offering a choice they cannot render truthfully.
    function hasScale(id as Number) as Boolean {
        var m = normalize(id);
        return (m == STEPS) || (m == HEART_RATE) || (m == RESTING_HR)
            || (m == BODY_BATTERY) || (m == STRESS) || (m == BATTERY)
            || (m == BATTERY_DAYS) || (m == ACTIVE_MINUTES) || (m == SLEEP_SCORE);
    }

    function ranged(value as Number?, low as Number, high as Number) as Number? {
        if (value == null || high <= low) { return null; }
        if (value <= low) { return 0; }
        if (value >= high) { return SCALE_FULL; }
        return ((value - low) * SCALE_FULL) / (high - low);
    }

    // ----------------------------------------------------------- formatting --

    function percent(v as Number?) as String? {
        return v == null ? null : v.format("%d") + "%";
    }

    // A clipped number is a WRONG number: 12345 shown as 1234 is not obviously
    // broken, it is merely false. Anything over four digits goes to thousands.
    function compact(v as Number) as String {
        if (v < 10000) { return v.format("%d"); }
        return (v / 1000).format("%d") + "K";
    }

    function distanceText() as String? {
        var cm = distanceCm();
        if (cm == null) { return null; }
        var metric = System.getDeviceSettings().distanceUnits == System.UNIT_METRIC;
        // Distance arrives in centimetres regardless of the display unit.
        var tenths = metric ? (cm / 10000) : ((cm * 6214) / 100000000);
        return (tenths / 10).format("%d") + "." + (tenths % 10).format("%d");
    }
}
