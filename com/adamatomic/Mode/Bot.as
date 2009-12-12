package com.adamatomic.Mode
{
	import flash.geom.Point;
	
	import org.flixel.*;

	public class Bot extends FlxSprite
	{
		[Embed(source="../../../data/bot.png")] private var ImgBot:Class;
		[Embed(source="../../../data/gibs.png")] private var ImgGibs:Class;
		[Embed(source="../../../data/jet.png")] private var ImgJet:Class;
		[Embed(source="../../../data/asplode.mp3")] private var SndExplode:Class;
		[Embed(source="../../../data/hit.mp3")] private var SndHit:Class;
		[Embed(source="../../../data/jet.mp3")] private var SndJet:Class;
		
		private var _gibs:FlxEmitter;
		private var _jets:FlxEmitter;
		private var _player:Player;
		private var _timer:Number;
		private var _b:Array;
		static private var _cb:uint = 0;
		private var _shotClock:Number;
		
		public function Bot(xPos:int,yPos:int,Bullets:Array,ThePlayer:Player)
		{
			super(xPos,yPos);
			loadGraphic(ImgBot,true);
			_player = ThePlayer;
			_b = Bullets;
			
			width = 12;
			height = 12;
			offset.x = 2;
			offset.y = 2;
			maxAngular = 120;
			angularDrag = 400;
			maxThrust = 100;
			drag.x = 80;
			drag.y = 80;
			
			addAnimation("idle", [0]);
			addAnimation("dead", [1, 2, 3, 4, 5], 15, false);

			//Gibs emitted upon death
			_gibs = new FlxEmitter(0,0,-1.5);
			_gibs.setXVelocity(-150,150);
			_gibs.setYVelocity(-200,0);
			_gibs.setRotation(-720,-720);
			_gibs.createSprites(ImgGibs,20);
			FlxG.state.add(_gibs);
			
			//Jet effect that shoots out from behind the bot
			_jets = new FlxEmitter(0,0,0.01);
			_jets.setRotation();
			_jets.gravity = 0;
			_jets.createSprites(ImgJet,15);
			FlxG.state.add(_jets);

			reset(x,y);
		}
		
		override public function update():void
		{
			if(dead)
			{
				if(finished) exists = false;
				else
					super.update();
				return;
			}
			
			var ot:Number = _timer;
			if((_timer == 0) && onScreen()) FlxG.play(SndJet);
			_timer += FlxG.elapsed;
			if((ot < 8) && (_timer >= 8))
				_jets.kill();

			//Aiming
			var dx:Number = x-_player.x;
			var dy:Number = y-_player.y;
			var da:Number = FlxG.getAngle(dx,dy);
			if(da < 0)
				da += 360;
			var ac:Number = angle;
			if(ac < 0)
				ac += 360;
			if(da < angle)
				angularAcceleration = -angularDrag;
			else if(da > angle)
				angularAcceleration = angularDrag;
			else
				angularAcceleration = 0;

			//Jets
			thrust = 0;
			if(_timer > 9)
				_timer = 0;
			else if(_timer < 8)
			{
				if(!_jets.active)
					_jets.restart();
				thrust = 40;
				_jets.x = x + width/2;
				_jets.y = y + height/2;
				var v:Point = FlxG.rotatePoint(thrust,0,0,0,angle);
				_jets.setXVelocity(v.x-30,v.x+30);
				_jets.setYVelocity(v.y-30,v.y+30);
			}

			//Shooting
			if(onScreen())
			{
				var os:Number = _shotClock;
				_shotClock += FlxG.elapsed;
				if((os < 4.0) && (_shotClock >= 4.0))
				{
					_shotClock = 0;
					shoot();
				}
				else if((os < 3.5) && (_shotClock >= 3.5))
					shoot();
				else if((os < 3.0) && (_shotClock >= 3.0))
					shoot();
			}
			
			super.update();
		}
		
		override public function hurt(Damage:Number):void
		{
			FlxG.play(SndHit);
			flicker(0.2);
			FlxG.score += 10;
			super.hurt(Damage);
		}
		
		override public function kill():void
		{
			if(dead)
				return;
			FlxG.play(SndExplode);
			super.kill();
			exists = true;
			flicker(-1);
			play("dead");
			_jets.kill();
			_gibs.x = x + width/2;
			_gibs.y = y + height/2;
			_gibs.restart();
			FlxG.score += 200;
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X,Y);
			thrust = 0;
			velocity.x = 0;
			velocity.y = 0;
			angle = Math.random()*360 - 180;
			health = 2;
			_timer = 0;
			_shotClock = 0;
			play("idle");
		}
		
		private function shoot():void
		{
			var ba:Point = FlxG.rotatePoint(-120,0,0,0,angle);
			_b[_cb].shoot(x+width/2-2,y+height/2-2,ba.x,ba.y);
			if(++_cb >= _b.length) _cb = 0;
		}
	}
}
