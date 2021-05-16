local function findIf(array, func: (any) -> boolean)
	for _, item in pairs(array) do
		if func(item) then
			return item
		end
	end
	return nil
end

local b = string.byte
local namedEscapes = {
	[b("\a")] = "\\a",
	[b("\b")] = "\\b",
	[b("\f")] = "\\f",
	[b("\n")] = "\\n",
	[b("\r")] = "\\r",
	[b("\t")] = "\\t",
	[b("\v")] = "\\v",
}
local function escape(char: number): string?
	if namedEscapes[char] then
		return namedEscapes[char]
	end
	if char < 32 or char == 127 then
		return string.format("\\x%02x", char)
	end

	return nil
end

local function formatColorAttr(color: Color3): string
	return string.format('color="rgb(%d, %d, %d)"', color.R * 255, color.G * 255, color.B * 255)
end

local function escapeTagName(name: string, theme: StudioTheme): string
	local dimmedColor = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText)
	local errorColor = theme:GetColor(Enum.StudioStyleGuideColor.ErrorText)
	local escapeFmt = "<font " .. formatColorAttr(dimmedColor) .. ">%s</font>"
	local errorFmt = "<font " .. formatColorAttr(errorColor) .. ">%s</font>"

	local output = {}
	local offset = 1
	local len = string.len(name)
	local errorStart = nil
	while offset <= len do
		local ok, ch = pcall(utf8.codepoint, name, offset)
		if ok then
			if errorStart then
				local errorContent = ""
				for i = errorStart, offset - 1 do
					local byte = string.byte(name, i)
					errorContent = errorContent .. string.format("\\x%02x", byte or 0)
				end
				table.insert(output, errorFmt:format(errorContent))
				errorStart = nil
			end
			local escaped = escape(ch)
			local charStr = utf8.char(ch)
			if escaped then
				table.insert(output, escapeFmt:format(escaped))
			else
				table.insert(output, charStr)
			end
			offset += charStr:len()
		else
			errorStart = errorStart or offset
			offset += 1
		end
	end

	if errorStart then
		local errorContent = ""
		for i = errorStart, offset - 1 do
			local byte = string.byte(name, i)
			errorContent = errorContent .. string.format("\\x%02x", byte or 0)
		end
		table.insert(output, errorFmt:format(errorContent))
		errorStart = nil
	end

	return table.concat(output)
end

local function merge(orig, new)
	local t = {}
	for k, v in pairs(orig or {}) do
		t[k] = v
	end
	for k, v in pairs(new or {}) do
		t[k] = v
	end
	return t
end

return {
	findIf = findIf,
	escapeTagName = escapeTagName,
	merge = merge,
}
