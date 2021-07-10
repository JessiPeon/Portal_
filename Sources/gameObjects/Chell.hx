package gameObjects;

import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionEngine;
import kha.input.KeyCode;
import com.collision.platformer.CollisionGroup;
import kha.math.FastVector2;
import com.framework.utils.Input;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import states.GlobalGameData;

class Chell extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var projectionCollision:CollisionGroup;
	public var blueCollision:CollisionGroup;
	public var orangeCollision:CollisionGroup;
	public var bluePortal:BluePortal;
	 var orangePortal:OrangePortal = null;
	var maxSpeed = 400;
	var facingDir:FastVector2 = new FastVector2(1,0);
	static var maxLife = 10000;
	var life = maxLife;

	//var lastWallGrabing:Float=0;
	var sideTouching:Int;

	public function new(x:Float,y:Float) {
		super();
		display = new Sprite("hero");
		display.smooth = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height()*0.5;
		display.pivotX=display.width()*0.5;
		display.offsetY = -display.height()*0.5;
		
		display.scaleX = -1;
		display.scaleY = 1;
		collision.x=x;
		collision.y=y;

		collision.userData = this;
		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
		
		projectionCollision=new CollisionGroup();
		blueCollision=new CollisionGroup();
		orangeCollision=new CollisionGroup();
	}

	override function update(dt:Float) {

		shoot();
		super.update(dt);
		if (life < maxLife && life > 0){
			life += 1;
		}
		CollisionEngine.overlap(GlobalGameData.worldMap.collision,projectionCollision,portalOnWall);
		if (bluePortal != null && orangePortal != null){
			CollisionEngine.overlap(collision,orangeCollision,chellVsOrangePortal);
			CollisionEngine.overlap(collision,blueCollision,chellVsBluePortal);
		}
		CollisionEngine.overlap(GlobalGameData.gatewayCollision,projectionCollision,deleteProyection);
		collision.update(dt);

	}

	inline function shoot() {
		if (Input.i.isKeyCodePressed(GlobalGameData.blue)) {
			var projection:Projection = new Projection(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5, facingDir,GlobalGameData.blue,projectionCollision);
			addChild(projection);
		}

		if (Input.i.isKeyCodePressed(GlobalGameData.orange)) {
			var projection:Projection = new Projection(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5, facingDir,GlobalGameData.orange,projectionCollision);
			addChild(projection);
		}
	}

	inline function portalOnWall(worldC:ICollider,projectionsC:ICollider){
		//var currentTile:CollisionTileMap = cast GlobalGameData.worldMap.collision.userData;
		var currentProjection:Projection = cast projectionsC.userData;
		
		var side:Int = 99;
		
		if (currentProjection.collision.isTouching(Sides.BOTTOM)) {
			side = Sides.BOTTOM;
		} else
		if (currentProjection.collision.isTouching(Sides.TOP)) {
			side = Sides.TOP;
		} else
		if (currentProjection.collision.isTouching(Sides.LEFT)) {
			side = Sides.LEFT;
		} else
		if (currentProjection.collision.isTouching(Sides.RIGHT)) {
			side = Sides.RIGHT;
		} 

		
		var posX:Float = currentProjection.collision.lastX;
		var posY:Float = currentProjection.collision.lastY;
		var portal:KeyCode = currentProjection.portal;
		if (portal == GlobalGameData.blue){
			if (GlobalGameData.bluePortal != null){
				GlobalGameData.bluePortal.destroy();
			}
			bluePortal = new BluePortal(posX, posY,blueCollision,side);
			GlobalGameData.bluePortal = bluePortal;
			addChild(bluePortal);
		} else {
			if (GlobalGameData.orangePortal != null){
				GlobalGameData.orangePortal.destroy();
			}
			orangePortal = new OrangePortal(posX, posY,orangeCollision,side);
			GlobalGameData.orangePortal = orangePortal;
			addChild(orangePortal);
		}
		

		currentProjection.destroy();
	}

	inline function sidePortal(proj:Projection){
		var side:Int = Sides.BOTTOM;
		/*if (proj.collision.isTouching(Sides.BOTTOM)) {
			
		} else*/
		if (proj.collision.isTouching(Sides.TOP)) {
			side = Sides.TOP;
		} else
		if (proj.collision.isTouching(Sides.LEFT)) {
			side = Sides.LEFT;
		} else
		if (proj.collision.isTouching(Sides.RIGHT)) {
			side = Sides.RIGHT;
		} 
		return side;
	}

	function chellVsOrangePortal(chellC:ICollider, orangePortalC:ICollider) {
		if(GlobalGameData.bluePortal.side == Sides.LEFT){
			collision.accelerationX = maxSpeed;
		} else
		if(GlobalGameData.bluePortal.side == Sides.RIGHT){
			collision.accelerationX = -maxSpeed;
		} 
		
		var posXFin:Float = GlobalGameData.bluePortal.collision.x;
		var posYFin:Float = GlobalGameData.bluePortal.collision.y;
		changePosition(posXFin,posYFin);
	}

	function chellVsBluePortal(chellC:ICollider, bluePortalC:ICollider) {
		if(GlobalGameData.orangePortal.side == Sides.LEFT){
			collision.accelerationX = maxSpeed;
		} else
		if(GlobalGameData.orangePortal.side == Sides.RIGHT){
			collision.accelerationX = -maxSpeed;
		} 
		var posXFin:Float = GlobalGameData.orangePortal.collision.x;
		var posYFin:Float = GlobalGameData.orangePortal.collision.y;
		changePosition(posXFin,posYFin);
	}

	inline function changePosition(posXFin:Float,posYFin:Float) {
		collision.x=posXFin;
		collision.y=posYFin;
	}

	function deleteProyection(gatewayC:ICollider,projectionsC:ICollider){
		var currentProjection:Projection = cast projectionsC.userData;
		currentProjection.destroy();
	}

	override function render() {
		super.render();
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		/*if (isWallGrabing()) {
			display.timeline.playAnimation("wallGrab");
		} else*/
		if (collision.isTouching(Sides.BOTTOM) && collision.velocityX * collision.accelerationX < 0) {
			display.timeline.playAnimation("slide");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("run");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY > 0) {
			display.timeline.playAnimation("fall");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("jump");
		}
		display.x = collision.x;
		display.y = collision.y;
		
	}

	public function getVida() {
		return life;
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed;
				display.scaleX = Math.abs(display.scaleX);
				facingDir.x = -1;

			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.accelerationX = maxSpeed;
				display.scaleX = -Math.abs(display.scaleX);
				facingDir.x = 1;
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM)) {
					collision.velocityY = -1000;
				}
			}
		}
		
	}

	public function damage() {
		//display.timeline.playAnimation("fall",false);/
		life = life - 50;
    }
/*
	inline function isWallGrabing():Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}
*/
	public function onAxisChange(id:Int, value:Float) {

	}
}
