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
				if(i%3)
					s = new FlxSprite(null,0,0,false,false,16,16,0xff3a5c39);
				else
					s = new FlxSprite(null,0,0,false,false,2,2,0xffd8eba2);
				a.push(this.add(s));
			}
			_e = new FlxEmitter(FlxG.width/2-50,FlxG.height/2-10,100,30,a,-5,-100,100,-800,-100,0,0,400);
			_e.kill();
			this.add(_e);
				
			_t1 = this.add(new FlxText(FlxG.width,FlxG.height/3,80,"mo",0x3a5c39,null,32)) as FlxText;
			_t1.antialiasing = true;
			_t2 = this.add(new FlxText(-60,FlxG.height/3,80,"de",0x3a5c39,null,32)) as FlxText;
			_t2.antialiasing = true;
			
			_ok = false;
			_ok2 = false;
			
			FlxG.showCursor(ImgCursor);
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
				
				this.add(new FlxText(t1m,FlxG.height/3+39,110,"by Adam Atomic",0x3a5c39,null,8,"center"));
				
				//flixel button
				this.add(new FlxSprite(null,t1m+1,FlxG.height/3+53,false,false,106,19,0xff131c1b));
				this.add(new FlxButton(t1m+2,FlxG.height/3+54,new FlxSprite(null,0,0,false,false,104,15,0xff3a5c39),onFlixel,new FlxSprite(null,0,0,false,false,104,15,0xff729954),new FlxText(15,1,100,"www.flixel.org",0x729954),new FlxText(15,1,100,"www.flixel.org",0xd8eba2)));
				
				//danny B button
				this.add(new FlxSprite(null,t1m+1,FlxG.height/3+75,false,false,106,19,0xff131c1b));
				this.add(new FlxButton(t1m+2,FlxG.height/3+76,new FlxSprite(null,0,0,false,false,104,15,0xff3a5c39),onDanny,new FlxSprite(null,0,0,false,false,104,15,0xff729954),new FlxText(8,1,100,"music by danny B",0x729954),new FlxText(8,1,100,"music by danny B",0xd8eba2)));
				
				//play button
				this.add(new FlxSprite(null,t1m+1,FlxG.height/3+137,false,false,106,19,0xff131c1b));
				this.add(new FlxText(t1m,FlxG.height/3+139,110,"PRESS X+C TO PLAY.",0x729954,null,8,"center"));
				_b = this.add(new FlxButton(t1m+2,FlxG.height/3+138,new FlxSprite(null,0,0,false,false,104,15,0xff3a5c39),onButton,new FlxSprite(null,0,0,false,false,104,15,0xff729954),new FlxText(25,1,100,"CLICK HERE",0x729954),new FlxText(25,1,100,"CLICK HERE",0xd8eba2))) as FlxButton;
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
