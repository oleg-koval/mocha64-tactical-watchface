import Toybox.Lang;

module Palette {

    const BG      = 0x000000;
    const PANEL   = 0x000055;
    const RULE    = 0x555555;
    const LABEL   = 0xAAAAAA;
    const VALUE   = 0xFFFFFF;

    const READY   = 0x55FF55;
    const CAUTION = 0xFFAA00;
    const STRAIN  = 0xFF5555;
    const DATA    = 0x55AAFF;

    const LEVELS = [0x00, 0x55, 0xAA, 0xFF];

    function quantizeChannel(value as Number) as Number {
        var nearest = LEVELS[0];
        var bestDelta = 256;
        for (var i = 0; i < LEVELS.size(); i += 1) {
            var delta = (value - LEVELS[i]).abs();
            if (delta < bestDelta) {
                bestDelta = delta;
                nearest = LEVELS[i];
            }
        }
        return nearest;
    }

    function quantize(color as Number) as Number {
        var r = quantizeChannel((color >> 16) & 0xFF);
        var g = quantizeChannel((color >> 8) & 0xFF);
        var b = quantizeChannel(color & 0xFF);
        return (r << 16) | (g << 8) | b;
    }

    function isLatticeExact(color as Number) as Boolean {
        return quantize(color) == color;
    }
}
