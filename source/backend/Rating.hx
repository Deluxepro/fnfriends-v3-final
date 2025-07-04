package backend;

import backend.ClientPrefs;

class Rating
{
	public var name:String = '';
	public var image:String = '';
	public var hitWindow:Null<Int> = 0; // ms
	public var ratingMod:Float = 1;
	public var score:Int = 350;
	public var noteSplash:Bool = true;
	public var hits:Int = 0;
	public var color:Int = 0xFFFFFFFF;

	public function new(name:String)
	{
		this.name = name;
		this.image = name;
		this.hitWindow = 0;

		var window:String = name + 'Window';
		try
		{
			this.hitWindow = Reflect.field(ClientPrefs.data, window);
		}
		catch (e)
			FlxG.log.error(e);
	}

	public static function loadDefault():Array<Rating>
	{
		var ratingsData:Array<Rating> = [new Rating('sick')]; // highest rating goes first

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.75;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.5;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		if (ClientPrefs.data.marvelousRating)
		{
			var rating:Rating = new Rating('marvelous');
			rating.ratingMod = 1;
			rating.score = 500;
			rating.image = ClientPrefs.data.marvelousSprite ? 'marvelous' : 'sick';
			rating.noteSplash = true;
			ratingsData.push(rating);
		}
		return ratingsData;
	}
}
