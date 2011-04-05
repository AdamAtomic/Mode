package
{
	import org.flixel.*;

	public class Bullet extends FlxSprite
	{
		[Embed(source="data/bullet.png")] private var ImgBullet:Class;
		[Embed(source="data/jump.mp3")] private var SndHit:Class;
		[Embed(source="data/shoot.mp3")] private var SndShoot:Class;
		
		public var speed:Number;
		
		public function Bullet()
		{
			super();
			loadGraphic(ImgBullet,true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
			
			addAnimation("up",[0]);
			addAnimation("down",[1]);
			addAnimation("left",[2]);
			addAnimation("right",[3]);
			addAnimation("poof",[4, 5, 6, 7], 50, false);
			
			speed = 360;
		}
		
		override public function update():void
		{
			if(!alive)
			{
				if(finished)
					exists = false;
			}
			else if(touching)
				kill();
		}
		
		override public function kill():void
		{
			if(!alive)
				return;
			velocity.x = 0;
			velocity.y = 0;
			if(onScreen())
				FlxG.play(SndHit);
			alive = false;
			solid = false;
			play("poof");
		}
		
		public function shoot(Location:FlxPoint, Aim:uint):void
		{
			FlxG.play(SndShoot);
			super.reset(Location.x-width/2,Location.y-height/2);
			solid = true;
			switch(Aim)
			{
				case UP:
					play("up");
					velocity.y = -speed;
					break;
				case DOWN:
					play("down");
					velocity.y = speed;
					break;
				case LEFT:
					play("left");
					velocity.x = -speed;
					break;
				case RIGHT:
					play("right");
					velocity.x = speed;
					break;
				default:
					break;
			}
		}
	}
}