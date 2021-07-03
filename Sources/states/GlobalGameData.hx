package states;

import com.gEngine.display.Layer;

class GlobalGameData {
	static public var simulationLayer:Layer;
	static public var roomFinal:String = "1";
    //static public var screenWidth:Int = 1280;
    //static public var screenHeight:Int = 720;

	static public function destroy() {
		simulationLayer = null;
	}
}


