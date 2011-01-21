package mx.core {
	import mx.controls.FlexNativeMenu;
	import flash.display.NativeWindow;
	import flash.events.MouseEvent;
	public class Window extends LayoutContainer implements IWindow {
		public function get alwaysInFront():Boolean;
		public function set alwaysInFront(value:Boolean):void;
		public function get closed():Boolean;
		public var controlBar:IUIComponent;
		public function get cursorManager():ICursorManager;
		public function get maxHeight():Number;
		public function set maxHeight(value:Number):void;
		public function get maximizable():Boolean;
		public function set maximizable(value:Boolean):void;
		public function get maxWidth():Number;
		public function set maxWidth(value:Number):void;
		public function get menu():FlexNativeMenu;
		public function set menu(value:FlexNativeMenu):void;
		public function get minHeight():Number;
		public function set minHeight(value:Number):void;
		public function get minimizable():Boolean;
		public function set minimizable(value:Boolean):void;
		public function get minWidth():Number;
		public function set minWidth(value:Number):void;
		public function get nativeWindow():NativeWindow;
		public function get resizable():Boolean;
		public function set resizable(value:Boolean):void;
		public function get showGripper():Boolean;
		public function set showGripper(value:Boolean):void;
		public function get showStatusBar():Boolean;
		public function set showStatusBar(value:Boolean):void;
		public function get showTitleBar():Boolean;
		public function set showTitleBar(value:Boolean):void;
		public function get status():String;
		public function set status(value:String):void;
		public function get statusBar():UIComponent;
		public function get statusBarFactory():IFactory;
		public function set statusBarFactory(value:IFactory):void;
		protected function get statusBarStyleFilters():Object;
		public function get systemChrome():String;
		public function set systemChrome(value:String):void;
		public function get title():String;
		public function set title(value:String):void;
		public function get titleBar():UIComponent;
		public function get titleBarFactory():IFactory;
		public function set titleBarFactory(value:IFactory):void;
		protected function get titleBarStyleFilters():Object;
		public function get titleIcon():Class;
		public function set titleIcon(value:Class):void;
		public function get transparent():Boolean;
		public function set transparent(value:Boolean):void;
		public function get type():String;
		public function set type(value:String):void;
		public function get visible():Boolean;
		public function set visible(value:Boolean):void;
		public function Window();
		public function activate():void;
		public function close():void;
		public static function getWindow(component:UIComponent):Window;
		public function maximize():void;
		public function minimize():void;
		protected function mouseDownHandler(event:MouseEvent):void;
		public function open(openWindowActive:Boolean = true):void;
		public function orderInBackOf(window:IWindow):Boolean;
		public function orderInFrontOf(window:IWindow):Boolean;
		public function orderToBack():Boolean;
		public function orderToFront():Boolean;
		public function restore():void;
	}
}
