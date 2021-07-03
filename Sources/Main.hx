package;

import kha.WindowMode;
import kha.FramebufferOptions;
import kha.WindowOptions;
import kha.System;
import com.framework.Simulation;
import states.GameState;
import states.StartGame;
#if (kha_html5 && js)
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
import js.Browser.navigator;
#end

class Main {
	
	public static function main() {
		#if hotml new hotml.Client(); #end
		var windowsOptions=new WindowOptions("portal",0,0,1280,720,null,true,WindowFeatures.FeatureResizable,WindowMode.Windowed);
		var frameBufferOptions=new FramebufferOptions(60,true,32,16,8,0);
		//var state = new GameState("","");
		System.start(new SystemOptions("portal",1280,720,windowsOptions,frameBufferOptions), function (w) {
			new Simulation(StartGame,1280,720,1,0);
		});
	}

}
