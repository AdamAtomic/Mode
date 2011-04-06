package
{
	import org.flixel.*;

	public class Player extends FlxSprite
	{
		[Embed(source="data/spaceman.png")] protected var ImgSpaceman:Class;
		
		[Embed(source="data/jump.mp3")] protected var SndJump:Class;
		[Embed(source="data/land.mp3")] protected var SndLand:Class;
		[Embed(source="data/asplode.mp3")] protected var SndExplode:Class;
		[Embed(source="data/menu_hit_2.mp3")] protected var SndExplode2:Class;
		[Embed(source="data/hurt.mp3")] protected var SndHurt:Class;
		[Embed(source="data/jam.mp3")] protected var SndJam:Class;
		
		protected var _jumpPower:int;
		protected var _bullets:FlxGroup;
		protected var _aim:uint;
		protected var _restart:Number;
		protected var _gibs:FlxEmitter;
		
		//This is the player object class.  Most of the comments I would put in here
		//would be near duplicates of the Enemy class, so if you're confused at all
		//I'd recommend checking that out for some ideas!
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
			_gibs = Gibs;
		}
		
		override public function destroy():void
		{
			super.destroy();
			_bullets = null;
			_gibs = null;
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
			
			//make a little noise if you just touched the floor
			if(justTouched(FLOOR) && (velocity.y > 50))
				FlxG.play(SndLand);
			
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
			if(FlxG.keys.justPressed("C"))
			{
				if(flickering)
					FlxG.play(SndJam);
				else
				{
					getMidpoint(_point);
					(_bullets.recycle(Bullet) as Bullet).shoot(_point,_aim);
					if(_aim == DOWN)
						velocity.y -= 36;
				}
			}
		}
		
		override public function hurt(Damage:Number):void
		{
			Damage = 0;
			if(flickering)
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
			flicker(0);
			exists = true;
			visible = false;
			velocity.make();
			acceleration.make();
			FlxG.camera.shake(0.005,0.35);
			FlxG.camera.flash(0xffd8eba2,0.35);
			if(_gibs != null)
			{
				_gibs.at(this);
				_gibs.start(true,5,0,50);
			}
		}
	}
}