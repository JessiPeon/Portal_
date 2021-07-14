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


    public function new(x:Float,y:Float,groupCollision:CollisionGroup,side:Int) {
		super(x,y,groupCollision,side);


		this.display.setColor(255, 165, 0);

    }

}