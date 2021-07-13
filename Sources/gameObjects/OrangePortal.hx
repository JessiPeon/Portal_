package gameObjects;

import haxe.Constraints.IMap;
import kha.graphics5_.AccelerationStructure;
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

class OrangePortal extends Portal  {
    /*public var display:RectangleDisplay;
	public var collision:CollisionBox;
	public var detect:Bool;
	var facingDir:FastVector2;
	var facingDir2:FastVector2;
	var death:Bool;*/

    public function new(x:Float,y:Float,groupCollision:CollisionGroup,side:Int) {
		super(x,y,groupCollision,side);

		//display = new Sprite("torreta");
		
		//display.setColor(0, 0, 255);
		this.display.setColor(255, 165, 0);
		/*facingDir = new FastVector2(-1,0);
		facingDir2 = new FastVector2(-1,0);
		death = false;
		//display = new Sprite("torreta");
		display = new RectangleDisplay();
		display.setColor(0, 0, 255);
		display.scaleX = 10;
		display.scaleY = 10;
		GlobalGameData.simulationLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.x=x;
		collision.y=y;

		groupCollision.clear();
		groupCollision.add(collision);
		collision.userData = this;*/
		
    }
/*
	function update(dt:Float) {
		super.update(dt);
	}


   function render() {
		super.render();
	}

	override function destroy() {
		super.destroy();
	}*/
}