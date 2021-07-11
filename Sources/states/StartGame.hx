package states;


import com.gEngine.display.Sprite;
import com.loading.basicResources.ImageLoader;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.gEngine.helpers.Screen;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import states.GameState;

class StartGame extends State {

    override function load(resources:Resources) {
        var atlas=new JoinAtlas(2048,2048);
        atlas.add(new ImageLoader("intro"));
        resources.add(atlas);
    }

    override function init() {
        var img:Sprite = new Sprite("intro");
        img.x=0;
        img.y=0;
		img.smooth = false;
        stage.addChild(img);
    }
    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
           this.changeState(new GameState("1","0"));
        }
    }

}