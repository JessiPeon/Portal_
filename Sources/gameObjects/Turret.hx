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

class Turret extends Entity {
    public var display:Sprite;
	public var collision:CollisionBox;
	public var bulletsCollision:CollisionGroup;
	public var detect:Bool;
	var facingDir:FastVector2 = new FastVector2(-1,0);
	var facingDir2:FastVector2 = new FastVector2(-1,0);
	var death = false;

    public function new(x:Float,y:Float,groupCollision:CollisionGroup) {
        super();
		display = new Sprite("torreta");
		display.smooth = false;
		detect = false;
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
        bulletsCollision=new CollisionGroup();
		
    }

    override function update(dt:Float) {

		
		if (!death){
			detectChell();
			collision.update(dt);
		}

		if (!collision.isTouching(Sides.BOTTOM)){
			display.timeline.playAnimation("falling",false);
		}

		CollisionEngine.overlap(GlobalGameData.chell.collision,bulletsCollision,chellVsBullet);
		CollisionEngine.overlap(GlobalGameData.gatewayCollision,bulletsCollision,deleteBullet);
		CollisionEngine.overlap(GlobalGameData.worldMap.collision,bulletsCollision,deleteBullet);

		super.update(dt);
	}

	inline function detectChell() {
		facingDir2.x = GlobalGameData.chell.collision.x - collision.x;
		facingDir2.y = GlobalGameData.chell.collision.y - collision.y;
		//facingDir.setFrom(facingDir.normalized());
		var dist:Float = Math.sqrt(facingDir2.x * facingDir2.x + facingDir2.y * facingDir2.y);
		if (dist < 400){
			shoot();
		}
	}

	inline function shoot() {
		var bullet:Bullet = new Bullet(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5, facingDir,bulletsCollision);
		addChild(bullet);
	}

	function chellVsBullet(chellC:ICollider, bulletC:ICollider) {
		var currentBullet:Bullet = cast bulletC.userData;
		GlobalGameData.chell.damage();
		currentBullet.destroy();
	}

	function deleteBullet(wallC:ICollider, bulletC:ICollider) {
		var currentBullet:Bullet = cast bulletC.userData;
		currentBullet.destroy();
	}
	

    override function render() {
		display.timeline.frameRate = 0.1;
		super.render();
		if (collision.isTouching(Sides.BOTTOM) && !death) {
			display.timeline.playAnimation("idle");
		}
        
		if (!death){
			display.x = collision.x;
			display.y = collision.y;
		}
	}

	public function damage() {
		bulletsCollision.clear();
		display.timeline.playAnimation("falling",false);
		display.timeline.playAnimation("fall",false);
		display.timeline.playAnimation("fall",false);
		display.timeline.playAnimation("fall",false);
        display.timeline.playAnimation("death",false);
		death = true;
        collision.removeFromParent();
    }


	public function fall() {
        display.timeline.playAnimation("death",false);
		death = true;
        collision.removeFromParent();
    }

}