package com.gdx.tweens;



class TweenEvent 
{
	public static var START:String = "start";
	public static var UPDATE:String = "update";
	public static var FINISH:String = "finish";
	public static var ACTIVATE = "activate";
	public static var ADDED = "added";
	public static var ADDED_TO_STAGE = "addedToStage";
	public static var CANCEL = "cancel";
	public static var CHANGE = "change";
	public static var CLOSE = "close";
	public static var COMPLETE = "complete";
	public static var CONNECT = "connect";
	public static var CONTEXT3D_CREATE = "context3DCreate";
	public static var DEACTIVATE = "deactivate";
	public static var ENTER_FRAME = "enterFrame";
	public static var ID3 = "id3";
	public static var INIT = "init";
	public static var MOUSE_LEAVE = "mouseLeave";
	public static var OPEN = "open";
	public static var REMOVED = "removed";
	public static var REMOVED_FROM_STAGE = "removedFromStage";
	public static var RENDER = "render";
	public static var RESIZE = "resize";
	public static var SCROLL = "scroll";
	public static var SELECT = "select";
	public static var SOUND_COMPLETE = "soundComplete";
	public static var TAB_CHILDREN_CHANGE = "tabChildrenChange";
	public static var TAB_ENABLED_CHANGE = "tabEnabledChange";
	public static var TAB_INDEX_CHANGE = "tabIndexChange";
	public static var UNLOAD = "unload";
	
	public var bubbles (default, null):Bool;
	public var cancelable (default, null):Bool;
	public var currentTarget:Dynamic;

	public var target:Dynamic;
	public var type (default, null):String;
	
	private var __isCancelled:Bool;
	private var __isCancelledNow:Bool;
	
	public function new (type:String, bubbles:Bool = false, cancelable:Bool = false) {
		
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;

		
	}
	

	
	
	public function isDefaultPrevented ():Bool {
		
		return (__isCancelled || __isCancelledNow);
		
	}
	
	
	public function stopImmediatePropagation ():Void {
		
		__isCancelled = true;
		__isCancelledNow = true;
		
	}
	
	
	public function stopPropagation ():Void {
		
		__isCancelled = true;
		
	}
	
	
	public function toString ():String {
		
		return "[Event type=" + type + " bubbles=" + bubbles + " cancelable=" + cancelable + "]";
		
	}
	
}
