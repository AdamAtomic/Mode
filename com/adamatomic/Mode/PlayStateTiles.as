package com.adamatomic.Mode
{
	import org.flixel.*;

	public class PlayStateTiles extends FlxState
	{
		[Embed(source="../../../data/mode.mp3")] private var SndMode:Class;
		[Embed(source="../../../data/map.txt",mimeType="application/octet-stream")] private var TxtMap:Class;
		[Embed(source="../../../data/map2.txt",mimeType="application/octet-stream")] private var TxtMap2:Class;
		[Embed(source="../../../data/tiles_all.png")] private var ImgTiles:Class;
		
		//major game objects
		private var _tilemap:FlxTilemap;
		private var _bullets:FlxGroup;
		private var _player:Player;
		
		override public function create():void
		{
			//create tilemap
			_tilemap = new FlxTilemap();
			_tilemap.collideIndex = 3;
			_tilemap.loadMap(new TxtMap,ImgTiles,8);
			//_tilemap.loadMap(new TxtMap2,ImgTiles,8); //This is an alternate tiny map
			
			//create player and bullets
			_bullets = new FlxGroup();
			_player = new Player(_tilemap.width/2-4,_tilemap.height/2-4,_bullets.members,null);
			for(var i:uint = 0; i < 8; i++)
				_bullets.add(new Bullet());
			add(_bullets);
			
			//add player and set up camera
			add(_player);
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			_tilemap.follow();	//Set the followBounds to the map dimensions
			
			//Uncomment these lines if you want to center TxtMap2
			//var fx:uint = _tilemap.width/2 - FlxG.width/2;
			//var fy:uint = _tilemap.height/2 - FlxG.height/2;
			//FlxG.followBounds(fx,fy,fx,fy);
			
			//add tilemap last so it is in front, looks neat
			add(_tilemap);
			
			//fade in
			FlxG.flash.start(0xff131c1b);
			
			//The music in this mode is positional - it fades out toward the edges of the level
			var s:FlxSound = FlxG.play(SndMode,1,true);
			s.proximity(320,320,_player,160);
		}

		override public function update():void
		{
			super.update();
			_tilemap.collide(_player);
			_tilemap.collide(_bullets);
		}
	}
}
