import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SlowMotionMoonWatchView extends WatchUi.WatchFace {
    // 2 pi
    var TWO_PI = Math.PI * 2;
   //angle adjust for time hands
    var ANGLE_ADJUST = Math.PI / 2.0;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var min = clockTime.min;
        // center, diameter, radius   
        var center_x = dc.getWidth() / 2;
        var center_y = dc.getHeight() / 2;
        var diameter = dc.getWidth() ;
        var radius = diameter / 2 ;
   
        var hour_fraction = min / 60.0;
        var hour_angle = ((hours  + hour_fraction) / 24.0) * TWO_PI;
        hour_angle -= ANGLE_ADJUST;

        dc.clear(); 

        // Set background color
        dc.setColor(Graphics.COLOR_BLACK , Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(center_x, center_y, diameter);

        //Hand
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);  
        dc.setPenWidth(2);
        dc.drawLine(center_x, center_y,
            (center_x + radius * 0.1 * Math.cos(hour_angle +  Math.PI)),
            (center_y + radius * 0.1 * Math.sin(hour_angle +  Math.PI)));
        dc.drawLine(center_x, center_y,
            (center_x + radius * Math.cos(hour_angle)),
            (center_y + radius * Math.sin(hour_angle)));
        dc.drawCircle(center_x , center_y, radius * 0.05);

        //Red Moon
	    var RedMoon = WatchUi.loadResource(Rez.Drawables.redmoon) ;
        dc.drawBitmap(center_x, center_y, RedMoon) ;

        //digits
        for (var i = 0; i < 24; i++) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);  
            dc.setPenWidth(2);
            dc.drawLine(
                (center_x + radius * 0.9 * Math.cos(i * 15 * TWO_PI / 360)), 
                (center_y + radius * 0.9 * Math.sin(i * 15 * TWO_PI / 360)),
                (center_x + radius * Math.cos(i * 15 * TWO_PI / 360)),
                (center_y + radius * Math.sin(i * 15 * TWO_PI / 360))
            );
        }

        for (var i = 0; i < 24; i++) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);  
            dc.setPenWidth(2);
            dc.drawLine(
                (center_x + radius * 0.8 * Math.cos((i * 15 + 15/2) * TWO_PI / 360)), 
                (center_y + radius * 0.8 * Math.sin((i * 15 + 15/2) * TWO_PI / 360)),
                (center_x + radius * Math.cos((i * 15 + 15/2) * TWO_PI / 360)),
                (center_y + radius * Math.sin((i * 15 + 15/2) * TWO_PI / 360))
            );
        }

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
