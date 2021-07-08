package gameObjects;

import kha.input.KeyCode;
import com.collision.platformer.CollisionGroup;
import states.GlobalGameData;
import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.helpers.RectangleDisplay;
import com.framework.utils.Entity;
import com.gEngine.display.Sprite;

class Projection extends Entity {
	var display:RectangleDisplay;
	public var collision:CollisionBox;
	public var portal:KeyCode;
	var width:Int = 5;
	var height:Int = 5;
	var speed:Float = 1000;
	var time:Float = 0;

	public function new(x:Float, y:Float, dir:FastVector2,pressedKey:KeyCode,collisionGroup:CollisionGroup) {
		super();
		display = new RectangleDisplay();
		display.setColor(255, 255, 255);
		display.scaleX = width;
		display.scaleY = height;
		GlobalGameData.simulationLayer.addChild(display);
		portal = pressedKey;
		collision = new CollisionBox();
		collision.width = width;
		collision.height = height;
		collision.x = x - width * 0.5;
		collision.y = y - height * 0.5;
		collision.velocityX = dir.x * speed;
		collision.velocityY = dir.y * speed;
        collision.userData=this;
        collisionGroup.add(collision);
	}

	override function update(dt:Float) {
		time += dt;
		super.update(dt);
		collision.update(dt);
		if (time > 4) {
			die();
		}
	}

	override function render() {
		super.render();
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
        collision.removeFromParent();
	}
}