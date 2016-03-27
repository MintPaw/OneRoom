package;

import openfl.display.Sprite;
import flixel.*;

class Main extends Sprite
{
	
	public function new()
	{
		super();

		var f:FlxGame = new FlxGame(
				stage.stageWidth,
				stage.stageHeight,
				MainState,
				1,
				60,
				60,
				true,
				false);

		addChild(f);

	}
}
