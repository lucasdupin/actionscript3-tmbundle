package
{

import flash.events.Event;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.display.StageAlign;

/**
 * Application entry point for ${TM_NEW_FILE_BASENAME}.
 * 
 * @langversion ActionScript 3.0
 * @playerversion Flash 10.0
 * 
 * @author ${TM_FULLNAME}
 * @since ${TM_DATE}
 */
public class Main extends Sprite
{
	
	/**
	 * @constructor
	 */
	public function Main()
	{
		if(stage)
			init();
		else
			stage.addEventListener( Event.ADDED_TO_STAGE, init );
	}

	/**
	 * Initialize stub.
	 */
	private function init(event:Event=null):void
	{
		stage.removeEventListener( Event.ADDED_TO_STAGE, init );
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		trace( "Main::initialize()" );
	}
	
}

}
