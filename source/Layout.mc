import Toybox.Lang;

module Layout {

    const SCREEN = 260;

    const MARGIN = 12;
    const RULE_WEIGHT = 1;

    const TIME_OFFSET_Y = 20;
    const BATTERY_OFFSET_Y = 46;

    const BAR_HEIGHT = 8;

    function inset(value as Number) as Number {
        return value + MARGIN;
    }

    function barWidth(fraction as Number, total as Number) as Number {
        if (fraction <= 0) {
            return 0;
        }
        return (total * fraction) / 100;
    }
}
