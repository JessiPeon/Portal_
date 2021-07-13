package states;

import com.gEngine.display.StaticLayer;
import kha.FastFloat;
import com.loading.basicResources.ImageLoader;
import gameObjects.Gateway;
import gameObjects.OrangePortal;
import gameObjects.BluePortal;
import com.gEngine.helpers.Screen;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import kha.math.FastVector2;
import gameObjects.Turret;
import com.gEngine.display.Sprite;
import format.tmx.Data.TmxTileLayer;
import com.collision.platformer.CollisionBox;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.ICollider;
import gameObjects.Chell;
import gameObjects.ButtonGateway;
import gameObjects.ButtonLaser;
import gameObjects.Laser;
import gameObjects.Cube;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import states.EndGame;


class GameState extends State {
	var worldMap:Tilemap;
	var chell:Chell;
	var turret:Turret;
	var gateway:Gateway;
	var bluePortal:BluePortal;
	var orangePortal:OrangePortal;
	var buttonGateway:ButtonGateway;
	var buttonLaser:ButtonLaser;
	var laser:Laser;
	var cube:Cube;
	var simulationLayer:Layer;
	var hudLayer:StaticLayer;
	var touchJoystick:VirtualGamepad;
	//var tray:helpers.Tray;
	//var mayonnaiseMap:TileMapDisplay;
	var bloqPortalMap:TileMapDisplay;
	var room:String;
	var winZone:CollisionBox;
	var deathZone:CollisionBox;
	var zone2:CollisionBox;
	var back:CollisionBox;
	var turretCollision:CollisionGroup= new CollisionGroup();
	var gatewayCollision:CollisionGroup= new CollisionGroup();
	var buttonGatewayCollision:CollisionGroup= new CollisionGroup();
	var buttonLaserCollision:CollisionGroup= new CollisionGroup();
	var laserCollision:CollisionGroup= new CollisionGroup();
	var cubeCollision:CollisionGroup= new CollisionGroup();
	//var blueCollision:CollisionGroup= new CollisionGroup();
	// orangeCollision:CollisionGroup= new CollisionGroup();
	var text:Text;
	var displayCube:Sprite;


	public function new(room:String, fromRoom:String) {
		super();
		this.room=room;
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader("room"+room+"_tmx"));
		var atlas = new JoinAtlas(2048, 2048);

		//////////////////////////
        atlas.add(new FontLoader("Kenney_Thick",20));

		//////////////////////////////

		atlas.add(new TilesheetLoader("tilesPortal", 32, 32, 0));
		atlas.add(new SpriteSheetLoader("chell", 45, 60, 0, [
			new Sequence("fall", [0]),
			new Sequence("slide", [1]),
			new Sequence("jump", [0]),
			new Sequence("run", [2, 3, 4, 5, 6, 7]),
			new Sequence("idle", [10])
		]));
		atlas.add(new SpriteSheetLoader("torreta", 50, 60, 0, [
			new Sequence("idle", [0]),
			new Sequence("open", [1,2]),
			new Sequence("falling", [3]),
			new Sequence("detect", [0,4]),
			new Sequence("fall", [5,6,7]),
			new Sequence("death", [8,9,10,11])
		]));
		atlas.add(new SpriteSheetLoader("puerta", 50, 60, 0, [
			new Sequence("idle", [0]),
			new Sequence("open", [1,2,3,4,5,6,7,8,9]),
			new Sequence("close", [8,7,6,5,4,3,2,1,0])
		]));
		atlas.add(new ImageLoader("botonPuerta"));
		atlas.add(new ImageLoader("botonLaser"));
		atlas.add(new ImageLoader("laser"));
		atlas.add(new SpriteSheetLoader("cubo", 45, 45, 0, [
			new Sequence("idle", [0]),
			new Sequence("falling", [1])
		]));
		resources.add(atlas);
		
	}

	override function init() {
		stageColor(0.5, 0.5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		hudLayer = new StaticLayer();
		stage.addChild(hudLayer);

		////////////////////////////
		
		text=new Text("Kenney_Thick");
        text.x = Screen.getWidth()*0.5-50;
        text.y = Screen.getHeight()*0.5;
        text.text="";
        stage.addChild(text);

		////////////////////////////

		GlobalGameData.simulationLayer = simulationLayer;
		GlobalGameData.gatewayCollision = gatewayCollision;
		worldMap = new Tilemap("room"+room+"_tmx");
		worldMap.init(parseTileLayers, parseMapObjects);
		GlobalGameData.worldMap = worldMap;
		GlobalGameData.bloqPortalMap = bloqPortalMap;
		//tray = new Tray(mayonnaiseMap);
		displayCube= new Sprite("cubo");
		displayCube.smooth = false;
		displayCube.x=20;
		displayCube.y=20;
		displayCube.timeline.playAnimation("idle",false);
		displayCube.scaleX = displayCube.scaleY = 0.75;
		hudLayer.addChild(displayCube);
		hudLayer.visible=false;

		stage.defaultCamera().limits(32*2, 0, worldMap.widthIntTiles * 32 - 4*32, worldMap.heightInTiles * 32 -16 );
		GlobalGameData.camera = stage.defaultCamera();
		createTouchJoystick();
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.A);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.D);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.W);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.W);
		
		touchJoystick.notify(chell.onAxisChange, chell.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(chell.onAxisChange, chell.onButtonChange);
	}

	function parseTileLayers(layerTilemap:Tilemap, tileLayer:TmxTileLayer) {

		// mayonnaiseMap = layerTilemap.createDisplay(tileLayer);
		//simulationLayer.addChild(mayonnaiseMap);
		if (tileLayer.properties.exists("noPortal")){
			layerTilemap.createCollisions(tileLayer);
			bloqPortalMap=layerTilemap.createDisplay(tileLayer,new Sprite("tilesPortal"));
			simulationLayer.addChild(bloqPortalMap);
		} else {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer,new Sprite("tilesPortal")));
		}
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		if(compareName(object,"playerPosition")){
			if(chell==null){
				chell = new Chell(object.x, object.y);
				GlobalGameData.chell = chell;
				addChild(chell);
			}
		}else
		if(compareName(object,"winZone"))
		{
			winZone=new CollisionBox();
			winZone.x=object.x;
			winZone.y=object.y;
			winZone.width=object.width;
			winZone.height=object.height;
		}else
		if(compareName(object,"deathZone"))
			{
				deathZone=new CollisionBox();
				deathZone.x=object.x;
				deathZone.y=object.y;
				deathZone.width=object.width;
				deathZone.height=object.height;
			}else
		if(compareName(object,"zone2"))
		{
			zone2=new CollisionBox();
			zone2.x=object.x;
			zone2.y=object.y;
			zone2.width=object.width;
			zone2.height=object.height;
		}else
		if(compareName(object,"back"))
		{
			back=new CollisionBox();
			back.x=object.x;
			back.y=object.y;
			back.width=object.width;
			back.height=object.height;
			back.staticObject=false;
		}else
		if(compareName(object,"enemyZoneDer")){
			turret = new Turret(object.x, object.y,1,turretCollision);
			addChild(turret);
		}
		if(compareName(object,"enemyZoneIzq")){
			turret = new Turret(object.x, object.y,-1,turretCollision);
			addChild(turret);
		}
		if(compareName(object,"puerta")){
			gateway = new Gateway(object.x+2, object.y-2*object.height+1,gatewayCollision);
			addChild(gateway);
		}
		if(compareName(object,"botonPuerta")){
			buttonGateway = new ButtonGateway(object.x, object.y-object.height+1,buttonGatewayCollision,gateway);
			addChild(buttonGateway);
		}
		if(compareName(object,"botonLaser")){
			buttonLaser = new ButtonLaser(object.x, object.y-object.height+1,buttonLaserCollision,laser);
			addChild(buttonLaser);
		}
		if(compareName(object,"laser")){
			laser = new Laser(object.x, object.y-object.height*0.5,laserCollision);
			addChild(laser);
		}
		if(compareName(object,"cubo")){
			cube = new Cube(object.x, object.y-2*object.height,cubeCollision);
			addChild(cube);
		}
	}
	inline function compareName(object:TmxObject,name:String) {
		return object.name.toLowerCase() == name.toLowerCase();
	}

	override function update(dt:Float) {
		super.update(dt);
		//stage.defaultCamera().setTarget(chell.collision.x, chell.collision.y);
		#if DEBUGDRAW
		text.text = Std.string(chell.collision.accelerationX) + " " + Std.string(chell.collision.accelerationY)  + " - " +Std.string(Math.round(chell.collision.velocityX)) + " " + Std.string(Math.round(chell.collision.velocityY));
		#end

		if (chell.getVida() <= 0){
			changeState(new LoseGame());
		}

		if (chell.getCube){
			
			hudLayer.visible = true;
		}

		CollisionEngine.collide(chell.collision,worldMap.collision);
		CollisionEngine.collide(turretCollision,worldMap.collision);
		CollisionEngine.collide(gatewayCollision,chell.collision);
		if(CollisionEngine.overlap(chell.collision,winZone)){
			if(room == GlobalGameData.roomFinal){
				changeState(new EndGame());
			} else {
				var nuevaRoomInt:Int = cast room;
				nuevaRoomInt += 1;
				var nuevaRoom:String = cast nuevaRoomInt;
				changeState(new GameState(nuevaRoom,room));
			}
		}
		if(CollisionEngine.overlap(chell.collision,deathZone)){
			chell.death();
		}
		if(CollisionEngine.overlap(chell.collision,zone2)){
			//stage.defaultCamera().setTarget(chell.collision.x, chell.collision.y);
			stage.defaultCamera().setTarget(zone2.x+Screen.getWidth()*0.5, zone2.y);
			GlobalGameData.camera = stage.defaultCamera();
			chell.getCube = false;
			CollisionEngine.collide(chell.collision,back);
			back.staticObject=true;
			if (GlobalGameData.bluePortal != null){
				GlobalGameData.bluePortal.die();
			}
			if (GlobalGameData.orangePortal != null){
				GlobalGameData.orangePortal.die();
			}
		}
		
		CollisionEngine.overlap(chell.collision,turretCollision,chellVsTurret);
		CollisionEngine.overlap(chell.collision,buttonGatewayCollision,chellVsButtonGateway);
		CollisionEngine.overlap(chell.collision,buttonLaserCollision,chellVsButtonLaser);
		CollisionEngine.overlap(chell.collision,cubeCollision,chellVsCube);
		

		//tray.setContactPosition(chell.collision.x + chell.collision.width / 2, chell.collision.y + chell.collision.height + 1, Sides.BOTTOM);
		//tray.setContactPosition(chell.collision.x + chell.collision.width + 1, chell.collision.y + chell.collision.height / 2, Sides.RIGHT);
		//tray.setContactPosition(chell.collision.x-1, chell.collision.y+chell.collision.height/2, Sides.LEFT);
	}

	function chellVsTurret(chellC:ICollider, turretC:ICollider) {
		var currentTurret:Turret = cast turretC.userData;
		currentTurret.damage();
	}
	inline function chellVsButtonGateway(chellC:ICollider,buttonC:ICollider){
		if (Input.i.isKeyCodePressed(GlobalGameData.action) && GlobalGameData.chell.getCube){
			var currentButton:ButtonGateway = cast buttonC.userData;
			var posX:FastFloat = currentButton.collision.x;
			var posY:FastFloat = currentButton.collision.y;
			var displayCube:Sprite = new Sprite("cubo");
			displayCube.smooth = false;
			displayCube.x=posX+20;
			displayCube.y=posY-15;
			displayCube.timeline.playAnimation("falling",false);
			displayCube.scaleX = displayCube.scaleY = 1;
			GlobalGameData.simulationLayer.addChild(displayCube);
			GlobalGameData.chell.getCube = false;
			hudLayer.visible = false;
			currentButton.gateway.openGateway();
			currentButton.destroy();
		}
	}
	inline function cubeVsButtonGateway(chellC:ICollider,buttonC:ICollider){
		var currentButton:ButtonGateway = cast buttonC.userData;
		currentButton.gateway.openGateway();
		currentButton.destroy();
	}
	inline function chellVsButtonLaser(chellC:ICollider,buttonC:ICollider){
		if (Input.i.isKeyCodePressed(GlobalGameData.action)){
			var currentButton:ButtonLaser = cast buttonC.userData;
			currentButton.laser.destroy();
			currentButton.destroy();
		}
	}
	inline function chellVsCube(chellC:ICollider,cubeC:ICollider){
		if (Input.i.isKeyCodePressed(GlobalGameData.action)){
			var currentCube:Cube = cast cubeC.userData;
			GlobalGameData.chell.getCube = true;
			currentCube.destroy();
		}
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var cameraAux = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, cameraAux);
	}
	#end
}
