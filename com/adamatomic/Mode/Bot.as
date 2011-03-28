package com.adamatomic.Mode
{
	import flash.geom.Point;
	
	import org.flixel.*;

	public class Bot extends FlxSprite
	{
		[Embed(source="../../../data/bot.png")] protected var ImgBot:Class;
		[Embed(source="../../../data/jet.png")] protected var ImgJet:Class;
		[Embed(source="../../../data/asplode.mp3")] protected var SndExplode:Class;
		[Embed(source="../../../data/hit.mp3")] protected var SndHit:Class;
		[Embed(source="../../../data/jet.mp3")] protected var SndJet:Class;
		
		protected var _gibs:FlxEmitter;
		protected var _jets:FlxEmitter;
		protected var _player:Player;
		protected var _timer:Number;
		protected var _b:Array;
		static protected var _cb:uint = 0;
		protected var _shotClock:Number;
		protected var _thrust:Number;
		
		public function Bot(xPos:int,yPos:int,Bullets:Array,Gibs:FlxEmitter,ThePlayer:Player)
		{
			super(xPos,yPos);
			loadRotatedGraphic(ImgBot,32,0);
			_player = ThePlayer;
			_b = Bullets;
			_gibs = Gibs;
			
			width = 12;
			height = 12;
			offset.x = 2;
			offset.y = 2;
			maxAngular = 120;
			angularDrag = 400;
			drag.x = 80;
			drag.y = 80;
			_thrust = 0;
			
			//Jet effect that shoots out from behind the bot
			_jets = new FlxEmitter();
			_jets.setRotation();
			_jets.gravity = 0;
			_jets.createSprites(ImgJet,15,0,false);

			reset(x,y);
		}
		
		override public function update():void
		{
			var ot:Number = _timer;
			if((_timer == 0) && onScreen()) FlxG.play(SndJet);
			_timer += FlxG.elapsed;
			if((ot < 8) && (_timer >= 8))
				_jets.stop(0.1);

			//Aiming
			var da:Number = FlxU.getAngle(this,_player);
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
			if(_timer > 9)
				_timer = 0;
			else if(_timer < 8)
			{
				velocity.x = velocity.y = 0;
				_thrust = FlxU.computeVelocity(_thrust,120,0,60);
				FlxU.rotatePoint(0,_thrust,0,0,angle,velocity);
				_jets.at(this);
				_jets.setXSpeed(-velocity.x-30,-velocity.x+30);
				_jets.setYSpeed(-velocity.y-30,-velocity.y+30);
				if(!_jets.on)
					_jets.start(false,0.01,0);
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
			
			_jets.update();
			super.update();
		}
		
		override public function draw():void
		{
			_jets.draw();
			super.draw();
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
			flicker(-1);
			_jets.kill();
			_gibs.at(this);
			_gibs.start(true,0,20);
			FlxG.score += 200;
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X,Y);
			velocity.x = 0;
			velocity.y = 0;
			angle = FlxG.random()*360 - 180;
			health = 2;
			_timer = 0;
			_shotClock = 0;
		}
		
		protected function shoot():void
		{
			var ba:FlxPoint = FlxU.rotatePoint(0,120,0,0,angle);
			_b[_cb].shoot(x+width/2-2,y+height/2-2,ba.x,ba.y);
			if(++_cb >= _b.length) _cb = 0;
		}
	}
}
