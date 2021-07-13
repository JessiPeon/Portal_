package states;

import com.gEngine.display.extra.TileMapDisplay;
import com.gEngine.display.Camera;
import com.collision.platformer.CollisionGroup;
import kha.input.KeyCode;
import gameObjects.BluePortal;
import gameObjects.OrangePortal;
import com.collision.platformer.Tilemap;
import com.gEngine.display.Layer;
import gameObjects.Chell;

class GlobalGameData {
	static public var simulationLayer:Layer;
	static public var roomFinal:String = "2";
	static public var chell:Chell;
	static public var worldMap:Tilemap;
	static public var bluePortal:BluePortal = null;
	static public var orangePortal:OrangePortal = null;
	static public var gatewayCollision:CollisionGroup;
	static public var blue:KeyCode = KeyCode.Q; 
	static public var orange:KeyCode = KeyCode.E; 
	static public var action:KeyCode = KeyCode.R;
	static public var camera:Camera;
	static public var bloqPortalMap:TileMapDisplay;
    //static public var screenWidth:Int = 1280;
    //static public var screenHeight:Int = 720;

	static public function destroy() {
		simulationLayer = null;
	}
}


