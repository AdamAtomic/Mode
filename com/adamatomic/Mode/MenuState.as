package com.adamatomic.Mode
{
	import org.flixel.*;

	public class MenuState extends FlxState
	{
		[Embed(source="../../../data/cursor.png")] private var ImgCursor:Class;
		[Embed(source="../../../data/menu_hit.mp3")] private var SndHit:Class;
		[Embed(source="../../../data/menu_hit_2.mp3")] private var SndHit2:Class;
		
		private var _e:FlxEmitter;
		private var _b:FlxButton;
		private var _t1:FlxText;
		private var _t2:FlxText;
		private var _ok:Boolean;
		private var _ok2:Boolean;
		
		override public function MenuState():void
		{
			var i:uint;
			var s:FlxSprite;
			var a:Array = new Array();
			for(i = 0; i < 2000; i++)
			{
				s = new FlxSprite();
				if(i%3)
					s.createGraphic(16,16,0xff3a5c39);
				else
					s.createGraphic(2,2,0xffd8eba2);
				a.push(add(s));
			}
			_e = new FlxEmitter(FlxG.width/2-50,FlxG.height/2-10,-5);
			_e.setSize(100,30);
			_e.setYVelocity(-800,-100);
			_e.setRotation();
			_e.loadSprites(a);
			add(_e);
				
			_t1 = new FlxText(FlxG.width,FlxG.height/3,80,"mo");
			_t1.size = 32;
			_t1.color = 0x3a5c39;
			_t1.antialiasing = true;
			add(_t1);

			_t2 = new FlxText(-60,FlxG.height/3,80,"de");
			_t2.size = _t1.size;
			_t2.color = _t1.color;
			_t2.antialiasing = _t1.antialiasing;
			add(_t2);
			
			_ok = false;
			_ok2 = false;
			
			FlxG.showCursor(ImgCursor);
			
			//Simple use of flixel save games
			var save:FlxSave = new FlxSave("Mode");
			if(save.data.plays == null)
				save.data.plays = 0;
			else
				save.data.plays++;
			FlxG.log("Number of plays: "+save.data.plays);
		}

		override public function update():void
		{
			//Slides the text ontot he screen
			var t1m:uint = FlxG.width/2-54;
			if(_t1.x > t1m)
			{
				_t1.x -= FlxG.elapsed*FlxG.width;
				if(_t1.x < t1m) _t1.x = t1m;
			}
			var t2m:uint = FlxG.width/2+6;
			if(_t2.x < t2m)
			{
				_t2.x += FlxG.elapsed*FlxG.width;
				if(_t2.x > t2m) _t2.x = t2m;
			}
			
			//Check to see if the text is in position
			if(!_ok && ((_t1.x == t1m) || (_t2.x == t2m)))
			{
				//explosion
				_ok = true;
				FlxG.play(SndHit);
				FlxG.flash(0xffd8eba2,0.5);
				FlxG.quake(0.035,0.5);
				_t1.color = 0xd8eba2;
				_t2.color = 0xd8eba2;
				_e.restart();
				_t1.angle = FlxG.random()*40-20;
				_t2.angle = FlxG.random()*40-20;
				
				var t1:FlxText;
				var t2:FlxText;
				var b:FlxButton;
				
				t1 = new FlxText(t1m,FlxG.height/3+39,110,"by Adam Atomic")
				t1.alignment = "center";
				t1.color = 0x3a5c39;
				add(t1);
				
				//flixel button
				this.add((new FlxSprite(t1m+1,FlxG.height/3+53)).createGraphic(106,19,0xff131c1b));
				b = new FlxButton(t1m+2,FlxG.height/3+54,onFlixel);
				b.loadGraphic((new FlxSprite()).createGraphic(104,15,0xff3a5c39),(new FlxSprite()).createGraphic(104,15,0xff729954));
				t1 = new FlxText(15,1,100,"www.flixel.org");
				t1.color = 0x729954;
				t2 = new FlxText(t1.x,t1.y,t1.width,t1.text);
				t2.color = 0xd8eba2;
				b.loadText(t1,t2);
				add(b);
				
				//danny B button
				this.add((new FlxSprite(t1m+1,FlxG.height/3+75)).createGraphic(106,19,0xff131c1b));
				b = new FlxButton(t1m+2,FlxG.height/3+76,onDanny);
				b.loadGraphic((new FlxSprite()).createGraphic(104,15,0xff3a5c39),(new FlxSprite()).createGraphic(104,15,0xff729954));
				t1 = new FlxText(8,1,100,"music by danny B");
				t1.color = 0x729954;
				t2 = new FlxText(t1.x,t1.y,t1.width,t1.text);
				t2.color = 0xd8eba2;
				b.loadText(t1,t2);
				add(b);
				
				//play button
				this.add((new FlxSprite(t1m+1,FlxG.height/3+137)).createGraphic(106,19,0xff131c1b));
				t1 = new FlxText(t1m,FlxG.height/3+139,110,"PRESS X+C TO PLAY.");
				t1.color = 0x729954;
				t1.alignment = "center";
				add(t1);
				_b = new FlxButton(t1m+2,FlxG.height/3+138,onButton);
				_b.loadGraphic((new FlxSprite()).createGraphic(104,15,0xff3a5c39),(new FlxSprite()).createGraphic(104,15,0xff729954));
				t1 = new FlxText(25,1,100,"CLICK HERE");
				t1.color = 0x729954;
				t2 = new FlxText(t1.x,t1.y,t1.width,t1.text);
				t2.color = 0xd8eba2;
				_b.loadText(t1,t2);
				add(_b);
			}
			
			//X + C were pressed, fade out and change to play state
			if(_ok && !_ok2 && FlxG.keys.X && FlxG.keys.C)
			{
				_ok2 = true;
				FlxG.play(SndHit2);
				FlxG.flash(0xffd8eba2,0.5);
				FlxG.fade(0xff131c1b,1,onFade);
			}

			super.update();
		}
		
		private function onFlixel():void
		{
			FlxG.openURL("http://flixel.org");
		}
		
		private function onDanny():void
		{
			FlxG.openURL("http://dbsoundworks.com");
		}
		
		private function onButton():void
		{
			_b.visible = false;
			_b.active = false;
			FlxG.play(SndHit2);
		}
		
		private function onFade():void
		{
			FlxG.switchState(PlayState);
			//FlxG.switchState(PlayStateTiles);
		}
	}
}
