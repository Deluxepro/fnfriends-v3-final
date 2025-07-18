package options;

import states.MainMenuState;
import states.FreeplayState;
import states.FreeplayStatePsych;
import mobile.substates.MobileControlSelectSubState;
import mobile.substates.MobileExtraControl;
import mobile.states.CopyState;
import backend.ClientPrefs;
import language.Language;
import backend.StageData;

class OptionsState extends MusicBeatState
{
	public static var instance:OptionsState;

	var filePath:String = 'menuExtend/OptionsState/';

	var naviArray = [];

	var extraBG:Rect;

	var tipButton:TipButton;
	var specButton:SpecButton;
	
	override function create()
	{
		persistentUpdate = persistentDraw = true;
		instance = this;

		naviArray = [
			'General',
			'User Interface',
			'GamePlay',
			'Game UI',
			'Skin',
			'Input',
			'Audio',
			'Graphics',
			'Maintenance'	
		];

		var bg = new Rect(0, 0, FlxG.width, FlxG.height, 0, 0, 0x302E3A);
		add(bg);

		var naviBG = new RoundRect(0, 0, UIScale.adjust(FlxG.width * 0.2), FlxG.height, 0, LEFT_CENTER,  0x24232C);
		add(naviBG);

		var downBG = new Rect(0, FlxG.height - Std.int(UIScale.adjust(FlxG.height * 0.1)), FlxG.width, Std.int(UIScale.adjust(FlxG.height * 0.1)), 0, 0, 0x24232C, 0.5);
		add(downBG);

		tipButton = new TipButton(
			UIScale.adjust(FlxG.width * 0.2) + UIScale.adjust(FlxG.height * 0.01), 
			downBG.y + Std.int(UIScale.adjust(FlxG.height * 0.01)),
			FlxG.width - UIScale.adjust(FlxG.width * 0.2) - UIScale.adjust(FlxG.height * 0.01) - Std.int(UIScale.adjust(FlxG.width * 0.15)) - Std.int(UIScale.adjust(FlxG.height * 0.01) * 2), 
			Std.int(UIScale.adjust(FlxG.height * 0.08))
		);
		add(tipButton);
		tipButton.changeText('text', 0.6);
		new FlxTimer().start(1.2, function(tmr:FlxTimer){
			tipButton.changeText('textsssssssssssss', 0.6);
		});

		specButton = new SpecButton(
			FlxG.width - Std.int(UIScale.adjust(FlxG.width * 0.15)) - Std.int(UIScale.adjust(FlxG.height * 0.01)), 
			downBG.y + Std.int(UIScale.adjust(FlxG.height * 0.01)),
			Std.int(UIScale.adjust(FlxG.width * 0.15)), 
			Std.int(UIScale.adjust(FlxG.height * 0.08))
		);
		specButton.alpha = 0.5;
		add(specButton);

		var extraBG = new Rect(UIScale.adjust(FlxG.width * 0.2), 0, FlxG.width - UIScale.adjust(FlxG.width * 0.2), Std.int(UIScale.adjust(FlxG.height * 0.1)), 0, 0, 0x24232C, 0.5);
		add(extraBG);
		
		for (i in 0...naviArray.length)
		{
			var naviSprite = new NaviSprite(UIScale.adjust(FlxG.width * 0.005), UIScale.adjust(FlxG.height * 0.005) + i * UIScale.adjust(FlxG.height * 0.1), UIScale.adjust(FlxG.width * 0.19), UIScale.adjust(FlxG.height * 0.09), naviArray[i], i, false);
			naviSprite.antialiasing = ClientPrefs.data.antialiasing;
			add(naviSprite);
		}

		var backShape = new GeneralBack(0, 720 - 72, UIScale.adjust(FlxG.width * 0.2), UIScale.adjust(FlxG.height * 0.1), Language.get('back', 'ma'), EngineSet.mainColor, backMenu);
		add(backShape);
		

		super.create();
	}

	public var ignoreCheck:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

	}

	override function closeSubState()
	{
		super.closeSubState();
	}

	public function moveState(type:Int)
	{
		switch (type)
		{
			case 1: // NoteOffsetState
				LoadingState.loadAndSwitchState(new NoteOffsetState());
			case 2: // NotesSubState
				persistentUpdate = false;
				openSubState(new NotesSubState());
			case 3: // ControlsSubState
				persistentUpdate = false;
				openSubState(new ControlsSubState());
			case 4: // MobileControlSelectSubState
				persistentUpdate = false;
				openSubState(new MobileControlSelectSubState());
			case 5: // MobileExtraControl
				persistentUpdate = false;
				openSubState(new MobileExtraControl());
			case 6: // CopyStates
				LoadingState.loadAndSwitchState(new CopyState(true));
		}
	}

	public static var stateType:Int = 0; //检测到底退回到哪个界面
	var backCheck:Bool = false;
	function backMenu()
	{
		if (!backCheck)
		{
			backCheck = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.saveSettings();
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
			Main.fpsVar.scaleX = Main.fpsVar.scaleY = ClientPrefs.data.FPSScale;
			Main.fpsVar.change();
			if (Main.watermark != null)
			{
				Main.watermark.scaleX = Main.watermark.scaleY = ClientPrefs.data.WatermarkScale;
				Main.watermark.y += (1 - ClientPrefs.data.WatermarkScale) * Main.watermark.bitmapData.height;
				Main.watermark.visible = ClientPrefs.data.showWatermark;
			}
			switch (stateType)
			{
				case 0:
					MusicBeatState.switchState(new MainMenuState());
				case 1:
						MusicBeatState.switchState(new FreeplayState());
				case 2:
					MusicBeatState.switchState(new PlayState());
					FlxG.mouse.visible = false;
			}
			stateType = 0;
		}
	}
}
