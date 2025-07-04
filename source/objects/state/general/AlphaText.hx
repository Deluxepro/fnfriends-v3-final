package objects.state.general;

class AlphaText extends FlxSpriteGroup
{
    public var mainText:FlxText;
    public var minorText:FlxText;

    var bound:Float;
    public var mainX:Float;
	public var mainY:Float;

    public function new(X:Float, Y:Float, boud:Float, text:String, size:Int, ?bound:Float = 0) {
        super(X, Y);

        if (bound != null) this.bound = bound;

        mainText = new FlxText(0, 0, boud, text, size);
        mainText.antialiasing = ClientPrefs.data.antialiasing;
        
		add(mainText);

        minorText = new FlxText(0, 0, boud, text, size);
        minorText.alpha = 0.0000001;
        minorText.antialiasing = ClientPrefs.data.antialiasing;
		add(minorText);
    }

    public function setFormat(?Font:String = null, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, ?BorderStyle:FlxTextBorderStyle,
			BorderColor:FlxColor = FlxColor.TRANSPARENT, EmbeddedFont:Bool = true) {
            if (Font == null) Font =  Paths.font(Language.get('fontName', 'ma') + '.ttf');
        mainText.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, EmbeddedFont);
        minorText.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, EmbeddedFont);

        mainText.borderStyle = NONE;
        minorText.borderStyle = NONE;
    }

    var mainTween:FlxTween;
    var minorTween:FlxTween;
    public function changeText(newText:String, time:Float = 0.6) {
        if (mainTween != null) mainTween.cancel();
        if (minorTween != null) minorTween.cancel();

        minorText.text = newText;
        minorText.scale.x = minorText.scale.y = 1;
        minorText.x = mainX;
        minorText.y = mainY;
        if (bound != 0) {
            if (minorText.width > bound) minorText.scale.x = minorText.scale.y = bound / minorText.width;
            minorText.x -= minorText.width * (1 - minorText.scale.x);
            minorText.y -= minorText.height * (1 - minorText.scale.y);
        }
        
        mainTween = FlxTween.tween(mainText, {alpha: 0}, time / 2, {
					ease: FlxEase.expoIn,
					onComplete: function(twn:FlxTween)
					{
                        minorTween = FlxTween.tween(minorText, {alpha: 1}, time / 2, {
                                    ease: FlxEase.expoOut,
                                    onComplete: function(twn:FlxTween)
                                        {
                                            minorText.alpha = 0.00001;

                                            mainText.alpha = 1;
                                            mainText.text = newText;
                                            mainText.scale.x = mainText.scale.y = 1;
                                            mainText.x = mainX;
                                            mainText.y = mainY;
                                            if (bound != 0) {
                                                if (mainText.width > bound) mainText.scale.x = mainText.scale.y = bound / mainText.width;
                                                mainText.x -= mainText.width * (1 - mainText.scale.x);
                                                mainText.y -= mainText.height * (1 - mainText.scale.y);
                                            }
                                        }
                        });
					}
		});
    }
} 