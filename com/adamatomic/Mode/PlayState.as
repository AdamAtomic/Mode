package com.adamatomic.Mode
{
	import flash.geom.Point;
	
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		[Embed(source="../../../data/tech_tiles.png")] private var ImgTech:Class;
		[Embed(source="../../../data/dirt_top.png")] private var ImgDirtTop:Class;
		[Embed(source="../../../data/dirt.png")] private var ImgDirt:Class;
		[Embed(source="../../../data/notch.png")] private var ImgNotch:Class;
		[Embed(source="../../../data/mode.mp3")] private var SndMode:Class;
		[Embed(source="../../../data/countdown.mp3")] private var SndCount:Class;
		
		//major game objects
		private var _blocks:Array;
		private var _bullets:Array;
		private var _player:Player;
		private var _bots:Array;
		private var _spawners:Array;
		private var _botBullets:Array;
		
		//HUD
		private var _score:FlxText;
		private var _scoreShadow:FlxText;
		private var _score2:FlxText;
		private var _score2Shadow:FlxText;
		private var _scoreTimer:Number;
		private var _jamTimer:Number;
		private var _jamBar:FlxSprite;
		private var _jamText:FlxText;
		private var _notches:Array;
		
		//just to prevent weirdness during level transition
		private var _fading:Boolean;
		
		function PlayState():void
		{
			super();
			
			//create basic objects
			_bullets = new Array();
			_player = new Player(316,300,_bullets);
			_botBullets = new Array();
			_bots = new Array();
			_spawners = new Array();
			
			//create level
			var i:uint;
			var r:uint = 160;
			var b:FlxBlock;
			_blocks = new Array();
			
			b = new FlxBlock(0,0,640,16);
			b.loadGraphic(ImgTech);
			_blocks.push(this.add(b));
			
			b = new FlxBlock(0,16,16,640-16);
			b.loadGraphic(ImgTech);
			_blocks.push(this.add(b));
			
			b = new FlxBlock(640-16,16,16,640-16);
			b.loadGraphic(ImgTech);
			_blocks.push(this.add(b));
			
			b = new FlxBlock(16,640-24,640-32,8);
			b.loadGraphic(ImgDirtTop);
			_blocks.push(this.add(b));
			
			b = new FlxBlock(16,640-16,640-32,16);
			b.loadGraphic(ImgDirt);
			_blocks.push(this.add(b));
			
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
			
			//create bullets
			for(i = 0; i < 50; i++)
				_botBullets.push(this.add(new BotBullet()));
			for(i = 0; i < 8; i++)
				_bullets.push(this.add(new Bullet()));
			
			//camera settings
			this.add(_player);
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(0,0,640,640);
			
			//HUD - score
			var ssf:Point = new Point(0,0);
			_score = new FlxText(0,0,FlxG.width);
			_score.color = 0xd8eba2;
			_score.size = 16;
			_score.alignment = "center";
			_score.scrollFactor = ssf;
			_scoreShadow = new FlxText(_score.x+2,_score.y+2,_score.width);
			_scoreShadow.color = 0x131c1b;
			_scoreShadow.size = _score.size;
			_scoreShadow.alignment = _score.alignment;
			_scoreShadow.scrollFactor = ssf;
			add(_scoreShadow);
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
			_score2Shadow = new FlxText(_score2.x+1,_score2.y+1,_score2.width);
			_score2Shadow.color = 0x131c1b;
			_score2Shadow.alignment = _score2.alignment;
			_score2Shadow.scrollFactor = ssf;
			add(_score2Shadow);
			add(_score2);
			if(FlxG.score > FlxG.scores[0])
				FlxG.scores[0] = FlxG.score;
			if(FlxG.scores[0] != 0)
			{
				_score2.text = "HIGHEST: "+FlxG.scores[0]+"\nLAST: "+FlxG.score;
				_score2Shadow.text = "HIGHEST: "+FlxG.scores[0]+"\nLAST: "+FlxG.score;
			}
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
			FlxG.flash(0xff131c1b);
			_fading = false;
		}

		override public function update():void
		{
			var os:uint = FlxG.score;
			
			super.update();
			
			//collisions with environment
			FlxG.collideArrays(_bullets,_blocks);
			FlxG.collideArrays(_botBullets,_blocks);
			FlxG.collideArrays(_bots,_blocks);
			FlxG.collideArrayX(_blocks,_player);
			FlxG.collideArrayY(_blocks,_player);
			
			//collisions between sprites
			FlxG.overlapArrays(_bullets,_bots,bulletHitBot);
			FlxG.overlapArrays(_bullets,_spawners,bulletHitBot);
			FlxG.overlapArray(_bots,_player,botHitPlayer);
			FlxG.overlapArray(_spawners,_player,botHitPlayer);
			FlxG.overlapArray(_botBullets,_player,bulletHitBot);
			
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
				var i:uint;
				var found:uint = 0;
				for(i = 0; i < _spawners.length; i++)
					if(!_spawners[i].dead) found++;
				if(found == 0)
				{
					_fading = true;
					FlxG.fade(0xffd8eba2,3,onVictory);
				}
				else
				{
					for(i = 0; i < _notches.length; i++)
					{
						if(i < found)
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
				_scoreShadow.text = FlxG.score.toString();
			}
		}
		
		private function bulletHitBot(Bullet:FlxSprite,Bot:FlxSprite):void
		{
			Bullet.hurt(0);
			Bot.hurt(1);
		}
		
		private function botHitPlayer(Bot:FlxSprite,Player:FlxSprite):void
		{
			Player.hurt(1);
		}
		
		private function onVictory():void
		{
			FlxG.music.stop();
			FlxG.switchState(VictoryState);
		}
		
		//Just plops down a spawner and some blocks - haphazard and crappy atm but functional!
		private function buildRoom(RX:uint,RY:uint,Spawners:Boolean=false):void
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
				check = false;
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
				
				var b:FlxBlock;
				
				b = new FlxBlock(RX+bx*8,RY+by*8,bw*8,bh*8);
				b.loadGraphic(ImgTech);
				_blocks.push(this.add(b));
				
				//If the block has room, add some non-colliding "dirt" graphics for variety
				if((bw >= 4) && (bh >= 5))
				{
					b = new FlxBlock(RX+bx*8+8,RY+by*8,bw*8-16,8);
					b.loadGraphic(ImgDirtTop);
					this.add(b);
					
					b = new FlxBlock(RX+bx*8+8,RY+by*8+8,bw*8-16,bh*8-24);
					b.loadGraphic(ImgDirt);
					this.add(b);
				}
			}
			
			//Finally actually add the spawner
			if(Spawners)
				_spawners.push(this.add(new Spawner(RX+sx*8,RY+sy*8,_bots,_botBullets,_player)));
		}
	}
}
