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

class Cube extends Entity {
    public var display:Sprite;
	public var collision:CollisionBox;
	public var active:Bool = false;


    public function new(x:Float,y:Float,groupCollision:CollisionGroup) {
        super();
		display = new Sprite("cubo");
		display.smooth = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width()*2;
		collision.height = display.height()*2;
		display.pivotX=display.width()*0.5;
		display.offsetY = display.height()*0.5;
		display.offsetX = display.width()*0.5;

        display.scaleX = display.scaleY = 1;
		collision.x=x;
		collision.y=y;
        collision.staticObject=true;
		groupCollision.add(collision);
		collision.userData = this;
		
    }
/*
	public function new(x:Float,y:Float) {
        super();
		display = new Sprite("cubo");
		display.smooth = false;
		display.x=x;
		display.y=y;
		GlobalGameData.simulationLayer.addChild(display);

        display.scaleX = display.scaleY = 1;
		
    }
*/
	override function update(dt:Float) {
		
		super.update(dt);
		if (collision !=null){
			collision.update(dt);
		}
		
	}

	override function render() {
		super.render();
		display.timeline.playAnimation("idle",false);
		if (collision !=null){
			display.x = collision.x;
			display.y = collision.y;
		}
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
        collision.removeFromParent();
	}

}