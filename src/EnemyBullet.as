package
{
	import org.flixel.*;

	public class EnemyBullet extends FlxSprite
	{
		[Embed(source="data/bot_bullet.png")] private var ImgBullet:Class;
		[Embed(source="data/jump.mp3")] private var SndHit:Class;
		[Embed(source="data/enemy.mp3")] private var SndShoot:Class;
		
		public var speed:Number;
		
		public function EnemyBullet()
		{
			super();
			loadGraphic(ImgBullet,true);
			addAnimation("idle",[0, 1], 50);
			addAnimation("poof",[2, 3, 4], 50, false);
			speed = 120;
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
		
		public function shoot(Location:FlxPoint, Angle:Number):void
		{
			FlxG.play(SndShoot,0.5);
			super.reset(Location.x-width/2,Location.y-height/2);
			FlxU.rotatePoint(0,speed,0,0,Angle,_point);
			velocity.x = _point.x;
			velocity.y = _point.y;
			solid = true;
			play("idle");
		}
	}
}