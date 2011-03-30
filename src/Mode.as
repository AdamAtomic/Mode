package
{
	import org.flixel.*;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class Mode extends FlxGame
	{
		public function Mode():void
		{
			super(320,240,MenuState);
			FlxState.bgColor = 0xff131c1b;
			debugOnRelease = true;
		}
	}
}
