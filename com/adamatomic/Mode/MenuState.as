package com.adamatomic.Mode
{
	import flash.net.SharedObject;
	
	import org.flixel.*;

	public class MenuState extends FlxState
	{
		[Embed(source="../../../data/spawner_gibs.png")] public var ImgGibs:Class;
		[Embed(source="../../../data/cursor.png")] public var ImgCursor:Class;
		[Embed(source="../../../data/menu_hit.mp3")] public var SndHit:Class;
		[Embed(source="../../../data/menu_hit_2.mp3")] public var SndHit2:Class;
		
		[Embed(source="../../../data/attract1.fgr",mimeType="application/octet-stream")] public var Attract1:Class;
		[Embed(source="../../../data/attract2.fgr",mimeType="application/octet-stream")] public var Attract2:Class;
		
		public var gibs:FlxEmitter;
		public var button1:FlxButton;
		public var title1:FlxText;
		public var title2:FlxText;
		public var ok:Boolean;
		public var ok2:Boolean;
		public var timer:Number;
		public var attractMode:Boolean;
		
		override public function create():void
		{
			FlxG.framerate = 40;
			FlxG.flashFramerate = 40;
			//FlxG.setDebuggerLayout(FlxG.DEBUGGER_MICRO);
			//FlxG.log(FlxG.globalSeed);
			
			var i:uint;
			var s:FlxSprite;
			
			gibs = new FlxEmitter(FlxG.width/2-50,FlxG.height/2-10);
			gibs.setSize(100,30);
			gibs.setYSpeed(-200,-20);
			gibs.setRotation(-720,720);
			gibs.gravity = 100;
			gibs.createSprites(ImgGibs,1000,32);
			add(gibs);
				
			title1 = new FlxText(FlxG.width,FlxG.height/3,80,"mo");
			title1.size = 32;
			title1.color = 0x3a5c39;
			title1.antialiasing = true;
			add(title1);

			title2 = new FlxText(-60,title1.y,title1.width,"de");
			title2.size = title1.size;
			title2.color = title1.color;
			title2.antialiasing = title1.antialiasing;
			add(title2);
			
			ok = false;
			ok2 = false;
			
			FlxG.mouse.show(ImgCursor);
			
			//Simple use of flixel save game object.
			//Tracks number of times the game has been played.
			var save:FlxSave = new FlxSave();
			if(save.bind("Mode"))
			{
				if(save.data.plays == null)
					save.data.plays = 0 as Number;
				else
					save.data.plays++;
				FlxG.log("Number of plays: "+save.data.plays);
				//save.erase();
				save.close();
			}
			
			timer = 0;
			attractMode = false;
		}

		override public function update():void
		{
			//Slides the text ontot he screen
			var t1m:uint = FlxG.width/2-54;
			if(title1.x > t1m)
			{
				title1.x -= FlxG.elapsed*FlxG.width;
				if(title1.x < t1m) title1.x = t1m;
			}
			var t2m:uint = FlxG.width/2+6;
			if(title2.x < t2m)
			{
				title2.x += FlxG.elapsed*FlxG.width;
				if(title2.x > t2m) title2.x = t2m;
			}
			
			//Check to see if the text is in position
			if(!ok && ((title1.x == t1m) || (title2.x == t2m)))
			{
				//explosion
				ok = true;
				FlxG.play(SndHit);
				FlxG.flash.start(0xffd8eba2,0.5);
				FlxG.quake.start(0.035,0.5);
				title1.color = 0xd8eba2;
				title2.color = 0xd8eba2;
				gibs.start(true,5);
				title1.angle = FlxG.random()*40-20;
				title2.angle = FlxG.random()*40-20;
				
				var text1:FlxText;
				var text2:FlxText;
				var button2:FlxButton;
				
				text1 = new FlxText(t1m,FlxG.height/3+39,110,"by Adam Atomic")
				text1.alignment = "center";
				text1.color = 0x3a5c39;
				add(text1);
				
				//flixel button
				this.add((new FlxSprite(t1m+1,FlxG.height/3+53)).createGraphic(106,19,0xff131c1b));
				button2 = new FlxButton(t1m+2,FlxG.height/3+54,onFlixel);
				button2.loadGraphic((new FlxSprite()).createGraphic(104,15,0xff3a5c39),(new FlxSprite()).createGraphic(104,15,0xff729954));
				text1 = new FlxText(15,1,100,"www.flixel.org");
				text1.color = 0x729954;
				text2 = new FlxText(text1.x,text1.y,text1.width,text1.text);
				text2.color = 0xd8eba2;
				button2.loadText(text1,text2);
				add(button2);
				
				//danny B button
				this.add((new FlxSprite(t1m+1,FlxG.height/3+75)).createGraphic(106,19,0xff131c1b));
				button2 = new FlxButton(t1m+2,FlxG.height/3+76,onDanny);
				button2.loadGraphic((new FlxSprite()).createGraphic(104,15,0xff3a5c39),(new FlxSprite()).createGraphic(104,15,0xff729954));
				text1 = new FlxText(8,1,100,"music by danny B");
				text1.color = 0x729954;
				text2 = new FlxText(text1.x,text1.y,text1.width,text1.text);
				text2.color = 0xd8eba2;
				button2.loadText(text1,text2);
				add(button2);
				
				//play button
				this.add((new FlxSprite(t1m+1,FlxG.height/3+137)).createGraphic(106,19,0xff131c1b));
				text1 = new FlxText(t1m,FlxG.height/3+139,110,"PRESS X+C TO PLAY.");
				text1.color = 0x729954;
				text1.alignment = "center";
				add(text1);
				button1 = new FlxButton(t1m+2,FlxG.height/3+138,onButton);
				button1.loadGraphic((new FlxSprite()).createGraphic(104,15,0xff3a5c39),(new FlxSprite()).createGraphic(104,15,0xff729954));
				text1 = new FlxText(25,1,100,"CLICK HERE");
				text1.color = 0x729954;
				text2 = new FlxText(text1.x,text1.y,text1.width,text1.text);
				text2.color = 0xd8eba2;
				button1.loadText(text1,text2);
				add(button1);
			}

			//X + C were pressed, fade out and change to play state.
			//Alternatively, if we sat on the menu too long, launch the attract mode instead!
			timer += FlxG.elapsed;
			if(timer >= 10) //go into demo mode if no buttons are pressed for 10 seconds
				attractMode = true;
			if(!ok2 && ((ok && !ok2 && FlxG.keys.X && FlxG.keys.C) || attractMode)) 
			{
				ok2 = true;
				FlxG.play(SndHit2);
				FlxG.flash.start(0xffd8eba2,0.5);
				FlxG.fade.start(0xff131c1b,1,onFade);
			}

			super.update();
		}
		
		public function onFlixel():void
		{
			FlxU.openURL("http://flixel.org");
		}
		
		public function onDanny():void
		{
			FlxU.openURL("http://dbsoundworks.com");
		}
		
		public function onButton():void
		{
			button1.visible = false;
			button1.active = false;
			FlxG.play(SndHit2);
		}
		
		public function onFade():void
		{
			if(attractMode)
				FlxG.loadReplay((FlxG.random()<0.5)?(new Attract1()):(new Attract2()),new PlayState(),["X","C"],10,onDemoComplete);
			else
				FlxG.state = new PlayState();
			//FlxG.state = new PlayStateTiles();
		}
		
		public function onDemoComplete():void
		{
			FlxG.fade.start(0xff131c1b,1,FlxG.resetGame);
		}
	}
}
