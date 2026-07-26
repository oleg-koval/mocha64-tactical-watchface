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
        return Fields.batteryColor(80.0) == Palette.LABEL;
    }

    (:test)
    function batteryColorBoundariesAreInclusive(logger as Logger) as Boolean {
        return Fields.batteryColor(10.0) == Palette.STRAIN
            && Fields.batteryColor(25.0) == Palette.CAUTION;
    }

    // A 14-day watch at 50% has a week left. Treating that as a warning was the
    // original bug -- half charge must read as healthy.
    (:test)
    function halfChargeIsHealthyNotCaution(logger as Logger) as Boolean {
        return Fields.batteryColor(50.0) == Palette.LABEL;
    }

    // Colour is reserved for states worth interrupting a glance for.
    (:test)
    function onlyUnhealthyBatteryTakesColour(logger as Logger) as Boolean {
        return Fields.batteryColor(90.0) == Palette.LABEL
            && Fields.batteryColor(25.0) == Palette.CAUTION
            && Fields.batteryColor(8.0) == Palette.STRAIN;
    }

    (:test)
    function goalPercentClampsAtHundred(logger as Logger) as Boolean {
        return Fields.goalPercent(15000, 10000) == 100;
    }

    (:test)
    function goalPercentSurvivesZeroGoal(logger as Logger) as Boolean {
        return Fields.goalPercent(500, 0) == 0;
    }

    (:test)
    function formatDayNameIsUppercaseAndThreeLetters(logger as Logger) as Boolean {
        return Fields.formatDayName(7).equals("SAT")
            && Fields.formatDayName(1).equals("SUN");
    }

    (:test)
    function formatDayMonthPadsBothPartsToTwoDigits(logger as Logger) as Boolean {
        return Fields.formatDayMonth(26, 7).equals("26.07")
            && Fields.formatDayMonth(1, 1).equals("01.01");
    }

    // Days-remaining is the number worth acting on; it must round DOWN so a
    // watch reading 6d never dies partway through day 6.
    (:test)
    function batteryDaysRoundsDownAgainstFullRuntime(logger as Logger) as Boolean {
        return Fields.batteryDays(100.0) == 14
            && Fields.batteryDays(50.0) == 7
            && Fields.batteryDays(99.0) == 13;
    }

    (:test)
    function batteryDaysBottomsOutAtZero(logger as Logger) as Boolean {
        return Fields.batteryDays(3.0) == 0
            && Fields.batteryDays(0.0) == 0;
    }

    (:test)
    function formatBatteryReadsInDaysNotPercent(logger as Logger) as Boolean {
        return Fields.formatBattery(50.0).equals("7d");
    }

    (:test)
    function bodyBatteryBandsRunLowToHigh(logger as Logger) as Boolean {
        return Fields.bodyBatteryColor(10) == Palette.STRAIN
            && Fields.bodyBatteryColor(40) == Palette.CAUTION
            && Fields.bodyBatteryColor(90) == Palette.READY;
    }

    (:test)
    function stressBandsAreInvertedVersusBodyBattery(logger as Logger) as Boolean {
        return Fields.stressColor(10) == Palette.READY
            && Fields.stressColor(30) == Palette.CAUTION
            && Fields.stressColor(80) == Palette.STRAIN;
    }

    (:test)
    function goalColorChangesOnCompletion(logger as Logger) as Boolean {
        return Fields.goalColor(99) == Palette.VALUE
            && Fields.goalColor(100) == Palette.FILL_OK;
    }

    (:test)
    function formatMetricShowsDashWhenSensorIsSilent(logger as Logger) as Boolean {
        return Fields.formatMetric(null).equals("--");
    }

    (:test)
    function formatCountLeavesSmallNumbersIntact(logger as Logger) as Boolean {
        return Fields.formatCount(8241).equals("8241");
    }

    (:test)
    function formatCountAbbreviatesAboveTenThousand(logger as Logger) as Boolean {
        return Fields.formatCount(12480).equals("12.4K");
    }

    (:test)
    function formatCountHandlesNull(logger as Logger) as Boolean {
        return Fields.formatCount(null).equals("--");
    }

    // The simulator reports zero steps and zero calories because it has no
    // activity data, not because the render path is broken. These pin the
    // behaviour at zero and at realistic values so a real watch is the only
    // remaining unknown.
    (:test)
    function zeroStepsRenderAsZeroNotDashes(logger as Logger) as Boolean {
        return Fields.formatCount(0).equals("0");
    }

    (:test)
    function zeroGoalProgressIsEmptyBarNotFullBar(logger as Logger) as Boolean {
        return Fields.goalPercent(0, 10000) == 0
            && Layout.barWidth(0, 100) == 0;
    }

    (:test)
    function realisticStepCountFormats(logger as Logger) as Boolean {
        return Fields.formatCount(8241).equals("8241")
            && Fields.goalPercent(8241, 10000) == 82;
    }

    (:test)
    function realisticCalorieCountFormats(logger as Logger) as Boolean {
        return Fields.formatCount(2140).equals("2140");
    }
}
