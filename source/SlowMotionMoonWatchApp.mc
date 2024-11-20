import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SlowMotionMoonWatchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    /*
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new SlowMotionMoonWatchView() ] as Array<Views or InputDelegates>;
    }
    */
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SlowMotionMoonWatchView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

}

function getApp() as SlowMotionMoonWatchApp {
    return Application.getApp() as SlowMotionMoonWatchApp;
}