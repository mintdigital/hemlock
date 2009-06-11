package com.mintdigital.hemlock.widgets.countdown{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.Timer;
    
    public class CountdownWidget extends HemlockWidget{
        /*
        This widget exists purely as a front-end for the built-in Timer class.
        If you need a timer, maintain a separate one outside of this class.
        */
        
        include 'events.as';
        include 'views.as';

        private var timer:Timer;
        
        public function CountdownWidget(parentSprite:HemlockSprite, options:Object = null){
            // TODO: Accept a Timer as a parameter, and manage it through start() and reset()?
            timer = new Timer(1000);
            
            super(parentSprite, options);
        }
        
        public function start(seconds:uint):void{
            // Starts counting down for the given number of seconds.
            timer.repeatCount = seconds;
            setSeconds(seconds);
            show();
            timer.start();
            startListeners();
        }
        
        public function reset():void{
            stopListeners();
            timer.reset();
            hide();
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        private function setSeconds(value:uint):void{
            views.countdown.getChildAt(0).text = value;
            // TODO: Make views.countdown.graphics reflect time remaining like a pie chart
        }
    }
}
