function onEvent(n,v1,v2)
	if n == 'Flash50' then
		setProperty('flash.alpha',0.1)
		doTweenAlpha('flTw','flash',0,v1,'linear')

	end
end

function onCreatePost()
	   makeLuaSprite('flash', '', 0, 0);
        makeGraphic('flash',1880,1320,'ffffff')
	      addLuaSprite('flash', true);
	      setLuaSpriteScrollFactor('flash',0,0)
	      setProperty('flash.scale.x',2)
	      setProperty('flash.scale.y',2)
		setProperty('flash.alpha',0)
end