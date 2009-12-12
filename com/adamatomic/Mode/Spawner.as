package com.adamatomic.Mode
{
	import org.flixel.*;

	public class Spawner extends FlxSprite
	{
		[Embed(source="../../../data/spawner.png")] private var ImgSpawner:Class;
		[Embed(source="../../../data/spawner_gibs.png")] private var ImgSpawnerGibs:Class;
		[Embed(source="../../../data/asplode.mp3")] private var SndExplode:Class;
		[Embed(source="../../../data/menu_hit_2.mp3")] private var SndExplode2:Class;
		[Embed(source="../../../data/hit.mp3")] private var SndHit:Class;
		
		private var _timer:Number;
		private var _b:Array;
		private var _b2:Array;
		private var _gibs:FlxEmitter;
		private var _player:Player;
		
		public function Spawner(X:int, Y:int,Bots:Array,BotBullets:Array,ThePlayer:Player)
		{
			super(X,Y);
			loadGraphic(ImgSpawner,true);
			_b = Bots;
			_b2 = BotBullets;
			_player = ThePlayer;
			_timer = Math.random()*20;
			health = 8;

			addAnimation("open", [1, 2, 3, 4, 5], 40, false);
			addAnimation("close", [5, 4, 3, 2, 1, 0], 40, false);
			addAnimation("dead", [6]);
		}
		
		override public function update():void
		{
			if(dead)
				return;
				
			_timer += FlxG.elapsed;
			var limit:uint = 20;
			if(onScreen())
				limit = 4;
			if(_timer > limit)
			{
				_timer = 0;
				makeBot();
			}
			else if(_timer > limit - 0.35)
				play("open");
			else if(_timer > 1)
				play("close");
				
			super.update();
		}
		
		override public function hurt(Damage:Number):void
		{
			FlxG.play(SndHit);
			flicker(0.2);
			FlxG.score += 50;
			super.hurt(Damage);
		}
		
		override public function kill():void
		{
			if(dead)
				return;
			FlxG.play(SndExplode);
			FlxG.play(SndExplode2);
			super.kill();
			exists = true;
			flicker(-1);
			play("dead");
			FlxG.quake(0.005,0.35);
			FlxG.flash(0xffd8eba2,0.35);
			makeBot();
			
			//Gibs emitted upon death
			_gibs = new FlxEmitter(x+width/2,y+height/2,-2);
			_gibs.setXVelocity(-200,200);
			_gibs.setYVelocity(-300,0);
			_gibs.setRotation(-720,-720);
			_gibs.createSprites(ImgSpawnerGibs);
			FlxG.state.add(_gibs);
			_gibs.restart();

			FlxG.score += 1000;
		}
		
		private function makeBot():void
		{
			//try to recycle a dead bot
			for(var i:uint = 0; i < _b.length; i++)
				if(!_b[i].exists)
				{
					_b[i].reset(x + width/2 - _b[i].width/2, y + width/2 - _b[i].height/2);
					return;
				} 
			
			//if that fails just make a new one
			var b:Bot = new Bot(x + width/2, y + width/2,_b2,_player);
			b.x -= b.width/2;
			b.y -= b.height/2;
			_b.push(FlxG.state.add(b));
		}
	}
}