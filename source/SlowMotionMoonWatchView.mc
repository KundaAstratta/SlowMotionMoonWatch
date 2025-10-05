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

    private var _centerX as Number = 0;
    private var _centerY as Number = 0;
    private var _radius as Number = 0;
    private var _radiusMarkers as Number = 0;
    //private var _hasNotifications as Boolean = false;


    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        _centerX = dc.getWidth() / 2;
        _centerY = dc.getHeight() / 2;
        _radiusMarkers = dc.getWidth() /2;
        _radius = (_centerX < _centerY ? _centerX : _centerY) - 20;
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
        View.onUpdate(dc);

        // Set background color
        dc.setColor(Graphics.COLOR_BLACK , Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(center_x, center_y, diameter);
        drawConcentricBackground(dc);
        drawStarField(dc);

        //Red Moon
	    var RedMoon = WatchUi.loadResource(Rez.Drawables.redmoon) ;
        dc.drawBitmap(center_x, center_y, RedMoon) ;

        //digits
        drawHourMarkers(dc);
        //month
        drawCurvedMonth(dc);
        //jours
        drawSystemInfo(dc);
        //moon phases
        drawMoonPhase(dc);

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


    private function drawHourMarkers(dc as Dc) as Void {
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        
        var outerRadius = _radiusMarkers - 5;
        var innerRadius = _radiusMarkers - 20; // Allongé de 15 à 20 (5 pixels de plus)
        
        // Dessiner les traits d'heures
        for (var i = 0; i < 24; i++) {
            var angle = (i * Math.PI * 2) / 24 - Math.PI / 2;
            var cos = Math.cos(angle);
            var sin = Math.sin(angle);
            
            var x1 = _centerX + outerRadius * cos;
            var y1 = _centerY + outerRadius * sin;
            var x2 = _centerX + innerRadius * cos;
            var y2 = _centerY + innerRadius * sin;
            
            dc.drawLine(x1, y1, x2, y2);
            
            // Ajouter 3 points entre ce trait et le suivant
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT); // Couleur or pour les points
            for (var j = 1; j <= 3; j++) {
                // Calculer l'angle pour chaque point (répartition égale)
                var nextHourAngle = ((i + 1) * Math.PI * 2) / 24 - Math.PI / 2;
                var pointAngle = angle + (nextHourAngle - angle) * j / 4;
                
                var pointCos = Math.cos(pointAngle);
                var pointSin = Math.sin(pointAngle);
                
                // Position des points (plus près du bord extérieur)
                var pointRadius = _radiusMarkers - 8;
                var pointX = _centerX + pointRadius * pointCos;
                var pointY = _centerY + pointRadius * pointSin;
                
                // Dessiner le point
                dc.fillCircle(pointX, pointY, 1);
            }
        }
        
        // Numéros des heures principales
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(_centerX, _centerY - _radiusMarkers * 0.92, Graphics.FONT_XTINY, "0", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _centerY + _radiusMarkers * 0.78, Graphics.FONT_XTINY, "12", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX - _radiusMarkers * 0.82, _centerY - _radiusMarkers * 0.08, Graphics.FONT_XTINY, "18", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX + _radiusMarkers * 0.82, _centerY - _radiusMarkers * 0.08, Graphics.FONT_XTINY, "6", Graphics.TEXT_JUSTIFY_CENTER);
    }

     // NOUVELLE FONCTION : pour dessiner background
     private function drawConcentricBackground(dc as Dc) as Void {
        // Couleurs du dégradé du plus foncé au plus clair
        var colors = [
            0x000510, // Centre: Bleu très très sombre
            0x000A18,
            0x001020,
            0x001528,
            0x001A30,
            0x002038,
            0x002540,
            0x003048,
            0x003550,
            0x004060  // Extérieur: Bleu nuit plus clair
        ];
        var maxRadius = _radius + 20;
        var numRings = colors.size();
        
        // Dessiner les cercles concentriques du plus grand au plus petit
        for (var i = numRings - 1; i >= 0; i--) {
            var ringRadius = maxRadius * (i + 1) / numRings;
            dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(_centerX, _centerY, ringRadius);
        }
    }


    private function drawStarField(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Vous pouvez ajuster le nombre d'étoiles ici
        var numStars = 200;
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Utilise une graine (seed) constante pour que le champ d'étoiles soit
        // identique à chaque appel. C'est un simple générateur pseudo-aléatoire.
        var seed = 1;

        for (var i = 0; i < numStars; i++) {
            // Génère une coordonnée X pseudo-aléatoire
            seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var x = seed % width;

            // Génère une coordonnée Y pseudo-aléatoire
            seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var y = seed % height;

            // Fait varier la taille des étoiles pour un effet plus naturel
            // 30% des étoiles seront un peu plus grandes.
            seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var size = (seed % 10 > 7) ? 2 : 1;

            dc.fillCircle(x, y, size);
        }
    }

     // NOUVELLE FONCTION : pour dessiner la phase de la Lune  
     private function drawMoonPhase(dc as Dc) as Void {
        //var settings = System.getDeviceSettings();
        //_hasNotifications = settings.notificationCount > 0;
        
        //if (_hasNotifications) {
            // Position de la lune
            var moonX = _centerX + _centerX / 2;
            var moonY = _centerY + _centerY / 2;  
            var moonRadius = 28; 
   
            // Calcul de la phase de la Lune (formule plus fiable)
            var today = Time.now();
            var dateInfo = Gregorian.info(today, Time.FORMAT_SHORT);
            
            // Calcul du jour julien
            var year = dateInfo.year;
            var month = dateInfo.month;
            var day = dateInfo.day;
            
            var ye = year;
            var m = month;
            if (month <= 2) {
                ye = ye - 1;
                m = m + 12;
            }
            var a = Math.floor(ye / 100);
            var b = 2 - a + Math.floor(a / 4);
            var julianDay = Math.floor(365.25 * (ye + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524.5;
            
            // Phase de la lune (0 = Nouvelle Lune, 1 = Pleine Lune)
            var lunarDaysSinceNewMoon = (julianDay - 2451550.1).toFloat(); // Jour julien de la Nouvelle Lune de janvier 2000
            var phase = lunarDaysSinceNewMoon / 29.530588853;
            phase = phase - Math.floor(phase);


            // Dessiner l'ombre de la lune
            var shadowColor = 0x001133;
            
            // Dessiner un cercle blanc pour la lune
            dc.setColor(shadowColor, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(moonX, moonY, moonRadius);
            
           
            // Calculer le décalage de l'ombre pour un effet de croissant
            var shadowOffset = Math.cos(phase * Math.PI * 2);
            
            // L'ombre est plus foncée au milieu du cycle (croissant/décroissant)
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            
            // Dessiner la partie ombragée
            for (var y = -moonRadius; y <= moonRadius; y++) {
                var x = Math.sqrt(moonRadius * moonRadius - y * y);
                var xOffset = x * shadowOffset;
                
                // Si la phase est croissante
                if (phase <= 0.5) {
                    dc.drawLine(moonX + xOffset.toNumber(), moonY + y, moonX + x.toNumber(), moonY + y);
                } 
                // Si la phase est décroissante
                else {
                    dc.drawLine(moonX - x.toNumber(), moonY + y, moonX - xOffset.toNumber(), moonY + y);
                }
            }
            dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT); // Orange
            dc.setPenWidth(2);
            dc.drawCircle(moonX, moonY, moonRadius);
        //}
    }


    // NOUVELLE FONCTION pour dessiner le mois en suivant une courbe
    private function drawCurvedMonth(dc as Dc) as Void {
        // NOUVEAU : Tableau des noms des mois en anglais
        var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

        // On récupère les informations de date avec le mois en tant que NUMÉRO (1-12)
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var monthNumber = today.month;

        // On sélectionne le nom du mois en anglais dans notre tableau
        // (on soustrait 1 car les tableaux commencent à l'index 0)
        var monthString = monthNames[monthNumber - 1];

        // Le reste de la fonction est inchangé et dessinera le mot anglais
        var font = Graphics.FONT_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var textRadius = _radiusMarkers - 28;
        var anglePerChar = 0.12; 
        var totalAngle = monthString.length() * anglePerChar;
        var centerAngle = (2.0 / 24.0) * Math.PI * 2 - Math.PI / 2;
        var startAngle = centerAngle - (totalAngle / 2.0);

        for (var i = 0; i < monthString.length(); i++) {
            var charAngle = startAngle + (i * anglePerChar);
            var char = monthString.substring(i, i + 1);

            var x = _centerX + textRadius * Math.cos(charAngle);
            var y = _centerY + textRadius * Math.sin(charAngle);

            dc.drawText(x, y, font, char, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // NOUVELLE FONCTION pour dessiner la date et l'icône de batterie en courbe
    private function drawSystemInfo(dc as Dc) as Void {
        // --- 1. Dessin de la date en courbe avec espacement ---
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayString = today.day.format("%02d");

        var font = Graphics.FONT_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var textRadius = _radiusMarkers - 28;
        
        // Espacement de base entre les centres des caractères
        var baseSpacing = 0.12; 
        // NOUVEAU : Espace supplémentaire à ajouter
        var extraSpaceAngle = 0.02; // Ajustez cette valeur pour plus/moins d'espace

        // L'angle de la position centrale (4h30) reste notre référence
        var centerAngle = (3.5 / 24.0) * Math.PI * 2 - Math.PI / 2;
        
        // L'écart total entre les centres des deux chiffres sera la somme des espacements
        var totalSpacing = baseSpacing + extraSpaceAngle;

        // Calculer l'angle pour chaque chiffre en se basant sur le centre
        var tensAngle = centerAngle - (totalSpacing / 2.0);
        var unitsAngle = centerAngle + (totalSpacing / 2.0);

        // Dessiner le premier chiffre (dizaines)
        var tensChar = dayString.substring(0, 1);
        var x1 = _centerX + textRadius * Math.cos(tensAngle);
        var y1 = _centerY + textRadius * Math.sin(tensAngle);
        dc.drawText(x1, y1, font, tensChar, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Dessiner le second chiffre (unités)
        var unitsChar = dayString.substring(1, 2);
        var x2 = _centerX + textRadius * Math.cos(unitsAngle);
        var y2 = _centerY + textRadius * Math.sin(unitsAngle);
        dc.drawText(x2, y2, font, unitsChar, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

}
