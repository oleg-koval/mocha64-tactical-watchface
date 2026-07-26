import Toybox.Lang;
import Toybox.Math;

module Layout {

    const SCREEN = 260;
    const CENTER = 130;

    // 26 put the date baseline outside the round bezel curve at that height
    // (halfWidthAt(26)=78, but the X corridor needs >=84) -- clipped on real
    // hardware. 34 clears it with margin.
    const STATUS_Y = 32;
    const STATUS_DATE_X = 46;

    // Days-remaining sits opposite the weekday on the top band, which is the
    // one horizontal strip with nothing else in it. Footer row 2 was the other
    // candidate, but the bezel curve leaves under 80px of usable width down
    // there -- not enough for two label+value pairs.
    const STATUS_BATTERY_X = 214;

    const TIME_X = STATUS_DATE_X;
    const GAP_DATE_TO_TIME = 2;

    // FONT_NUMBER_MEDIUM measures 74px tall on this device, so stacking the two
    // time lines at full font height costs 148px of a 260px face and pushes the
    // footer clean off the bottom. The glyph box carries a lot of padding the
    // ink never uses, so the lines sit at 5/8 pitch -- the boxes overlap, the
    // digits do not. This is the one place a measured height must be reduced
    // rather than used raw.
    function timeLinePitch(timeH as Number) as Number {
        return (timeH * 5) / 8;
    }

    const DIVIDER_X = 112;
    const DIVIDER_TOP = 44;

    // Status colour used to ride a chip beside the label so the number could
    // stay full-white: a coloured pixel on a transflective panel reflects only
    // its own channel, so a coloured glyph is dimmer than a white one. The
    // chips are gone by request -- the value carries its own status colour now,
    // which trades some outdoor legibility for a faster read.
    const COL_LABEL_X = 120;
    const COL_VALUE_X = 228;
    const COL_TOP_Y = 50;
    const COL_ROWS = 4;

    // Vertical gaps, applied to measured glyph heights at draw time. Every
    // absolute Y below the recovery column is derived, never written down:
    // hardcoding one against an assumed font height put the goal bar through
    // the STEPS label, and then the rule through STRESS.
    // Kept tight on purpose. The two-line time block is ~100px of the 260px
    // face, so every pixel spent above the rule pushes footer row 2 further
    // down the bezel curve, where the usable X corridor collapses fast.
    const GAP_ABOVE_RULE = 6;
    const GAP_BELOW_RULE = 6;
    const GAP_BETWEEN_ROWS = 4;

    const RULE_FROM = 30;
    const RULE_TO = 230;

    // Footer row X corridors. All footer Y values are computed at draw time.
    // Row 1 sits high enough that the fixed corridor clears the bezel curve
    // with margin at every font size this face uses. Row 2 sits low enough
    // that a fixed corridor does not: at the real FONT_SMALL height (32px),
    // the old 46/214 corridor needed a curve half-width of ~84px but only
    // ~64px is actually available at that row's bottom edge -- clipped by
    // the round bezel on real hardware. footerRowXBounds() derives row 2's
    // corridor from the curve itself instead of a second guessed constant.

    const ROW_1_LABEL_X = 42;
    const ROW_1_VALUE_X = 218;

    const BOTTOM_MARGIN = 14;

    // The footer is the thing that falls off the face when anything above it
    // grows, and content drawn past y=260 is invisible with no warning at all.
    // So the rule is clamped: the two footer rows reserve their space first and
    // the stack above gives way, rather than the other way round.
    function clampRuleY(derived as Number, footerH as Number) as Number {
        var reserved = (footerH * 2) + GAP_BELOW_RULE + GAP_BETWEEN_ROWS;
        var maxRuleY = SCREEN - BOTTOM_MARGIN - reserved;
        return derived > maxRuleY ? maxRuleY : derived;
    }

    const FOOTER_BEZEL_MARGIN = 4;

    function footerRowXBounds(bottomY as Number) as Array<Number> {
        var half = halfWidthAt(bottomY) - FOOTER_BEZEL_MARGIN;
        if (half < 0) {
            half = 0;
        }
        return [CENTER - half, CENTER + half] as Array<Number>;
    }

    // The bar lives in the gap between label and value, never spanning across
    // either of them.
    const STEP_BAR_X = 104;
    const STEP_BAR_W = 74;
    const STEP_BAR_H = 8;

    // The recovery column is spread across exactly the height of the time
    // block, so its row pitch comes from the measured layout rather than a
    // constant. The old COL_STEP_Y of 25 was smaller than the real FONT_SMALL
    // height of 32, so every row overlapped the one below it by 7px.
    function columnStep(availableHeight as Number) as Number {
        return availableHeight / COL_ROWS;
    }

    function columnY(row as Number, step as Number) as Number {
        return COL_TOP_Y + (row * step);
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
