﻿package at{	import flash.media.Sound;	import flash.net.URLRequest;		public class Tone	{		var sound:Sound = new Sound();		var drums:Boolean;		public function Tone(path:String,drums:Boolean)		{			this.drums = drums;			sound.load(new URLRequest(path));		}		public function play()		{			sound.play();		}		public function getSound():Sound		{			return sound;		}		public function isDrum():Boolean{			return drums;		}	}}