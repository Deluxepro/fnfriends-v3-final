function onCreate()
makeLuaSprite('RBG', nil, -2500, -1200)
makeGraphic('RBG',5000,5000,'ffffff')
addLuaSprite('RBG', false)
scaleObject('RBG', 5, 5);
setScrollFactor('RBG', 0, 0)
setProperty('RBG.visible', false)

end


function onEvent(name,value1,value2)
if name == 'RBG' then

if value1 == 'Won' then

setProperty('RBG.colorTransform.greenOffset', 0)
setProperty('RBG.colorTransform.redOffset', 255)
setProperty('RBG.colorTransform.blueOffset', 0)

setProperty('dad.colorTransform.greenOffset', -255)
setProperty('dad.colorTransform.redOffset', -255)
setProperty('dad.colorTransform.blueOffset', -255)

setProperty('boyfriend.colorTransform.greenOffset', -255)
setProperty('boyfriend.colorTransform.redOffset', -255)
setProperty('boyfriend.colorTransform.blueOffset', -255)

setProperty('gf.colorTransform.greenOffset', -255)
setProperty('gf.colorTransform.redOffset', -255)
setProperty('gf.colorTransform.blueOffset', -255)

setProperty('RBG.visible', true)
setProperty('iconP1.visible', false)
setProperty('healthBar.visible', false)
setProperty('iconP2.visible', false)
setProperty('scoreTxt.visible', false)
setProperty('timeTxt.visible', false)
end

if value1 == 'Bon' then

setProperty('RBG.colorTransform.greenOffset', -255)
setProperty('RBG.colorTransform.redOffset', -255)
setProperty('RBG.colorTransform.blueOffset', -255)

setProperty('dad.colorTransform.greenOffset', 255)
setProperty('dad.colorTransform.redOffset', 255)
setProperty('dad.colorTransform.blueOffset', 255)

setProperty('boyfriend.colorTransform.greenOffset', 255)
setProperty('boyfriend.colorTransform.redOffset', 255)
setProperty('boyfriend.colorTransform.blueOffset', 255)

setProperty('gf.colorTransform.greenOffset', 255)
setProperty('gf.colorTransform.redOffset', 255)
setProperty('gf.colorTransform.blueOffset', 255)

setProperty('RBG.visible', true)
setProperty('iconP1.visible', false)
setProperty('healthBar.visible', false)
setProperty('iconP2.visible', false)
setProperty('scoreTxt.visible', false)
setProperty('timeTxt.visible', false)
end

if value1 == 'off' then
setProperty('RBG.colorTransform.greenOffset', 0)
setProperty('RBG.colorTransform.redOffset', 0)
setProperty('RBG.colorTransform.blueOffset', 0)

setProperty('dad.colorTransform.greenOffset', 0)
setProperty('dad.colorTransform.redOffset', 0)
setProperty('dad.colorTransform.blueOffset', 0)

setProperty('gf.colorTransform.greenOffset', 0)
setProperty('gf.colorTransform.redOffset', 0)
setProperty('gf.colorTransform.blueOffset', 0)

setProperty('boyfriend.colorTransform.greenOffset', 0)
setProperty('boyfriend.colorTransform.redOffset', 0)
setProperty('boyfriend.colorTransform.blueOffset', 0)

setProperty('RBG.visible', false)
setProperty('iconP1.visible', true)
setProperty('healthBar.visible', true)
setProperty('iconP2.visible', true)
setProperty('timeTxt.visible', true)
setProperty('scoreTxt.visible', true)

end
end
end