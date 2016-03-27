package;

import flixel.*;

class MainState extends FlxState
{
	
	public function new()
	{
		super();
	}

	override public function create():Void
	{
		super.create();
		var skipMenu:Bool = false;
		// skipMenu = true;

		if (skipMenu) {
			Reg.playerDefs = [
					{
						controls: "kb1"
					},
					{
						controls: "kb2"
					}
			];

			FlxG.switchState(new GameState());
		} else {
			FlxG.switchState(new MenuState());
		}
	}
}
