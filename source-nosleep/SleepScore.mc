import Toybox.Lang;

// Sleep score stub, for devices whose API predates Complications (4.2.0) --
// the fenix 6 family, vivoactive 4 and the legacy watches. The real module is
// in source-sleep; monkey.jungle picks one per device.
//
// isSupported() being false is what keeps sleep OUT of the settings pickers on
// these devices, rather than offering a choice that could only ever read blank.
module SleepScore {

    function isSupported() as Boolean {
        return false;
    }

    function value() as Number? {
        return null;
    }
}
