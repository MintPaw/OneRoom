package;

import flixel.*;
import flixel.math.*;
import flixel.tweens.*;
import flixel.effects.particles.*;
import flixel.util.*;

class Player extends FlxSprite
{
	public var playerNumber:Int = -1;
	public var attackCallback:Dynamic;
	public var keys:Dynamic;
	public var dead:Bool = false;
	public var emitter:FlxEmitter;
	public var flashEmitter:FlxEmitter;
	public var noEmit:Bool = false;
	public var leaving:Bool = false;
	
	private var _attackCooldown:Float = 0;
	private var _aiChangeCooldown:Float = 0;
	private var _runCooldown:Float = 0;
	private var _runDir:Float;
	private var _specials:Int = 1;

	public function new(playerNumber)
	{
		super();
		this.playerNumber = playerNumber;
		emitter = new FlxEmitter(0, 0, 0);
		emitter.lifespan.set(0.5, 0.5);

		if (playerNumber != -1) {
			flashEmitter = new FlxEmitter();
			flashEmitter.lifespan.set(1, 1);
		}

		makeGraphic(30, 30, Reg.rnd.int(0xFF000000, 0xFFFFFFFF));
		drag.set(10000, 10000);

		keys = {};
		keys.left = keys.right = keys.up = keys.down = false;
		keys.a = keys.b = keys.c = false;
	}

	public override function update(elapsed:Float):Void
	{
		emitter.x = x + width/2;
		emitter.y = y + height/2;

		if (flashEmitter != null) {
			flashEmitter.x = x + width/2;
			flashEmitter.y = y + height/2;
		}

		if (dead)
		{
			velocity.set();
			acceleration.set();
			return;
		}

		if (_runCooldown > 0 || keys.c)
			maxVelocity.set(200, 200);
		else
			maxVelocity.set(100, 100);

		if (_runCooldown > 0) _runCooldown -= elapsed;

		if (leaving) {
			super.update(elapsed);
			return;
		}

		if (_runCooldown > 2)
		{
			velocity =
				FlxVelocity.velocityFromAngle(_runDir * FlxAngle.TO_DEG, maxVelocity.x*2);
			acceleration.set();
			super.update(elapsed);
			return;
		}

		if (playerNumber > -1)
		{
			keys = Reg.playerKeys[playerNumber];
		}
		else
		{
			if (_aiChangeCooldown > 0)
			{
				_aiChangeCooldown -= FlxG.elapsed;
			}
			else 
			{
				_aiChangeCooldown = Reg.rnd.float(1, 7);
				keys.left = Reg.rnd.bool();
				keys.right = Reg.rnd.bool();
				keys.up = Reg.rnd.bool();
				keys.down = Reg.rnd.bool();

				if (Reg.rnd.float(0, 10) == 0)
					keys.left = keys.right = keys.up = keys.down = false;
			}

			{ // bounce off walls
				if (isTouching(FlxObject.LEFT) && keys.left)
				{
					keys.left = false;
					keys.right = true;
				}
				if (isTouching(FlxObject.RIGHT) && keys.right)
				{
					keys.right = false;
					keys.left = true;
				}
				if (isTouching(FlxObject.UP) && keys.up)
				{
					keys.up = false;
					keys.down = true;
				}
				if (isTouching(FlxObject.DOWN) && keys.down)
				{
					keys.down = false;
					keys.up = true;
				}
			}
		}

		super.update(elapsed);

		if (_attackCooldown > 0)
		{
			_attackCooldown -= elapsed;
			velocity = FlxVelocity.velocityFromFacing(this, _attackCooldown * 500);
			return;
		}

		if (keys.a && _attackCooldown <= 0)
		{
			Reg.playEffect("slash");
			emitter.makeParticles(2, 2, 0xFF6666FF, 10);
			emitter.start(false, 0.05, 10);
			attackCallback(this);
			_attackCooldown = 0.5;
		}

		if (keys.b && _specials >= 1) {
			_specials--;
			flashEmitter.makeParticles(2, 2, 0xFF999999, 100);
			flashEmitter.start(false, 0.02, 100);
			Reg.playEffect("flashFuse");

			new FlxTimer().start(2, function(t:FlxTimer) {
				Reg.playEffect("flash");
				FlxG.camera.flash(0xFFFFFFFF, 10, true);
			});
		}

		acceleration.set();
		var speed:Int = 10000;
		if (keys.left) acceleration.x -= speed;
		if (keys.right) acceleration.x += speed;
		if (keys.up) acceleration.y -= speed;
		if (keys.down) acceleration.y += speed;

		if (keys.left) facing = FlxObject.LEFT;
		if (keys.right) facing = FlxObject.RIGHT;
		if (keys.up) facing = FlxObject.UP;
		if (keys.down) facing = FlxObject.DOWN;
	}

	override public function kill():Void
	{
		dead = true;
		if (!noEmit) for (p in emitter) emitter.remove(p);

		if (playerNumber == -1) {
			Reg.playEffect("hit");
			if (!noEmit) {
				emitter.makeParticles(2, 2, 0xFFFF0000, 10);
				emitter.start(true, 0, 10);
			}

			FlxTween.tween(this, {alpha:0}, 1,
					{onComplete: function(t:FlxTween){reallyKill();}});
		} else {
			Reg.playEffect("playerHit");
			if (!noEmit) {
				emitter.makeParticles(8, 8, 0x88FF0000, 30);
				emitter.start(true, 0, 30);
			}

			FlxTween.tween(this, {alpha:0}, 3);
			FlxTween.tween(this.scale, {x:2, y:2}, 3,
					{onComplete: function(t:FlxTween){reallyKill();}});
		}
	}

	public function run(dir:Float):Void
	{
		_runCooldown = Reg.rnd.float(4, 6);
		_runDir = dir;
	}

	private function reallyKill():Void
	{
		super.kill();
	}

	public function leave():Void
	{
		leaving = true;
		allowCollisions = FlxObject.NONE;
		keys.left = keys.right = keys.up = keys.down = false;

		var dir:Int = Reg.rnd.int(0, 4);
		if (dir == 0) keys.left = true;
		if (dir == 1) keys.right = true;
		if (dir == 2) keys.up = true;
		if (dir == 3) keys.down = true;

		new FlxTimer().start(20, function(t:FlxTimer){reallyKill();});
	}

}
