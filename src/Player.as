package
{
	import org.flixel.*;

	public class Player extends FlxSprite
	{
		[Embed(source="data/spaceman.png")] private var ImgSpaceman:Class;
		
		[Embed(source="data/jump.mp3")] private var SndJump:Class;
		[Embed(source="data/land.mp3")] private var SndLand:Class;
		[Embed(source="data/asplode.mp3")] private var SndExplode:Class;
		[Embed(source="data/menu_hit_2.mp3")] private var SndExplode2:Class;
		[Embed(source="data/hurt.mp3")] private var SndHurt:Class;
		[Embed(source="data/jam.mp3")] private var SndJam:Class;
		
		private var _jumpPower:int;
		private var _bullets:FlxGroup;
		private var _aim:uint;
		private var _restart:Number;
		private var _gibs:FlxEmitter;
		
		public function Player(X:int,Y:int,Bullets:FlxGroup,Gibs:FlxEmitter)
		{
			super(X,Y);
			loadGraphic(ImgSpaceman,true,true,8);
			_restart = 0;
			
			//bounding box tweaks
			width = 6;
			height = 7;
			offset.x = 1;
			offset.y = 1;
			
			//basic player physics
			var runSpeed:uint = 80;
			drag.x = runSpeed*8;
			acceleration.y = 420;
			_jumpPower = 200;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower;
			
			//animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3, 0], 12);
			addAnimation("jump", [4]);
			addAnimation("idle_up", [5]);
			addAnimation("run_up", [6, 7, 8, 5], 12);
			addAnimation("jump_up", [9]);
			addAnimation("jump_down", [10]);
			
			//bullet stuff
			_bullets = Bullets;
			
			//Gibs emitted upon death
			_gibs = Gibs;
		}
		
		override public function update():void
		{
			//game restart timer
			if(!alive)
			{
				_restart += FlxG.elapsed;
				if(_restart > 2)
					FlxG.resetState();
				return;
			}
			
			//MOVEMENT
			acceleration.x = 0;
			if(FlxG.keys.LEFT)
			{
				facing = LEFT;
				acceleration.x -= drag.x;
			}
			else if(FlxG.keys.RIGHT)
			{
				facing = RIGHT;
				acceleration.x += drag.x;
			}
			if(FlxG.keys.justPressed("X") && !velocity.y)
			{
				velocity.y = -_jumpPower;
				FlxG.play(SndJump);
			}
			
			//AIMING
			if(FlxG.keys.UP)
				_aim = UP;
			else if(FlxG.keys.DOWN && velocity.y)
				_aim = DOWN;
			else
				_aim = facing;
			
			//ANIMATION
			if(velocity.y != 0)
			{
				if(_aim == UP) play("jump_up");
				else if(_aim == DOWN) play("jump_down");
				else play("jump");
			}
			else if(velocity.x == 0)
			{
				if(_aim == UP) play("idle_up");
				else play("idle");
			}
			else
			{
				if(_aim == UP) play("run_up");
				else play("run");
			}
			
			//SHOOTING
			if(!flickering() && FlxG.keys.justPressed("C"))
			{
				getMidpoint(_point);
				(_bullets.recycle(Bullet) as Bullet).shoot(_point,_aim);
				if(_aim == DOWN)
					velocity.y -= 36;
			}
				
			//UPDATE POSITION AND ANIMATION
			super.update();

			//Jammed, can't fire!
			if(flickering())
			{
				if(FlxG.keys.justPressed("C"))
					FlxG.play(SndJam);
			}
		}
		
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			if(velocity.y > 50)
				FlxG.play(SndLand);
			onFloor = true;
			return super.hitBottom(Contact,Velocity);
		}
		
		override public function hurt(Damage:Number):void
		{
			Damage = 0;
			if(flickering())
				return;
			FlxG.play(SndHurt);
			flicker(1.3);
			if(FlxG.score > 1000) FlxG.score -= 1000;
			if(velocity.x > 0)
				velocity.x = -maxVelocity.x;
			else
				velocity.x = maxVelocity.x;
			super.hurt(Damage);
		}
		
		override public function kill():void
		{
			if(!alive)
				return;
			solid = false;
			FlxG.play(SndExplode);
			FlxG.play(SndExplode2);
			super.kill();
			flicker(-1);
			exists = true;
			visible = false;
			FlxG.quake.start(0.005,0.35);
			FlxG.flash.start(0xffd8eba2,0.35);
			if(_gibs != null)
			{
				_gibs.at(this);
				_gibs.start(true,5,0,50);
			}
		}
	}
}