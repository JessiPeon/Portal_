package gameObjects;

import com.collision.platformer.CollisionGroup;
import kha.math.FastVector2;
import com.framework.utils.Input;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import states.GlobalGameData;

class Chell extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var bulletsCollision:CollisionGroup;//
	var maxSpeed = 200;
	var facingDir:FastVector2 = new FastVector2(1,0);

	//var lastWallGrabing:Float=0;
	var sideTouching:Int;

	public function new(x:Float,y:Float) {
		super();
		display = new Sprite("hero");
		display.smooth = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height()*0.5;
		display.pivotX=display.width()*0.5;
		display.offsetY = -display.height()*0.5;
		
		display.scaleX = display.scaleY = 1;
		collision.x=x;
		collision.y=y;

		collision.userData = this;
		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
		
		bulletsCollision=new CollisionGroup();
		
		var bullet:Bullet = new Bullet(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5, facingDir,bulletsCollision);
		addChild(bullet);
	}

	override function update(dt:Float) {
		
		//shoot();
		
		super.update(dt);
		
		collision.update(dt);

	}

	inline function shoot() {
			
			var bullet:Bullet = new Bullet(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5, facingDir,bulletsCollision);
			addChild(bullet);
	}

	override function render() {
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		/*if (isWallGrabing()) {
			display.timeline.playAnimation("wallGrab");
		} else*/
		if (collision.isTouching(Sides.BOTTOM) && collision.velocityX * collision.accelerationX < 0) {
			display.timeline.playAnimation("slide");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("run");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY > 0) {
			display.timeline.playAnimation("fall");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("jump");
		}
		display.x = collision.x;
		display.y = collision.y;
		
	}

	

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed * 4;
				display.scaleX = Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM)) {
					collision.velocityY = -1000;
				} else {				
					collision.velocityY = -1000;
				}
			}
		}
		
	}

	inline function isWallGrabing():Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}

	public function onAxisChange(id:Int, value:Float) {

	}
}
