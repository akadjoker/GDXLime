package com.gdx;

import lime.app.Application;
import lime.audio.AudioSource;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.Assets;

import com.gdx.Gdx;
import com.gdx.input.Keys;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class App extends Application
{
   public var gdx:Gdx;
   private var start:Bool;
	public function new() 
	{
	    super ();
		
		start = false;
	}	
	
	public function OnStart():Void
	{
		
	}
	public function OnEnd():Void
	{
		
	}
	
	public override  function init (context:RenderContext):Void 
	{
    
		gdx = Gdx.Instance();	
		gdx.init(this.window.width, this.window.height);
		start = true;
		OnStart();
	}
	
	
	public override function onKeyDown (keyCode:Int, modifier:Int):Void
	{
		if (!start) return;
		var keyCode = convertKeyCode (cast keyCode);
	    gdx.onKeyDown(keyCode); 
	}
	public  override function onKeyUp (keyCode:Int, modifier:Int):Void
	{
     if (!start) return;
	 var keyCode = convertKeyCode (cast keyCode);
	 gdx.onKeyUp(keyCode); 
	}

	public override  function onMouseDown (x:Float, y:Float, button:Int):Void 
	{if (!start) return;gdx.mouseDown(x, y, button); }
	public  override function onMouseMove (x:Float, y:Float, button:Int):Void 
	{if (!start) return;gdx.mouseMove(x, y, button); }
	public  override function onMouseUp (x:Float, y:Float, button:Int):Void 
	{if (!start) return;gdx.mouseUp(x, y, button); }

	public  override function onTouchEnd (x:Float, y:Float, id:Int):Void 
	{if (!start) return;gdx.onTouchEnd(x, y, id); }
	public  override function onTouchMove (x:Float, y:Float, id:Int):Void 
	{if (!start) return;gdx.onTouchMove(x, y, id); }
	public  override function onTouchStart (x:Float, y:Float, id:Int):Void 
	{if (!start) return;gdx.onTouchBegin(x, y, id); }
	
	public override  function onWindowResize (width:Int, height:Int):Void 
	{if (!start) return;gdx.onresize(width, height); }

	public override  function onWindowFocusIn ():Void
	{if (!start) return;gdx.onShow(); }
	public override  function onWindowFocusOut ():Void 
	{if (!start) return;gdx.onHide(); }
	public  override function onWindowClose ():Void 
	{if (!start) return; gdx.onClose(); OnEnd(); }
		
	
	
	public override function render (context:RenderContext):Void
	{
		if (!start) return;
		gdx.render();	
		
	}
	public override function update (deltaTime:Int):Void
	{if (!start) return;
	 gdx.Update(deltaTime /1000);
	}
	
	private function convertKeyCode (keyCode:KeyCode):Int {
		
		return switch (keyCode) {
			
			case BACKSPACE: Keys.BACKSPACE;
			case TAB: Keys.TAB;
			case RETURN: Keys.ENTER;
			case ESCAPE: Keys.ESCAPE;
			case SPACE: Keys.SPACE;
			//case EXCLAMATION: 0x21;
			//case QUOTE: 0x22;
			//case HASH: 0x23;
			//case DOLLAR: 0x24;
			//case PERCENT: 0x25;
			//case AMPERSAND: 0x26;
			case SINGLE_QUOTE: Keys.QUOTE;
			//case LEFT_PARENTHESIS: 0x28;
			//case RIGHT_PARENTHESIS: 0x29;
			//case ASTERISK: 0x2A;
			//case PLUS: 0x2B;
			case COMMA: Keys.COMMA;
			case MINUS: Keys.MINUS;
			case PERIOD: Keys.PERIOD;
			case SLASH: Keys.SLASH;
			case NUMBER_0: Keys.NUMBER_0;
			case NUMBER_1: Keys.NUMBER_1;
			case NUMBER_2: Keys.NUMBER_2;
			case NUMBER_3: Keys.NUMBER_3;
			case NUMBER_4: Keys.NUMBER_4;
			case NUMBER_5: Keys.NUMBER_5;
			case NUMBER_6: Keys.NUMBER_6;
			case NUMBER_7: Keys.NUMBER_7;
			case NUMBER_8: Keys.NUMBER_8;
			case NUMBER_9: Keys.NUMBER_9;
			//case COLON: 0x3A;
			case SEMICOLON: Keys.SEMICOLON;
			//case LESS_THAN: 0x3C;
			case EQUALS: Keys.EQUAL;
			//case GREATER_THAN: 0x3E;
			//case QUESTION: 0x3F;
			//case AT: 0x40;
			case LEFT_BRACKET: Keys.LEFTBRACKET;
			case BACKSLASH: Keys.BACKSLASH;
			case RIGHT_BRACKET: Keys.RIGHTBRACKET;
			//case CARET: 0x5E;
			//case UNDERSCORE: 0x5F;
			case GRAVE: Keys.BACKQUOTE;
			case A: Keys.A;
			case B: Keys.B;
			case C: Keys.C;
			case D: Keys.D;
			case E: Keys.E;
			case F: Keys.F;
			case G: Keys.G;
			case H: Keys.H;
			case I: Keys.I;
			case J: Keys.J;
			case K: Keys.K;
			case L: Keys.L;
			case M: Keys.M;
			case N: Keys.N;
			case O: Keys.O;
			case P: Keys.P;
			case Q: Keys.Q;
			case R: Keys.R;
			case S: Keys.S;
			case T: Keys.T;
			case U: Keys.U;
			case V: Keys.V;
			case W: Keys.W;
			case X: Keys.X;
			case Y: Keys.Y;
			case Z: Keys.Z;
			case DELETE: Keys.DELETE;
			case CAPS_LOCK: Keys.CAPS_LOCK;
			case F1: Keys.F1;
			case F2: Keys.F2;
			case F3: Keys.F3;
			case F4: Keys.F4;
			case F5: Keys.F5;
			case F6: Keys.F6;
			case F7: Keys.F7;
			case F8: Keys.F8;
			case F9: Keys.F9;
			case F10: Keys.F10;
			case F11: Keys.F11;
			case F12: Keys.F12;
			//case PRINT_SCREEN: 0x40000046;
			//case SCROLL_LOCK: 0x40000047;
			//case PAUSE: 0x40000048;
			case INSERT: Keys.INSERT;
			case HOME: Keys.HOME;
			case PAGE_UP: Keys.PAGE_UP;
			case END: Keys.END;
			case PAGE_DOWN: Keys.PAGE_DOWN;
			case RIGHT: Keys.RIGHT;
			case LEFT: Keys.LEFT;
			case DOWN: Keys.DOWN;
			case UP: Keys.UP;
			//case NUM_LOCK_CLEAR: 0x40000053;
			case NUMPAD_DIVIDE: Keys.NUMPAD_DIVIDE;
			case NUMPAD_MULTIPLY: Keys.NUMPAD_MULTIPLY;
			case NUMPAD_MINUS: Keys.NUMPAD_SUBTRACT;
			case NUMPAD_PLUS: Keys.NUMPAD_ADD;
			case NUMPAD_ENTER: Keys.NUMPAD_ENTER;
			case NUMPAD_1: Keys.NUMPAD_1;
			case NUMPAD_2: Keys.NUMPAD_2;
			case NUMPAD_3: Keys.NUMPAD_3;
			case NUMPAD_4: Keys.NUMPAD_4;
			case NUMPAD_5: Keys.NUMPAD_5;
			case NUMPAD_6: Keys.NUMPAD_6;
			case NUMPAD_7: Keys.NUMPAD_7;
			case NUMPAD_8: Keys.NUMPAD_8;
			case NUMPAD_9: Keys.NUMPAD_9;
			case NUMPAD_0: Keys.NUMPAD_0;
			case NUMPAD_PERIOD: Keys.NUMPAD_DECIMAL;
			//case APPLICATION: 0x40000065;
			//case POWER: 0x40000066;
			//case NUMPAD_EQUALS: 0x40000067;
			case F13: Keys.F13;
			case F14: Keys.F14;
			case F15: Keys.F15;
			//case F16: 0x4000006B;
			//case F17: 0x4000006C;
			//case F18: 0x4000006D;
			//case F19: 0x4000006E;
			//case F20: 0x4000006F;
			//case F21: 0x40000070;
			//case F22: 0x40000071;
			//case F23: 0x40000072;
			//case F24: 0x40000073;
			//case EXECUTE: 0x40000074;
			//case HELP: 0x40000075;
			//case MENU: 0x40000076;
			//case SELECT: 0x40000077;
			//case STOP: 0x40000078;
			//case AGAIN: 0x40000079;
			//case UNDO: 0x4000007A;
			//case CUT: 0x4000007B;
			//case COPY: 0x4000007C;
			//case PASTE: 0x4000007D;
			//case FIND: 0x4000007E;
			//case MUTE: 0x4000007F;
			//case VOLUME_UP: 0x40000080;
			//case VOLUME_DOWN: 0x40000081;
			//case NUMPAD_COMMA: 0x40000085;
			////case NUMPAD_EQUALS_AS400: 0x40000086;
			//case ALT_ERASE: 0x40000099;
			//case SYSTEM_REQUEST: 0x4000009A;
			//case CANCEL: 0x4000009B;
			//case CLEAR: 0x4000009C;
			//case PRIOR: 0x4000009D;
			//case RETURN2: 0x4000009E;
			//case SEPARATOR: 0x4000009F;
			//case OUT: 0x400000A0;
			//case OPER: 0x400000A1;
			//case CLEAR_AGAIN: 0x400000A2;
			//case CRSEL: 0x400000A3;
			//case EXSEL: 0x400000A4;
			//case NUMPAD_00: 0x400000B0;
			//case NUMPAD_000: 0x400000B1;
			//case THOUSAND_SEPARATOR: 0x400000B2;
			//case DECIMAL_SEPARATOR: 0x400000B3;
			//case CURRENCY_UNIT: 0x400000B4;
			//case CURRENCY_SUBUNIT: 0x400000B5;
			//case NUMPAD_LEFT_PARENTHESIS: 0x400000B6;
			//case NUMPAD_RIGHT_PARENTHESIS: 0x400000B7;
			//case NUMPAD_LEFT_BRACE: 0x400000B8;
			//case NUMPAD_RIGHT_BRACE: 0x400000B9;
			//case NUMPAD_TAB: 0x400000BA;
			//case NUMPAD_BACKSPACE: 0x400000BB;
			//case NUMPAD_A: 0x400000BC;
			//case NUMPAD_B: 0x400000BD;
			//case NUMPAD_C: 0x400000BE;
			//case NUMPAD_D: 0x400000BF;
			//case NUMPAD_E: 0x400000C0;
			//case NUMPAD_F: 0x400000C1;
			//case NUMPAD_XOR: 0x400000C2;
			//case NUMPAD_POWER: 0x400000C3;
			//case NUMPAD_PERCENT: 0x400000C4;
			//case NUMPAD_LESS_THAN: 0x400000C5;
			//case NUMPAD_GREATER_THAN: 0x400000C6;
			//case NUMPAD_AMPERSAND: 0x400000C7;
			//case NUMPAD_DOUBLE_AMPERSAND: 0x400000C8;
			//case NUMPAD_VERTICAL_BAR: 0x400000C9;
			//case NUMPAD_DOUBLE_VERTICAL_BAR: 0x400000CA;
			//case NUMPAD_COLON: 0x400000CB;
			//case NUMPAD_HASH: 0x400000CC;
			//case NUMPAD_SPACE: 0x400000CD;
			//case NUMPAD_AT: 0x400000CE;
			//case NUMPAD_EXCLAMATION: 0x400000CF;
			//case NUMPAD_MEM_STORE: 0x400000D0;
			//case NUMPAD_MEM_RECALL: 0x400000D1;
			//case NUMPAD_MEM_CLEAR: 0x400000D2;
			//case NUMPAD_MEM_ADD: 0x400000D3;
			//case NUMPAD_MEM_SUBTRACT: 0x400000D4;
			//case NUMPAD_MEM_MULTIPLY: 0x400000D5;
			//case NUMPAD_MEM_DIVIDE: 0x400000D6;
			//case NUMPAD_PLUS_MINUS: 0x400000D7;
			//case NUMPAD_CLEAR: 0x400000D8;
			//case NUMPAD_CLEAR_ENTRY: 0x400000D9;
			//case NUMPAD_BINARY: 0x400000DA;
			//case NUMPAD_OCTAL: 0x400000DB;
			//case NUMPAD_DECIMAL: 0x400000DC;
			//case NUMPAD_HEXADECIMAL: 0x400000DD;
			case LEFT_CTRL: Keys.CONTROL;
			case LEFT_SHIFT: Keys.SHIFT;
			case LEFT_ALT: Keys.ALTERNATE;
			//case LEFT_META: 0x400000E3;
			case RIGHT_CTRL: Keys.CONTROL;
			case RIGHT_SHIFT: Keys.SHIFT;
			case RIGHT_ALT: Keys.ALTERNATE;
			//case RIGHT_META: 0x400000E7;
			//case MODE: 0x40000101;
			//case AUDIO_NEXT: 0x40000102;
			//case AUDIO_PREVIOUS: 0x40000103;
			//case AUDIO_STOP: 0x40000104;
			//case AUDIO_PLAY: 0x40000105;
			//case AUDIO_MUTE: 0x40000106;
			//case MEDIA_SELECT: 0x40000107;
			//case WWW: 0x40000108;
			//case MAIL: 0x40000109;
			//case CALCULATOR: 0x4000010A;
			//case COMPUTER: 0x4000010B;
			//case APP_CONTROL_SEARCH: 0x4000010C;
			//case APP_CONTROL_HOME: 0x4000010D;
			//case APP_CONTROL_BACK: 0x4000010E;
			//case APP_CONTROL_FORWARD: 0x4000010F;
			//case APP_CONTROL_STOP: 0x40000110;
			//case APP_CONTROL_REFRESH: 0x40000111;
			//case APP_CONTROL_BOOKMARKS: 0x40000112;
			//case BRIGHTNESS_DOWN: 0x40000113;
			//case BRIGHTNESS_UP: 0x40000114;
			//case DISPLAY_SWITCH: 0x40000115;
			//case BACKLIGHT_TOGGLE: 0x40000116;
			//case BACKLIGHT_DOWN: 0x40000117;
			//case BACKLIGHT_UP: 0x40000118;
			//case EJECT: 0x40000119;
			//case SLEEP: 0x4000011A;
			default: cast keyCode;
			
		}
		
	}
	
}