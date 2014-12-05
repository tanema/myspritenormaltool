conv = {}

function conv.HeightmapToNormalmap(heightMap, strength, steps, invert)
	local imgData = heightMap:getData()
	local imgData2 = love.image.newImageData(heightMap:getWidth(), heightMap:getHeight())
	local red, green, blue, alpha
	local x, y
	strength = strength or 1.0
  steps = steps or 3
	local matrix = {}
  for i = 1, steps do
    matrix[i] = {}
  end

	for i = 0, heightMap:getHeight() - 1 do
		for k = 0, heightMap:getWidth() - 1 do
			for l = 1, steps do
				for m = 1, steps do
					if k + (l - 1) < 1 then
						x = heightMap:getWidth() - 1
					elseif k + (l - 1) > heightMap:getWidth() - 1 then
						x = 1
					else
						x = k + l - 1
					end

					if i + (m - 1) < 1 then
						y = heightMap:getHeight() - 1
					elseif i + (m - 1) > heightMap:getHeight() - 1 then
						y = 1
					else
						y = i + m - 1
					end

					local red, green, blue, alpha = imgData:getPixel(x, y)
					matrix[l][m] = red
				end
			end

			red = (255 + ((matrix[1][2] - matrix[2][2]) + (matrix[2][2] - matrix[3][2])) * strength) / 2.0
			green = (255 + ((matrix[2][2] - matrix[1][1]) + (matrix[2][3] - matrix[2][2])) * strength) / 2.0
			blue = 192
					
      local _, _, _, alpha = imgData:getPixel(k, i)

      if invert then
			  imgData2:setPixel(k, i, red, 255 - green, blue, alpha)
      else
			  imgData2:setPixel(k, i, red, green, blue, alpha)
      end
		end
	end

	return love.graphics.newImage(imgData2)
end

conv.grayTypes = {'grayscale', 'percievedgreyscale', 'BT.709', 'BT.601', 
    'desaturation', 'maximum decomposition', 'minimum decomposition'}
function conv.ImageToHeightmap(img, type)
	local imgData = img:getData()
	local imgData2 = love.image.newImageData(img:getWidth(), img:getHeight())
	local red, green, blue, alpha
	local x, y, gray

	for y = 0, img:getHeight() - 1 do
		for x = 0, img:getWidth() - 1 do
			local red, green, blue, alpha = imgData:getPixel(x, y)

      if type == 'grayscale' then
        gray = (red + green + blue) / 3
      elseif type == 'percievedgreyscale' then
        gray = (red * 0.3 + green * 0.59 + blue * 0.11)
      elseif type == 'BT.709' then
        gray = (red * 0.2126 + green * 0.7152 + blue * 0.0722)
      elseif type == 'BT.601' then
        gray = (red * 0.299 + green * 0.587 + blue * 0.114)
      elseif type == 'desaturation' then
        gray = (math.max(red, green, blue) + math.min(red, green, blue) ) / 2
      elseif type == 'maximum decomposition' then
        gray = math.max(red, green, blue)
      elseif type == 'minimum decomposition' then
        gray = math.min(red, green, blue)
      else
        print(type)
        gray = (red + green + blue) / 3 --default grayscale
      end

			imgData2:setPixel(x, y, gray, gray, gray, alpha)
		end
	end

  --normalize greyscale
	return love.graphics.newImage(imgData2)
end

function conv.trimAlpha(normal, img)
	local imgData = img:getData()
	local normalData = normal:getData()
	local newNormalData = love.image.newImageData(img:getWidth(), img:getHeight())
	local red, green, blue, alpha
	local x, y

	for y = 0, img:getHeight() - 1 do
		for x = 0, img:getWidth() - 1 do
			local _, _, _, ia = imgData:getPixel(x, y)
			local r, g, b, a = normalData:getPixel(x, y)
      if ia > 0 then
			  newNormalData:setPixel(x, y, r, g, b, ia)
      end
    end
  end

	return love.graphics.newImage(newNormalData)
end

return conv
