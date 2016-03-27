package;

import flixel.*;
import flixel.math.*;
import flixel.input.gamepad.*;
import openfl.*;
import openfl.media.*;
import openfl.Assets;

class Reg
{
	public static var rnd:FlxRandom = new FlxRandom();
	public static var playerDefs:Array<Dynamic> = [];

	public static var playerKeys:Array<Dynamic> = [];

	public static var effectChannel:SoundChannel;

	public static function init():Void
	{
		playerKeys = [];
		for (i in 0...playerDefs.length) playerKeys.push({});
	}

	public static function resolveKeys():Void
	{
		for (i in 0...playerDefs.length)
		{
			var c:String = playerDefs[i].controls;

			if (c == "kb1")
			{
				playerKeys[i].left = FlxG.keys.pressed.LEFT;
				playerKeys[i].right = FlxG.keys.pressed.RIGHT;
				playerKeys[i].up = FlxG.keys.pressed.UP;
				playerKeys[i].down = FlxG.keys.pressed.DOWN;
				playerKeys[i].a = FlxG.keys.pressed.Z;
				playerKeys[i].b = FlxG.keys.pressed.X;
				playerKeys[i].c = FlxG.keys.pressed.C;
			}
			else if (c == "kb2")
			{
				playerKeys[i].left = FlxG.keys.pressed.A;
				playerKeys[i].right = FlxG.keys.pressed.D;
				playerKeys[i].up = FlxG.keys.pressed.W;
				playerKeys[i].down = FlxG.keys.pressed.S;
				playerKeys[i].a = FlxG.keys.pressed.J;
				playerKeys[i].b = FlxG.keys.pressed.K;
				playerKeys[i].c = FlxG.keys.pressed.L;
			}
			else if (c.substr(0, 3) == "joy")
			{
				var pad:FlxGamepad = FlxG.gamepads.getByID(Std.parseInt(c.charAt(3)));
				if (pad == null || pad.connected == false) return;
				var d:Float = 0.5;

				playerKeys[i].left =
					pad.analog.value.LEFT_STICK_X < -d || pad.pressed.DPAD_LEFT;
				playerKeys[i].right =
					pad.analog.value.LEFT_STICK_X > d || pad.pressed.DPAD_RIGHT;
				playerKeys[i].up =
					pad.analog.value.LEFT_STICK_Y < -d || pad.pressed.DPAD_UP;
				playerKeys[i].down =
					pad.analog.value.LEFT_STICK_Y > d || pad.pressed.DPAD_DOWN;

				playerKeys[i].a = pad.pressed.A;
				playerKeys[i].b = pad.pressed.B;
				playerKeys[i].c = pad.pressed.X;
			}
		}
	}

	public static function playEffect(id:String):Void
	{
		var soundList:Array<String> = Assets.list(AssetType.SOUND);
		var paths:Array<String> = [];

		for (path in soundList) {
			if (path.indexOf("sound/" + id) != -1) paths.push(path);
		}

		var path:String = Reg.rnd.getObject(paths);
		effectChannel = Assets.getSound(path).play(0, 1);
	}

}
