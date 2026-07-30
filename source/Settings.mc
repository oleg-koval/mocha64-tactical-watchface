import Toybox.Lang;
import Toybox.Application;

// Property reads in one place, each with a default.
//
// Application.Properties.getValue THROWS when a key is absent, which happens on
// a fresh install before settings have ever been written -- so every read is
// wrapped. This module exists so the view and the on-device menu cannot
// disagree about what the defaults are: two readers with two sets of defaults
// is exactly how the watch and the phone come to disagree about a setting.
//
// Every default here reproduces what the face showed before it was
// configurable, so an existing wearer sees no change until they choose one.
module Settings {

    // The four rows of the recovery column, top to bottom.
    const SLOT_KEYS = ["slot1", "slot2", "slot3", "slot4"];
    const SLOT_DEFAULTS = [Metrics.BODY_BATTERY, Metrics.HEART_RATE,
                           Metrics.RESTING_HR, Metrics.STRESS];
    const SLOT_COUNT = 4;

    var slots as Array<Number> = [Metrics.BODY_BATTERY, Metrics.HEART_RATE,
                                  Metrics.RESTING_HR, Metrics.STRESS] as Array<Number>;

    function load() as Void {
        var next = new Array<Number>[SLOT_COUNT];
        for (var i = 0; i < SLOT_COUNT; i += 1) {
            next[i] = Metrics.normalize(numberOr(SLOT_KEYS[i], SLOT_DEFAULTS[i]));
        }
        slots = next;
    }

    function numberOr(key as String, fallback as Number) as Number {
        try {
            return (Application.Properties.getValue(key) as Number).toNumber();
        } catch (e) {
            return fallback;
        }
    }
}
