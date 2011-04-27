package
{
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	
	import org.flixel.*;
	import org.flixel.plugin.DebugPathDisplay;

	public class MenuState extends FlxState
	{
		//Some graphics and sounds
		[Embed(source="data/bot.png")] protected var ImgEnemy:Class;
		[Embed(source="data/spawner_gibs.png")] public var ImgGibs:Class;
		[Embed(source="data/cursor.png")] public var ImgCursor:Class;
		[Embed(source="data/menu_hit.mp3")] public var SndHit:Class;
		[Embed(source="data/menu_hit_2.mp3")] public var SndHit2:Class;
		
		//Replay data for the "Attract Mode" gameplay demos
		[Embed(source="data/attract1.fgr",mimeType="application/octet-stream")] public var Attract1:Class;
		[Embed(source="data/attract2.fgr",mimeType="application/octet-stream")] public var Attract2:Class;
		
		public var gibs:FlxEmitter;
		public var playButton:FlxButton;
		public var title1:FlxText;
		public var title2:FlxText;
		public var fading:Boolean;
		public var timer:Number;
		public var attractMode:Boolean;
		
		public var pathFollower:FlxSprite;
		public var testPath:FlxPath;
		
		override public function create():void
		{
			FlxG.bgColor = 0xff131c1b;
			
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

			//All the bits that blow up when the text smooshes together
			gibs = new FlxEmitter(FlxG.width/2-50,FlxG.height/2-10);
			gibs.setSize(100,30);
			gibs.setYSpeed(-200,-20);
			gibs.setRotation(-720,720);
			gibs.gravity = 100;
			gibs.makeParticles(ImgGibs,650,32,true,0);
			add(gibs);

			//the letters "mo"
			title1 = new FlxText(FlxG.width + 16,FlxG.height/3,64,"mo");
			title1.size = 32;
			title1.color = 0x3a5c39;
			title1.antialiasing = true;
			title1.velocity.x = -FlxG.width;
			add(title1);

			//the letters "de"
			title2 = new FlxText(-60,title1.y,title1.width,"de");
			title2.size = title1.size;
			title2.color = title1.color;
			title2.antialiasing = title1.antialiasing;
			title2.velocity.x = FlxG.width;
			add(title2);
			
			fading = false;
			timer = 0;
			attractMode = false;
			
			/*silly path following test
			pathFollower = new FlxSprite(-20,-20,ImgEnemy);
			testPath = new FlxPath();
			add(pathFollower);//*/
			
			FlxG.mouse.show(ImgCursor,2);
		}
		
		override public function destroy():void
		{
			super.destroy();
			gibs = null;
			playButton = null;
			title1 = null;
			title2 = null;
			
			/*silly path following test
			testPath.destroy();//*/
		}

		override public function update():void
		{
			/*silly path following test code
			if(FlxG.mouse.justPressed() && FlxG.keys.SPACE)
			{
				timer = 0;
				testPath.addPoint(FlxG.mouse);
				if(pathFollower.path == null)
					pathFollower.followPath(testPath,100,FlxObject.PATH_LOOP_FORWARD,true);
			}//*/
			
			super.update();
			
			if(title2.x > title1.x + title1.width - 4)
			{
				//Once mo and de cross each other, fix their positions
				title2.x = title1.x + title1.width - 4;
				title1.velocity.x = 0;
				title2.velocity.x = 0;
				
				//Then, play a cool sound, change their color, and blow up pieces everywhere
				FlxG.play(SndHit);
				FlxG.flash(0xffd8eba2,0.5);
				FlxG.shake(0.035,0.5);
				title1.color = 0xd8eba2;
				title2.color = 0xd8eba2;
				gibs.start(true,5);
				title1.angle = FlxG.random()*30-15;
				title2.angle = FlxG.random()*30-15;
				
				//Then we're going to add the text and buttons and things that appear
				//If we were hip we'd use our own button animations, but we'll just recolor
				//the stock ones for now instead.
				var text:FlxText;
				text = new FlxText(FlxG.width/2-50,FlxG.height/3+39,100,"by Adam Atomic")
				text.alignment = "center";
				text.color = 0x3a5c39;
				add(text);
				
				var flixelButton:FlxButton = new FlxButton(FlxG.width/2-40,FlxG.height/3+54,"flixel.org",onFlixel);
				flixelButton.color = 0xff729954;
				flixelButton.label.color = 0xffd8eba2;
				add(flixelButton);
				
				var dannyButton:FlxButton = new FlxButton(flixelButton.x,flixelButton.y + 22,"music: dannyB",onDanny);
				dannyButton.color = flixelButton.color;
				dannyButton.label.color = flixelButton.label.color;
				add(dannyButton);
				
				text = new FlxText(FlxG.width/2-40,FlxG.height/3+139,80,"X+C TO PLAY");
				text.color = 0x729954;
				text.alignment = "center";
				add(text);
				
				playButton = new FlxButton(flixelButton.x,flixelButton.y + 82,"CLICK HERE",onPlay);
				playButton.color = flixelButton.color;
				playButton.label.color = flixelButton.label.color;
				add(playButton);
			}

			//X + C were pressed, fade out and change to play state.
			//OR, if we sat on the menu too long, launch the attract mode instead!
			timer += FlxG.elapsed;
			if(timer >= 10) //go into demo mode if no buttons are pressed for 10 seconds
				attractMode = true;
			if(!fading && ((FlxG.keys.X && FlxG.keys.C) || attractMode)) 
			{
				fading = true;
				FlxG.play(SndHit2);
				FlxG.flash(0xffd8eba2,0.5);
				FlxG.fade(0xff131c1b,1,onFade);
			}
		}
		
		//These are all "event handlers", or "callbacks".
		//These first three are just called when the
		//corresponding buttons are pressed with the mouse.
		protected function onFlixel():void
		{
			FlxU.openURL("http://flixel.org");
		}
		
		protected function onDanny():void
		{
			FlxU.openURL("http://dbsoundworks.com");
		}
		
		protected function onPlay():void
		{
			playButton.exists = false;
			FlxG.play(SndHit2);
		}
		
		//This function is passed to FlxG.fade() when we are ready to go to the next game state.
		//When FlxG.fade() finishes, it will call this, which in turn will either load
		//up a game demo/replay, or let the player start playing, depending on user input.
		protected function onFade():void
		{
			if(attractMode)
				FlxG.loadReplay((FlxG.random()<0.5)?(new Attract1()):(new Attract2()),new PlayState(),["ANY"],22,onDemoComplete);
			else
				FlxG.switchState(new PlayState());
		}
		
		//This function is called by FlxG.loadReplay() when the replay finishes.
		//Here, we initiate another fade effect.
		protected function onDemoComplete():void
		{
			FlxG.fade(0xff131c1b,1,onDemoFaded);
		}
		
		//Finally, we have another function called by FlxG.fade(), this time
		//in relation to the callback above.  It stops the replay, and resets the game
		//once the gameplay demo has faded out.
		protected function onDemoFaded():void
		{
			FlxG.stopReplay();
			FlxG.resetGame();
		}
	}
}
