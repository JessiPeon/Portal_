package states;
import com.soundLib.SoundManager.SM;
import com.loading.basicResources.SoundLoader;
import com.loading.basicResources.ImageLoader;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import gameObjects.Turret;
import com.gEngine.display.Sprite;
import format.tmx.Data.TmxTileLayer;
import com.collision.platformer.CollisionBox;
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
import com.gEngine.helpers.Screen;


class EndGame extends State {
	var worldMap:Tilemap;
	var chell:Chell;
	var simulationLayer:Layer;
	var creditsZone:CollisionBox;
	var text:Text;
	var cake:Sprite;
	var touchJoystick:VirtualGamepad; //temp
	var soundOn:Bool = true;

	override function load(resources:Resources) {
		resources.add(new DataLoader("roomFinal_tmx"));
		var atlas = new JoinAtlas(2048, 2048);
		
		atlas.add(new FontLoader("Kenney_Thick",20));
		atlas.add(new TilesheetLoader("tilesPortal", 32, 32, 0));
		atlas.add(new SpriteSheetLoader("chell", 45, 60, 0, [
			new Sequence("fall", [0]),
			new Sequence("slide", [1]),
			new Sequence("jump", [0]),
			new Sequence("run", [2, 3, 4, 5, 6, 7]),
			new Sequence("idle", [10])
		]));
		atlas.add(new ImageLoader("cake"));
		atlas.add(new ImageLoader("portalNaranja"));
		atlas.add(new ImageLoader("portalAzul"));
		//atlas.add(new SpriteSheetLoader("cake", 45, 45, 0,[new Sequence("idle", [0])]) );
		resources.add(atlas);
		resources.add(new SoundLoader("orangePortal"));
		resources.add(new SoundLoader("bluePortal"));
		resources.add(new SoundLoader("StillAlive",false));
	}

	override function init() {
		stageColor(0.5, .5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);

		GlobalGameData.simulationLayer = simulationLayer;

		worldMap = new Tilemap("roomFinal_tmx");
		worldMap.init(parseTileLayers, parseMapObjects);

		text=new Text("Kenney_Thick");
		text.x = Screen.getWidth()*0.5-50;
		text.y = Screen.getHeight()*0.5;
		text.text="";
		text.smooth=false;
		stage.addChild(text);

		stage.defaultCamera().limits(32*2, 0, worldMap.widthIntTiles * 32 - 4*32, worldMap.heightInTiles * 32 );
		GlobalGameData.camera = stage.defaultCamera();
		SM.stopMusic();
		//temporal hasta poner camino
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
				addChild(chell);
			}
		}else
		if(compareName(object,"creditsZone"))
		{
			creditsZone=new CollisionBox();
			creditsZone.x=object.x;
			creditsZone.y=object.y;
			creditsZone.width=object.width;
			creditsZone.height=object.height;
		}else
		if(compareName(object,"cake")){
			cake=new Sprite("cake");
			cake.x=object.x-object.width*0.15;
			cake.y=object.y-object.height;
			cake.smooth=false;
			stage.addChild(cake);
		}
	}
	inline function compareName(object:TmxObject,name:String) {
		return object.name.toLowerCase() == name.toLowerCase();
	}

	override function update(dt:Float) {
		super.update(dt);

		CollisionEngine.collide(chell.collision,worldMap.collision);
		if(CollisionEngine.overlap(chell.collision,creditsZone)){
			cake.visible = false;
			text.text="The Cake is a Lie";
			//soundOn = true;
			if (soundOn){
				SM.playMusic("StillAlive");
				soundOn = false;
			}
		}
		if(Input.i.isKeyCodePressed(GlobalGameData.action) && !cake.visible){
			this.changeState(new StartGame());
		 }
		
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end
}
