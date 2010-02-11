package com.adamatomic.Mode
{
	import org.flixel.*;

	public class BotBullet extends FlxSprite
	{
		[Embed(source="../../../data/bot_bullet.png")] private var ImgBullet:Class;
		[Embed(source="../../../data/jump.mp3")] private var SndHit:Class;
		[Embed(source="../../../data/enemy.mp3")] private var SndShoot:Class;
		
		public function BotBullet()
		{
			super();
			loadGraphic(ImgBullet,true);
			addAnimation("idle",[0, 1], 50);
			addAnimation("poof",[2, 3, 4], 50, false);
			exists = false;
		}
		
		override public function update():void
		{
			if(dead && finished) exists = false;
			else super.update();
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
			FlxG.play(SndShoot,0.5);
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			play("idle");
		}
	}
}