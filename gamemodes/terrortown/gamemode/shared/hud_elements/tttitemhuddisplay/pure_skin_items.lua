-- item info
COLOR_DARKGREY = COLOR_DARKGREY or Color(100, 100, 100, 255)

local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	surface.CreateFont("ItemInfoFont", {font = "Trebuchet24", size = 14, weight = 700})

	local padding = 10

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 48, h = 48},
		minsize = {w = 48, h = 48}
	}

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.padding = padding

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return false, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = self.padding, y = ScrH() * 0.5}

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()
		self.padding = padding * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return client:Alive() or client:Team() == TEAM_TERROR
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()

		local basepos = self:GetBasePos()
		local itms = client:GetEquipmentItems()
		local pos = self:GetPos()
		local size = self.size.w

		-- get number of new icons
		local num_icons = 0

		for _, itemCls in ipairs(itms) do
			local item = items.GetStored(itemCls)

			if item and item.hud then
				num_icons = num_icons + 1
			end
		end

		local curY = basepos.y + 0.5 * (num_icons -1) * (self.size.w + self.padding)

		-- at first, calculate old items because they don't take care of the new ones
		for _, itemCls in ipairs(itms) do
			local item = items.GetStored(itemCls)

			if item and item.oldHud then
				curY = curY - 80
			end
		end

		-- now draw our new items automatically
		for _, itemCls in ipairs(itms) do
			local item = items.GetStored(itemCls)

			if item and item.hud then
				curY = curY - (size + self.padding)

				surface.SetDrawColor(36, 115, 51, 255)
				surface.DrawRect(pos.x, curY, size, size)

				util.DrawFilteredTexturedRect(pos.x, curY, size, size, item.hud, 175)

				self:DrawLines(pos.x, curY, size, size, self.basecolor.a)

				if isfunction(item.DrawInfo) then
					local info = item:DrawInfo()
					if info then
						-- right bottom corner
						local tx = pos.x + size - 5
						local ty = curY +  size - 2
						local pad = 5 * self.scale

						surface.SetFont("ItemInfoFont")

						local infoW, infoH = surface.GetTextSize(info)
						infoW = infoW * self.scale
						infoH = (infoH + 2) * self.scale

						local bx = tx - infoW * 0.5 - pad
						local by = ty - infoH * 0.5
						local bw = infoW + pad * 2

						self:DrawBg(bx, by, bw, infoH, self.basecolor)

						self:AdvancedText(info, "ItemInfoFont", tx, ty, self:GetDefaultFontColor(self.basecolor), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, false, self.scale)

						self:DrawLines(bx, by, bw, infoH, self.basecolor.a)
					end
				end
			end
		end

		self:SetSize(size, - math.max(basepos.y - curY, self.minsize.h)) -- adjust the size
	end
end
