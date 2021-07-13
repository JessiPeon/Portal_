package gameObjects;

import js.lib.webassembly.Global;
import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionEngine;
import com.collision.platformer.CollisionGroup;
import com.framework.utils.Input;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import states.GlobalGameData;
import kha.math.FastVector2;
import kha.input.KeyCode;

class Chell extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var projectionCollision:CollisionGroup;
	public var blueCollision:CollisionGroup;
	public var orangeCollision:CollisionGroup;
	public var bluePortal:BluePortal = null;
	public var orangePortal:OrangePortal = null;
	public var getCube:Bool = false;
	var maxSpeed = 300;
	var facingDir:FastVector2 = new FastVector2(1,0);
	var facingDirProy:FastVector2 = new FastVector2(1,0);
	static var maxLife = 10000;
	var life = maxLife;
	var deadChell = false;
	var lastAccelerationX:Float;
	var lastAccelerationY:Float;
	//var lastWallGrabing:Float=0;
	var sideTouching:Int;
	var time:Float = 0;

	public function new(x:Float,y:Float) {
		super();
		display = new Sprite("chell");
		display.smooth = false;
		GlobalGameData.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width()*0.5;
		collision.height = display.height()*0.75;
		display.pivotX=display.width()*0.5;
		display.offsetX = -display.width()*0.1;
		display.offsetY = -display.height()*0.25;
		
		display.scaleX = 1;
		display.scaleY = 1;
		collision.x=x;
		collision.y=y;

		collision.userData = this;
		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.3;
		
		projectionCollision=new CollisionGroup();
		blueCollision=new CollisionGroup();
		orangeCollision=new CollisionGroup();
	}

	override function update(dt:Float) {

		shoot();
		super.update(dt);
		if (life < maxLife && life > 0 && !deadChell){
			life += 10;
		}
		var frenar = false;
		/*if (collision.accelerationX > 2*maxSpeed){
			//frenar=true;
			collision.accelerationX=2*maxSpeed;
			collision.dragX = 0.1;
		} else {
			collision.dragX = 0.3;
		}*/
		/*if (frenar){
			time += dt;
			if (time >= 1 ) {
				collision.accelerationX=maxSpeed;
				frenar=false;
			}
		}*/
		
		if (projectionCollision != null){
			collidePortalOnWall(GlobalGameData.worldMap.collision,projectionCollision,portalOnWall);
		}
		
		if (bluePortal != null && orangePortal != null){
			collideChellVsPortal(collision,orangeCollision,chellVsOrangePortal);
			collideChellVsPortal(collision,blueCollision,chellVsBluePortal);
		}
		lastAccelerationX = collision.accelerationX;
		lastAccelerationY = collision.accelerationY;
		CollisionEngine.overlap(GlobalGameData.gatewayCollision,projectionCollision,deleteProyection);
		collision.update(dt);

	}
	function collidePortalOnWall(worldC:ICollider, projectionsC:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		var c:Bool = worldC.collide(projectionsC, aCallBack);
		return c;
	}

	function collideChellVsPortal(chellC:ICollider, portalC:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		var c:Bool = chellC.collide(portalC, aCallBack);
		return c;
	}

	function shoot() {
		var mousePosition = GlobalGameData.camera.screenToWorld(Input.i.getMouseX(),Input.i.getMouseY());
		facingDirProy.x = mousePosition.x - collision.x;
		facingDirProy.y = mousePosition.y - collision.y;
		facingDirProy.setFrom(facingDirProy.normalized());
		var projection:Projection = new Projection(collision.x + collision.width * 0.5, collision.y + collision.height * 0.25, facingDirProy,projectionCollision);
		addChild(projection);
	}

	function portalOnWall(worldC:ICollider,projectionsC:ICollider){
		var currentProjection:Projection = cast projectionsC.userData;
		var x:Int = Std.int( (currentProjection.collision.x + currentProjection.collision.width / 2) / 32) ;
		var y:Int = Std.int( (currentProjection.collision.y + currentProjection.collision.height + 1) / 32);
		var type:Int = GlobalGameData.bloqPortalMap.getTile(x, y);
		//if (type == 0){
			if (Input.i.isKeyCodePressed(GlobalGameData.orange) || Input.i.isKeyCodePressed(GlobalGameData.blue)){
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
				if (Input.i.isKeyCodePressed(GlobalGameData.blue)){
					if (GlobalGameData.bluePortal != null){
						GlobalGameData.bluePortal.die();
					}
					bluePortal = new BluePortal(posX, posY,blueCollision,side);
					GlobalGameData.bluePortal = bluePortal;
					addChild(bluePortal);
				} else {
					if (GlobalGameData.orangePortal != null){
						GlobalGameData.orangePortal.die();
					}
					orangePortal = new OrangePortal(posX, posY,orangeCollision,side);
					GlobalGameData.orangePortal = orangePortal;
					addChild(orangePortal);
				}
				
			}
		//}
		
		currentProjection.die();
	}


	function chellVsOrangePortal(chellC:ICollider, orangePortalC:ICollider) {
		var posXFin:Float = GlobalGameData.bluePortal.collision.x;
		var posYFin:Float = GlobalGameData.bluePortal.collision.y;
		if(GlobalGameData.bluePortal.side == Sides.LEFT){
			posXFin = posXFin  + 20;
		} else
		if(GlobalGameData.bluePortal.side == Sides.RIGHT){
			posXFin = posXFin - 55;
		} else
		if(GlobalGameData.bluePortal.side == Sides.TOP){
			posYFin = posYFin +15;
		} else
		if(GlobalGameData.bluePortal.side == Sides.BOTTOM){
			posYFin = posYFin -50;
		} 
		changePosition(posXFin,posYFin);
		changeDirection();

		
		
	}

	function chellVsBluePortal(chellC:ICollider, bluePortalC:ICollider) {
		var posXFin:Float = GlobalGameData.orangePortal.collision.x;
		var posYFin:Float = GlobalGameData.orangePortal.collision.y;
		if(GlobalGameData.orangePortal.side == Sides.LEFT){
			posXFin = posXFin  + 20;
		} else
		if(GlobalGameData.orangePortal.side == Sides.RIGHT){
			posXFin = posXFin - 55;
		} else
		if(GlobalGameData.orangePortal.side == Sides.TOP){
			posYFin = posYFin + 15;
		} 
		else
		if(GlobalGameData.orangePortal.side == Sides.BOTTOM){
			posYFin = posYFin -50;
		} 
		changePosition(posXFin,posYFin);
		changeDirection();
		
	}

	inline function changePosition(posXFin:Float,posYFin:Float) {
		collision.x=posXFin;
		collision.y=posYFin;
	}

	inline function changeDirection(){
		if ((((GlobalGameData.bluePortal.side == Sides.TOP) || (GlobalGameData.bluePortal.side == Sides.BOTTOM)) && ((GlobalGameData.orangePortal.side == Sides.LEFT)||(GlobalGameData.orangePortal.side == Sides.RIGHT) ) ) || 
			(((GlobalGameData.bluePortal.side == Sides.RIGHT) || (GlobalGameData.bluePortal.side == Sides.LEFT)) && ((GlobalGameData.orangePortal.side == Sides.BOTTOM)||(GlobalGameData.orangePortal.side == Sides.TOP))  )){
			collision.velocityX = collision.lastVelocityY;
			collision.velocityY = collision.lastVelocityX;
			collision.accelerationX = collision.lastVelocityY;
			//collision.accelerationY = lastAccelerationX;
		} else {
			collision.accelerationX = lastAccelerationX;
			collision.accelerationY = lastAccelerationY;
			collision.velocityX = collision.lastVelocityX;
			collision.velocityY = collision.lastVelocityY;
		}
		
		if(GlobalGameData.orangePortal.side == GlobalGameData.bluePortal.side){
			if ((GlobalGameData.bluePortal.side == Sides.TOP) || (GlobalGameData.bluePortal.side == Sides.BOTTOM)){
				collision.velocityY = collision.velocityY * (-1);
				facingDir.y = facingDir.y * (-1);
			} else {
				collision.velocityX = collision.velocityX * (-1);
				facingDir.x = facingDir.x * (-1);
				display.scaleX = display.scaleX*(-1);
			}
		}
	}

	function deleteProyection(gatewayC:ICollider,projectionsC:ICollider){
		var currentProjection:Projection = cast projectionsC.userData;
		currentProjection.die();
	}

	override function render() {
		super.render();
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
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
		if (facingDirProy.x < 0){
			display.scaleX = -Math.abs(display.scaleX);
		} else {
			display.scaleX = Math.abs(display.scaleX);
		}
		
	}

	public function getVida() {
		return life;
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD ) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed;
				display.scaleX = -Math.abs(display.scaleX);
				facingDir.x = -1;
				facingDirProy = facingDir;
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD ) {
			if (value == 1) {
				collision.accelerationX = maxSpeed;
				display.scaleX = Math.abs(display.scaleX);
				facingDir.x = 1;
				facingDirProy = facingDir;
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
		life = life - 200;
    }

	public function death() {
		//display.timeline.playAnimation("fall",false);/
		deadChell = true;
		life = life -500;
    }
/*
	inline function isWallGrabing():Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}
*/
	public function onAxisChange(id:Int, value:Float) {

	}
}
