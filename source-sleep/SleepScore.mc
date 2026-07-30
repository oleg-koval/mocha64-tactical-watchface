import Toybox.Lang;
import Toybox.Complications;

// Sleep score, for devices whose API actually has it.
//
// There is no direct sleep API in Connect IQ at all: ActivityMonitor has none,
// SensorHistory has none, and UserProfile.sleepTime is the bedtime you
// configured rather than how you slept. The Complications API is the only
// route, and it arrived in 4.2.0.
//
// A `Toybox has :Complications` guard is NOT enough. The compiler resolves the
// symbol at build time and rejects the file outright for a device whose API is
// older, so this lives in a source path included only for capable devices --
// see monkey.jungle. source-nosleep holds the stub for everyone else.
module SleepScore {

    function isSupported() as Boolean {
        return true;
    }

    function value() as Number? {
        try {
            var c = Complications.getComplication(
                new Complications.Id(Complications.COMPLICATION_TYPE_SLEEP_SCORE));
            if (c == null) { return null; }
            var v = c.value;
            if (v == null) { return null; }
            return v.toNumber();
        } catch (e) {
            // getComplication throws when the system publishes no such
            // complication, rather than returning null, so this catch is the
            // ordinary path on a supported device with no sleep recorded yet.
            return null;
        }
    }
}
