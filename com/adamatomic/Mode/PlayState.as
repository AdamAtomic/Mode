package com.adamatomic.Mode
{
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		[Embed(source="../../../data/tech_tiles.png")] protected var ImgTech:Class;
		[Embed(source="../../../data/dirt_top.png")] protected var ImgDirtTop:Class;
		[Embed(source="../../../data/dirt.png")] protected var ImgDirt:Class;
		[Embed(source="../../../data/notch.png")] protected var ImgNotch:Class;
		[Embed(source="../../../data/mode.mp3")] protected var SndMode:Class;
		[Embed(source="../../../data/countdown.mp3")] protected var SndCount:Class;
		[Embed(source="../../../data/gibs.png")] private var ImgGibs:Class;
		[Embed(source="../../../data/spawner_gibs.png")] private var ImgSpawnerGibs:Class;
		
		//major game objects
		protected var _blocks:FlxGroup;
		protected var _decorations:FlxGroup;
		protected var _bullets:FlxGroup;
		protected var _player:Player;
		protected var _bots:FlxGroup;
		protected var _spawners:FlxGroup;
		protected var _botBullets:FlxGroup;
		protected var _littleGibs:FlxEmitter;
		protected var _bigGibs:FlxEmitter;
		
		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		protected var _enemies:FlxGroup;
		
		//HUD
		protected var _score:FlxText;
		protected var _score2:FlxText;
		protected var _scoreTimer:Number;
		protected var _jamTimer:Number;
		protected var _jamBar:FlxSprite;
		protected var _jamText:FlxText;
		protected var _notches:Array;
		
		//just to prevent weirdness during level transition
		protected var _fading:Boolean;
		
		//used to safely reload the playstate after dying
		public var reload:Boolean;
		
		override public function create():void
		{
			FlxG.mouse.hide();
			reload = false;
			
			//get the gibs set up and out of the way
			_littleGibs = new FlxEmitter();
			_littleGibs.delay = 1.5;
			_littleGibs.setXSpeed(-150,150);
			_littleGibs.setYSpeed(-200,0);
			_littleGibs.setRotation(-720,-720);
			_littleGibs.createSprites(ImgGibs,100,10,true,0.5);
			_bigGibs = new FlxEmitter();
			_bigGibs.setXSpeed(-200,200);
			_bigGibs.setYSpeed(-300,0);
			_bigGibs.setRotation(-720,-720);
			_bigGibs.createSprites(ImgSpawnerGibs,50,20,true,0.5);
			
			//level generation needs to know about the spawners (and thusly the bots, players, etc)
			_blocks = new FlxGroup();
			_decorations = new FlxGroup();
			_bullets = new FlxGroup();
			_player = new Player(316,300,_bullets.members,_littleGibs);
			_bots = new FlxGroup();
			_botBullets = new FlxGroup();
			_spawners = new FlxGroup();
			
			//simple procedural level generation
			var i:uint;
			var r:uint = 160;
			var b:FlxTileblock;
			
			b = new FlxTileblock(0,0,640,16);
			b.loadGraphic(ImgTech);
			_blocks.add(b);
			
			b = new FlxTileblock(0,16,16,640-16);
			b.loadGraphic(ImgTech);
			_blocks.add(b);
			
			b = new FlxTileblock(640-16,16,16,640-16);
			b.loadGraphic(ImgTech);
			_blocks.add(b);
			
			b = new FlxTileblock(16,640-24,640-32,8);
			b.loadGraphic(ImgDirtTop);
			_blocks.add(b);
			
			b = new FlxTileblock(16,640-16,640-32,16);
			b.loadGraphic(ImgDirt);
			_blocks.add(b);
			
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
			
			//Add bots and spawners after we add blocks to the state,
			// so that they're drawn on top of the level, and so that
			// the bots are drawn on top of both the blocks + the spawners.
			add(_spawners);
			add(_littleGibs);
			add(_bigGibs);
			add(_blocks);
			add(_decorations);
			add(_bots);
			
			//actually create the bullets now
			for(i = 0; i < 50; i++)
				_botBullets.add(new BotBullet());
			for(i = 0; i < 8; i++)
				_bullets.add(new Bullet());

			//add player and set up scrolling camera
			add(_player);
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(0,0,640,640);
			
			//add gibs + bullets to scene here, so they're drawn on top of pretty much everything
			add(_botBullets);
			add(_bullets);
			
			//finally we are going to sort things into a couple of helper groups.
			//we don't add these to the state, we just use them for collisions later!
			_enemies = new FlxGroup();
			_enemies.add(_botBullets);
			_enemies.add(_spawners);
			_enemies.add(_bots);
			_objects = new FlxGroup();
			_objects.add(_botBullets);
			_objects.add(_bullets);
			_objects.add(_bots);
			_objects.add(_player);
			_objects.add(_littleGibs);
			_objects.add(_bigGibs);
			
			//HUD - score
			var ssf:FlxPoint = new FlxPoint(0,0);
			_score = new FlxText(0,0,FlxG.width);
			_score.color = 0xd8eba2;
			_score.size = 16;
			_score.alignment = "center";
			_score.scrollFactor = ssf;
			_score.shadow = 0x131c1b;
			add(_score);
			if(FlxG.scores.length < 2)
			{
				FlxG.scores.push(0);
				FlxG.scores.push(0);
			}
			
			//HUD - highest and last scores
			_score2 = new FlxText(FlxG.width/2,0,FlxG.width/2)
			_score2.color = 0xd8eba2;
			_score2.alignment = "right";
			_score2.scrollFactor = ssf;
			_score2.shadow = _score.shadow;
			add(_score2);
			if(FlxG.score > FlxG.scores[0])
				FlxG.scores[0] = FlxG.score;
			if(FlxG.scores[0] != 0)
				_score2.text = "HIGHEST: "+FlxG.scores[0]+"\nLAST: "+FlxG.score;
			FlxG.score = 0;
			_scoreTimer = 0;
			
			//HUD - the "number of spawns left" icons
			_notches = new Array();
			var tmp:FlxSprite;
			for(i = 0; i < 6; i++)
			{
				tmp = new FlxSprite(4+i*10,4);
				tmp.loadGraphic(ImgNotch,true);
				tmp.scrollFactor.x = tmp.scrollFactor.y = 0;
				tmp.addAnimation("on",[0]);
				tmp.addAnimation("off",[1]);
				tmp.moves = false;
				tmp.play("on");
				_notches.push(this.add(tmp));
			}
			
			//HUD - the "gun jammed" notification
			_jamBar = this.add((new FlxSprite(0,FlxG.height-22)).createGraphic(FlxG.width,24,0xff131c1b)) as FlxSprite;
			_jamBar.scrollFactor.x = _jamBar.scrollFactor.y = 0;
			_jamBar.visible = false;
			_jamText = new FlxText(0,FlxG.height-22,FlxG.width,"GUN IS JAMMED");
			_jamText.color = 0xd8eba2;
			_jamText.size = 16;
			_jamText.alignment = "center";
			_jamText.scrollFactor = ssf;
			_jamText.visible = false;
			add(_jamText);
			
			FlxG.playMusic(SndMode);
			FlxG.flash.start(0xff131c1b);
			_fading = false;
		}

		override public function update():void
		{
			var os:uint = FlxG.score;
			
			super.update();
			
			//collisions with environment
			FlxU.collide(_blocks,_objects);
			FlxU.overlap(_enemies,_player,overlapped);
			FlxU.overlap(_bullets,_enemies,overlapped);
			
			//Jammed message
			if(FlxG.keys.justPressed("C") && _player.flickering())
			{
				_jamTimer = 1;
				_jamBar.visible = true;
				_jamText.visible = true;
			}
			if(_jamTimer > 0)
			{
				if(!_player.flickering()) _jamTimer = 0;
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
					var l:uint = _notches.length;
					for(var i:uint = 0; i < l; i++)
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
				if(_player.dead) FlxG.score = 0;
				_score.text = FlxG.score.toString();
			}
			
			if(reload)
				FlxG.state = new PlayState();
		}

		protected function overlapped(Object1:FlxObject,Object2:FlxObject):void
		{
			if((Object1 is BotBullet) || (Object1 is Bullet))
				Object1.kill();
			Object2.hurt(1);
		}
		
		protected function onVictory():void
		{
			FlxG.music.stop();
			FlxG.state = new VictoryState();
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
				sx = 2+FlxU.random()*(rw-7);
				sy = 2+FlxU.random()*(rw-7);
			}
			
			//then place a bunch of blocks
			var numBlocks:uint = 3+FlxU.random()*4;
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
				check = false;
				do
				{
					//keep generating different specs if they overlap the spawner
					bw = minW + FlxU.random()*(maxW-minW);
					bh = minH + FlxU.random()*(maxH-minH);
					bx = -1 + FlxU.random()*(rw+1-bw);
					by = -1 + FlxU.random()*(rw+1-bh);
					if(Spawners)
						check = ((sx>bx+bw) || (sx+3<bx) || (sy>by+bh) || (sy+3<by));
					else
						check = true;
				} while(!check);
				
				var b:FlxTileblock;
				
				b = new FlxTileblock(RX+bx*8,RY+by*8,bw*8,bh*8);
				b.loadGraphic(ImgTech);
				_blocks.add(b);
				
				//If the block has room, add some non-colliding "dirt" graphics for variety
				if((bw >= 4) && (bh >= 5))
				{
					b = new FlxTileblock(RX+bx*8+8,RY+by*8,bw*8-16,8);
					b.loadGraphic(ImgDirtTop);
					_decorations.add(b);
					
					b = new FlxTileblock(RX+bx*8+8,RY+by*8+8,bw*8-16,bh*8-24);
					b.loadGraphic(ImgDirt);
					_decorations.add(b);
				}
			}
			
			//Finally actually add the spawner
			if(Spawners)
				_spawners.add(new Spawner(RX+sx*8,RY+sy*8,_bigGibs,_bots,_botBullets.members,_littleGibs,_player));
		}
	}
}
