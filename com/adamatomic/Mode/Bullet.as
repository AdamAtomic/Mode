package com.adamatomic.Mode
{
	import org.flixel.*;

	public class Bullet extends FlxSprite
	{
		[Embed(source="../../../data/bullet.png")] private var ImgBullet:Class;
		[Embed(source="../../../data/jump.mp3")] private var SndHit:Class;
		[Embed(source="../../../data/shoot.mp3")] private var SndShoot:Class;
		
		public function Bullet()
		{
			super();
			loadGraphic(ImgBullet,true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
			exists = false;
			
			addAnimation("up",[0]);
			addAnimation("down",[1]);
			addAnimation("left",[2]);
			addAnimation("right",[3]);
			addAnimation("poof",[4, 5, 6, 7], 50, false);
		}
		
		override public function update():void
		{
			if(dead && finished) exists = false;
			else super.update();
		}
		
		override public function render():void
		{
			super.render();
		}

		override public function hitLeft(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitTop(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			if(onScreen()) FlxG.play(SndHit);
			dead = true;
			solid = false;
			play("poof");
		}
		
		public function shoot(X:int, Y:int, VelocityX:int, VelocityY:int):void
		{
			FlxG.play(SndShoot);
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			if(velocity.y < 0)
				play("up");
			else if(velocity.y > 0)
				play("down");
			else if(velocity.x < 0)
				play("left");
			else if(velocity.x > 0)
				play("right");
		}
	}
}