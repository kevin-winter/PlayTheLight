﻿package {	import net.eriksjodin.arduino.*;	import net.eriksjodin.arduino.events.ArduinoEvent;	import net.eriksjodin.arduino.events.ArduinoSysExEvent;		import flash.display.StageDisplayState; 	import flash.display.StageScaleMode; 	import flash.display.StageAlign;	import flash.ui.Mouse; 	import flash.ui.MouseCursor; 		import flash.events.Event;	import flash.display.MovieClip;	import flash.media.Sound;	import flash.media.SoundChannel;	import at.Instrument;	import flash.events.TimerEvent;	import flash.utils.Timer;		//Sion imports	import org.si.sion.SiONDriver; //Driver	import org.si.sound.DrumMachine;	import org.si.sion.utils.SiONPresetVoice;	import flash.display.Loader;	import flash.net.URLRequest;	public class PlayTheLight extends MovieClip	{		public var antiFlackerTimer:Timer = new Timer(400,1);		public var initComplete:Boolean;		public var numEvents:int;		public var arduino:Arduino;				public var BPM:int = 80;		public var beat:Timer = new Timer(60000/(BPM*4));		public var globalOffset:int = 0;		public var offsets:Array = [0,0,0,0,0,0,0,0];		private var sionSound:SiONPresetVoice = new SiONPresetVoice();				private var gameMode:String;		private var piano = new Instrument("Piano", "valsound.piano1", 60, "./images/piano.png"); //60		private var trumpet = new Instrument("Trumpet", "valsound.strpad1", 20, "./images/trumpet.png"); //20		private var guitar = new Instrument("Guitar", "valsound.guitar1", 60, "./images/guitar.png"); //60		//Drums Einzeltöne		private var bass = new Instrument("Bass", "svmidi.drum33", 50);		private var snare = new Instrument("Snare", "snare", 50);		private var hihat = new Instrument("Hihat", "closedhh", 50);				private var instr:Array = [piano,trumpet,guitar];		private var instrumentLoader = new Loader(); 		private var modeLoader = new Loader(); 				public var lData:Array = [0,0,0,0,0,0,0,0];				private var sionDriver:SiONDriver;		private var lichtsensoren:Array = new Array();		private var timer:Timer = new Timer(1000,1);				var current:Number = 0;		private var pressed:Array = [false,false,false,false,false,false,false,false,false];				public function PlayTheLight()		{				//Init Sion			sionDriver = new SiONDriver();//Sion Driver erstellen			sionDriver.play(null, false);						arduino = new Arduino("127.0.0.1",5331);			arduino.addEventListener(Event.CONNECT,onSocketConnect);			arduino.addEventListener(Event.CLOSE,onSocketClose);			arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, onReceiveFirmwareVersion);			arduino.addEventListener(ArduinoEvent.DIGITAL_DATA, onReceiveDigitalData);			arduino.addEventListener(ArduinoEvent.ANALOG_DATA, onReceiveAnalogData);			arduino.addEventListener(ArduinoSysExEvent.SYSEX_MESSAGE, onReceiveSysExMessage);		}/*			ARDUINO*/		public function onReceiveFirmwareVersion(e:ArduinoEvent):void		{			trace("Firmware version: " + e.value);			if (int(e.value) != 2)			{				trace("Unexpected Firmware version encountered! This Version of as3glue was written for Firmata2.");			}			trace("Port: " + e.port);						this.initArduino();		}		public function initArduino():void		{			stage.displayState=StageDisplayState.FULL_SCREEN;			stage.scaleMode=StageScaleMode.NO_SCALE;			Mouse.cursor=MouseCursor.AUTO; 			Mouse.hide(); 						trace("Initializing Arduino");			arduino.enableDigitalPinReporting();			for (var i=12; i<=21; i++) { //Laser				arduino.setPinMode(i, Arduino.OUTPUT);			}						for (var i=4; i<=11; i++) { //Button				arduino.setPinMode(i,Arduino.INPUT);			}						for (var i=1; i<=10; i++) { //Lichtsensoren 8-9 = Drehregler				arduino.setAnalogPinReporting(i, Arduino.ON);			}						setInstruments(arduino.getAnalogData(8));			setMode(arduino.getAnalogData(9));						beat.addEventListener(TimerEvent.TIMER, beatSet);			beat.start();			getLightsensorData(0);			//calculateLightsensor();			for (var i=0; i<=7;i++) {				if (lData[i] == 0 || lData[i] > 1023) {					getLightsensorData(0);				}				lichtsensoren[i] = lData[i]-50;				//lichtsensoren[7] += 30;			}			trace(lichtsensoren);			//setLaser("on");			initComplete = true;			trace("Init complete");		}		public function onSocketConnect(e:Object):void		{			trace("Socket connected!");			arduino.requestFirmwareVersion();		}		public function onSocketClose(e:Object):void		{			trace("Socket closed!");		}		public function onReceiveSysExMessage(e:ArduinoSysExEvent)		{			trace((numEvents++) +"Received SysExMessage. Command:"+e.data[0]);		}						//Laser ein/aus		public function setLaser(option:String):void {			for (var i=12; i<=21; i++) {				if (option == "off")					arduino.writeDigitalPin(i, 0);				else if(option == "on")					arduino.writeDigitalPin(i, 1);			}		}				//Speichert 10 Werte in lData		public function getLightsensorData(val:int):void {			if (val == 1) return;			for (var i=1; i<=7; i++) {				lData[i] = arduino.getAnalogData(i);				trace("analoData "+i+" "+arduino.getAnalogData(i));			}			lData[0] = arduino.getAnalogData(10);			trace("analoData "+0+" "+arduino.getAnalogData(10));			getLightsensorData(++val);		}				public function calculateLightsensor() {			/*			getLightsensorData(0);			trace("on");			setLaser("off");			timer.addEventListener(TimerEvent.TIMER_COMPLETE, laserOff);			//timer.start();						function laserOff() {				trace("off");				getLightsensorData(0);				for (var i=0; i<=7; i++) {					lData[i] = lData[i]/2;				}			}			trace(lData); 			*/		}				//Ton abspielen		function keyOn(index:int):void {			if (pressed[index] == false) {				switch (index) {					case 0: on1.visible = true; break;					case 1: on2.visible = true; break;					case 2: on3.visible = true; break;					case 3: on4.visible = true; break;					case 4: on5.visible = true; break;					case 5: on6.visible = true; break;					case 6: on7.visible = true; break;					case 7: on8.visible = true; break;				}								pressed[index] = true;				if (index == 0 && gameMode == "dj")					sionDriver.noteOn(bass.getTone()+index, sionSound[bass.getSound()],1);				else if (index == 1 && gameMode == "dj")					sionDriver.noteOn(snare.getTone()+index, sionSound[snare.getSound()],1);				else if (index == 2 && gameMode == "dj")					sionDriver.noteOn(hihat.getTone()+index, sionSound[hihat.getSound()],1);				else					sionDriver.noteOn(instr[current].getTone()+index, sionSound[instr[current].getSound()],2);			}		}				//Ton stoppen		function keyOff(index:int):void {			if (pressed[index] == false) return;			pressed[index] = false;			switch (index) {					case 0: on1.visible = false; break;					case 1: on2.visible = false; break;					case 2: on3.visible = false; break;					case 3: on4.visible = false; break;					case 4: on5.visible = false; break;					case 5: on6.visible = false; break;					case 6: on7.visible = false; break;					case 7: on8.visible = false; break;				}			}				//get Instrument		public function getCurrentInstrument():String {			return instr[current].getName();		}		public function getMode():String {			return gameMode;		}/*			Sensoren*/		public function setMode(v:int):void {			var old:String = gameMode;			if (v < 570) gameMode = "normal";			else gameMode = "dj";						if (old != gameMode) {				modeLoader.load(new URLRequest("./images/"+getMode()+".png")); 				modeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoading(960,40,modeLoader)); 				trace("game mode changed to: "+gameMode);			}		}				public function setInstruments(v:int):void {			var instrument:String = getCurrentInstrument();			if (v>0 && v<341 && instrument != "Piano") current = 0; //piano			else if (v>342 && v<682 && instrument != "Guitar") current = 2; //guitar			else if (v>682 && v<1023 && instrument != "Trumpet") current = 1; //trumpet						if (instrument != getCurrentInstrument() || !initComplete) {				instrumentLoader.load(new URLRequest(instr[current].getImage())); 				instrumentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoading(40,40,instrumentLoader)); 				trace("instrument changed to: "+getCurrentInstrument());			}		}		public function onReceiveDigitalData(e:ArduinoEvent):void {				if (initComplete) {				var i = e.pin%8				if (i <= 7 && initComplete && e.value == 0)				{					trace(i + " "+" "+ antiFlackerTimer.running.toString());					if (!antiFlackerTimer.running) {						antiFlackerTimer.start();						offsets[i] = globalOffset;						instr[current].setIsOn(i);									}				}			}		}				public function onReceiveAnalogData(e:ArduinoEvent):void {						if (initComplete){								if (e.pin == 8) setInstruments(e.value) //Drehregler 1				else if (e.pin == 9) setMode(e.value) // Drehregler 2				//laser unterbrochen -> Ton abspielen				else if (e.pin == 10 && e.value < lichtsensoren[0]) keyOn(0);				else if (e.pin == 1 && e.value < lichtsensoren[1]) keyOn(1);				else if (e.pin == 2 && e.value < lichtsensoren[2]) keyOn(2);				else if (e.pin == 3 && e.value < lichtsensoren[3]) keyOn(3);				else if (e.pin == 4 && e.value < lichtsensoren[4]) keyOn(4);				else if (e.pin == 5 && e.value < lichtsensoren[5]) keyOn(5);				else if (e.pin == 6 && e.value < lichtsensoren[6]) keyOn(6);				else if (e.pin == 7 && e.value < lichtsensoren[7]) keyOn(7);				//laser nicht unterbrochen				else if (e.pin == 10 && e.value > lichtsensoren[0]) keyOff(0);				else if (e.pin == 1 && e.value > lichtsensoren[1]) keyOff(1);				else if (e.pin == 2 && e.value > lichtsensoren[2]) keyOff(2);				else if (e.pin == 3 && e.value > lichtsensoren[3]) keyOff(3);				else if (e.pin == 4 && e.value > lichtsensoren[4]) keyOff(4);				else if (e.pin == 5 && e.value > lichtsensoren[5]) keyOff(5);				else if (e.pin == 6 && e.value > lichtsensoren[6]) keyOff(6);				else if (e.pin == 7 && e.value > lichtsensoren[7]) keyOff(7);			}		}				public function beatSet(e:TimerEvent):void {			for (var i:int=0; i<=7; i++){				if (instr[current].getIsOn(i) && offsets[i]==globalOffset){					//sionDriver.noteOn(420+i, sionSound[instr[current].getSound()],2)					keyOn(i);				}			}			globalOffset=(globalOffset+1)%3;		}				public function imageLoading(x:int, y:int, loader:Loader, height:int=200 ,width:int=300):Function{			return function imageLoaded(e:Event):void {				loader.x = x; 				loader.y = y;  				loader.width = width; //instrumentLoader.width / imageScale; 				loader.height = height; //instrumentLoader.width / imageScale;				stage.addChild(loader);//				if (stage.contains(initImage)) {//					//initImage.visible = false;//					removeChild(getChildByName("initImage"));//				}			}		}	}}