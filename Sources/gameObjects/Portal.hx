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

class Portal extends Entity{
	public var display:RectangleDisplay;
	public var collision:CollisionBox;
	public var detect:Bool;
	public var side:Int;
	var facingDir:FastVector2;
	var facingDir2:FastVector2;
	var death:Bool;

	public function new(x:Float,y:Float,groupCollision:CollisionGroup,sideP:Int) {
        super();

		facingDir = new FastVector2(-1,0);
		facingDir2 = new FastVector2(-1,0);
		death = false;
		//display = new Sprite("torreta");
		display = new RectangleDisplay();
		
		//display.setColor(0, 0, 255);
		display.scaleX = display.scaleY = 10;
		GlobalGameData.simulationLayer.addChild(display);
		side = sideP;
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.x=x;
		collision.y=y;
		collision.staticObject=true;
		groupCollision.clear();
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