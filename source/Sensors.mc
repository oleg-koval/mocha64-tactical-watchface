import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.UserProfile;

module Sensors {

    function currentHeartRate() as Number? {
        var info = Activity.getActivityInfo();
        if (info != null && info.currentHeartRate != null) {
            return info.currentHeartRate;
        }
        return latest(heartRateIterator());
    }

    // ActivityMonitor.Info.restingHeartRate is not present on every device, so
    // UserProfile is the fallback -- it carries the value the watch computed
    // overnight even when the activity monitor does not expose it.
    function restingHeartRate() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info has :restingHeartRate && info.restingHeartRate != null) {
            return info.restingHeartRate as Number;
        }

        if (Toybox has :UserProfile && UserProfile has :getProfile) {
            var profile = UserProfile.getProfile();
            if (profile has :restingHeartRate && profile.restingHeartRate != null) {
                return profile.restingHeartRate as Number;
            }
        }

        return null;
    }

    function bodyBattery() as Number? {
        return latest(bodyBatteryIterator());
    }

    function stress() as Number? {
        return latest(stressIterator());
    }

    // The most recent bucket can exist with null data when the device has not
    // computed it yet, so asking for a single sample loses the metric entirely.
    // Ask for a window and take the newest sample that actually carries data.
    const SCAN_DEPTH = 24;

    function bodyBatteryIterator() as SensorHistory.SensorHistoryIterator? {
        if (Toybox has :SensorHistory && SensorHistory has :getBodyBatteryHistory) {
            return SensorHistory.getBodyBatteryHistory({
                :period => SCAN_DEPTH,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
        }
        return null;
    }

    function stressIterator() as SensorHistory.SensorHistoryIterator? {
        if (Toybox has :SensorHistory && SensorHistory has :getStressHistory) {
            return SensorHistory.getStressHistory({
                :period => SCAN_DEPTH,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
        }
        return null;
    }

    function heartRateIterator() as SensorHistory.SensorHistoryIterator? {
        if (Toybox has :SensorHistory && SensorHistory has :getHeartRateHistory) {
            return SensorHistory.getHeartRateHistory({
                :period => SCAN_DEPTH,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
        }
        return null;
    }

    function latest(iterator as SensorHistory.SensorHistoryIterator?) as Number? {
        if (iterator == null) {
            return null;
        }

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

    function heartRateSeries(buckets as Number) as Array<Number> {
        var series = [] as Array<Number>;

        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getHeartRateHistory)) {
            return series;
        }

        var iterator = SensorHistory.getHeartRateHistory({
            :period => buckets * 6,
            :order => SensorHistory.ORDER_NEWEST_FIRST
        });
        var sample = iterator.next();
        while (sample != null && series.size() < buckets) {
            var data = sample.data;
            if (data != null) {
                series.add(data.toNumber());
            }
            sample = iterator.next();
        }

        return series;
    }
}
