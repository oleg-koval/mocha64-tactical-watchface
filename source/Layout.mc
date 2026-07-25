import Toybox.Lang;
import Toybox.Math;

module Layout {

    const SCREEN = 260;
    const CENTER = 130;

    const STATUS_Y = 26;
    const STATUS_DATE_X = 46;
    const STATUS_BATTERY_X = 214;

    const TIME_X = STATUS_DATE_X;
    const TIME_HH_Y = 78;
    const TIME_MM_Y = 126;

    const DIVIDER_X = 112;
    const DIVIDER_TOP = 50;

    // Status colour rides a chip beside the label, never the value itself:
    // a coloured pixel on a transflective panel reflects only its own channel,
    // so colouring a number makes the thing you read the dimmest thing on screen.
    const CHIP_X = 120;
    const CHIP_W = 5;
    const CHIP_H = 13;
    const CHIP_INSET_Y = 4;

    const COL_LABEL_X = 132;
    const COL_VALUE_X = 228;
    const COL_TOP_Y = 50;
    const COL_STEP_Y = 25;
    const COL_ROWS = 4;

    // Vertical gaps, applied to measured glyph heights at draw time. Every
    // absolute Y below the recovery column is derived, never written down:
    // hardcoding one against an assumed font height put the goal bar through
    // the STEPS label, and then the rule through STRESS.
    const GAP_ABOVE_RULE = 8;
    const GAP_BELOW_RULE = 8;
    const GAP_BETWEEN_ROWS = 6;

    const RULE_FROM = 30;
    const RULE_TO = 230;

    // Footer row X corridors. All footer Y values are computed at draw time.

    const ROW_1_LABEL_X = 30;
    const ROW_1_VALUE_X = 230;
    const ROW_2_LABEL_X = 46;
    const ROW_2_VALUE_X = 214;

    // The bar lives in the gap between label and value, never spanning across
    // either of them.
    const STEP_BAR_X = 104;
    const STEP_BAR_W = 74;
    const STEP_BAR_H = 8;

    function columnY(row as Number) as Number {
        return COL_TOP_Y + (row * COL_STEP_Y);
    }

    // Widest half-chord of the round screen at a given y, so a row can be
    // checked against the bezel curve instead of the 260x260 square.
    function halfWidthAt(y as Number) as Number {
        var dy = y - CENTER;
        var inside = (CENTER * CENTER) - (dy * dy);
        if (inside <= 0) {
            return 0;
        }
        return Math.sqrt(inside).toNumber();
    }

    function barWidth(percent as Number, total as Number) as Number {
        if (percent <= 0) {
            return 0;
        }
        var w = (total * percent) / 100;
        return w > total ? total : w;
    }
}
