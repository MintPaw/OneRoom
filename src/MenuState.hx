package ;

import flixel.*;
import flixel.input.gamepad.*;
import flixel.text.*;
import flixel.text.FlxText;

class MenuState extends FlxState
{
	private var _playerSlots:Array<FlxText> = [];
	private var _endText:FlxText;

	public function new():Void
	{
		super();
	}

	override public function create():Void
	{
		super.create();

		var t:FlxText = new FlxText();
		t.size = 30;
		t.text = "Press Z/J/(A) to join";
		t.alignment = FlxTextAlign.CENTER;
		t.x = FlxG.width - t.width - 10;
		t.y = 20;
		add(t);

		_endText = new FlxText();
		_endText.text = "Enter/Start: Start game with 0 players";
		_endText.size = 20;
		_endText.alignment = FlxTextAlign.CENTER;
		_endText.x = FlxG.width - _endText.width - 10;
		_endText.y = t.y + t.height + 10;
		add(_endText);

		var infoText:FlxText = new FlxText();
		infoText.size = 20;
		infoText.text = "Locate yourself and assassinate the other humans among the AIs in the (one) room.\nManipulate the crowd of AIs to gain an advantage.\n";
		infoText.text += "Button 1: Attack in direction you're facing\n";
		infoText.text += "Button 2: Throw your one flash grenade\n";
		infoText.text += "Button 3: Hold to run\n";
		infoText.y = FlxG.height - infoText.height - 10;
		add(infoText);
	}

	public override function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.Z)
		{
			for (d in Reg.playerDefs) if (d.controls == "kb1") return;
			Reg.playerDefs.push({controls:"kb1"});
			addPlayerSlot("Arrows, Z, X, C");
		}

		if (FlxG.keys.justPressed.J)
		{
			for (d in Reg.playerDefs) if (d.controls == "kb2") return;
			Reg.playerDefs.push({controls:"kb2"});
			addPlayerSlot("WSAD, J, K, L");
		}

		for (i in 0...10) {
			var pad:FlxGamepad = FlxG.gamepads.getByID(i);
			if (pad == null || pad.connected == false) continue;
			if (pad.pressed.A)
			{
				for (d in Reg.playerDefs) if (d.controls == "joy"+i) return;
				Reg.playerDefs.push({controls:"joy"+i});
				addPlayerSlot("Left stick, A, B, X");
			}
		}

		if (FlxG.keys.justPressed.ENTER) {
			if (_playerSlots.length >= 2) {
				FlxG.camera.fade(
						0xFF000000,
						1,
						false,
						FlxG.switchState.bind(new GameState()), false);
			}
		}

		super.update(elapsed);
	}

	private function addPlayerSlot(keys:String):Void
	{
		var t:FlxText = new FlxText();
		t.text = "Player " + (_playerSlots.length + 1) + " joined. Keys: " + keys;
		t.alignment = FlxTextAlign.CENTER;
		t.x = 10;
		t.size = 20;

		if (_playerSlots.length == 0)
		{
			t.y = 0;
		}
		else
		{
			t.y = _playerSlots[_playerSlots.length-1].y + t.height + 5;
		}

		add(t);
		_playerSlots.push(t);

		_endText.text = "Enter/Start: Start game with " +
		(_playerSlots.length) + "	players";
	}

}
