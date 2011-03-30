package
{
	import flash.geom.Point;
	
	import org.flixel.*;

	public class Enemy extends FlxSprite
	{
		[Embed(source="data/bot.png")] protected var ImgBot:Class;
		[Embed(source="data/jet.png")] protected var ImgJet:Class;
		[Embed(source="data/asplode.mp3")] protected var SndExplode:Class;
		[Embed(source="data/hit.mp3")] protected var SndHit:Class;
		[Embed(source="data/jet.mp3")] protected var SndJet:Class;
		
		protected var _gibs:FlxEmitter;
		protected var _jets:FlxEmitter;
		protected var _player:Player;
		protected var _timer:Number;
		protected var _b:FlxGroup;
		protected var _shotClock:Number;
		protected var _thrust:Number;
		
		public function Enemy()
		{
			super();
			loadRotatedGraphic(ImgBot,64,0); //Load the 

			width = 12;
			height = 12;
			offset.x = 2;
			offset.y = 2;
			
			maxAngular = 120;
			angularDrag = 400;
			drag.x = 80;
			drag.y = 80;
			_thrust = 0;

			_jets = new FlxEmitter();
			_jets.setRotation();
			_jets.gravity = 0;
			_jets.makeParticles(ImgJet,15,0,false,0,0);
		}
		
		public function init(xPos:int,yPos:int,Bullets:FlxGroup,Gibs:FlxEmitter,ThePlayer:Player):void
		{
			_player = ThePlayer;
			_b = Bullets;
			_gibs = Gibs;
			
			reset(xPos - width/2,yPos - height/2);
		}
		
		override public function destroy():void
		{
			_gibs = null;
			_jets.destroy();
			_jets = null;
			_player = null;
			_b = null;
		}
		
		override public function update():void
		{
			//First, figure out the angle from this bot to the player
			var da:Number = FlxU.getAngle(getMidpoint(),_player.getMidpoint());
			
			//Then, rotate toward that angle
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

			//Figure out if the jets are on or not.
			_timer += FlxG.elapsed;
			if(_timer > 8)
				_timer = 0;
			var jetsOn:Boolean = _timer < 6;
			
			//Set the bot's movement speed and direction
			//based on angle and whether the jets are on.
			_thrust = FlxU.computeVelocity(_thrust,(jetsOn?90:0),40,60);
			FlxU.rotatePoint(0,_thrust,0,0,angle,velocity);
			
			//Aim and operate the "jet poof" particles that come out the back of the robot
			if(jetsOn)
			{
				if(!_jets.on)
				{
					_jets.start(false,0.01,0);
					if(onScreen())
						FlxG.play(SndJet);
				}
				_jets.at(this);
				_jets.setXSpeed(-velocity.x-30,-velocity.x+30);
				_jets.setYSpeed(-velocity.y-30,-velocity.y+30);
			}
			else
				_jets.on = false;

			//Shooting - three shots every few seconds
			if(onScreen())
			{
				var shoot:Boolean = false;
				var os:Number = _shotClock;
				_shotClock += FlxG.elapsed;
				if((os < 4.0) && (_shotClock >= 4.0))
				{
					_shotClock = 0;
					shoot = true;
				}
				else if((os < 3.5) && (_shotClock >= 3.5))
					shoot = true;
				else if((os < 3.0) && (_shotClock >= 3.0))
					shoot = true;

				if(shoot) //actually shoot a bullet out along the angle of the bot
				{
					var ba:FlxPoint = FlxU.rotatePoint(0,120,0,0,angle);
					(_b.recycle(BotBullet) as BotBullet).shoot(x+width/2-2,y+height/2-2,ba.x,ba.y);
				}
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
			if(!alive)
				return;
			FlxG.play(SndExplode);
			super.kill();
			flicker(-1);
			_jets.kill();
			_gibs.at(this);
			_gibs.start(true,3,0,20);
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
	}
}
