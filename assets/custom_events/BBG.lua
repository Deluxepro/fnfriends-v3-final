function onCreate()
		makeLuaSprite('WBG', nil, -1500, -1200)
		makeGraphic('WBG',5000,5000,'016064')
		addLuaSprite('WBG', false)
scaleObject('WBG', 5, 5);
setScrollFactor('WBG', 0, 0)
	setProperty('WBG.alpha',0)


end
function onEvent(name,value1,value2)
if name == 'WBG' then 
if value1 == 'on' then

    doTweenColor('boyfr8272iend', 'boyfriend', 'ffffff', 1, 'linear');
    doTweenColor('g7272f', 'gf', 'ffffff', 1, 'linear');
    doTweenColor('da9173d', 'dad', 'ffffff', 1, 'linear');
    doTweenAlpha('WBG','WBG',1,1);
    doTweenAlpha('TBG4','TBG4',0,1);
doTweenAlpha('iconP1', 'iconP1', 0, 1, 'linear')
doTweenAlpha('healthBar', 'healthBar', 0, 1, 'linear')
doTweenAlpha('timeTxt', 'timeTxt', 0, 1, 'linear')
doTweenAlpha('timeBar', 'timeBar', 0, 1, 'linear')
doTweenAlpha('scoreTxt', 'scoreTxt', 0, 1, 'linear')
doTweenAlpha('iconP2', 'iconP2', 0, 1, 'linear')

end
if value1 == 'off' then
    doTweenColor('boyfr8272iend', 'boyfriend', 'ffffff', 1, 'linear');
    doTweenColor('g7272f', 'gf', 'ffffff', 1, 'linear');
    doTweenColor('da9173d', 'dad', 'ffffff', 1, 'linear');
    doTweenAlpha('WBG','WBG',0,1);
    doTweenAlpha('TBG4','TBG4',1,1);
doTweenAlpha('iconP1', 'iconP1', 1, 1, 'linear')
doTweenAlpha('healthBar', 'healthBar', 1, 1, 'linear')
doTweenAlpha('timeTxt', 'timeTxt', 1, 1, 'linear')
doTweenAlpha('timeBar', 'timeBar', 1, 1, 'linear')
doTweenAlpha('scoreTxt', 'scoreTxt', 1, 1, 'linear')
doTweenAlpha('iconP2', 'iconP2', 1, 1, 'linear')
end
if value1 == 'on i' then
    doTweenColor('boyfr8272iend', 'boyfriend', '000000', 0.001, 'linear');
    doTweenColor('g7272f', 'gf', '000000', 0.001, 'linear');
    doTweenColor('da9173d', 'dad', '000000', 0.001, 'linear');
    doTweenAlpha('WBG','WBG',1,0.001);
    doTweenAlpha('TBG4','TBG4',0,0.001);
doTweenAlpha('iconP1', 'iconP1', 0, 0.001, 'linear')
doTweenAlpha('healthBar', 'healthBar', 0, 0.001, 'linear')
doTweenAlpha('timeTxt', 'timeTxt', 0, 0.001, 'linear')
doTweenAlpha('timeBar', 'timeBar', 0, 0.001, 'linear')
doTweenAlpha('scoreTxt', 'scoreTxt', 0, 0.001, 'linear')
doTweenAlpha('iconP2', 'iconP2', 0, 0.001, 'linear')

end
if value1 == 'off i' then
    doTweenColor('boyfr8272iend', 'boyfriend', 'ffffff', 0.001, 'linear');
    doTweenColor('g7272f', 'gf', 'ffffff', 0.001, 'linear');
    doTweenColor('da9173d', 'dad', 'ffffff', 0.001, 'linear');
    doTweenAlpha('WBG','WBG',0,0.001);
    doTweenAlpha('TBG4','TBG4',1,0.001);
doTweenAlpha('iconP1', 'iconP1', 1, 0.001, 'linear')
doTweenAlpha('healthBar', 'healthBar', 1, 0.001, 'linear')
doTweenAlpha('timeTxt', 'timeTxt', 1, 0.001, 'linear')
doTweenAlpha('timeBar', 'timeBar', 1, 0.001, 'linear')
doTweenAlpha('scoreTxt', 'scoreTxt', 1, 0.001, 'linear')
doTweenAlpha('iconP2', 'iconP2', 1, 0.001, 'linear')
end
end
end