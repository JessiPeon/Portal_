package gameObjects;

import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionEngine;
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
import com.gEngine.helpers.RectangleDisplay;

class OrangePortal extends Entity {
    public var display:RectangleDisplay;
	public var collision:CollisionBox;
	public var detect:Bool;
	var facingDir:FastVector2 = new FastVector2(-1,0);
	var facingDir2:FastVector2 = new FastVector2(-1,0);
	var death = false;

    public function new(x:Float,y:Float,groupCollision:CollisionGroup) {
        super();
		//display = new Sprite("torreta");
		display = new RectangleDisplay();
		display.setColor(255,165,0);
		display.scaleX = 10;
		display.scaleY = 10;
		GlobalGameData.simulationLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.x=x;
		collision.y=y;

		groupCollision.add(collision);
		collision.userData = this;
		
    }

    override function update(dt:Float) {


		super.update(dt);
	}

	

    override function render() {
		super.render();
		/*if (collision.isTouching(Sides.BOTTOM) && !death) {
			display.timeline.playAnimation("idle");
		}
        */
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
        collision.removeFromParent();
	}

}