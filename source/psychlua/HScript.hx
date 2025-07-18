package psychlua;

import flixel.FlxBasic;
import objects.Character;
import psychlua.LuaUtils;
import psychlua.CustomSubstate;
#if LUA_ALLOWED
import psychlua.FunkinLua;
#end
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr;
import crowplexus.hscript.Parser;
import crowplexus.hscript.Interp;
import crowplexus.hscript.Printer;

typedef HScriptInfos =
{
	> haxe.PosInfos,
	var ?funcName:String;
	var ?showLine:Null<Bool>;
	#if LUA_ALLOWED
	var ?isLua:Null<Bool>;
	#end
}

class HScript {
	public static var originError:(Dynamic, ?haxe.PosInfos) -> Void = Iris.error;

	public var active:Bool;
	public var loaded:Bool;

	public var filePath(default, null):String;
	public var modFolder:String;
	public var origin(get, never):String;
	@:dox(hide) inline function get_origin():String {
		return filePath;
	}
	var scriptCode(default, null):Null<String>;
	var expr:Expr;
	var interp:Interp;
	var parser:Parser;

	public function new(file:String, ?parent:Dynamic, ?manualRun:Bool = false, ?experimental:Bool = false) {
		active = true;

		filePath = file;
		#if MODS_ALLOWED
		var myFolder:Array<String> = filePath.split('/');
		if (myFolder[0] + '/' == Paths.mods()
			&& (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
			this.modFolder = myFolder[1];
		#end

		interp = new Interp();
		parser = new Parser();
		parser.allowTypes = parser.allowMetadata = parser.allowJSON = true;
		parser.allowInterpolation = experimental;
		preset(parent);

		loadFile();
		if(manualRun)
			execute();
	}

	public function execute():Dynamic {
		var ret:Dynamic = null;
		if(active && expr != null && !loaded) {
			try {
				ret = interp.execute(expr);
				loaded = true;
			}
			#if hscriptPos
			catch(e:Error) {
				Iris.error(Printer.errorToString(e, false), cast {fileName: e.origin, lineNumber: e.line});
				active = false;
			}
			#end
			catch(e) {
				Iris.error(Std.string(e), cast this.interp.posInfos());
				active = false;
			}
		}
		return ret;
	}

	public function get(name:String) {
		if(interp.directorFields.get(name) != null)
			return interp.directorFields.get(name).value;
		else return interp.variables.get(name);
	}

	public function exists(name:String) {
		return interp.variables.exists(name) || interp.directorFields.get(name) != null;
	}

	public inline function checkType(name:String):Null<String> {
		if(interp.directorFields.get(name) != null) {
			return interp.directorFields.get(name).type;
		}
		return null;
	}

	public function call(name:String, ?args:Array<Dynamic>):Dynamic {
		var ret:Dynamic = null;
		if(active && exists(name)) {
			final func = get(name);
			if(checkType(name) == "func" && Reflect.isFunction(func)) {
				try {
					ret = Reflect.callMethod(null, func, (args == null ? [] : args));
				}
				#if hscriptPos
				catch(e:Error) {
					Iris.error(Printer.errorToString(e, false), cast {fileName: e.origin, lineNumber: e.line});
					active = false;
				}
				#end
				catch(e) {
					Iris.error(Std.string(e), cast #if hscriptPos this.interp.posInfos() #else cast {fileName: this.origin, lineNumber: 0} #end);
					active = false;
				}
			} else {
				Iris.error("Invalid Function -> " + '"' + name + '"');
			}
		}
		return ret;
	}

	public function set(name:String, value:Dynamic) {
		if(value is Class || value is Enum) interp.imports.set(name, value);
		else interp.variables.set(name, value);
	}

	public function destroy() {
		active = false;
	}

	function loadFile() {
		if(!active) return;

		#if MODS_ALLOWED
		if(FileSystem.exists(filePath)) {
			scriptCode = try {
				File.getContent(filePath);
			} catch(e) {
				Iris.warn('Invalid Expected File Path -> "$filePath"', cast {fileName: filePath, lineNumber: 0});
				null;
			}
		} else {
			Iris.warn('This File Path Was Not Exist -> "$filePath"', cast {fileName: filePath, lineNumber: 0});
		}
		#else
		if(openfl.Assets.exists(filePath)) {
			scriptCode = try {
				openfl.Assets.getText(filePath);
			} catch(e) {
				Iris.warn('Invalid Expected This File Path -> "$filePath"', cast {fileName: filePath, lineNumber: 0});
				null;
			}
		} else {
			Iris.warn('This File Path Was Not Exist -> "$filePath"', cast {fileName: filePath, lineNumber: 0});
		}
		#end

		if(scriptCode != null && scriptCode.trim() != '') {
			try {
				expr = parser.parseString(scriptCode, this.origin);
			}
			#if hscriptPos
			catch(e:Error) {
				Iris.error(Printer.errorToString(e, false), cast {fileName: e.origin, lineNumber: e.line});
				active = false;
			}
			#end
			catch(e) {
				Iris.error(Std.string(e), cast {fileName: this.origin, lineNumber: 0});
				active = false;
			}
		}
	}

	function preset(parent:Dynamic) {
			// Some very commonly used classes
			// set('Type', Type);
			if(parent != null) this.interp.parentInstance = parent;
			#if sys
			set('File', File);
			set('FileSystem', FileSystem);
			#end
			set('FlxG', flixel.FlxG);
			set('FlxMath', flixel.math.FlxMath);
			set('FlxSprite', flixel.FlxSprite);
			set('FlxText', flixel.text.FlxText);
			set('FlxCamera', flixel.FlxCamera);
			set('PsychCamera', backend.PsychCamera);
			set('FlxTimer', flixel.util.FlxTimer);
			set('FlxTween', flixel.tweens.FlxTween);
			set('FlxEase', flixel.tweens.FlxEase);
			set('FlxColor', CustomFlxColor);
			set('Countdown', backend.BaseStage.Countdown);
			set('PlayState', PlayState);
			set('Paths', Paths);
			// set('StorageUtil', StorageUtil); //nf引擎不支持这个玩意
			set('Conductor', Conductor);
			set('ClientPrefs', ClientPrefs);
			#if ACHIEVEMENTS_ALLOWED
			set('Achievements', Achievements);
			#end
			set('Character', Character);
			set('Alphabet', Alphabet);
			set('Note', objects.Note);
			set('CustomSubstate', CustomSubstate);
			#if (!flash && sys)
			set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
			set('ErrorHandledRuntimeShader', shaders.ErrorHandledShader.ErrorHandledRuntimeShader);
			#end
			set('ShaderFilter', openfl.filters.ShaderFilter);
			// set('StringTools', StringTools);
			#if flxanimate
			set('FlxAnimate', FlxAnimate);
			#end
			if(parent is MusicBeatState) {
				set('setVar', function(name:String, value:Dynamic)
				{
					MusicBeatState.getVariables().set(name, value);
					return value;
				});
				set('getVar', function(name:String)
				{
					var result:Dynamic = null;
					if (MusicBeatState.getVariables().exists(name))
						result = MusicBeatState.getVariables().get(name);
					return result;
				});
				set('removeVar', function(name:String)
				{
					if (MusicBeatState.getVariables().exists(name))
					{
						MusicBeatState.getVariables().remove(name);
						return true;
					}
					return false;
				});

				if(parent is PlayState) {
					set('debugPrint', function(text:String, ?color:FlxColor = null)
					{
						if (color == null)
							color = FlxColor.WHITE;
						PlayState.instance.addTextToDebug(text, color);
					});

					set('keyJustPressed', function(name:String = '')
					{
						name = name.toLowerCase();
						switch (name)
						{
							case 'left':
								return Controls.instance.NOTE_LEFT_P;
							case 'down':
								return Controls.instance.NOTE_DOWN_P;
							case 'up':
								return Controls.instance.NOTE_UP_P;
							case 'right':
								return Controls.instance.NOTE_RIGHT_P;
							default:
								return Controls.instance.justPressed(name);
						}
						return false;
					});

					set('keyPressed', function(name:String = '')
					{
						name = name.toLowerCase();
						switch (name)
						{
							case 'left':
								return Controls.instance.NOTE_LEFT;
							case 'down':
								return Controls.instance.NOTE_DOWN;
							case 'up':
								return Controls.instance.NOTE_UP;
							case 'right':
								return Controls.instance.NOTE_RIGHT;
							default:
								return Controls.instance.pressed(name);
						}
						return false;
					});

					set('keyReleased', function(name:String = '')
					{
						name = name.toLowerCase();
						switch (name)
						{
							case 'left':
								return Controls.instance.NOTE_LEFT_R;
							case 'down':
								return Controls.instance.NOTE_DOWN_R;
							case 'up':
								return Controls.instance.NOTE_UP_R;
							case 'right':
								return Controls.instance.NOTE_RIGHT_R;
							default:
								return Controls.instance.justReleased(name);
						}
						return false;
					});
					#if LUA_ALLOWED
					set('createGlobalCallback', function(name:String, func:Dynamic)
					{
						for (script in PlayState.instance.luaArray)
							if (script != null && script.lua != null && !script.closed)
								Lua_helper.add_callback(script.lua, name, func);

						FunkinLua.customFunctions.set(name, func);
					});

					// this one was tested
					set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
					{
						if (funk == null)
							return;

						if (funk != null)
							funk.addLocalCallback(name, func);
						else
							Iris.error('createCallback ($name): 3rd argument is null', this.interp.posInfos());
					});
					#end

					#if LUA_ALLOWED
					set("addVirtualPad", (DPadMode:String, ActionMode:String) ->
					{
						PlayState.instance.makeLuaVirtualPad(DPadMode, ActionMode);
						PlayState.instance.addLuaVirtualPad();
					});

					set("removeVirtualPad", () ->
					{
						PlayState.instance.removeLuaVirtualPad();
					});

					set("addVirtualPadCamera", () ->
					{
						if (PlayState.instance.luaVirtualPad == null)
						{
							Iris.error('addVirtualPadCamera: TPAD does not exist.', cast this.interp.posInfos());
							return;
						}
						PlayState.instance.addLuaVirtualPadCamera();
					});

					set("virtualPadJustPressed", function(button:Dynamic):Bool
					{
						if (PlayState.instance.luaVirtualPad == null)
						{
							// FunkinLua.luaTrace('virtualPadJustPressed: TPAD does not exist.');
							return false;
						}
						return PlayState.instance.luaVirtualPadJustPressed(button);
					});

					set("virtualPadPressed", function(button:Dynamic):Bool
					{
						if (PlayState.instance.luaVirtualPad == null)
						{
							// FunkinLua.luaTrace('virtualPadPressed: TPAD does not exist.');
							return false;
						}
						return PlayState.instance.luaVirtualPadPressed(button);
					});

					set("virtualPadJustReleased", function(button:Dynamic):Bool
					{
						if (PlayState.instance.luaVirtualPad == null)
						{
							// FunkinLua.luaTrace('virtualPadJustReleased: TPAD does not exist.');
							return false;
						}
						return PlayState.instance.luaVirtualPadJustReleased(button);
					});
					#end

					set('game', FlxG.state);
					set('controls', Controls.instance);
				}
			}

			// Functions & Variables
			set('getModSetting', function(saveTag:String, ?modName:String = null)
			{
				if (modName == null)
				{
					if (this.modFolder == null)
					{
						Iris.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', this.interp.posInfos());
						return null;
					}
					modName = this.modFolder;
				}
				return LuaUtils.getModSetting(saveTag, modName);
			});

			// Keyboard & Gamepads
			set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
			set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
			set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

			set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
			set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
			set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

			set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return 0.0;
	
				return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
			});
			set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return 0.0;
	
				return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
			});
			set('gamepadJustPressed', function(id:Int, name:String)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;
	
				return Reflect.getProperty(controller.justPressed, name) == true;
			});
			set('gamepadPressed', function(id:Int, name:String)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;
	
				return Reflect.getProperty(controller.pressed, name) == true;
			});
			set('gamepadReleased', function(id:Int, name:String)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;
	
				return Reflect.getProperty(controller.justReleased, name) == true;
			});

			// For adding your own callbacks
			// not very tested but should work

		// set('this', this);

		set('buildTarget', LuaUtils.getBuildTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('Function_StopLua', LuaUtils.Function_StopLua); // doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);
	}
}

/*class HScript extends Iris
{
	public static var originError:(Dynamic, ?haxe.PosInfos) -> Void = Iris.error;

	public var filePath:String;
	public var modFolder:String;
	public var returnValue:Dynamic;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;

	public static function initHaxeModule(parent:FunkinLua)
	{
		if (parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null)
	{
		var hs:HScript = try parent.hscript catch (e) null;
		if (hs == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			try
			{
				parent.hscript = new HScript(parent, code, varsToBring);
			}
			catch (e:Error)
			{
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if (parent.lastCalledFunction != '')
					pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				parent.hscript = null;
			}
		}
		else
		{
			try
			{
				hs.scriptCode = code;
				hs.varsToBring = varsToBring;
				hs.parse(true);
				var ret:Dynamic = hs.execute();
				hs.returnValue = ret;
			}
			catch (e:Error)
			{
				var pos:HScriptInfos = cast hs.interp.posInfos();
				pos.isLua = true;
				if (parent.lastCalledFunction != '')
					pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				hs.returnValue = null;
			}
		}
	}
	#end

	public var origin:String;

	override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false)
	{
		if (file == null)
			file = '';

		filePath = file;
		if (filePath != null && filePath.length > 0)
		{
			this.origin = filePath;
			#if MODS_ALLOWED
			var myFolder:Array<String> = filePath.split('/');
			if (myFolder[0] + '/' == Paths.mods()
				&& (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}
		var scriptThing:String = file;
		var scriptName:String = null;
		if (parent == null && file != null)
		{
			var f:String = file.replace('\\', '/');
			if (f.contains('/') && !f.contains('\n'))
			{
				scriptThing = File.getContent(f);
				scriptName = f;
			}
		}
		#if LUA_ALLOWED
		if (scriptName == null && parent != null)
			scriptName = parent.scriptName;
		#end
		super(scriptThing, new IrisConfig(scriptName, false, false));

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
		{
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end
		preset();
		this.varsToBring = varsToBring;
		if (!manualRun)
		{
			try
			{
				var ret:Dynamic = execute();
				returnValue = ret;
			}
			catch (e:Error)
			{
				returnValue = null;
				this.destroy();
				throw e;
			}
		}
	}

	var varsToBring(default, set):Any = null;

		override function preset()
		{
			super.preset();
	
			// Some very commonly used classes
			// set('Type', Type);
			#if sys
			set('File', File);
			set('FileSystem', FileSystem);
			#end
			set('FlxG', flixel.FlxG);
			set('FlxMath', flixel.math.FlxMath);
			set('FlxSprite', flixel.FlxSprite);
			set('FlxText', flixel.text.FlxText);
			set('FlxCamera', flixel.FlxCamera);
			set('PsychCamera', backend.PsychCamera);
			set('FlxTimer', flixel.util.FlxTimer);
			set('FlxTween', flixel.tweens.FlxTween);
			set('FlxEase', flixel.tweens.FlxEase);
			set('FlxColor', CustomFlxColor);
			set('Countdown', backend.BaseStage.Countdown);
			set('PlayState', PlayState);
			set('Paths', Paths);
			// set('StorageUtil', StorageUtil); //nf引擎不支持这个玩意
			set('Conductor', Conductor);
			set('ClientPrefs', ClientPrefs);
			#if ACHIEVEMENTS_ALLOWED
			set('Achievements', Achievements);
			#end
			set('Character', Character);
			set('Alphabet', Alphabet);
			set('Note', objects.Note);
			set('CustomSubstate', CustomSubstate);
			#if (!flash && sys)
			set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
			set('ErrorHandledRuntimeShader', shaders.ErrorHandledShader.ErrorHandledRuntimeShader);
			#end
			set('ShaderFilter', openfl.filters.ShaderFilter);
			// set('StringTools', StringTools);
			#if flxanimate
			set('FlxAnimate', FlxAnimate);
			#end
	
			// Functions & Variables
			set('setVar', function(name:String, value:Dynamic)
			{
				MusicBeatState.getVariables().set(name, value);
				return value;
			});
			set('getVar', function(name:String)
			{
				var result:Dynamic = null;
				if (MusicBeatState.getVariables().exists(name))
					result = MusicBeatState.getVariables().get(name);
				return result;
			});
			set('removeVar', function(name:String)
			{
				if (MusicBeatState.getVariables().exists(name))
				{
					MusicBeatState.getVariables().remove(name);
					return true;
				}
				return false;
			});
			set('debugPrint', function(text:String, ?color:FlxColor = null)
			{
				if (color == null)
					color = FlxColor.WHITE;
				PlayState.instance.addTextToDebug(text, color);
			});
			set('getModSetting', function(saveTag:String, ?modName:String = null)
			{
				if (modName == null)
				{
					if (this.modFolder == null)
					{
						Iris.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', this.interp.posInfos());
						return null;
					}
					modName = this.modFolder;
				}
				return LuaUtils.getModSetting(saveTag, modName);
			});
	
			// Keyboard & Gamepads
			set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
			set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
			set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));
	
			set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
			set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
			set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));
	
			set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return 0.0;
	
				return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
			});
			set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return 0.0;
	
				return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
			});
			set('gamepadJustPressed', function(id:Int, name:String)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;
	
				return Reflect.getProperty(controller.justPressed, name) == true;
			});
			set('gamepadPressed', function(id:Int, name:String)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;
	
				return Reflect.getProperty(controller.pressed, name) == true;
			});
			set('gamepadReleased', function(id:Int, name:String)
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;
	
				return Reflect.getProperty(controller.justReleased, name) == true;
			});
	
			set('keyJustPressed', function(name:String = '')
			{
				name = name.toLowerCase();
				switch (name)
				{
					case 'left':
						return Controls.instance.NOTE_LEFT_P;
					case 'down':
						return Controls.instance.NOTE_DOWN_P;
					case 'up':
						return Controls.instance.NOTE_UP_P;
					case 'right':
						return Controls.instance.NOTE_RIGHT_P;
					default:
						return Controls.instance.justPressed(name);
				}
				return false;
			});
			set('keyPressed', function(name:String = '')
			{
				name = name.toLowerCase();
				switch (name)
				{
					case 'left':
						return Controls.instance.NOTE_LEFT;
					case 'down':
						return Controls.instance.NOTE_DOWN;
					case 'up':
						return Controls.instance.NOTE_UP;
					case 'right':
						return Controls.instance.NOTE_RIGHT;
					default:
						return Controls.instance.pressed(name);
				}
				return false;
			});
			set('keyReleased', function(name:String = '')
			{
				name = name.toLowerCase();
				switch (name)
				{
					case 'left':
						return Controls.instance.NOTE_LEFT_R;
					case 'down':
						return Controls.instance.NOTE_DOWN_R;
					case 'up':
						return Controls.instance.NOTE_UP_R;
					case 'right':
						return Controls.instance.NOTE_RIGHT_R;
					default:
						return Controls.instance.justReleased(name);
				}
				return false;
			});
	
			// For adding your own callbacks
			// not very tested but should work
			#if LUA_ALLOWED
			set('createGlobalCallback', function(name:String, func:Dynamic)
			{
				for (script in PlayState.instance.luaArray)
					if (script != null && script.lua != null && !script.closed)
						Lua_helper.add_callback(script.lua, name, func);
	
				FunkinLua.customFunctions.set(name, func);
			});
	
			// this one was tested
			set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
			{
				if (funk == null)
					funk = parentLua;
	
				if (funk != null)
					funk.addLocalCallback(name, func);
				else
					Iris.error('createCallback ($name): 3rd argument is null', this.interp.posInfos());
			});
			#end
	
			set('addHaxeLibrary', function(libName:String, ?libPackage:String = '')
			{
				try
				{
					var str:String = '';
					if (libPackage.length > 0)
						str = libPackage + '.';
	
					set(libName, Type.resolveClass(str + libName));
				}
				catch (e:Error)
				{
				Iris.error(Printer.errorToString(e, false), this.interp.posInfos());
			}
		});
		#if LUA_ALLOWED
		set('parentLua', parentLua);

		set("addVirtualPad", (DPadMode:String, ActionMode:String) ->
		{
			PlayState.instance.makeLuaVirtualPad(DPadMode, ActionMode);
			PlayState.instance.addLuaVirtualPad();
		});

		set("removeVirtualPad", () ->
		{
			PlayState.instance.removeLuaVirtualPad();
		});

		set("addVirtualPadCamera", () ->
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				FunkinLua.luaTrace('addVirtualPadCamera: TPAD does not exist.');
				return;
			}
			PlayState.instance.addLuaVirtualPadCamera();
		});

		set("virtualPadJustPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				// FunkinLua.luaTrace('virtualPadJustPressed: TPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadJustPressed(button);
		});

		set("virtualPadPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				// FunkinLua.luaTrace('virtualPadPressed: TPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadPressed(button);
		});

		set("virtualPadJustReleased", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				// FunkinLua.luaTrace('virtualPadJustReleased: TPAD does not exist.');
				return false;
			}
			return PlayState.instance.luaVirtualPadJustReleased(button);
		});
		#else
		set('parentLua', null);
		#end
		// set('this', this);
		set('game', FlxG.state);
		set('controls', Controls.instance);

		set('buildTarget', LuaUtils.getBuildTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('Function_StopLua', LuaUtils.Function_StopLua); // doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		funk.addLocalCallback("runHaxeCode",
			function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic
			{
				initHaxeModuleCode(funk, codeToRun, varsToBring);
				if (funk.hscript != null)
				{
					final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
					if (retVal != null)
					{
						return (LuaUtils.isLuaSupported(retVal.returnValue)) ? retVal.returnValue : null;
					}
					else if (funk.hscript.returnValue != null)
					{
						return funk.hscript.returnValue;
					}
				}
				return null;
			});

		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null)
		{
			if (funk.hscript != null)
			{
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
				{
					return (LuaUtils.isLuaSupported(retVal.returnValue)) ? retVal.returnValue : null;
				}
			}
			else
			{
				var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
				if (funk.lastCalledFunction != '')
					pos.funcName = funk.lastCalledFunction;
				Iris.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
			}
			return null;
		});
		// This function is unnecessary because import already exists in HScript as a native feature
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '')
		{
			var str:String = '';
			if (libPackage.length > 0)
				str = libPackage + '.';
			else if (libName == null)
				libName = '';

			var c:Dynamic = Type.resolveClass(str + libName);
			if (c == null)
				c = Type.resolveEnum(str + libName);

			if (funk.hscript == null)
				initHaxeModule(funk);

			var pos:HScriptInfos = cast funk.hscript.interp.posInfos();
			pos.showLine = false;
			if (funk.lastCalledFunction != '')
				pos.funcName = funk.lastCalledFunction;

			try
			{
				if (c != null)
					funk.hscript.set(libName, c);
			}
			catch (e:Error)
			{
				Iris.error(Printer.errorToString(e, false), pos);
			}
			FunkinLua.lastCalledScript = funk;
			if (FunkinLua.getBool('luaDebugMode') && FunkinLua.getBool('luaDeprecatedWarnings'))
				Iris.warn("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
		});
	}
	#end

	override function call(funcToRun:String, ?args:Array<Dynamic>):IrisCall
	{
		if (funcToRun == null || interp == null)
			return null;

		if (!exists(funcToRun))
		{
			Iris.error('No function named: $funcToRun', this.interp.posInfos());
			return null;
		}

		try
		{
			var func:Dynamic = interp.variables.get(funcToRun); // function signature
			final ret = Reflect.callMethod(null, func, args ?? []);
			return {funName: funcToRun, signature: func, returnValue: ret};
		}
		catch (e:Error)
		{
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.funcName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '')
					pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			Iris.error(Printer.errorToString(e, false), pos);
		}
		catch (e:ValueException)
		{
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.funcName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '')
					pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			Iris.error('$e', pos);
		}
		return null;
	}

	override public function destroy()
	{
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end
		super.destroy();
	}

	function set_varsToBring(values:Any)
	{
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if (exists(key.trim()))
					interp.variables.remove(key.trim());

		if (values != null)
		{
			for (key in Reflect.fields(values))
			{
				key = key.trim();
				set(key, Reflect.field(values, key));
			}
		}

		return varsToBring = values;
	}
}*/

class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int
		return cast FlxColor.fromInt(Value);

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);

	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);

	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);

	public static function fromString(str:String):Int
		return cast FlxColor.fromString(str);
}
#end