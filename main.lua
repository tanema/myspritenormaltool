require 'loveframes'
require 'lovefs/lovefs'
require 'lovefs/dialogs'
local conv = require 'conv'

function love.load()
	fsload = lovefs()
	fsloadn = lovefs()
	fssave = lovefs()
  strength = 1
  steps = 10
  grayType = conv.grayTypes[1]

  imageContainerW, imageContainerH = 550, 250

  local controlPanel = loveframes.Create("panel")
	controlPanel:SetSize(200, 600)

	btload = loveframes.Create('button', controlPanel)	
	btload:SetPos(0,0)
	btload:SetSize(200, 25)
	btload:SetText('Load Image')
	btload.OnClick = function(object)
		l = loadDialog(fsload, {'All | *.*', 'Jpeg | *.jpg *.jpeg', 'PNG | *.png', 'Bitmap | *.bmp', '*.gif'})
	end

	btsave = loveframes.Create('text', controlPanel)	
	btsave:SetPos(0,25)
	btsave:SetText('Grayscale Conversion')

  local multichoice = loveframes.Create("multichoice", controlPanel)
	multichoice:SetPos(0,50)
	multichoice:SetSize(200, 25)
  for i = 0, #conv.grayTypes  do
    multichoice:AddChoice(conv.grayTypes[i])
  end
  multichoice:SelectChoice(grayType)
  multichoice.OnChoiceSelected = function(object, choice)
    grayType = choice
  end
 
  local strengthLabel = loveframes.Create("text", controlPanel)
  strengthLabel:SetPos(20, 80)
  strengthLabel:SetText("strength ("..(strength*100)..")")
 
  local slider = loveframes.Create("slider", controlPanel)
  slider:SetPos(0, 100)
  slider:SetWidth(200)
  slider:SetMinMax(0, 1)
  slider:SetValue(strength)
  slider.OnValueChanged = function(object)
    strength = object:GetValue()
    strengthLabel:SetText("strength ("..(strength*100)..")")
    return true
  end
 
  local stepsLabel = loveframes.Create("text", controlPanel)
  stepsLabel:SetPos(20, 125)
  stepsLabel:SetText("steps ("..steps..")")
 
  local steps_slider = loveframes.Create("slider", controlPanel)
  steps_slider:SetPos(0, 150)
  steps_slider:SetWidth(200)
  steps_slider:SetMinMax(0, 50)
  steps_slider:SetValue(strength)
  steps_slider:SetDecimals(0)
  steps_slider.OnValueChanged = function(object)
    steps = object:GetValue()
    stepsLabel:SetText("steps ("..steps..")")
    return true
  end
 
  invert = loveframes.Create("checkbox", controlPanel)
  invert:SetText("Invert Normal")
  invert:SetPos(20, 175)

	btload = loveframes.Create('button', controlPanel)	
	btload:SetPos(0,200)
	btload:SetSize(200, 25)
	btload:SetText('Generate Shitty Normal')
	btload.OnClick = function(object)
    generateNormal()
	end
 
  generateImageFrame = loveframes.Create("image", window)
  generateImageFrame:SetImage("placeholder.png")
  scale = math.min(imageContainerW / generateImageFrame:GetImageWidth(), imageContainerH / generateImageFrame:GetImageHeight())
  generateImageFrame:SetScale(scale)
  generateImageFrame:SetPos(225, 0)

  generateNormalFrame = loveframes.Create("image", window)
  generateNormalFrame:SetImage("placeholder.png")
  generateNormalFrame:SetScale(scale)
  generateNormalFrame:SetPos(225, 300)

	loadNormal = loveframes.Create('button', controlPanel)	
	loadNormal:SetPos(0,225)
	loadNormal:SetSize(200, 25)
	loadNormal:SetText('Load Normal')
	loadNormal.OnClick = function(object)
		l = loadDialog(fsloadn, {'All | *.*', 'Jpeg | *.jpg *.jpeg', 'PNG | *.png', 'Bitmap | *.bmp', '*.gif'})
	end

	trimNormalbtn = loveframes.Create('button', controlPanel)	
	trimNormalbtn:SetPos(0, 250)
	trimNormalbtn:SetSize(200, 25)
	trimNormalbtn:SetText('Trim Normal')
	trimNormalbtn.OnClick = function(object)
    trimNormal()
	end

	saveNormal = loveframes.Create('button', controlPanel)	
	saveNormal:SetPos(0, 275)
	saveNormal:SetSize(200, 25)
	saveNormal:SetText('Save Normal')
	saveNormal.OnClick = function(object)
		if normal then s = saveDialog(fssave) end
	end
end

function generateNormal()
  if img then
    local heightmap = conv.ImageToHeightmap(img, grayType)
    normal = conv.HeightmapToNormalmap(img, strength, steps, invert:GetEnabled())
    generateNormalFrame:SetImage(normal)
    generateNormalFrame:SetScale(scale)
  end
end

function trimNormal()
  if img and normal then
    normal = conv.trimAlpha(normal, img)
  end
end

function love.update(dt)
	if fsload.selectedFile then
		img = fsload:loadImage()
	end
	if fsloadn.selectedFile then
		normal = fsloadn:loadImage()
	end
  if normal then
    generateNormalFrame:SetImage(normal)
    scale = math.min(imageContainerW / generateNormalFrame:GetImageWidth(), imageContainerH / generateNormalFrame:GetImageHeight())
    generateNormalFrame:SetScale(scale)
  end
  if img then
    generateImageFrame:SetImage(img)
    scale = math.min(imageContainerW / generateImageFrame:GetImageWidth(), imageContainerH / generateImageFrame:GetImageHeight())
    generateImageFrame:SetScale(scale)
  end
	if fssave and fssave.selectedFile then
		fssave:saveImage(normal)
	end
	loveframes.update(dt)
end

function love.draw()
	loveframes.draw()
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
	loveframes.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	loveframes.keyreleased(key)
end

function love.textinput(text)
	loveframes.textinput(text)
end
