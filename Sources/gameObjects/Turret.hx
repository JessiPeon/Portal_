package gameObjects;

import com.framework.utils.Entity;
import com.framework.utils.Input;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import states.GlobalGameData;
import com.collision.platformer.CollisionGroup;
import kha.math.FastVector2;
import kha.input.KeyCode;

class Turret extends Entity {
    public var display:Sprite;
	public var collision:CollisionBox;
	//public var bulletsCollision:CollisionGroup;
	var facingDir:FastVector2 = new FastVector2(-1,0);
	var death = false;

    public function new(x:Float,y:Float,groupCollision:CollisionGroup) {
        super();
		display = new Sprite("torreta");
		display.smooth = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width()*0.5;
		collision.height = display.height()*0.5;
		display.pivotX=display.width()*0.5;
		display.offsetY = -display.height()*0.5;
		display.offsetX = -display.width()*0.25;

        display.scaleX = display.scaleY = 1;
		collision.x=x;
		collision.y=y;

		groupCollision.add(collision);
		collision.userData = this;

		collision.accelerationY = 2000;
		//collision.dragX = 0.9;
        //bulletsCollision=new CollisionGroup();
		
    }

    override function update(dt:Float) {

		//shoot();
		
		collision.update(dt);
		super.update(dt);
	}

	inline function shoot() {
		//if (Input.i.isKeyCodePressed(KeyCode.X)) {
			//var bullet:Bullet = new Bullet(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5, facingDir,bulletsCollision);
			//addChild(bullet);
		//}
	}

    override function render() {
        
		if (collision.isTouching(Sides.BOTTOM) && !death) {
			display.timeline.playAnimation("idle");
		}
        display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {//damage
        super.destroy();//animacion + death true
        display.removeFromParent();
        collision.removeFromParent();
    }

}