package options.group;

class SkinGroup
{
	static public function add(follow:OptionBG)
	{
		var option:Option = new Option(Language.get('Skin'), TITLE);
		follow.addOption(option);

		var reset:ResetRect = new ResetRect(450, 20, follow);
		follow.add(reset);

		var option:Option = new Option(Language.get('Note'), TEXT);
		follow.addOption(option);

		var noteSkins:Array<String> = [];
		if (Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared').length > 0)
			noteSkins = Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared');
		else
			noteSkins = CoolUtil.coolTextFile(Paths.getSharedPath('shared/images/noteSkins/list.txt'));
		if (noteSkins.length > 0)
		{
			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);

			var option:Option = new Option(Language.get('noteSkin'), 'noteSkin', STRING, noteSkins);
			follow.addOption(option);
		}

		var option:Option = new Option(Language.get('noteRGB'), 'noteRGB', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('NotesSubState'), 'NotesSubState', STATE);
		follow.addOption(option);

		///////////////////////////////

		var option:Option = new Option(Language.get('Splash'), TEXT);
		follow.addOption(option);

		var noteSplashes:Array<String> = [];
		if (Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared').length > 0)
			noteSplashes = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		else
			noteSplashes = CoolUtil.coolTextFile(Paths.getSharedPath('shared/images/noteSplashes/list.txt'));

		if (noteSplashes.length > 0)
		{
			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin);

			var option:Option = new Option(Language.get('splashSkin'), 'splashSkin', STRING, noteSplashes);
			follow.addOption(option);
		}

		var option:Option = new Option(Language.get('splashRGB'), 'splashRGB', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('showSplash'), 'showSplash', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('splashAlpha'), 'splashAlpha', FLOAT, 0, 1, 1);
		follow.addOption(option);
	}
}
