import Toybox.Lang;
import Toybox.Test;

module FieldsTest {

    (:test)
    function formatTimePadsBothParts(logger as Logger) as Boolean {
        return Fields.formatTime(9, 5).equals("09:05");
    }

    (:test)
    function formatTimeKeepsTwentyFourHour(logger as Logger) as Boolean {
        return Fields.formatTime(23, 59).equals("23:59");
    }

    (:test)
    function formatTimeHandlesMidnight(logger as Logger) as Boolean {
        return Fields.formatTime(0, 0).equals("00:00");
    }

    (:test)
    function batteryColorFlagsCritical(logger as Logger) as Boolean {
        return Fields.batteryColor(5.0) == Palette.STRAIN;
    }

    (:test)
    function batteryColorFlagsHealthy(logger as Logger) as Boolean {
        return Fields.batteryColor(80.0) == Palette.READY;
    }

    (:test)
    function batteryColorBoundariesAreInclusive(logger as Logger) as Boolean {
        return Fields.batteryColor(20.0) == Palette.STRAIN
            && Fields.batteryColor(50.0) == Palette.CAUTION;
    }

    (:test)
    function goalPercentClampsAtHundred(logger as Logger) as Boolean {
        return Fields.goalPercent(15000, 10000) == 100;
    }

    (:test)
    function goalPercentSurvivesZeroGoal(logger as Logger) as Boolean {
        return Fields.goalPercent(500, 0) == 0;
    }
}
