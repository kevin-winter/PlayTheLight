﻿package at{	import flash.net.URLRequest;	import flash.media.Sound;	import at.Tone;	import org.si.sion.utils.SiONPresetVoice;//Instrumente	//import org.si.sion.SiONDriver; //Driver		public class Instrument	{		private var instrumentName:String = "";		private var sionSound:SiONPresetVoice = new SiONPresetVoice();		private var drums:Boolean;		private var sound:String;		private var image:String;		private var isOn:Array = [false,false,false,false,false,false,false,false];		private var tone:int;		public function Instrument(n:String, sound:String, tone:int, image:String = "")		{			this.image = image			this.sound = sound;			this.instrumentName = n;			this.drums = drums;			this.tone = tone;		}				public function getTone():int {			return this.tone;		}				public function getImage():String{			return this.image;		}				public function getIsOn(val:int):Boolean {			return isOn[val];		}				public function setOn(i:int, bool:Boolean){			isOn[i]=bool;		}				public function setIsOn(i:int):Boolean {			if (getIsOn(i) == true) {				isOn[i] = false;				return false;			} else {				isOn[i] = true;				return true;			}		}		public function getSound():String {			return this.sound;		}		public function getName():String		{			return this.instrumentName;		}		public function isDrum(index:Number):Boolean		{			return this.drums;		}	}}