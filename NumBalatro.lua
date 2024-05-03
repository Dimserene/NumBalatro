--- STEAMODDED HEADER
--- MOD_NAME: NumBalatro
--- MOD_ID: NumBalatro
--- MOD_AUTHOR: [Numbuh214]
--- MOD_DESCRIPTION: Game balance tweaks that I've either thought of, or have seen and been inspired by. (Credits for the latter will be added as they come.)
--- PRIORITY: 214

----------------------------------------------
------------MOD CODE -------------------------
function SMODS.INIT.NumBalatro()

    local numbuh_mod = SMODS.findModByID("NumBalatro")
    G.P_CENTERS.b_black.config = {
      voucher = 'v_hieroglyph',
      hands = 0,
      joker_slot = 1
    }
    G.localization.descriptions['Back']['b_black'].text =
    {
      "{C:attention}+#1#{} Joker slot",
      "Start run with the",
      "{C:attention,T:v_hieroglyph}Hieroglyph{} voucher",
      " ",
      "{S:0.75}{C:inactive}Idea by {C:attention}u/Winderkorffin{} and {C:attention}u/Purasangre{}"
    }
    G.localization.descriptions['Joker']['j_superposition'].text =
    {
      "{C:attention}Straights{} can loop {C:inactive}(ex: K, Q, A, 2, 3){}",
      "and hands containing a {C:attention}Straight{}",
      "and an {C:attention}Ace{} create a {C:tarot}Tarot{} card",
      "{C:inactive}(Must have room)"
    }
    G.localization.descriptions['Joker']['j_seance'].text =
    {
        "Gains {X:mult,C:white}X#1#{} Mult per {C:spectral}Spectral{} card",
        "used this run {C:inactive}(currently {X:mult,C:white}X#2#{C:inactive} Mult){}",
        "Playing a {C:attention}#3#{} creates",
        "a random {C:spectral}Spectral{} card",
        "{C:inactive}(Must have room)"
    }
    newJokers = {
      onearmed_bandit = {
        name = "One-Armed Bandit",
        set = "Joker",
        rarity = 2,
        cost = 7,
        config = {
        
        },
        loc_text = {
          text = {
            "Each played {C:attention}7{}",
            "becomes a {C:attention}Lucky{}",
            "card when scored",
          }
        },
        loc_vars = {
        }
      },
    punchclock = {
      name = "Punch Clock",
      set = "Joker",
      rarity = 2,
      cost = 5,
      config = {
        extra = {
          chips = 40,
          mult = 15
        }
      },
      loc_text = {
        text = {
          "Each played {C:attention}9{} or {C:attention}5{} gives",
          "{C:chips}+#2#{} Chips when scored"
        }
      },
      loc_vars = {
        "mult",
        "chips"
      }
    },
      magicnumber = {
        name = "Magic Number",
        set = "Joker",
        rarity = 1,
        cost = 3,
        config = {
          extra = {
            chips = 30,
            mult = 6,
            x_mult = 1.2
          }
        },
        loc_text = {
          text = {
            "Each played {C:attention}3{} gives",
            "{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult,",
            "or {X:mult,C:white}X#3#{} Mult when scored"
          }
        },
        loc_vars = {
          "chips",
          "mult",
          "x_mult"
        }
      },
    }
    local order =
      {
       "onearmed_bandit",
       "punchclock",
       "magicnumber",
      }
    local j_table = {}
    for k, v in pairs(newJokers) do
      --sendDebugMessage("Creating sprite for "..v.name.."...")
      local s = SMODS.Sprite:new(
        "j_numbuh_"..k,
        numbuh_mod.path,
        "j_"..k..".png",
        71, 95,
        "asset_atli"
      )
      --sendDebugMessage("Sprite created successfully!")
      s:register()
    end
    table.sort(newJokers, function(a, b) return a.order < b.order end)
    for _, k in ipairs(order) do
      local v = newJokers[k]
      --sendDebugMessage(v.name)
      --sendDebugMessage("Creating definition for "..v.name.."...")
      v.loc_text.name = v.name
      local j = SMODS.Joker:new(v.name, "numbuh_"..k, v.config,{x = 0,y = 0},v.loc_text,v.rarity, v.cost, true, true, true, true, nil, "j_numbuh_"..k, nil)
      --sendDebugMessage("Definition created successfully!")
      j_table[k] = j
      j:register()
      j.loc_def = function()
	    local results = {}
		for _, key in pairs(v.loc_vars) do
		  results[#results+1] = j.config.extra[key]
		end
        return results
      end
      sendDebugMessage(tostring(j.name))
      for k2, v2 in pairs(j.loc_txt.text) do
        sendDebugMessage(k2..": "..v2)
      end
    end
end

local get_straight_ref = get_straight
function get_straight(hand)
  local base = get_straight_ref(hand)
  local results = {}
  local vals = {}
  local verified = {}
  local can_loop = next(find_joker('Superposition'))
  local target = next(find_joker('Four Fingers')) and 4 or 5
  local skip_var = next(find_joker('Shortcut')) and 2 or 1
  
  if #base > 0 or not(can_loop) or #hand < target then
    return base
  else
    table.sort(hand,function(a,b) return a:get_id() > b:get_id() end)
    for i=1, #hand do
	  sendDebugMessage(hand[i]:get_id()+13)
	  table.insert(vals,hand[i]:get_id()+13)
	end
    for i=1, #hand do
	  sendDebugMessage(hand[i]:get_id())
	  table.insert(vals,hand[i]:get_id())
	end
	sendDebugMessage("--------------------------------------")
	for i=2,#vals do
	  if vals[i-1]-vals[i] > 0 and vals[i-1]-vals[i] <= skip_var then
	    if i == 2 then
		  verified[1] = true
	    --sendDebugMessage("1: "..hand[1]:get_id())
		end
		local x = (i-1)%#hand+1
		hand[x].verified = true
	    --sendDebugMessage(x..": "..hand[x]:get_id())
	  end
	end
	table.sort(hand,function(a,b) return a.T.x <  b.T.x end)
	for i=1,#hand do
	 if hand[i].verified == true then
	   table.insert(results,hand[i])
	 end
	end
	if #results == target then return {results} end
  end
  return {}
end

local init_game_object_ref = Game.init_game_object
function Game:init_game_object()
    local t = init_game_object_ref(self)
    t.hands['Straight'].l_mult = 3
    t.hands['Straight Flush'].l_mult = 4
    return t
end

function generate_badges(card, loc_vars)
    local badges = {}
    if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or card.debuff then
        badges.card_type = card_type
    end
    if card.ability.set == 'Joker' and card.bypass_discovery_ui then
        badges.force_rarity = true
    end
    if card.edition then
        if card.edition.type == 'negative' and card.ability.consumeable then
            badges[#badges + 1] = 'negative_consumable'
        else
            badges[#badges + 1] = (card.edition.type == 'holo' and 'holographic' or card.edition.type)
        end
    end
    if card.seal then badges[#badges + 1] = string.lower(card.seal)..'_seal' end
    if card.ability.eternal then badges[#badges + 1] = 'eternal' end
    if card.ability.perishable then
        loc_vars = loc_vars or {}; loc_vars.perish_tally=card.ability.perish_tally
        badges[#badges + 1] = 'perishable'
    end
    if card.ability.rental then badges[#badges + 1] = 'rental' end
    if card.pinned then badges[#badges + 1] = 'pinned_left' end

    if card.sticker then loc_vars = loc_vars or {}; loc_vars.sticker=card.sticker end
	return badges
end

function get_loc_vars(card)
    if card.config.extra == nil then
      sendDebugMessage(card.name.." lacking \"config.extra\".")
      return nil
    end
    for k, v in pairs(newJokers) do
      if v.name == card.name then
        sendDebugMessage(card.name.." found!")
        local loc_def = {}
          for i=1, #v.loc_vars do
            local val = v.loc_vars[i]
            loc_def[#loc_def+1] = card.config.extra[val]
          end
        return loc_def
      end
    end
    sendDebugMessage(card.name.." not found.")
    return nil
end

local startrun_ref = Game.start_run
function Game:start_run(args)
    startrun_ref(self,args)
    if G.GAME.round == 0 then
      if self.GAME.selected_back.name == 'Black Deck' then
        --G.GAME.starting_params.hands = 3
        G.GAME.round_resets.hands = 3
        --G.GAME.current_round.hands = 3
      end
    end
end

local calculate_jokerref = Card.calculate_joker
function Card:calculate_joker(context)
    local calc_ref = calculate_jokerref(self,context)
    if context.before then
      if self.ability.name == 'One-Armed Bandit' then
        for k, v in ipairs(context.full_hand) do
          if v:get_id() == 7 and v.config.center ~= G.P_CENTERS.m_lucky and (G.P_CENTERS.m_xcard and v.config.center ~= G.P_CENTERS.m_xcard) then
            sendDebugMessage("Should make card Lucky")
            v:set_ability(G.P_CENTERS.m_lucky, nil, true)
            card_eval_status_text(v, 'extra', nil, nil, nil, {message = "Lucky!", colour = G.C.MONEY})
            v:juice_up()
          end
        end
      end
    elseif context.individual then
      if self.ability.name == 'Magic Number' and context.other_card:get_id() == 3 then
        local rand = pseudorandom('j_magicnumber')
        if rand < 1.0/3.0 then
          sendDebugMessage("Should give x"..self.ability.extra.x_mult.." mult")
          return {
            x_mult = self.ability.extra.x_mult,
            card = self
          }
        elseif rand < 2.0/3.0 then
          sendDebugMessage("Should give "..self.ability.extra.mult.." mult")
          return {
            mult = self.ability.extra.mult,
            card = self
          }
        else
          sendDebugMessage("Should give "..self.ability.extra.chips.." chips")
          return {
            chips = self.ability.extra.chips,
            card = self
          }
        end
      elseif self.ability.name == 'Punch Clock' and (context.other_card:get_id() == 9 or context.other_card:get_id() == 5) then
        sendDebugMessage("Should give "..self.ability.extra.chips.." chips")
        return {
          chips = self.ability.extra.chips,
          card = self
        }
      end
    elseif (context.joker_main and context.cardarea == G.jokers) then
      if self.ability.name == 'Seance' and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.spectral > 0 then
        return {
          message = localize{type='variable',key='a_xmult',vars={0.5 * G.GAME.consumeable_usage_total.spectral + 1}},
          Xmult_mod = 0.5 * G.GAME.consumeable_usage_total.spectral + 1
        }
      end
    end
    return calc_ref
end
----------------------------------------------
------------MOD CODE END----------------------