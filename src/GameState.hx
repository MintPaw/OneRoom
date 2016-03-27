package;

import flixel.*;
import flixel.group.FlxGroup;
import flixel.group.*;
import flixel.math.*;
import flixel.text.*;
import flixel.text.FlxText;
import flixel.util.*;

class GameState extends FlxState
{
	private var _playerGroup:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	private var _wallGroup:FlxGroup = new FlxGroup();
	private var _leaveCooldown:Float;
	
	public function new()
	{
		super();
	}

	override public function create():Void
	{
		super.create();
		Reg.init();

		{ // walls
			var t:FlxSprite = new FlxSprite();
			t.makeGraphic(FlxG.width, 5, 0xFFFFFFFF);
			t.y = -5;

			var b:FlxSprite = new FlxSprite();
			b.makeGraphic(FlxG.width, 5, 0xFFFFFFFF);
			b.y = FlxG.height;

			var l:FlxSprite = new FlxSprite();
			l.makeGraphic(5, FlxG.height, 0xFFFFFFFF);
			l.x = -5;

			var r:FlxSprite = new FlxSprite();
			r.makeGraphic(5, FlxG.height, 0xFFFFFFFF);
			r.x = FlxG.width;

			t.immovable = b.immovable = l.immovable = r.immovable = true;

			_wallGroup.add(t);
			_wallGroup.add(b);
			_wallGroup.add(l);
			_wallGroup.add(r);

			add(t);
			add(b);
			add(l);
			add(r);
		}

		for (i in 0...100)
		{
			var p:Player = new Player(i < Reg.playerDefs.length ? i : -1);
			p.attackCallback = attack;
			p.x = Reg.rnd.int(0, cast FlxG.width - p.width);
			p.y = Reg.rnd.int(0, cast FlxG.height - p.height);
			add(p);
			add(p.emitter);
			if (p.flashEmitter != null) add(p.flashEmitter);

			_playerGroup.add(p);
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		Reg.resolveKeys();

		FlxG.collide(_playerGroup, _wallGroup);

		if (_leaveCooldown > 0) {
			_leaveCooldown -= elapsed;
		} else {
			_leaveCooldown = 5;
			var living:Array<Player> = [];
			for (p in _playerGroup)
				if (!p.dead && !p.leaving && p.playerNumber == -1) living.push(p);

			var toLeave:Player = Reg.rnd.getObject(living);
			if (toLeave != null) toLeave.leave();
		}
	}

	private function attack(p:Player):Void
	{
		var deathBox:FlxRect = new FlxRect();
		deathBox.width = 75;
		deathBox.height = 75;
		deathBox.x = p.x + p.width/2 - deathBox.width/2;
		deathBox.y = p.y + p.height/2 - deathBox.height/2;
		
		if (!p.keys.left && !p.keys.right && !p.keys.up && !p.keys.down) {
			if (p.facing == FlxObject.LEFT) p.keys.left = true;
			if (p.facing == FlxObject.RIGHT) p.keys.right = true;
			if (p.facing == FlxObject.UP) p.keys.up = true;
			if (p.facing == FlxObject.DOWN) p.keys.down = true;
		}

		if (p.keys.left) deathBox.x -= deathBox.width*0.6;
		if (p.keys.right) deathBox.x += deathBox.width*0.6;
		if (p.keys.up) deathBox.y -= deathBox.height*0.6;
		if (p.keys.down) deathBox.y += deathBox.height*0.6;

		// if (p.keys.left || p.keys.right) deathBox.width /= 2;
		// if (p.keys.up || p.keys.down) deathBox.height /= 2;

		// var s = new FlxSprite();
		// s.makeGraphic(Std.int(deathBox.width), Std.int(deathBox.height), 0x88FFFFFF);
		// s.x = deathBox.x;
		// s.y = deathBox.y;
		// add(s);

		for (other in _playerGroup)
		{
			if (other != p && deathBox.overlaps(other.getHitbox()))
			{
				other.kill();
				_playerGroup.remove(other);
				continue;
			}

			if (other.playerNumber == -1) {
				var distTime:Float =
					FlxMath.lerp(0, 2, FlxMath.distanceBetween(other, p)/1500);

				new FlxTimer().start(distTime, function(t:FlxTimer) {
					other.run(FlxAngle.angleBetween(other, p) - Math.PI);
				});
			}
		}

		var living:Int = 0;
		for (other in _playerGroup)
		{
			if (other.playerNumber > -1 && !other.dead) living++;
		}

		if (living <= 1)
		{
			for (other in _playerGroup)
			{
				if (other.playerNumber == -1 && !other.dead)
				{
					other.noEmit = true;
					other.kill();
					_playerGroup.remove(other);
				}
			}

			var t:FlxText = new FlxText();
			t.text = "Game over";
			t.alignment = FlxTextAlign.CENTER;
			t.size = 20;
			t.x = FlxG.width / 2 - t.width / 2;
			t.y = 200;
			add(t);
			new FlxTimer().start(5, 
					function(t:FlxTimer){FlxG.switchState(new MenuState());});
			return;
		}

	}
}
