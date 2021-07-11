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

class Laser extends Entity {
    public var display:Sprite;
	public var collision:CollisionBox;
	public var laserCollision:CollisionGroup;
	public var on:Bool = true;
	var facingDir:FastVector2 = new FastVector2(0,-1);

    public function new(x:Float,y:Float,groupCollision:CollisionGroup) {
        super();
		display = new Sprite("laser");
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
        laserCollision=new CollisionGroup();
		
    }

    override function update(dt:Float) {
		if (on){
			shoot();
			CollisionEngine.overlap(GlobalGameData.worldMap.collision,laserCollision,laserOnWall);
			collideLaser(GlobalGameData.chell.collision, laserCollision);
		}
		
		super.update(dt);
	}


	inline function shoot() {
		var laserBeam:LaserBeam = new LaserBeam(collision.x + collision.width * 0.5, collision.y+ collision.height *0.5+3, facingDir,laserCollision);
		addChild(laserBeam);
	}

	function collideLaser(chellC:ICollider, projectionsC:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		var c:Bool = chellC.collide(projectionsC, aCallBack);
		if (c){
			GlobalGameData.chell.damage();
		}
		return c;
	}

	function chellVsLaser(chellC:ICollider,laserC:ICollider){
		GlobalGameData.chell.damage();
	}

	function laserOnWall(wallC:ICollider, laserC:ICollider) {
		var currentLaser:Bullet = cast laserC.userData;
		currentLaser.destroy();
	}
	

    override function render() {
		super.render();
        
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		on = false;
		laserCollision.clear();
		super.destroy();
		//display.removeFromParent();
        collision.removeFromParent();
	}

}