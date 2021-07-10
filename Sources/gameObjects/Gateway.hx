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

class Gateway extends Entity {
    public var display:Sprite;
	public var collision:CollisionBox;
	public var open:Bool;

    public function new(x:Float,y:Float,groupCollision:CollisionGroup) {
        super();
		display = new Sprite("puerta");
		display.smooth = false;
		open = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width()*0.25;
		collision.height = display.height();
		display.pivotX=display.width()*0.5;
		display.offsetY = 0;
		display.offsetX = -display.width()*0.39;

        display.scaleX = display.scaleY = 1;
		collision.x=x;
		collision.y=y;
        collision.staticObject=true;
		groupCollision.add(collision);
		collision.userData = this;
		
    }


    override function update(dt:Float) {
		super.update(dt);
        /*if (open) {
            display.timeline.playAnimation("open",false);
        }*/
        collision.update(dt);
	}
	
	override function render() {
		super.render();
        if (!open) {
            display.timeline.playAnimation("idle");
        } else {
            //display.visible = false;
        }
		//
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
        collision.removeFromParent();
	}

    public function openGateway() {
        open = true;
        display.timeline.playAnimation("open",false);
		super.destroy();
        collision.removeFromParent();
	}

    public function closeGateway(groupCollision:CollisionGroup) {
        open = false;
		collision = new CollisionBox();
		collision.width = display.width()*0.25;
		collision.height = display.height();

		collision.x=display.x;
		collision.y=display.y;
        collision.staticObject=true;
		groupCollision.add(collision);
		collision.userData = this;
	}
}