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

class ButtonGateway extends Entity {
    public var display:Sprite;
	public var collision:CollisionBox;
	public var active:Bool = false;
	public var gateway:Gateway;


    public function new(x:Float,y:Float,groupCollision:CollisionGroup,gatewayP:Gateway) {
        super();
		display = new Sprite("boton2");
		display.smooth = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width()*2;
		collision.height = display.height();
		display.pivotX=display.width()*0.5;
		display.offsetY = 0;
		display.offsetX = display.width()*0.5;

        display.scaleX = display.scaleY = 1;
		collision.x=x;
		collision.y=y;
        collision.staticObject=true;
		groupCollision.add(collision);
		collision.userData = this;

		gateway= gatewayP;
		
    }

	override function update(dt:Float) {
		super.update(dt);

		
		collision.update(dt);		
	}



	override function render() {
		super.render();
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		super.destroy();
		//display.removeFromParent();
        collision.removeFromParent();
	}

}