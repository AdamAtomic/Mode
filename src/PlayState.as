package
{
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		[Embed(source="data/tech_tiles.png")] protected var ImgTech:Class;
		[Embed(source="data/dirt_top.png")] protected var ImgDirtTop:Class;
		[Embed(source="data/dirt.png")] protected var ImgDirt:Class;
		[Embed(source="data/notch.png")] protected var ImgNotch:Class;
		[Embed(source="data/mode.mp3")] protected var SndMode:Class;
		[Embed(source="data/countdown.mp3")] protected var SndCount:Class;
		[Embed(source="data/gibs.png")] private var ImgGibs:Class;
		[Embed(source="data/spawner_gibs.png")] private var ImgSpawnerGibs:Class;
		
		//major game object storage
		protected var _blocks:FlxGroup;
		protected var _decorations:FlxGroup;
		protected var _bullets:FlxGroup;
		protected var _player:Player;
		protected var _enemies:FlxGroup;
		protected var _spawners:FlxGroup;
		protected var _enemyBullets:FlxGroup;
		protected var _littleGibs:FlxEmitter;
		protected var _bigGibs:FlxEmitter;
		protected var _hud:FlxGroup;
		
		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		protected var _hazards:FlxGroup;
		
		//HUD/User Interface stuff
		protected var _score:FlxText;
		protected var _score2:FlxText;
		protected var _scoreTimer:Number;
		protected var _jamTimer:Number;
		protected var _jamBar:FlxSprite;
		protected var _jamText:FlxText;
		protected var _notches:Array;
		
		//just to prevent weirdness during level transition
		protected var _fading:Boolean;
		
		override public function create():void
		{			
			FlxG.mouse.hide();
			
			//Here we are creating a pool of 100 little metal bits that can be exploded.
			//We will recycle the crap out of these!
			_littleGibs = new FlxEmitter();
			_littleGibs.setXSpeed(-150,150);
			_littleGibs.setYSpeed(-200,0);
			_littleGibs.setRotation(-720,-720);
			_littleGibs.makeParticles(ImgGibs,100,10,true,0.5,0.5);
			
			//Next we create a smaller pool of larger metal bits for exploding.
			_bigGibs = new FlxEmitter();
			_bigGibs.setXSpeed(-200,200);
			_bigGibs.setYSpeed(-300,0);
			_bigGibs.setRotation(-720,-720);
			_bigGibs.makeParticles(ImgSpawnerGibs,50,20,true);
			
			//Then we'll set up the rest of our object groups or pools
			_blocks = new FlxGroup();
			_decorations = new FlxGroup();
			_enemies = new FlxGroup();
			_spawners = new FlxGroup();
			_hud = new FlxGroup();
			_enemyBullets = new FlxGroup();
			_bullets = new FlxGroup();
			
			//Now that we have references to the bullets and metal bits,
			//we can create the player object.
			_player = new Player(316,300,_bullets,_littleGibs);

			//This refers to a custom function down at the bottom of the file
			//that creates all our level geometry.
			generateLevel();
			
			//Add bots and spawners after we add blocks to the state,
			// so that they're drawn on top of the level, and so that
			// the bots are drawn on top of both the blocks + the spawners.
			add(_spawners);
			add(_littleGibs);
			add(_bigGibs);
			add(_blocks);
			add(_decorations);
			add(_enemies);

			//Then we add the player and set up the scrolling camera
			add(_player);
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(0,0,640,640);
			
			//We add the bullets to the scene here,
			//so they're drawn on top of pretty much everything
			add(_enemyBullets);
			add(_bullets);
			add(_hud);
			
			//Finally we are going to sort things into a couple of helper groups.
			//We don't add these groups to the state, we just use them for collisions later!
			_hazards = new FlxGroup();
			_hazards.add(_enemyBullets);
			_hazards.add(_spawners);
			_hazards.add(_enemies);
			_objects = new FlxGroup();
			_objects.add(_enemyBullets);
			_objects.add(_bullets);
			_objects.add(_enemies);
			_objects.add(_player);
			_objects.add(_littleGibs);
			_objects.add(_bigGibs);
			
			//From here on out we are making objects for the HUD,
			//that is, the player score, number of spawners left, etc.
			//First, we'll create a text field for the current score
			_score = new FlxText(0,0,FlxG.width);
			_score.setFormat(null,16,0xd8eba2,"center",0x131c1b);
			_hud.add(_score);
			if(FlxG.scores.length < 2)
			{
				FlxG.scores.push(0);
				FlxG.scores.push(0);
			}
			
			//Then for the player's highest and last scores
			_score2 = new FlxText(FlxG.width/2,0,FlxG.width/2);
			_score2.setFormat(null,8,0xd8eba2,"right",_score.shadow);
			_hud.add(_score2);
			if(FlxG.score > FlxG.scores[0])
				FlxG.scores[0] = FlxG.score;
			if(FlxG.scores[0] != 0)
				_score2.text = "HIGHEST: "+FlxG.scores[0]+"\nLAST: "+FlxG.score;
			FlxG.score = 0;
			_scoreTimer = 0;
			
			//Create an Array of sprites with 1 icon for each spawner, like a checklist.
			_notches = new Array();
			var tmp:FlxSprite;
			for(var i:uint = 0; i < 6; i++)
			{
				tmp = new FlxSprite(4+i*10,4);
				tmp.loadGraphic(ImgNotch,true);
				tmp.addAnimation("on",[0]);
				tmp.addAnimation("off",[1]);
				tmp.moves = false;
				tmp.solid = false;
				tmp.play("on");
				_notches.push(tmp);
				_hud.add(tmp);
			}
			
			//Then we create the "gun jammed" notification
			_jamBar = new FlxSprite(0,FlxG.height-22).makeGraphic(FlxG.width,24,0xff131c1b);
			_jamBar.visible = false;
			_hud.add(_jamBar);
			_jamText = new FlxText(0,FlxG.height-22,FlxG.width,"GUN IS JAMMED");
			_jamText.setFormat(null,16,0xd8eba2,"center");
			_jamText.visible = false;
			_hud.add(_jamText);
			
			//After we add all the objects to the HUD, we can go through
			//and set any property we want on all the objects we added
			//with this sweet function.  In this case, we want to set
			//the scroll factors to zero, to make sure the HUD doesn't
			//wiggle around while we play.
			_hud.setAll("scrollFactor",new FlxPoint(0,0));
			
			FlxG.playMusic(SndMode);
			FlxG.flash.start(0xff131c1b);
			_fading = false;
			
			FlxG.watch(_enemies,"length","enemies used");
			FlxG.watch(_enemies.members,"length","enemies capacity");
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			_blocks = null;
			_decorations = null;
			_bullets = null;
			_player = null;
			_enemies = null;
			_spawners = null;
			_enemyBullets = null;
			_littleGibs = null;
			_bigGibs = null;
			_hud = null;
			
			//meta groups, to help speed up collisions
			_objects = null;
			_hazards = null;
			
			//HUD/User Interface stuff
			_score = null;
			_score2 = null;
			_jamBar = null;
			_jamText = null;
			_notches = null;
		}

		override public function update():void
		{
			var os:uint = FlxG.score;
			
			super.update();
			
			//collisions with environment
			FlxU.collide(_blocks,_objects);
			FlxU.overlap(_hazards,_player,overlapped);
			FlxU.overlap(_bullets,_hazards,overlapped);
			
			//Jammed message
			if(FlxG.keys.justPressed("C") && _player.flickering)
			{
				_jamTimer = 1;
				_jamBar.visible = true;
				_jamText.visible = true;
			}
			if(_jamTimer > 0)
			{
				if(!_player.flickering) _jamTimer = 0;
				_jamTimer -= FlxG.elapsed;
				if(_jamTimer < 0)
				{
					_jamBar.visible = false;
					_jamText.visible = false;
				}
			}

			if(!_fading)
			{
				//Score + countdown stuffs
				if(os != FlxG.score) _scoreTimer = 2;
				_scoreTimer -= FlxG.elapsed;
				if(_scoreTimer < 0)
				{
					if(FlxG.score > 0)
					{
						FlxG.play(SndCount);
						if(FlxG.score > 100) FlxG.score -= 100;
						else { FlxG.score = 0; _player.kill(); }
						_scoreTimer = 1;
						if(FlxG.score < 600)
							FlxG.play(SndCount);
						if(FlxG.score < 500)
							FlxG.play(SndCount);
						if(FlxG.score < 400)
							FlxG.play(SndCount);
						if(FlxG.score < 300)
							FlxG.play(SndCount);
						if(FlxG.score < 200)
							FlxG.play(SndCount);
					}
				}
			
				//Fade out to victory screen stuffs
				var spawnerCount:int = _spawners.countLiving();
				if(spawnerCount <= 0)
				{
					_fading = true;
					FlxG.fade.start(0xffd8eba2,3,onVictory);
				}
				else
				{
					for(var i:uint = 0; i < _notches.length; i++)
					{
						if(i < spawnerCount)
							_notches[i].play("on");
						else
							_notches[i].play("off");
					}
				}
			}
			
			//actually update score text if it changed
			if(os != FlxG.score)
			{
				if(!_player.alive) FlxG.score = 0;
				_score.text = FlxG.score.toString();
			}
		}

		//This is an overlap callback function, triggered by the calls to FlxU.overlap().
		protected function overlapped(Sprite1:FlxSprite,Sprite2:FlxSprite):void
		{
			if((Sprite1 is EnemyBullet) || (Sprite1 is Bullet))
				Sprite1.kill();
			Sprite2.hurt(1);
		}
		
		//A FlxG.fade callback, like in MenuState.
		protected function onVictory():void
		{
			FlxG.music.stop();
			FlxG.switchState(new VictoryState());
		}
		
		//These next two functions look crazy, but all they're doing is generating
		//the level structure and placing the enemy spawners.
		protected function generateLevel():void
		{
			var r:uint = 160;
			var b:FlxTileblock;
		
			//First, we create the walls, ceiling and floors:
			b = new FlxTileblock(0,0,640,16);
			b.loadTiles(ImgTech);
			_blocks.add(b);
			
			b = new FlxTileblock(0,16,16,640-16);
			b.loadTiles(ImgTech);
			_blocks.add(b);
			
			b = new FlxTileblock(640-16,16,16,640-16);
			b.loadTiles(ImgTech);
			_blocks.add(b);
			
			b = new FlxTileblock(16,640-24,640-32,8);
			b.loadTiles(ImgDirtTop);
			_blocks.add(b);
			
			b = new FlxTileblock(16,640-16,640-32,16);
			b.loadTiles(ImgDirt);
			_blocks.add(b);
			
			//Then we split the game world up into a 4x4 grid,
			//and generate some blocks in each area.  Some grid spaces
			//also get a spawner!
			buildRoom(r*0,r*0,true);
			buildRoom(r*1,r*0);
			buildRoom(r*2,r*0);
			buildRoom(r*3,r*0,true);
			buildRoom(r*0,r*1,true);
			buildRoom(r*1,r*1);
			buildRoom(r*2,r*1);
			buildRoom(r*3,r*1,true);
			buildRoom(r*0,r*2);
			buildRoom(r*1,r*2);
			buildRoom(r*2,r*2);
			buildRoom(r*3,r*2);
			buildRoom(r*0,r*3,true);
			buildRoom(r*1,r*3);
			buildRoom(r*2,r*3);
			buildRoom(r*3,r*3,true);
		}
		
		//Just plops down a spawner and some blocks - haphazard and crappy atm but functional!
		protected function buildRoom(RX:uint,RY:uint,Spawners:Boolean=false):void
		{
			//first place the spawn point (if necessary)
			var rw:uint = 20;
			var sx:uint;
			var sy:uint;
			if(Spawners)
			{
				sx = 2+FlxG.random()*(rw-7);
				sy = 2+FlxG.random()*(rw-7);
			}
			
			//then place a bunch of blocks
			var numBlocks:uint = 3+FlxG.random()*4;
			if(!Spawners) numBlocks++;
			var maxW:uint = 10;
			var minW:uint = 2;
			var maxH:uint = 8;
			var minH:uint = 1;
			var bx:uint;
			var by:uint;
			var bw:uint;
			var bh:uint;
			var check:Boolean;
			for(var i:uint = 0; i < numBlocks; i++)
			{
				do
				{
					//keep generating different specs if they overlap the spawner
					bw = minW + FlxG.random()*(maxW-minW);
					bh = minH + FlxG.random()*(maxH-minH);
					bx = -1 + FlxG.random()*(rw+1-bw);
					by = -1 + FlxG.random()*(rw+1-bh);
					if(Spawners)
						check = ((sx>bx+bw) || (sx+3<bx) || (sy>by+bh) || (sy+3<by));
					else
						check = true;
				} while(!check);
				
				var b:FlxTileblock;
				b = new FlxTileblock(RX+bx*8,RY+by*8,bw*8,bh*8);
				b.loadTiles(ImgTech);
				_blocks.add(b);
				
				//If the block has room, add some non-colliding "dirt" graphics for variety
				if((bw >= 4) && (bh >= 5))
				{
					b = new FlxTileblock(RX+bx*8+8,RY+by*8,bw*8-16,8);
					b.loadTiles(ImgDirtTop);
					_decorations.add(b);
					
					b = new FlxTileblock(RX+bx*8+8,RY+by*8+8,bw*8-16,bh*8-24);
					b.loadTiles(ImgDirt);
					_decorations.add(b);
				}
			}
			
			//Finally actually add the spawner
			if(Spawners)
				_spawners.add(new Spawner(RX+sx*8,RY+sy*8,_bigGibs,_enemies,_enemyBullets,_littleGibs,_player));
		}
	}
}
