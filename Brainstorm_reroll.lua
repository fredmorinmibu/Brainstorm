local lovely = require("lovely")
local nativefs = require("nativefs")

Brainstorm.AUTOREROLL = {}

G.FUNCS.change_search_tag = function(x)
	Brainstorm.SETTINGS.autoreroll.searchTagID = x.to_key
	Brainstorm.SETTINGS.autoreroll.searchTag = Brainstorm.SearchTagList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_tag_count = function(x)
	Brainstorm.SETTINGS.autoreroll.searchTagCount = x.to_val
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_legendary_1 = function(x)
	Brainstorm.SETTINGS.autoreroll.searchLegendary1ID = x.to_key
	Brainstorm.SETTINGS.autoreroll.searchLegendary1 = Brainstorm.SearchLegendaryList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_legendary_2 = function(x)
	Brainstorm.SETTINGS.autoreroll.searchLegendary2ID = x.to_key
	Brainstorm.SETTINGS.autoreroll.searchLegendary2 = Brainstorm.SearchLegendaryList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_rare_joker = function(x)
	Brainstorm.SETTINGS.autoreroll.searchRareJoker = Brainstorm.SearchRareJokerList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_edition = function(x)
	Brainstorm.SETTINGS.autoreroll.searchEditionID = x.to_key
	Brainstorm.SETTINGS.autoreroll.searchEdition = Brainstorm.SearchEditionList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_voucher = function(x)
	Brainstorm.SETTINGS.autoreroll.searchVoucher = Brainstorm.SearchVoucherList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_pack = function(x)
	Brainstorm.SETTINGS.autoreroll.searchPackID = x.to_key
	Brainstorm.SETTINGS.autoreroll.searchPack = Brainstorm.SearchPackList[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_search_soul_count = function(x)
	Brainstorm.SETTINGS.autoreroll.searchForSoul = x.to_val
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

G.FUNCS.change_seeds_per_frame = function(x)
	Brainstorm.SETTINGS.autoreroll.seedsPerFrameID = x.to_key
	Brainstorm.SETTINGS.autoreroll.seedsPerFrame = Brainstorm.seedsPerFrame[x.to_val]
	nativefs.write(lovely.mod_dir .. "/Brainstorm/settings.lua", STR_PACK(Brainstorm.SETTINGS))
end

Brainstorm.AUTOREROLL.autoRerollActive = false
Brainstorm.AUTOREROLL.rerollInterval = 0.01 -- Time interval between rerolls (in seconds)
Brainstorm.AUTOREROLL.rerollTimer = 0

function FastReroll()
	G.GAME.viewed_back = nil
	G.run_setup_seed = G.GAME.seeded
	G.challenge_tab = G.GAME and G.GAME.challenge and G.GAME.challenge_tab or nil
	G.forced_seed, G.setup_seed = nil, nil
	if G.GAME.seeded then
		G.forced_seed = G.GAME.pseudorandom.seed
	end
	local current_stake = G.GAME.stake
	local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
	local _challenge = G.challenge_tab
	if not G.challenge_tab then
		_stake = current_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
	else
		_stake = 1
	end
	G:delete_run()
	G:start_run({ stake = _stake, seed = _seed, challenge = _challenge })
end

-- The first draw of "Tag1" is the Small Blind tag, the second the Big Blind tag
function Brainstorm.next_tag(seed_found)
	-- Skip the tags the game culls from its pool (Multiplayer removes its own), so the pick matches the real one
	return pseudorandom_element(G.P_CENTER_POOLS["Tag"], Brainstorm.pseudoseed("Tag1" .. seed_found), {
		in_pool = function(v)
			return not (MP and MP.should_exclude_from_pool(v))
		end,
	}).key
end

-- Mimics create_card for the Rare Tag: locked Jokers stay in the pool as gaps, and hitting one resamples
function Brainstorm.next_rare_tag_joker(seed_found, ante)
	local pool = {}
	for _, v in ipairs(G.P_JOKER_RARITY_POOLS[3]) do
		if not (MP and MP.should_exclude_from_pool(v)) then
			local banned = G.GAME.banned_keys and G.GAME.banned_keys[v.key]
			pool[#pool + 1] = (v.unlocked == false or banned) and "UNAVAILABLE" or v.key
		end
	end
	local pool_key = "Joker3rta" .. ante
	local joker = pseudorandom_element(pool, Brainstorm.pseudoseed(pool_key .. seed_found))
	local it = 1
	while joker == "UNAVAILABLE" do
		it = it + 1
		joker = pseudorandom_element(pool, Brainstorm.pseudoseed(pool_key .. "_resample" .. it .. seed_found))
	end
	return joker
end

-- Mimics create_card for The Soul: a Legendary already owned is unavailable, so the game resamples
function Brainstorm.next_legendary(seed_found, owned)
	local pool = {}
	for _, v in ipairs(G.P_JOKER_RARITY_POOLS[4]) do
		if not (MP and MP.should_exclude_from_pool(v)) then
			pool[#pool + 1] = v.key
		end
	end
	local legendary = pseudorandom_element(pool, Brainstorm.pseudoseed("Joker4" .. seed_found))
	local it = 1
	while legendary == owned do
		it = it + 1
		legendary = pseudorandom_element(pool, Brainstorm.pseudoseed("Joker4_resample" .. it .. seed_found))
	end
	return legendary
end

-- The edition roll of a Legendary from The Soul, used in Ante 1
function Brainstorm.next_legendary_edition(seed_found)
	local poll = pseudorandom(Brainstorm.pseudoseed("edisou1" .. seed_found))
	if poll > 0.997 then
		return "e_negative"
	elseif poll > 0.994 then
		return "e_polychrome"
	elseif poll > 0.98 then
		return "e_holo"
	elseif poll > 0.96 then
		return "e_foil"
	end
	return ""
end

-- The Voucher pool at the start of a run on this deck or challenge, whatever has been bought since
function Brainstorm.voucher_pool()
	local used = {}
	local back = G.GAME.selected_back
	local config = back and back.effect and back.effect.config or {}
	if config.voucher then
		used[config.voucher] = true
	end
	for _, v in pairs(config.vouchers or {}) do
		used[v] = true
	end
	for _, v in ipairs(G.GAME.challenge_tab and G.GAME.challenge_tab.vouchers or {}) do
		used[v.id] = true
	end
	local banned = G.GAME.banned_keys or {}
	local pool = {}
	for _, v in ipairs(G.P_CENTER_POOLS["Voucher"]) do
		if not (MP and MP.should_exclude_from_pool(v)) then
			local available = v.unlocked ~= false and not used[v.key] and not banned[v.key]
			for _, required in pairs(v.requires or {}) do
				if not used[required] then
					available = false
				end
			end
			pool[#pool + 1] = available and v.key or "UNAVAILABLE"
		end
	end
	return pool
end

function Brainstorm.table_has(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

-- Mimics SMODS.get_next_vouchers for the first shop
function Brainstorm.next_voucher(seed_found, pool)
	local voucher = pseudorandom_element(pool, Brainstorm.pseudoseed("Voucher1" .. seed_found))
	local it = 1
	while voucher == "UNAVAILABLE" do
		it = it + 1
		voucher = pseudorandom_element(pool, Brainstorm.pseudoseed("Voucher1_resample" .. it .. seed_found))
	end
	return voucher
end

function Brainstorm.stop_search(message)
	Brainstorm.AUTOREROLL.autoRerollActive = false
	Brainstorm.clear_reroll_text()
	saveManagerAlert(message)
end

function Brainstorm.center_name(key)
	return G.P_CENTERS[key] and G.P_CENTERS[key].name or key
end

-- Kept in Balatro's save folder, so updating the mod doesn't lose the history
function Brainstorm.log_found_seed(seed_found, draws, rare_found)
	local parts = {
		os.date("%Y-%m-%d %H:%M"),
		seed_found,
		G.GAME.selected_back.name,
		"Stake " .. G.GAME.stake,
		"Tags: " .. G.P_TAGS[G.GAME.round_resets.blind_tags.Small].name .. ", " .. G.P_TAGS[G.GAME.round_resets.blind_tags.Big].name,
		"Voucher: " .. Brainstorm.center_name(G.GAME.current_round.voucher[1]),
	}
	for i, draw in ipairs(draws or {}) do
		local edition = draw.edition ~= "" and (Brainstorm.center_name(draw.edition) .. " ") or ""
		parts[#parts + 1] = "Soul " .. i .. ": " .. edition .. Brainstorm.center_name(draw.joker)
	end
	if rare_found then
		parts[#parts + 1] = "Rare Tag: " .. Brainstorm.center_name(rare_found)
	end
	parts[#parts + 1] = Brainstorm.format_count(Brainstorm.AUTOREROLL.seedsTried or 0) .. " seeds tried"
	love.filesystem.append("brainstorm_seeds.txt", table.concat(parts, " | ") .. "\n")
end

function Brainstorm.auto_reroll()
	-- A locked or removed Joker never comes out of the Rare Tag, so that search could never end
	local wanted = Brainstorm.SETTINGS.autoreroll.searchRareJoker or ""
	local center = G.P_CENTERS[wanted]
	if wanted ~= "" and (Brainstorm.SETTINGS.autoreroll.searchTagCount or 1) < 2 and (not center or center.unlocked == false) then
		Brainstorm.stop_search((center and center.name or wanted) .. " is not available on this profile")
		return nil
	end
	-- Same for a Voucher this deck can't offer in its first shop
	local voucher = Brainstorm.SETTINGS.autoreroll.searchVoucher or ""
	local voucher_pool = voucher ~= "" and Brainstorm.voucher_pool()
	if voucher_pool and not Brainstorm.table_has(voucher_pool, voucher) then
		Brainstorm.stop_search(Brainstorm.center_name(voucher) .. " can't be in the first shop on this deck")
		return nil
	end
	local draws, rare_found = nil, nil
	local rerollsThisFrame = 0
	-- This part is meant to mimic how Balatro rerolls for Gold Stake
	local extra_num = -0.561892350821
	local seed_found = nil
	while not seed_found and rerollsThisFrame < Brainstorm.SETTINGS.autoreroll.seedsPerFrame do
		rerollsThisFrame = rerollsThisFrame + 1
		extra_num = extra_num + 0.561892350821
		seed_found = random_string(
			8,
			extra_num
				+ G.CONTROLLER.cursor_hover.T.x * 0.33411983
				+ G.CONTROLLER.cursor_hover.T.y * 0.874146
				+ 0.412311010 * G.CONTROLLER.cursor_hover.time
		)
		Brainstorm.random_state = {
			hashed_seed = pseudohash(seed_found),
		}
		if Brainstorm.SETTINGS.autoreroll.searchTag ~= "" then
			for i = 1, Brainstorm.SETTINGS.autoreroll.searchTagCount or 1 do
				_tag = Brainstorm.next_tag(seed_found)
				if _tag ~= Brainstorm.SETTINGS.autoreroll.searchTag then
					seed_found = nil
					break
				end
			end
		end
		if seed_found and Brainstorm.SETTINGS.autoreroll.searchForSoul then
			-- Check if arcana pack from skip has The Soul
			for i = 1, Brainstorm.SETTINGS.autoreroll.searchForSoul do
				local soul_found = false
				for i = 1, 5 do
					if pseudorandom(Brainstorm.pseudoseed("soul_Tarot1" .. seed_found)) > 0.997 then
						-- The game stops rolling for The Soul once one is in the pack, so the next pack picks up from here
						soul_found = true
						break
					end
				end
				if not soul_found then
					seed_found = nil
					break
				end
			end
		end
		local rare_joker = Brainstorm.SETTINGS.autoreroll.searchRareJoker or ""
		local tag_count = Brainstorm.SETTINGS.autoreroll.searchTagCount or 1
		-- Two search tags fill both skips, so there is no room for a Rare Tag
		if seed_found and rare_joker ~= "" and tag_count < 2 then
			local ante = nil
			local search_tag = Brainstorm.SETTINGS.autoreroll.searchTag
			if search_tag == "tag_rare" or (search_tag == "" and Brainstorm.next_tag(seed_found) == "tag_rare") then
				-- Skip the Small Blind only: the Joker comes in the shop after the Big Blind, still Ante 1
				ante = 1
			elseif Brainstorm.next_tag(seed_found) == "tag_rare" then
				-- Skipping the Big Blind puts it in the shop after the Boss, which is already Ante 2
				ante = 2
			end
			rare_found = ante and Brainstorm.next_rare_tag_joker(seed_found, ante)
			if rare_found ~= rare_joker then
				seed_found = nil
			end
		end
		local souls = Brainstorm.SETTINGS.autoreroll.searchForSoul or 0
		local legendary1 = Brainstorm.SETTINGS.autoreroll.searchLegendary1 or ""
		local legendary2 = Brainstorm.SETTINGS.autoreroll.searchLegendary2 or ""
		local edition = Brainstorm.SETTINGS.autoreroll.searchEdition or ""
		draws = {}
		if seed_found then
			-- Souls give their Legendary and its edition in the order they are used
			for i = 1, souls do
				local joker = Brainstorm.next_legendary(seed_found, draws[1] and draws[1].joker)
				draws[i] = { joker = joker, edition = Brainstorm.next_legendary_edition(seed_found) }
			end
		end
		if seed_found and souls > 0 and (legendary1 ~= "" or (souls > 1 and legendary2 ~= "")) then
			local first = draws[1].joker
			local second = draws[2] and draws[2].joker
			if souls > 1 and legendary1 ~= "" and legendary2 ~= "" and legendary1 ~= legendary2 then
				-- Two different picks count in either order
				local other = (first == legendary1 and legendary2) or (first == legendary2 and legendary1)
				if not other or second ~= other then
					seed_found = nil
				end
			else
				if legendary1 ~= "" and first ~= legendary1 then
					seed_found = nil
				end
				-- The second Legendary can never match the first, so the same pick twice only checks the first
				if seed_found and souls > 1 and legendary2 ~= "" and legendary2 ~= first then
					if second ~= legendary2 then
						seed_found = nil
					end
				end
			end
		end
		if seed_found and souls > 0 and edition ~= "" then
			-- With a Legendary chosen, the edition has to be on that Legendary
			local any_legendary = legendary1 == "" and (souls < 2 or legendary2 == "")
			local edition_found = false
			for _, draw in ipairs(draws) do
				local chosen = any_legendary or draw.joker == legendary1 or (souls > 1 and draw.joker == legendary2)
				if chosen and draw.edition == edition then
					edition_found = true
				end
			end
			if not edition_found then
				seed_found = nil
			end
		end
		if seed_found and voucher ~= "" and Brainstorm.next_voucher(seed_found, voucher_pool) ~= voucher then
			seed_found = nil
		end
		if seed_found and Brainstorm.SETTINGS.autoreroll.searchPack and #Brainstorm.SETTINGS.autoreroll.searchPack > 0 then
		    local cume, it, center = 0, 0, nil
			for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
				if (not _type or _type == v.kind) then cume = cume + (v.weight or 1 ) end
			end
			local poll = pseudorandom(Brainstorm.pseudoseed("shop_pack1"..seed_found))*cume
			for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
				if not _type or _type == v.kind then it = it + (v.weight or 1) end
				if it >= poll and it - (v.weight or 1) <= poll then center = v
break end
			end
			local pack_found = false
			for i = 1, #Brainstorm.SETTINGS.autoreroll.searchPack do
				if Brainstorm.SETTINGS.autoreroll.searchPack[i] == center.key then
					pack_found = true
					break
				end
			end
			if not pack_found then
				seed_found = nil
			end
		end
		--[[
		Relevant vanilla pack code
		    local cume, it, center = 0, 0, nil
			for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
				if (not _type or _type == v.kind) and not G.GAME.banned_keys[v.key] then cume = cume + (v.weight or 1 ) end
			end
			local poll = pseudorandom(pseudoseed((_key or 'pack_generic')..G.GAME.round_resets.ante))*cume
			for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
				if not G.GAME.banned_keys[v.key] then 
					if not _type or _type == v.kind then it = it + (v.weight or 1) end
					if it >= poll and it - (v.weight or 1) <= poll then center = v; break end
				end
			end
			return center
		]]
	end
	Brainstorm.AUTOREROLL.seedsTried = (Brainstorm.AUTOREROLL.seedsTried or 0) + rerollsThisFrame
	if seed_found then
		_stake = G.GAME.stake
		G:delete_run()
		G:start_run({
			stake = _stake,
			seed = seed_found,
			challenge = G.GAME and G.GAME.challenge and G.GAME.challenge_tab,
		})
		G.GAME.seeded = false
		pcall(Brainstorm.log_found_seed, seed_found, draws, rare_found)
		saveManagerAlert("Found " .. seed_found .. " after " .. Brainstorm.format_count(Brainstorm.AUTOREROLL.seedsTried) .. " seeds")
	end
	return seed_found
end

function Brainstorm.searchParametersMet()
	--note: this appears to be deprecated, so I didn't update it
	if not G or not G.GAME or not G.GAME.round_resets or not G.GAME.round_resets.blind_tags then
		print("One or more variables are nil or undefined")
		return false
	end

	local _tag = G.GAME.round_resets.blind_tags.Small
	if not _tag then
		print("Value of _tag is nil or undefined")
		return false
	end

	if _tag == Brainstorm.SETTINGS.autoreroll.searchTag then
		if Brainstorm.SETTINGS.autoreroll.searchForSoul then
			return true
		end
		-- Check if arcana pack from skip has The Soul
		Brainstorm.random_state = copy_table(G.GAME.pseudorandom)
		for i = 1, 5 do
			if pseudorandom(Brainstorm.pseudoseed("soul_Tarot1")) > 0.997 then
				return true
			end
		end
		return false
	else
		return false
	end
end

function wait(seconds)
	local start = os.clock()
	while os.clock() - start < seconds do
		-- Busy wait
	end
end

function Brainstorm.pseudoseed(key, predict_seed)
	if key == "seed" then
		return math.random()
	end

	if predict_seed then
		local _pseed = pseudohash(key .. (predict_seed or ""))
		_pseed = math.abs(tonumber(string.format("%.13f", (2.134453429141 + _pseed * 1.72431234) % 1)))
		return (_pseed + (pseudohash(predict_seed) or 0)) / 2
	end

	if not Brainstorm.random_state[key] then
		Brainstorm.random_state[key] = pseudohash(key .. (Brainstorm.random_state.seed or ""))
	end

	Brainstorm.random_state[key] =
		math.abs(tonumber(string.format("%.13f", (2.134453429141 + Brainstorm.random_state[key] * 1.72431234) % 1)))
	return (Brainstorm.random_state[key] + (Brainstorm.random_state.hashed_seed or 0)) / 2
end

--Used for reroll UI
--Based on Balatro's attention_text
function Brainstorm.attention_text(args)
    args = args or {}
    args.text = args.text or 'test'
    args.scale = args.scale or 1
    args.colour = copy_table(args.colour or G.C.WHITE)
    args.hold = (args.hold or 0) + 0.1*(G.SPEEDFACTOR)
    args.pos = args.pos or {x = 0, y = 0}
    args.align = args.align or 'cm'
    args.emboss = args.emboss or nil

    args.fade = 1

    if args.cover then
      args.cover_colour = copy_table(args.cover_colour or G.C.RED)
      args.cover_colour_l = copy_table(lighten(args.cover_colour, 0.2))
      args.cover_colour_d = copy_table(darken(args.cover_colour, 0.2))
    else
      args.cover_colour = copy_table(G.C.CLEAR)
    end

    args.uibox_config = {
      align = args.align or 'cm',
      offset = args.offset or {x=0,y=0}, 
      major = args.cover or args.major or nil,
    }

    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0,
      blockable = false,
      blocking = false,
      func = function()
          args.AT = UIBox{
            T = {args.pos.x,args.pos.y,0,0},
            definition = 
              {n=G.UIT.ROOT, config = {align = args.cover_align or 'cm', minw = (args.cover and args.cover.T.w or 0.001) + (args.cover_padding or 0), minh = (args.cover and args.cover.T.h or 0.001) + (args.cover_padding or 0), padding = 0.03, r = 0.1, emboss = args.emboss, colour = args.cover_colour}, nodes={
                {n=G.UIT.O, config={draw_layer = 1, object = DynaText({scale = args.scale, string = args.text, maxw = args.maxw, colours = {args.colour},float = true, shadow = true, silent = not args.noisy, args.scale, pop_in = 0, pop_in_rate = 6, rotate = args.rotate or nil})}},
              }}, 
            config = args.uibox_config
          }
          args.AT.attention_text = true

          args.text = args.AT.UIRoot.children[1].config.object
          args.text:pulse(0.5)

          if args.cover then
            Particles(args.pos.x,args.pos.y, 0,0, {
              timer_type = 'TOTAL',
              timer = 0.01,
              pulse_max = 15,
              max = 0,
              scale = 0.3,
              vel_variation = 0.2,
              padding = 0.1,
              fill=true,
              lifespan = 0.5,
              speed = 2.5,
              attach = args.AT.UIRoot,
              colours = {args.cover_colour, args.cover_colour_l, args.cover_colour_d},
          })
          end
          if args.backdrop_colour then
            args.backdrop_colour = copy_table(args.backdrop_colour)
            Particles(args.pos.x,args.pos.y,0,0,{
              timer_type = 'TOTAL',
              timer = 5,
              scale = 2.4*(args.backdrop_scale or 1), 
              lifespan = 5,
              speed = 0,
              attach = args.AT,
              colours = {args.backdrop_colour}
            })
          end
          return true
      end
      }))
      return args
end

function Brainstorm.remove_attention_text(args)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        blockable = false,
        blocking = false,
        func = function()
          if not args.start_time then
            args.start_time = G.TIMERS.TOTAL
            args.text:pop_out(3)
          else
            --args.AT:align_to_attach()
            args.fade = math.max(0, 1 - 3*(G.TIMERS.TOTAL - args.start_time))
            if args.cover_colour then args.cover_colour[4] = math.min(args.cover_colour[4], 2*args.fade) end
            if args.cover_colour_l then args.cover_colour_l[4] = math.min(args.cover_colour_l[4], args.fade) end
            if args.cover_colour_d then args.cover_colour_d[4] = math.min(args.cover_colour_d[4], args.fade) end
            if args.backdrop_colour then args.backdrop_colour[4] = math.min(args.backdrop_colour[4], args.fade) end
            args.colour[4] = math.min(args.colour[4], args.fade)
            if args.fade <= 0 then
              args.AT:remove()
              return true
            end
          end
        end
      }))
end