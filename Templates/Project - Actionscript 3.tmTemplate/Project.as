package
{

import flash.events.Event;
import flash.display.Sprite;

/**
 * Application entry point for ${TM_NEW_FILE_BASENAME}.
 * 
 * @langversion ActionScript 3.0
 * @playerversion Flash 10.0
 * 
 * @author ${TM_FULLNAME}
 * @since ${TM_DATE}
 */
public class ${TM_NEW_FILE_BASENAME} extends Sprite
{
	
	/**
	 * @constructor
	 */
	public function ${TM_NEW_FILE_BASENAME}()
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
		trace( "${TM_NEW_FILE_BASENAME}::initialize()" );
	}
	
}

}
