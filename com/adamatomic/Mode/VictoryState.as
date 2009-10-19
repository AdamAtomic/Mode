package com.adamatomic.Mode
{
	import org.flixel.*;

	public class VictoryState extends FlxState
	{
		[Embed(source="../../../data/spawner_gibs.png")] private var ImgGibs:Class;
		[Embed(source="../../../data/menu_hit_2.mp3")] private var SndMenu:Class;
		
		private var _timer:Number;
		private var _fading:Boolean;

		public function VictoryState()
		{
			super();
			_timer = 0;
			_fading = false;
			FlxG.flash(0xffd8eba2);
			this.add(new FlxEmitter(0,-50,FlxG.width,0,null,0.03,0,0,0,100,-360,360,80,0,ImgGibs,120,true)) as FlxEmitter;
			this.add(new FlxText(0,FlxG.height/2-35,FlxG.width,80,"VICTORY\n\nSCORE: "+FlxG.score,0xd8eba2,null,16,"center"));
		}

		override public function update():void
		{
			super.update();
			if(!_fading)
			{
				_timer += FlxG.elapsed;
				if((_timer > 0.35) && ((_timer > 10) || FlxG.justPressed(FlxG.A) || FlxG.justPressed(FlxG.B)))
				{
					_fading = true;
					FlxG.play(SndMenu);
					FlxG.fade(0xff131c1b,2,onPlay);
				}
			}
		}
		
		private function onPlay():void { FlxG.switchState(PlayState); }
	}
}