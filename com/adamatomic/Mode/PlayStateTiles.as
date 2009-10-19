package com.adamatomic.Mode
{
	import com.adamatomic.flixel.*;

	public class PlayStateTiles extends FlxState
	{
		[Embed(source="../../../data/mode.mp3")] private var SndMode:Class;
		[Embed(source="../../../data/map.txt",mimeType="application/octet-stream")] private var TxtMap:Class;
		[Embed(source="../../../data/map2.txt",mimeType="application/octet-stream")] private var TxtMap2:Class;
		[Embed(source="../../../data/tiles_all.png")] private var ImgTiles:Class;
		
		//major game objects
		private var _tilemap:FlxTilemap;
		private var _bullets:FlxArray;
		private var _player:Player;
		
		function PlayStateTiles():void
		{
			super();
			
			//create tilemap
			_tilemap = new FlxTilemap(new TxtMap,ImgTiles,3);
			//_tilemap = new FlxTilemap(new TxtMap2,ImgTiles,3); //This is an alternate tiny map
			
			//create player and bullets
			_bullets = new FlxArray();
			_player = new Player(_tilemap.width/2-4,_tilemap.height/2-4,_bullets);
			_player.addAnimationCallback(AnimationCallbackTest);
			for(var i:uint = 0; i < 8; i++)
				_bullets.add(this.add(new Bullet()));
			
			//add player and set up camera
			this.add(_player);
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(0,0,640,640);
			
			//Uncomment these lines if you want to center TxtMap2
			//var fx:uint = _tilemap.width/2 - FlxG.width/2;
			//var fy:uint = _tilemap.height/2 - FlxG.height/2;
			//FlxG.followBounds(fx,fy,fx,fy);
			
			//add tilemap last so it is in front, looks neat
			this.add(_tilemap);
			
			//turn on music and fade in
			FlxG.setMusic(SndMode);
			FlxG.flash(0xff131c1b);
		}

		override public function update():void
		{
			super.update();
			FlxG.collideArray2(_tilemap,_bullets);
			_tilemap.collide(_player);
		}
		
		private function AnimationCallbackTest(Name:String, Frame:uint, FrameIndex:uint):void
		{
			FlxG.log("ANIMATION NAME: "+Name+", FRAME: "+Frame+", FRAME INDEX: "+FrameIndex);
		}
	}
}
