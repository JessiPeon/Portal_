package states;

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
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import states.EndGame;
import states.StartGame;


class GameState extends State {
	var worldMap:Tilemap;
	var chell:Chell;
	var turret:Turret;
	var bluePortal:BluePortal;
	var orangePortal:OrangePortal;
	var simulationLayer:Layer;
	var touchJoystick:VirtualGamepad;
	//var tray:helpers.Tray;
	//var mayonnaiseMap:TileMapDisplay;
	var room:String;
	var winZone:CollisionBox;
	var turretCollision:CollisionGroup= new CollisionGroup();
	//var blueCollision:CollisionGroup= new CollisionGroup();
	// orangeCollision:CollisionGroup= new CollisionGroup();
	var portalCollision:CollisionGroup= new CollisionGroup();
	var text:Text;


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
		atlas.add(new SpriteSheetLoader("hero", 45, 60, 0, [
			new Sequence("fall", [0]),
			new Sequence("slide", [0]),
			new Sequence("jump", [1]),
			new Sequence("run", [2, 3, 4, 5, 6, 7, 8, 9]),
			new Sequence("idle", [10]),
			new Sequence("wallGrab", [11])
		]));
		atlas.add(new SpriteSheetLoader("torreta", 50, 60, 0, [
			new Sequence("idle", [0]),
			new Sequence("attack", [1,2]),
			new Sequence("falling", [3]),
			new Sequence("detect", [0,4]),
			new Sequence("fall", [5,6,7]),
			new Sequence("death", [8,9,10,11])
		]));
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, 0.5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);

		////////////////////////////
		
		text=new Text("Kenney_Thick");
        text.x = Screen.getWidth()*0.5-50;
        text.y = Screen.getHeight()*0.5;
        text.text="Vida: ";
        stage.addChild(text);

		////////////////////////////

		GlobalGameData.simulationLayer = simulationLayer;

		worldMap = new Tilemap("room"+room+"_tmx");
		worldMap.init(parseTileLayers, parseMapObjects);
		GlobalGameData.worldMap = worldMap;
		//tray = new Tray(mayonnaiseMap);
	

		stage.defaultCamera().limits(32*2, 0, worldMap.widthIntTiles * 32 - 4*32, worldMap.heightInTiles * 32 );

		createTouchJoystick();
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
		
		touchJoystick.notify(chell.onAxisChange, chell.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(chell.onAxisChange, chell.onButtonChange);
	}

	function parseTileLayers(layerTilemap:Tilemap, tileLayer:TmxTileLayer) {
		if (!tileLayer.properties.exists("noCollision")) {
			layerTilemap.createCollisions(tileLayer);
		}
		simulationLayer.addChild(layerTilemap.createDisplay(tileLayer,new Sprite("tilesPortal")));
		// mayonnaiseMap = layerTilemap.createDisplay(tileLayer);
		//simulationLayer.addChild(mayonnaiseMap);
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		if(compareName(object,"playerPosition")){
			if(chell==null){
				chell = new Chell(object.x, object.y);
				GlobalGameData.chell = chell;
				addChild(chell);
/*
				bluePortal = new BluePortal(object.x - 50, object.y+110,portalCollision);
				addChild(bluePortal);

				orangePortal = new OrangePortal(object.x + 150, object.y+110,portalCollision);
				addChild(orangePortal);*/
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
		if(compareName(object,"enemyZone")){
			turret = new Turret(object.x, object.y,turretCollision);
			addChild(turret);
		}

		
	}
	inline function compareName(object:TmxObject,name:String) {
		return object.name.toLowerCase() == name.toLowerCase();
	}

	override function update(dt:Float) {
		super.update(dt);
		//stage.defaultCamera().setTarget(chell.collision.x, chell.collision.y);
		//var life:Int = chell.getVida();
		text.text = Std.string(chell.getVida());

		if (chell.getVida() <= 0){
			changeState(new LoseGame());
		}

		CollisionEngine.collide(chell.collision,worldMap.collision);
		CollisionEngine.collide(turretCollision,worldMap.collision);
		CollisionEngine.collide(turretCollision,chell.collision);
		if(CollisionEngine.overlap(chell.collision,winZone)){
			if(room == GlobalGameData.roomFinal){
				changeState(new EndGame());
			} else {
				var nuevaRoomInt:Int = cast room;
				//nuevaRoomInt += 0;
				var nuevaRoom:String = cast nuevaRoomInt;
				changeState(new GameState(nuevaRoom,room));
			}
		}
		
		CollisionEngine.overlap(chell.collision,turretCollision,chellVsTurret);

		//CollisionEngine.overlap(chell.collision,portalCollision,chellVsPortal);

		

		//tray.setContactPosition(chell.collision.x + chell.collision.width / 2, chell.collision.y + chell.collision.height + 1, Sides.BOTTOM);
		//tray.setContactPosition(chell.collision.x + chell.collision.width + 1, chell.collision.y + chell.collision.height / 2, Sides.RIGHT);
		//tray.setContactPosition(chell.collision.x-1, chell.collision.y+chell.collision.height/2, Sides.LEFT);
	}

	function chellVsTurret(chellC:ICollider, turretC:ICollider) {
		var currentTurret:Turret = cast turretC.userData;
		currentTurret.damage();
	}

	function chellVsPortal(chellC:ICollider, portalC:ICollider) {
		/*if (bluePortal != null && orangePortal != null){

		}
		var currentTurret:Turret = cast portalC.userData;
		currentTurret.damage();*/
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end
}
