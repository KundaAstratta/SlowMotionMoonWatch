import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Application;

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

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var moonNumber = getMoonPhase(today.year, ((today.month)-1), today.day);  

        //dc.clear(); 
        View.onUpdate(dc);

        // Set background color
        dc.setColor(Graphics.COLOR_BLACK , Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(center_x, center_y, diameter);

        //Red Moon
	    var RedMoon = WatchUi.loadResource(Rez.Drawables.redmoon) ;
        dc.drawBitmap(center_x, center_y, RedMoon) ;

        //Moon phase
        showMoonPhase(dc, moonNumber, center_x + center_x / 3 , center_y + center_y / 3);

        //digits
        for (var i = 0; i < 24; i++) {
            // Dessiner le contour blanc du tiret
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);  
            dc.setPenWidth(4); // Largeur du contour blanc
            dc.drawLine(
                (center_x + radius * 0.9 * Math.cos(i * 15 * TWO_PI / 360)), 
                (center_y + radius * 0.9 * Math.sin(i * 15 * TWO_PI / 360)),
                (center_x + radius * Math.cos(i * 15 * TWO_PI / 360)),
                (center_y + radius * Math.sin(i * 15 * TWO_PI / 360))
            );
            // Dessiner le tiret
            dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);  
            dc.setPenWidth(2);
            dc.drawLine(
                (center_x + radius * 0.9 * Math.cos(i * 15 * TWO_PI / 360)), 
                (center_y + radius * 0.9 * Math.sin(i * 15 * TWO_PI / 360)),
                (center_x + radius * Math.cos(i * 15 * TWO_PI / 360)),
                (center_y + radius * Math.sin(i * 15 * TWO_PI / 360))
            );
        }

        for (var i = 0; i < 24; i++) {
            // Dessiner le contour blanc du tiret
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);  
            dc.setPenWidth(4); // Largeur du contour blanc
            dc.drawLine(
                (center_x + radius * 0.8 * Math.cos((i * 15 + 15/2) * TWO_PI / 360)), 
                (center_y + radius * 0.8 * Math.sin((i * 15 + 15/2) * TWO_PI / 360)),
                (center_x + radius * Math.cos((i * 15 + 15/2) * TWO_PI / 360)),
                (center_y + radius * Math.sin((i * 15 + 15/2) * TWO_PI / 360))
            );
            // Dessiner le tiret
            dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);  
            dc.setPenWidth(2);
            dc.drawLine(
                (center_x + radius * 0.8 * Math.cos((i * 15 + 15/2) * TWO_PI / 360)), 
                (center_y + radius * 0.8 * Math.sin((i * 15 + 15/2) * TWO_PI / 360)),
                (center_x + radius * Math.cos((i * 15 + 15/2) * TWO_PI / 360)),
                (center_y + radius * Math.sin((i * 15 + 15/2) * TWO_PI / 360))
            );
        }

        //Numbers
        var isShowNumbers = Application.getApp().getProperty("isShowNumbers") ; 
        if (isShowNumbers) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);  
            dc.drawText(center_x, center_y - radius * 0.92, Graphics.FONT_SMALL, "0", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(center_x, center_y + radius * 0.7, Graphics.FONT_SMALL, "12", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(center_x - radius * 0.82, center_y - radius * 0.12, Graphics.FONT_SMALL, "18", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(center_x + radius * 0.82, center_y - radius * 0.12 , Graphics.FONT_SMALL, "6", Graphics.TEXT_JUSTIFY_CENTER);
        }

        //Hand
        var isBasicHand = Application.getApp().getProperty("isBasicHand");
        var handColor = Graphics.COLOR_YELLOW;
        if (isBasicHand) {
            //Basic hand
            basicHand(dc,handColor, center_x, center_y, hour_angle, radius);
        }

        if (!isBasicHand) {
            //Design Hand
            designHand(dc,handColor, center_x, center_y, hour_angle, radius);
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

    function basicHand(dc,handColor, center_x, center_y, hour_angle, radius) {
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);  
        dc.setColor(handColor, Graphics.COLOR_TRANSPARENT);  

        dc.setPenWidth(3);
        dc.drawLine(center_x, center_y,
            (center_x + radius * 0.1 * Math.cos(hour_angle +  Math.PI)),
            (center_y + radius * 0.1 * Math.sin(hour_angle +  Math.PI)));
        dc.drawLine(center_x, center_y,
            (center_x + radius * Math.cos(hour_angle)),
            (center_y + radius * Math.sin(hour_angle)));
        dc.drawCircle(center_x , center_y, radius * 0.05);
    }

    function designHand(dc,handColor, center_x, center_y, hour_angle, radius)  {
        // Couleur plus foncée pour l'effet de profondeur
        var handOutlineColor = Graphics.COLOR_DK_GRAY; 

        // Calcul des coordonnées pour la pointe en triangle
        var tipX = center_x + radius  * Math.cos(hour_angle);
        var tipY = center_y + radius  * Math.sin(hour_angle);
        var tipX1 = center_x + radius * 0.1 * Math.cos(hour_angle +  Math.PI/10); // Même facteur et angle que la queue
        var tipY1 = center_y + radius * 0.1 * Math.sin(hour_angle +  Math.PI/10);
        var tipX2 = center_x + radius * 0.1 * Math.cos(hour_angle -  Math.PI/10);
        var tipY2 = center_y + radius * 0.1 * Math.sin(hour_angle -  Math.PI/10);

        // Calcul des coordonnées pour la queue de l'aiguille
        var tailX = center_x + radius * 0.15 * Math.cos(hour_angle + Math.PI);
        var tailY = center_y + radius * 0.15 * Math.sin(hour_angle + Math.PI);
        var tailX1 = center_x + radius * 0.1 * Math.cos(hour_angle + Math.PI + Math.PI/10);
        var tailY1 = center_y + radius * 0.1 * Math.sin(hour_angle + Math.PI + Math.PI/10);
        var tailX2 = center_x + radius * 0.1 * Math.cos(hour_angle + Math.PI - Math.PI/10);
        var tailY2 = center_y + radius * 0.1 * Math.sin(hour_angle + Math.PI - Math.PI/10);

        // Dessiner le contour de l'aiguille
        dc.setColor(handOutlineColor, Graphics.COLOR_TRANSPARENT);  
        dc.setPenWidth(5);
        dc.drawLine(tailX, tailY, tipX, tipY);

        // Dessiner l'aiguille
        dc.setColor(handColor, Graphics.COLOR_TRANSPARENT);  
        dc.setPenWidth(3);
        dc.drawLine(tailX, tailY, tipX, tipY);
        dc.fillPolygon([[tipX, tipY], [tipX1, tipY1], [tipX2, tipY2]]); 

        // Dessiner la queue de l'aiguille
        dc.fillPolygon([[tailX, tailY], [tailX1, tailY1], [tailX2, tailY2]]);

        // Dessiner le disque central avec dégradé
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.fillCircle(center_x , center_y, radius * 0.05);
        dc.setColor(handColor, Graphics.COLOR_TRANSPARENT);  
        dc.drawCircle(center_x , center_y, radius * 0.05);        
    }


    function getMoonPhase(year, month, day) {

      var c=0;
      var e=0;
      var jd=0;
      var b=0;

      if (month < 3) {
        year--;
        month += 12;
      }

      ++month; 

      c = 365.25 * year;

      e = 30.6 * month;

      jd = c + e + day - 694039.09; 

      jd /= 29.5305882; 

      b = (jd).toNumber(); 

      jd -= b; 

      b = Math.round(jd * 8); 

      if (b >= 8) {
        b = 0; 
      }
     
      return (b).toNumber();
    }

     /*
     0 => New Moon
     1 => Waxing Crescent Moon
     2 => Quarter Moon
     3 => Waxing Gibbous Moon
     4 => Full Moon
     5 => Waning Gibbous Moon
     6 => Last Quarter Moon
     7 => Waning Crescent Moon
     */

    function showMoonPhase(dc, moonNumber, position_x, position_y) {
        if (moonNumber == 0) {
            var newMoon = WatchUi.loadResource(Rez.Drawables.newMoon) ;
            dc.drawBitmap(position_x, position_y, newMoon) ;
        }

        if (moonNumber == 1) {
            var waxingCrescent = WatchUi.loadResource(Rez.Drawables.waxingCrescent) ;
            dc.drawBitmap(position_x, position_y, waxingCrescent) ;
        }

        if (moonNumber == 2) {
            var firstQuarter = WatchUi.loadResource(Rez.Drawables.firstQuarter) ;
            dc.drawBitmap(position_x, position_y, firstQuarter) ;
        }

        if (moonNumber == 3) {
            var waxingGibbous = WatchUi.loadResource(Rez.Drawables.waxingGibbous) ;
            dc.drawBitmap(position_x, position_y, waxingGibbous) ;
        }

        if (moonNumber == 4) {
            var fullMoon = WatchUi.loadResource(Rez.Drawables.fullMoon) ;
            dc.drawBitmap(position_x, position_y, fullMoon) ;
        }


        if (moonNumber == 5) {
            var waningGibbous = WatchUi.loadResource(Rez.Drawables.waningGibbous) ;
            dc.drawBitmap(position_x, position_y, waningGibbous) ;
        }

        if (moonNumber == 6) {
            var thirdQuarter = WatchUi.loadResource(Rez.Drawables.thirdQuarter) ;
            dc.drawBitmap(position_x, position_y, thirdQuarter) ;
        }

        if (moonNumber == 7) {
            var waningCrescent = WatchUi.loadResource(Rez.Drawables.waningCrescent) ;
            dc.drawBitmap(position_x, position_y, waningCrescent) ;
        }
    }



}
