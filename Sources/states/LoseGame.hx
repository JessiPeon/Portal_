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

class LoseGame extends State {

    override function load(resources:Resources) {
        var atlas=new JoinAtlas(512,512);
        atlas.add(new FontLoader("Kenney_Thick",20));
        resources.add(atlas);
    }

    override function init() {
        var text=new Text("Kenney_Thick");
        text.x = Screen.getWidth()*0.5-50;
        text.y = Screen.getHeight()*0.5;
        text.text="Game Over";
        stage.addChild(text);
    }
    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
           this.changeState(new GameState("1","0"));
        }
    }

}