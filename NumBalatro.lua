--- STEAMODDED HEADER
--- MOD_NAME: NumBalatro
--- MOD_ID: NumBalatro
--- MOD_AUTHOR: [Numbuh214]
--- PREFIX: numbuh
--- MOD_DESCRIPTION: Game balance tweaks that I've either thought of, or have seen and been inspired by. (Credits for the latter will be added as they come.)
--- PRIORITY: 214
----------------------------------------------
------------MOD CODE -------------------------
    local NumBalatro = SMODS.current_mod
    suit_bias = {
      odds = 2,
      name = "Suit Bias: #1#",
      text = {
        "{C:green}#2# in #3#{} chance",
        "to change suit conversion",
        "{C:purple}Tarot{} cards to {V:1}#4#{}",
        --"{C:inactive}{S:0.75}(Changes #5# cards to {V:1}{S:0.75}#1#{C:inactive}{S:0.75})"
      }
    }
    local bd = {set = "Back", name = "Black Deck", key = "b_black"}
    black_deck_text = {
      name = "Black Deck",
      text =
      {
        "{C:attention}+#1#{} Joker slot",
        "Start run with the",
        "{C:attention,T:v_hieroglyph}Hieroglyph{} voucher",
        " ",
        "{S:0.75}{C:inactive}Idea by {C:attention}u/Winderkorffin{C:inactive} and {C:attention}u/Purasangre{}"
      }
    }
    bd.config ={
      voucher = 'v_hieroglyph',
      hands = 0,
      joker_slot = 1
    }
    bd.loc_def = function(self)
      return {
        self.joker_slot,
        "Hieroglyph"
      }
    end
    local ritual = {name="Current Stats",text={"{C:chips}+#1#{} Chips","{C:mult}+#2#{} Mult"}}
    bd.process_loc_text = function()
      SMODS.process_loc_text(G.localization.descriptions.Other, 'suit_bias', {name = suit_bias.name, text = suit_bias.text})
      SMODS.process_loc_text(G.localization.descriptions.Other, 'ritual', ritual)
      SMODS.process_loc_text(G.localization.descriptions.Back, 'b_black', black_deck_text)
    end
    SMODS.Back:take_ownership("b_black",bd):register()
    newJokers =
    {
      {
        key = "onearmed_bandit",
        name = "One-Armed Bandit",
        rarity = 2,
        cost = 7,
        config = {
          odds_retrigger = 10
        },
        loc_text = {
          text = {
            "{C:attention}Lucky{} Cards {C:red}cost {C:money}$1{} when",
            "played, but gain a {C:green}#1# in #2#{}",
            "chance to retrigger once",
            "Odds of both payouts",
            "are also {C:attention}increased{}"
          }
        },
        loc_vars = {
          "odds_retrigger"
        },
        enhancement_gate = 'm_lucky',
        calculate = function(self, card, context)
          --if self then
            --for k,v in pairs(self) do
              --sendDebugMessage(k..": "..tostring(v))
            --end
          --end
          if (context.repetition and context.cardarea == G.play and context.other_card.config.center_key == "m_lucky") then
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Bonus Spin!"})
            return {
              message = localize('k_again_ex'),
              repetitions = 1,
              card = card
            }
          end
          if context.before then
            --takes money from every lucky card played
            for i = 1, #context.scoring_hand do
              if context.scoring_hand[i].config.center_key == "m_lucky" and not context.scoring_hand[i].debuff then
                G.E_MANAGER:add_event(Event({func = function() context.scoring_hand[i]:juice_up(); return true end }))
                ease_dollars(-1)
                delay(0.23)
              end
            end
          end
          if context.individual and context.cardarea == G.play then
          end
          return nil
        end
      },
      {
        key = "punchclock",
        name = "Punch Clock",
        rarity = 2,
        cost = 5,
        config = {
          chips = 40,
          mult = 15
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
        },
        calculate = function(self, card, context)
          if context.individual and context.cardarea == G.play and (context.other_card.base.value == "5" or context.other_card.base.value == "9") then
            return {
              chips = 40
            }
          end
        end
      },
      {
        key = "magicnumber",
        name = "Magic Number",
        rarity = 1,
        cost = 3,
        config = {
          per_chips = 30,
          per_mult = 6,
          per_x_mult = 1.2
        },
        loc_text = {
          text = {
            "Each played {C:attention}3{} gives",
            "{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult,",
            "or {X:mult,C:white}X#3#{} Mult when scored"
          }
        },
        loc_vars = {
          "per_chips",
          "per_mult",
          "per_x_mult"
        },
        calculate = function(self, card, context)
          if context.individual and context.cardarea == G.play then
            if context.other_card.base.value ~= "3" then
              return nil
            end
            local rand = math.floor(3*pseudorandom('magic_number'))
            return {
              chips = rand == 0 and newJokers[3].config.per_chips or nil,
              mult = rand == 1 and newJokers[3].config.per_mult or nil,
              x_mult = rand == 2 and newJokers[3].config.per_x_mult or nil,
              card = context.other_card
            }
          end
        end
      },
      {
        key = "brickbybrick",
        name = "Brick By Brick",
        rarity = 1,
        cost = 5,
        config = {
        },
        loc_text = {
          name = "Brick by Brick",
          text = {
            "{C:attention,T:m_stone}Stone{} cards count",
            "as their own unique {C:attention}rank{}",
          }
        },
        enhancement_gate = 'm_stone',
        loc_vars = {
        },
      },
      {
        key = "brothers_hamm",
        name = "Brothers Hamm",
        rarity = 1,
        cost = 5,
        config = {
          h_size = 0
        },
        loc_text = {
          text = {
            "Gain {C:attention}+1{} hand size (up to {C:attention}+3{}) if",
            "played hand contains a {C:attention}Full House{}",
            "{C:red}Resets{} if other hand type is played",
            "{C:inactive}(currently {C:attention}+#1#{C:inactive} hand size){}",
          }
        },
        loc_vars = {
          "h_size"
        },
        calculate = function(self,card,context)
          if context.joker_main and context.cardarea == G.jokers and context.poker_hands then
            if next(context.poker_hands["Full House"]) then
             if card.ability.h_size < 3 then
                G.hand:change_size(1)
                card.ability.h_size = card.ability.h_size + 1
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = card.ability.h_size.."/3", colour = G.C.GREEN})
                return nil
              end
            elseif card.ability.h_size > 0 then
              G.hand:change_size(-card.ability.h_size)
              card.ability.h_size = 0
              card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize("k_reset"), colour = G.C.RED})
            end
          end
          if context.selling_card and context.card == card then
            G.hand:change_size(-card.ability.h_size)
          end
        end
      },
      {
        key = "climbers",
        name = "The Climbers",
        rarity = 1,
        cost = 5,
        config = {
        },
        loc_text = {
          text = {
            "If played hand contains",
            "hand of higher level,",
            "{C:attention}upgrade{} played hand"
          }
        },
        loc_vars = {
        },
        calculate = function(self,card,context)
          if context.before and not card.debuff then
            local base = nil
            for k, v in pairs(G.handlist) do
              if next(context.poker_hands[v]) then
                if base == nil then
                  base = v
                else
                  if (G.GAME.hands[v].level > G.GAME.hands[base].level) then
                    local thing = context.blueprint_card or card
                    card_eval_status_text(thing, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                    return
                    {
                      card = thing,
                      level_up = true,
                      message = localize('k_level_up_ex')
                    }
                  end
                  --sendDebugMessage(v)
                  --sendDebugMessage(" Level "..G.GAME.hands[v].level)
                end
              end
            end
          end
        end
      },
      
      {
        key = "lucky_rabbit",
        name = "Lucky The Rabbit",
        rarity = 1,
        cost = 7,
        config = {
          mult = 0
        },
        loc_text = {
          text = {
            "All scored {C:attention}7{} cards",
            "become {C:attention}Lucky{}",
            "Gain {C:mult}+7{} Mult for every",
            "{C:attention}Lucky{} card held in hand"
          }
        },
        loc_vars = {
        },
        calculate = function(self,card,context)
          if context.before then
            local sevens = {}
            for i = 1, #context.scoring_hand do
              v = context.scoring_hand[i]
              if v.base.value == "7" and not v.debuff and v.config.center_key ~= "m_lucky" then
                table.insert(sevens, i)
              end
            end
            if #sevens == 0 or type(sevens[1]) ~= "number" then return nil end
            G.E_MANAGER:add_event(Event({
              trigger = "before",
              delay = 0.7,
              blocking = true,
              func = function()
                delay(0.4)
                for k, v in pairs(sevens) do
                  context.scoring_hand[v]:set_ability(G.P_CENTERS.m_lucky, nil)
                  context.scoring_hand[v]:juice_up()
                end
                play_sound('generic1')
                if card.ability.name == newJokers[7].name then
                  card:juice_up()
                end
                return true
              end
            }))
            -- return {
                -- message = "Lucky!",
                -- colour = G.C.MONEY,
                -- card = card
            -- }
          end
          if context.individual and context.cardarea == G.hand and context.other_card and context.other_card.config.center_key == "m_lucky" then
            if context.other_card.debuff then
              return {
                message = localize('k_debuffed'),
                colour = G.C.RED,
                card = card,
              }
            else
              return {
                h_mult = 7,
                card = card
              }
            end
          end
        end
      },
    }
    override =
      {
        "square",
        "seance",
        "superposition",
        "sly",
        "jolly",
        "duo",
        "wily",
        "zany",
        "trio",
        "clever",
        "mad",
        "runner",
        "matador",
        "to_the_moon",
        "ceremonial",
        "red_card",
      }
    oldJokers = {
      square = {
        name = "Square Joker",
        set = "Joker",
        rarity = 3,
        cost = 9,
        config = {
          chips = 0,
          chip_mod = 1
        },
        loc_text = {
          text = {
            "If played hand has exactly",
            "{C:attention}4{} cards, this Joker gains",
            "{C:chips}+#2#{} Chips, and this effect's value",
            "is permanently increased by {C:attention}2{}",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chip#3#)"
          }
        },
        loc_vars = function(self, info_queue, card)
          local singular = self.chips or card.ability.chips
          return
          {
            singular,
            self.chip_mod,
            (singular == 1) and "" or "s"
          }
        end,
        calculate = function(self, card, context)
          if context.before and #context.full_hand == 4 and not context.blueprint then
            card.ability.chips = card.ability.chips + card.ability.chip_mod
            card.ability.chip_mod = card.ability.chip_mod + 2
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
          end
          if context.joker_main and context.cardarea == G.jokers then
            return {
              message = localize{type='variable',key='a_chips',vars={card.ability.chips}},
              colour = G.C.CHIPS,
              chip_mod = card.ability.chips,
              card = card
            }
          end
        end,
        atlas = true
      },
      seance = {
        name = "Seance",
        rarity = 2,
        cost = 6,
        config = {
          x_mult = 0.5,
          current = 1,
        },
        loc_text = {
          name = "Séance",
          text = {
            "Gains {X:mult,C:white}X#1#{} Mult per {C:spectral}Spectral{}",
            "card used this run",
            "{C:inactive}(currently {X:mult,C:white}X#2#{C:inactive} Mult){}",
          }
        },
        loc_vars = {
          "x_mult",
          "current"
        },
        atlas = false
      },
      superposition = {
        name = "Superposition",
        rarity = 2,
        cost = 6,
        config = {
           
        },
        loc_text = {
          text = {
            "{C:attention}Straights{} can loop {C:inactive}(ex: K, Q, A, 2, 3){}",
            "and hands containing a {C:attention}Straight{}",
            "create a random consumable",
            "{C:inactive}(Must have room)"
          }
        },
        loc_vars = {
          "x_mult",
          "current",
          "poker_hand"
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers and next(context.poker_hands["Straight"]) and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local card_types = {'Tarot','Planet','Spectral'}
            local rand = pseudorandom('j_superposition') * 100
            local idx = 1
            if rand < 55 then
              idx = 2
            end
            if rand < 10 then
              idx = 3
            end
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                        local card = create_card(card_types[idx],G.consumeables, nil, nil, nil, nil, nil, 'sup')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                    return true
                end)}))
            return {
                message = localize('k_plus_'..string.lower(card_types[idx])),
                colour = G.C.SECONDARY_SET[card_types[idx]],
                card = card
            }
          end
        end,
        atlas = false
      },
      sly = {
        name = "Sly Joker",
        config = {
          type = "Pair",
          t_chips = 22
        },
        loc_text = {
          text = {
            "{C:chips}+#2#{} Chips for each",
            "unique {C:attention}#1#{} or better",
            "in played hand"
          }
        },
        loc_vars = {
          "type",
          "t_chips"
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers then
            return pair_joker_calc(card, context, 'chips', false)
          end
        end,
        atlas = true
      },
      jolly = {
        name = "Jolly Joker",
        config = {
          type = "Pair",
          t_mult = 6
        },
        loc_text = {
          text = {
            "{C:mult}+#2#{} Mult for each",
            "unique {C:attention}#1#{} or better",
            "in played hand"
          }
        },
        loc_vars = {
          "type",
          "t_mult"
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers then
            return pair_joker_calc(card, context, 'mult', false)
          end
        end,
        atlas = true
      },
      duo = {
        name = "The Duo",
        config = {
          x_mult = 2
        },
        loc_text = {
          text = {
            "{X:mult,C:white}x#1#{} Mult if",
            "played hand has",
            "exactly {C:attention}2{} cards",
            "of a single rank"
          }
        },
        loc_vars = {
          "x_mult"
        },
        calculate = function(self,card,context)
          if context.joker_main and context.cardarea == G.jokers and next(get_X_same(card.ability.x_mult, context.scoring_hand)) and #get_X_same(card.ability.x_mult, context.scoring_hand)[1] == card.ability.x_mult then
            return {
              message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
              colour = G.C.MULT,
              Xmult_mod = card.ability.x_mult or nil,
              card = card
            }
          end
        end,
        atlas = true
      },
      wily = {
        name = "Wily Joker",
        config = {
          type = "Three of a Kind",
          t_chips = 33,
        },
        loc_text = {
          text = {
            "{C:chips}+#2#{} Chips if hand",
            "contains {C:attention}#1#{}",
            "{C:chips}+#3#{} Chips if hand contains",
            "exactly {C:attention}3{} scoring cards",
          }
        },
        loc_vars = {
          "type",
          "t_chips",
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers then
            return oak_joker_calc(card, context, 3, 'chips', false)
          end
        end,
        atlas = true
      },
      zany = {
        name = "Zany Joker",
        config = {
          type = "Three of a Kind",
          t_mult = 6,
        },
        loc_text = {
          text = {
            "{C:mult}+#2#{} Mult if hand",
            "contains {C:attention}#1#{}",
            "{C:mult}+#3#{} Mult if hand contains",
            "exactly {C:attention}3{} scoring cards",
          }
        },
        loc_vars = {
          "type",
          "t_mult",
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers then
            return oak_joker_calc(card, context, 3, 'mult', false)
          end
        end,
        atlas = true
      },
      trio = {
        name = "The Trio",
        config = {
          x_mult = 3
        },
        loc_text = {
          text = {
            "{X:mult,C:white}x#1#{} Mult if",
            "played hand has",
            "exactly {C:attention}3{} cards",
            "of a single rank"
          }
        },
        loc_vars = {
          "x_mult"
        },
        calculate = function(self,card,context)
          if context.joker_main and context.cardarea == G.jokers and next(get_X_same(card.ability.x_mult, context.scoring_hand)) and #get_X_same(card.ability.x_mult, context.scoring_hand)[1] == card.ability.x_mult then
            return {
              message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
              colour = G.C.MULT,
              Xmult_mod = card.ability.x_mult or nil,
              card = card
            }
          end
        end,
        atlas = false
      },
      clever = {
        name = "Clever Joker",
        config = {
          type = "Four of a Kind",
          t_chips = 44,
        },
        loc_text = {
          text = {
            "{C:chips}+#2#{} Chips if hand",
            "contains {C:attention}#1#{}",
            "{C:chips}+#3#{} Chips if hand",
            "has exactly {C:attention}4{} scoring cards"
          }
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers then
            return oak_joker_calc(card, context, 4, 'chips', false)
          end
        end,
        loc_vars = {
          "type",
          "t_chips",
        },
        atlas = true
      },
      mad = {
        name = "Mad Joker",
        config = {
          type = "Four of a Kind",
          t_mult = 8,
        },
        loc_text = {
          text = {
            "{C:mult}+#2#{} Mult if hand",
            "contains {C:attention}#1#{}",
            "{C:mult}+#3#{} Mult if hand",
            "has exactly {C:attention}4{} scoring cards"
          }
        },
        calculate = function(self, card, context)
          if context.joker_main and context.cardarea == G.jokers then
            return oak_joker_calc(card, context, 4, 'mult', false)
          end
        end,
        loc_vars = {
          "type",
          "t_mult",
        },
        atlas = true
      },
      runner = {
        name = "Runner",
        config = {
          chips = 0,
          chip_mod = 1,
        },
        loc_text = {
          text = {
            "If played hand contains a",
            "{C:attention}Straight{}, this Joker gains",
            "{C:chips}+#2#{} Chips, and this effect's value",
            "is permanently increased by {C:attention}1{}",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chip#3#)"
          }
        },
        loc_vars = function(self, info_queue, card)
          return {
            self.chips,
            self.chip_mod,
            self.chips == 1 and "" or "s"
          }
        end,
        calculate = function(self, card, context)
          if context.before and next(context.poker_hands["Straight"]) and not context.blueprint then
            card.ability.chips = card.ability.chips + card.ability.chip_mod
            card.ability.chip_mod = card.ability.chip_mod + 1
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
          end
          if context.joker_main and context.cardarea == G.jokers then
            return {
              message = localize{type='variable',key='a_chips',vars={card.ability.chips}},
              colour = G.C.CHIPS,
              chip_mod = self.chips,
              card = card
            }
          end
        end,
        atlas = false
      },
      crazy = {
        name = "Crazy Joker",
        config = {
          t_mult = 20,
          type = "Straight"
        },
        loc_text = {
          text = {
            "{C:mult}+#2#{} Mult if hand",
            "contains a {C:attention}#1#{}"
          }
        },
        loc_vars = {
          "type",
          "t_mult",
        },
        atlas = false
      },
      devious = {
        name = "Devious Joker",
        config = {
          t_chips = 123,
          type = "Straight"
        },
        loc_text = {
          text = {
            "{C:chips}+#2#{} Chips if hand",
            "contains a {C:attention}#1#{}"
          }
        },
        loc_vars = {
          "type",
          "t_chips",
        },
        atlas = false
      },
      matador = {
        name = "Matador",
        config = {
          big_payout = 5,
          small_payout = 3
        },
        loc_text = {
          text = {
            "Earn {C:money}$#2#{} per card affected by",
            "a {C:attention}Boss Blind{},",
            "and {C:money}$#1#{} when any other",
            "{C:attention}Boss Blind{} ability is triggered",
          }
        },
        loc_vars = {
          "big_payout",
          "small_payout",
        },
        atlas = false,
        calculate = function(self,card,context)
          if context.setting_blind then
            card.ability.old_size = G.hand.config.card_limit
            card.ability.old_hand = G.GAME.current_round.discards_left
            card.ability.old_discard = G.GAME.current_round.discards_left
          end
          if context.first_hand_drawn then
            if G.GAME.blind.triggered == true or card.facing == "back" or G.GAME.blind.mult > 2 or card.ability.old_size > G.hand.config.card_limit then
              payout_big(card)
            end
            if card.ability.old_hand > G.GAME.current_round.hands_left then
              for i = 1, card.ability.old_hand do
                payout_big(card, 0.4)
              end
            end
            if card.ability.old_discard > G.GAME.current_round.discards_left then
              for i = 1, card.ability.old_discard+1 do
                payout_big(card, 0.4)
              end
            end
          end
          if context.debuffed_hand then
              payout_big(card)
          end
          if context.before then
            local postage = true
            for k, v in pairs(G.jokers.cards) do
              if v.ability.crimson_heart_chosen then
                payout_big(card)
                break
              end
            end
            for k, v in pairs(context.full_hand) do
              --sendDebugMessage(v.base.name)
              --sendDebugMessage("Is this flipped?")
              --sendDebugMessage(v.flipped_by_blind == true and "Yes" or "No")
              if v.flipped_by_blind == true then
                payout_small(card, 0.4, v)
                G.GAME.blind.triggered = false
              end
            end
            sendDebugMessage("("..G.GAME.blind.old_level.." > "..G.GAME.hands[context.scoring_name].level..") ?")
            if G.GAME.blind.old_level > G.GAME.hands[context.scoring_name].level then
              payout_big(card)
            end
          end
        end
      },
      to_the_moon = {
        name = "To the Moon",
        config = {
          extra = 0,
          stonks = 0,
          increase = 0.01,
          triggers = 0,
          x_mult = 1,
        },
        loc_text = {
          text = {
            "Gains an additional {X:mult,C:white}X#1#{} mult",
            "whenever money is gained",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{} mult)"
          }
        },
        loc_vars = {
          "increase",
          "x_mult"
        },
        calculate = function(self, card, context)
          if context.joker_main and card.ability.x_mult+card.ability.triggers > 1 then
            sendDebugMessage(card.ability.triggers.." triggers.")
            return {
              message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult+card.ability.triggers}},
              colour = G.C.MULT,
              Xmult_mod = card.ability.x_mult+card.ability.triggers,
              card = card
            }
          end
          if G.GAME.dollar_buffer then
            if G.GAME.dollar_buffer > (self.stonks and self.stonks or 0) then
              self.triggers = (self.triggers or 0) + card.ability.increase
              self.stonks = G.GAME.dollar_buffer
              sendDebugMessage("Trigger # "..self.triggers)
            end
            if G.GAME.dollar_buffer == 0 and (self.stonks and (self.stonks > 0)) then
              sendDebugMessage("Resetting buffer")
              self.triggers = 0
              self.stonks = 0
            end
          elseif (self.stonks and (self.stonks > 0)) then
            sendDebugMessage("Resetting buffer")
            self.triggers = 0
            self.stonks = 0
          end
        end,
        atlas = false
      },
      ceremonial = {
        name = "Ceremonial Dagger",
        config = {
          bonus = 0,
          mult = 0,
          extra_value = 0
        },
        loc_text = {
          text = {
            "When {C:attention}Blind{} is selected,",
            "destroy Joker to the right and",
            "gain {C:chips}Chips{}, {C:mult}Mult{}, and {C:money}sell{} value",
            "equal to half its listed value(s)",
            "{C:inactive}(Does not absorb {X:mult,C:white}XMult{}{C:inactive}){}"
          }
        },
        loc_vars = {
        },
        calculate = function(self,card,context)
          if context.setting_blind and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos+1] and not card.getting_sliced and not G.jokers.cards[my_pos+1].ability.eternal and not G.jokers.cards[my_pos+1].getting_sliced then 
                local sliced_card = G.jokers.cards[my_pos+1]
                local soul = {
                      chips = sliced_card.ability.chips or 0,
                      mult = sliced_card.ability.mult or sliced_card.ability.t_mult or sliced_card.ability.s_mult or 0,
                      extra_value = sliced_card.sell_cost or 0
                    }
                if sliced_card.ability.name == "Onyx Agate" then
                  soul.mult = sliced_card.ability.extra
                end
                if sliced_card.ability.name == "Banner" then
                  soul.chips = G.GAME.current_round.discards_left*sliced_card.ability.extra
                end
                if soul.chips == 0 then
                  soul.chips = sliced_card.ability.t_chips
                  sendDebugMessage(type(sliced_card.ability.extra))
                  if sliced_card.ability.extra and type(sliced_card.ability.extra) == "table" then
                    if sliced_card.ability.extra.chip_mod and sliced_card.ability.extra.chip_mod > 0 then
                      soul.chips = sliced_card.ability.extra.chip_mod
                    elseif sliced_card.ability.extra.chips and sliced_card.ability.extra.chips > 0 then 
                      soul.chips = sliced_card.ability.extra.chips
                    end
                  end
                end
                if sliced_card.ability.effect == "Joker Mult" then
                  soul.mult = #G.jokers.cards*sliced_card.ability.extra
                end
                if sliced_card.ability.name == "Fortune Teller" then
                  soul.mult = G.GAME.consumeable_usage_total.tarot*sliced_card.ability.extra
                end
                if soul.mult == 0 then
                  soul.mult = sliced_card.ability.t_mult== 0 and sliced_card.ability.s_mult or sliced_card.ability.t_mult
                  if sliced_card.ability.extra and type(sliced_card.ability.extra) == "table" and sliced_card.ability.extra.mult and sliced_card.ability.extra.mult > 0 then
                    soul.mult = sliced_card.ability.extra.mult
                  end
                end
                for k, v in pairs(soul) do
                  sendDebugMessage(k..": "..tostring(card.ability[k]))
                  card.ability[k] = (card.ability[k] or 0) + math.ceil(0.5*v)
                  sendDebugMessage("Increased to "..tostring(card.ability[k]))
                end
                sliced_card.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = "before", delay = 1.4, func = function()
                    G.GAME.joker_buffer = 0
                    card:juice_up(0.8, 0.8)
                    sliced_card:start_dissolve({HEX("57ecab")}, nil, 1.6)
                    play_sound('slice1', 0.96+math.random()*0.08)
                return true end
                }))
                sendDebugMessage(sliced_card.ability.name.." sliced.")
                sendDebugMessage("Chips: "..soul.chips)
                sendDebugMessage("Mult: "..soul.mult)
                sendDebugMessage("Sell Value: "..soul.extra_value)
                if soul.chips > 0 then
                  card_eval_status_text(card, 'chips', math.ceil(0.5*(soul.chips)), nil, nil, {no_juice = true})
                  if soul.mult > 0 or soul.extra_value > 0 then
                    delay(0.4)
                  end
                end
                if soul.mult > 0 then
                  card_eval_status_text(card, 'mult',math.ceil(0.5*(soul.mult)), nil, nil, {no_juice = true})
                  if soul.extra_value > 0 then
                    delay(0.4)
                  end
                end
                card_eval_status_text(card, 'dollars', math.ceil(0.5*(soul.extra_value)), nil, nil, {no_juice = true})
            end
          end
          if context.joker_main and context.cardarea == G.jokers then
            if card.ability.mult == 0 then
              return {
                message = localize{type='variable',key='a_chips',vars={card.ability.chips}},
                colour = G.C.CHIPS,
                chip_mod = card.ability.chips,
                card = self
              }
            end
            if card.ability.chips and card.ability.chips > 0 then
              G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.7,
                func = function()
                card_eval_status_text(card, 'chips', card.ability.chips, nil, nil, {instant=true})
                G.GAME.current_round.current_hand['chips'] = G.GAME.current_round.current_hand['chips'] + card.ability['chips']
                G.GAME.current_round.current_hand["chip_text"] = G.GAME.current_round.current_hand['chip_text'] + card.ability['chips']
                G.hand_text_area['chips']:update(0)
                G.hand_text_area['chips']:juice_up()
                return true
                end
              }))
            end
            return 
            {
              message = localize{type='variable',key='a_mult',vars={card.ability.mult}},
              colour = G.C.MULT,
              chip_mod = card.ability.chips,
              mult_mod = card.ability.mult,
              card = self
            }
          end
        end,
        atlas = false
      },
      red_card = {
        name = "Red Card",
        config = {
          mult = 0,
          increase = 2,
        },
        loc_text = {
          text = {
            "{C:red}+#1#{} Mult per {C:attention}Booster Pack{}",
            "not purchased this run and",
            "{C:red}+#2#{} Mult per {C:attention}Booster Pack{}",
            "skipped this run",
            "{C:inactive}(Currently {C:red}+#3#{C:inactive} Mult)"
          }
        },
        loc_vars = function(self, info_queue, card)
          return
          {
            vars =
            {
              self.increase or card.ability.increase,
              (self.increase or card.ability.increase)+1,
              self.mult or card.ability.mult
            }
          }
        end,
        calculate = function(self,card,context)
          local number = 0
          if context.ending_shop and (G.GAME.shop_done == nil or G.GAME.shop_done == false) and not context.blueprint then
            sendDebugMessage(#G.shop_booster.cards.." packs left, ending shop")
            number = card.ability.increase*#G.shop_booster.cards
            card.ability.mult = (card.ability.mult or 0) + number
            if number > 0 then
              G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.7,
                blocking = true,
                func = function()
                  card_eval_status_text(card, "extra", number, nil, nil, {message = localize{type='variable',key='a_mult',vars={number}, instant = true}})
                  return true
                end
              }))
            end
          end
        end,
        atlas = false
      },
      flower_pot = {
        name = "Flower Pot",
        config = {
        },
        loc_text = {
          text = {
            "{C:white,X:mult}X1{} Mult for every",
            "unique suit in full hand",
            "{C:inactive}Wild cards give {C:white,X:mult}X1{C:inactive} Mult each{}",
            "{C:inactive}Minimum is {C:white,X:mult}X1{C:inactive} Mult{}"
          }
        },
        loc_vars = {
        },
        calculate = function(self,card,context)
          local suits = {}
          local number = 0
          if context.joker_main and context.cardarea == G.jokers and context.full_hand and context.cardarea == G.jokers then
            for k, v in pairs(context.full_hand) do
              if v.ability.name == "Wild Card" then
                number = number + 1
              elseif not suits[v.base.suit] then
                suits[v.base.suit] = true
                number = number + 1
              end
            end
            if number <= 1 then return nil end
            return {
              message = localize{type='variable',key='a_xmult',vars={number}},
              colour = G.C.MULT,
              Xmult_mod = number,
              card = card
            }
          end
        end,
        atlas_hc = true,
      },
    }
    if NumBalatro.config.alter_vanilla_jokers then
      SMODS.Atlas{
          key = "Jokers_hc",
          path = "Jokers_hc.png",
          px = 71,
          py = 95
        }
      SMODS.Atlas{
          key = "Jokers",
          path = "Jokers.png",
          px = 71,
          py = 95
        }
      for k,v in pairs(oldJokers) do
        sendDebugMessage(tostring(G.P_CENTERS["j_"..k].name))
        if v.atlas_hc then
          SMODS.Atlas{
            key = k.."_hc",
            path = "j_"..k..(string.sub(v.name,-5) == "Joker" and "_joker" or "").."_hc.png",
            px = 71,
            py = 95
          }
          SMODS.Atlas{
            key = k,
            path = "j_"..k..(string.sub(v.name,-5) == "Joker" and "_joker" or "").."_lc.png",
            px = 71,
            py = 95
          }
        elseif v.atlas then
            SMODS.Atlas{
              key = k,
              path = "j_"..k..(string.sub(v.name,-5) == "Joker" and "_joker" or "")..".png",
              px = 71,
              py = 95
            }
        end
        --sendDebugMessage(" "..tostring(v.atlas))
        local center = (G.P_CENTERS["j_"..k.."_joker"]) or (G.P_CENTERS["j_"..k])
        
        --sendDebugMessage(" ("..tostring(G.P_CENTERS["j_"..k].pos.x)..", "..tostring(G.P_CENTERS["j_"..k].pos.y)..")")
        if v.atlas or v.atlas_hc then
          sendDebugMessage("Using position ("..center.pos.x..", "..center.pos.y..") of custom atlas for "..v.name)
        else
          sendDebugMessage("Using position ("..center.pos.x..", "..center.pos.y..") of default atlas for "..v.name)
        end
        SMODS.Joker:take_ownership(center.key,{
          set = "Joker",
          name = v.name or center.name,
          loc_txt = {
            name = v.loc_text.name or v.name,
            text = v.loc_text.text
          },
          key= "j_"..k,
          atlas = v.atlas and (NumBalatro.config.separate_joker_loading and k or "Jokers") or center.atlas,
          lc_atlas = v.atlas_hc and (NumBalatro.config.separate_joker_loading and k.."_lc" or "Jokers") or center.atlas,
          hc_atlas = v.atlas_hc and (NumBalatro.config.separate_joker_loading and k or "Jokers").."_hc" or center.atlas,
          config = v.config,
          calculate = v.calculate,
          pos = (NumBalatro.config.separate_joker_loading and (v.atlas or v.atlas_hc)) and {x=0,y=0} or center.pos,
          blueprint_compat = v.blueprint or true,
          eternal_compat = v.eternal or true,
          perishable_compat = v.perishable or true,
          loc_vars = (type(v.loc_vars) == "function") and v.loc_vars or function(self, info_queue, card)
            local postage = {}
            for key, val in pairs(v.loc_vars) do
              if string.sub(val,1,4) == "odds" then
                table.insert(postage,G.GAME.probabilities.normal)
              end
              table.insert(postage,v.config[val] or center.config[val])
              if string.sub(val,1,2) == "t_" and type(postage[#postage]) == "number" then
                local maths = postage[#postage] * ((v.name == "Wily Joker" or v.name == "Zany Joker") and 2 or 3)
                table.insert(postage,maths)
              end
            end
            sendDebugMessage((v.name or center.name)..":")
            for key, val in pairs(postage) do
              sendDebugMessage("- "..key..": "..tostring(val))
            end
            return {vars = postage}
          end,
        })
      end
    end
    for k,v in pairs(newJokers) do
      SMODS.Atlas{
        key = v.key,
        path = "j_"..v.key..".png",
        px = 71,
        py = 95
      }
      SMODS.Joker{
        key = v.key,
        atlas = v.key,
        set = "Joker",
        name = v.name,
        rarity = v.rarity,
        cost = v.cost,
        config = v.config,
        blueprint_compat = v.blueprint or true,
        eternal_compat = v.eternal or true,
        perishable_compat = v.perishable or true,
        loc_txt = {
          name = v.loc_text.name or v.name,
          text = v.loc_text.text
        },
        discovered = true,
        unlocked = true,
        calculate = v.calculate,
        loc_vars = function(self, info_queue, card)
          local postage = {}
          for key, val in pairs(v.loc_vars) do
            sendDebugMessage(string.sub(val,1,4))
            if string.sub(val,1,4) == "odds" then
              postage[#postage+1] = G.GAME.probabilities.normal
            end
          postage[#postage+1] = self.config[val]
          --sendDebugMessage(val..": "..postage[key])
          end
          return {vars = postage}
        end,
      }
    end
    NumBalatro.config_tab = function()
    local scale = 5/6
    return {n=G.UIT.ROOT, config = {align = "cl", minh = G.ROOM.T.h*0.25, padding = 0.0, r = 0.1, colour = G.C.GREY}, nodes = {
        {n = G.UIT.R, config = { padding = 0.05 }, nodes = {
            {n = G.UIT.C, config = { align = "cr", minw = G.ROOM.T.w*0.25, padding = 0.05 }, nodes = {
                create_toggle{ label = localize("alter_vanilla_jokers"), info = localize("alter_vanilla_jokers_desc"), active_colour = G.C.BLUE, ref_table = NumBalatro.config, ref_value = "alter_vanilla_jokers"},
            }},
            {n = G.UIT.C, config = { align = "cr", minw = G.ROOM.T.w*0.25, padding = 0.05 }, nodes = {
                create_toggle{ label = localize("separate_joker_loading"), info = localize("separate_joker_loading_desc"), active_colour = G.C.BLUE, ref_table = NumBalatro.config, ref_value = "separate_joker_loading"},
            }},
        }}
    }}
    end
    
local startrun_ref = Game.start_run
function Game:start_run(args)
    startrun_ref(self,args)
    if self.GAME.round == 0 then
      if self.GAME.selected_back.name == 'Black Deck' then
        --G.GAME.starting_params.hands = 3
        self.GAME.round_resets.hands = 3
        --G.GAME.current_round.hands = 3
      end
    end
    self.GAME.stocks = 0
end

local flip_ref = Card.flip
function Card:flip() 
  local postage = flip_ref(self)
  if self.facing == 'front' then
    self.flipped_by_blind = true
  end
  return postage
end

local generate_UIBox_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
  if self.config.center_key == "m_lucky" then
    local progression_mult = {5,3,2,1}
    local progression_money = {15,7,3,2,1}
    local idx = {1,1}
    if G.jokers then
      for k, v in pairs(G.jokers.cards) do
        if v.ability.name == "One-Armed Bandit" then
          idx[1] = math.min(idx[1] + 1,#progression_mult)
          idx[2] = math.min(idx[2] + 1,#progression_money)
        end
      end
    end
    self.ability.odds_mult = progression_mult[idx[1]]
    self.ability.odds_money = progression_money[idx[2]]
  end
  return generate_UIBox_ability_table_ref(self)
end

local get_X_same_ref = get_X_same
function get_X_same(num, hand)
    local ofakind = get_X_same_ref(num, hand)
    if #hand < num then return ofakind end
    for k, v in pairs(G.jokers.cards) do
      if v.ability.name == "Brick By Brick" then
        local new = #ofakind+1
        ofakind[new] = {}
        for k2, v2 in pairs(hand) do
          if v2.config.center == G.P_CENTERS.m_stone then
            table.insert(ofakind[new], v2)
            sendDebugMessage(#ofakind[new].." stones")
          end
        end
        if #ofakind[new] ~= num then
          ofakind[new] = nil
        end
        break
      end
    end
    return ofakind
end

function pair_joker_calc(self, context, chipmult, dbl_msg)
  local _pairs = next(context.poker_hands["Two Pair"]) and 2 or 1
  local variable = "t_"..chipmult
  sendDebugMessage("Should be giving "..self.ability[variable]*_pairs.." "..chipmult)
  if _pairs == 2 then
    G.E_MANAGER:add_event(Event({
      trigger = 'before',
      delay = 0.7,
      blocking = true,
      func = function()
        card_eval_status_text(self, chipmult, self.ability[variable], nil, nil, {message = localize{type='variable',key='a_'..chipmult,vars={self.ability[variable]}}, instant = true})
        sendDebugMessage(self.ability.name.." grants +"..self.ability[variable].." "..chipmult)
        update_hand_text({immediate = true, delay = 0}, {
          chips = chipmult == 'chips' and (G.GAME.current_round.current_hand[chipmult] + self.ability[variable]) or nil,
          mult = chipmult == 'mult' and (G.GAME.current_round.current_hand[chipmult] + self.ability[variable]) or nil,
        })
        return true
      end
    }))
  end
  if next(context.poker_hands["Pair"]) then
    self:juice_up()
  end
  if dbl_msg == true then
    message = pair_joker_calc(self,context,chipmult,false)
    return nil
  else
    return 
      {
        message = localize{type='variable',key='a_'..chipmult,vars={self.ability[variable]}},
        sound = self.ability.name == 'Sly Joker' and "chips1" or "multhit1",
        colour = G.C[string.upper(chipmult)],
        chip_mod = chipmult == 'chips' and (self.ability.t_chips * _pairs) or nil,
        mult_mod = chipmult == 'mult' and (self.ability.t_mult * _pairs) or nil,
        card = self
      }
  end
end

function oak_joker_calc(self, context, number, chipmult, dbl_msg)
  local var = 0
  local primary = true
  local secondary = #context.scoring_hand == number
  local writeout = 
  {
    "Three",
    "Four",
    "Five"
  }
  sendDebugMessage(tostring(self.ability["t_"..chipmult]))
  for k, v in pairs(writeout) do
    if next(context.poker_hands[v.." of a Kind"]) and k+2 == number then
      primary = true
      break
    end
  end
  if primary then
    if secondary then
      local variable = "t_"..chipmult
      G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.7,
        blocking = true,
        func = function()
          card_eval_status_text(self, chipmult, self.ability[variable], nil, nil, {message = localize{type='variable',key='a_'..chipmult,vars={self.ability[variable]}}, instant = true})
          sendDebugMessage(self.ability.name.." grants +"..self.ability[variable]*(number - 1).." "..chipmult)
          update_hand_text({immediate = true, delay = 0}, {
            chips = chipmult == 'chips' and (G.GAME.current_round.current_hand[chipmult] + self.ability[variable]) or nil,
            mult = chipmult == 'mult' and (G.GAME.current_round.current_hand[chipmult] + self.ability[variable]) or nil,
          })
          return true
        end
      }))
      return
      {
        message = localize{type='variable',key='a_'..chipmult,vars={self.ability["t_"..chipmult]*(number-1)}},
        colour = G.C[string.upper(chipmult)],
        chip_mod = chipmult == 'chips' and self.ability.t_chips * number or nil,
        mult_mod = chipmult == 'mult' and self.ability.t_mult * number or nil,
        card = self
      }
    else
      return
      {
        message = localize{type='variable',key='a_'..chipmult,vars={self.ability["t_"..chipmult]}},
        colour = G.C[string.upper(chipmult)],
        chip_mod = chipmult == 'chips' and self.ability.t_chips or nil,
        mult_mod = chipmult == 'mult' and self.ability.t_mult or nil,
        card = self
      }
    end
  elseif secondary then
      return
      {
        message = localize{type='variable',key='a_'..chipmult,vars={self.ability["t_"..chipmult]*(number-1)}},
        colour = G.C[string.upper(chipmult)],
        chip_mod = chipmult == 'chips' and self.ability.t_chips*(number-1) or nil,
        mult_mod = chipmult == 'mult' and self.ability.t_mult*(number-1) or nil,
        card = self
      }
  else
    return nil
  end
end

local evaluate_poker_hand_ref = evaluate_poker_hand
function evaluate_poker_hand(hand)  
  local results = evaluate_poker_hand_ref(hand)
  local order = {
    "Flush Five",
    "Flush House",
    "Five of a Kind",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card",
  }
  local _pairs = get_X_same(2, hand)
  if next(results["Three of a Kind"]) and next(results["Pair"]) then
    results["Full House"] = {hand}
    table.sort(results["Full House"], function(a,b)
      return a.T.x < b.T.x
    end)
    if next(results["Flush"]) then
      results["Flush House"] = results["Full House"]
    end
    results["Two Pair"] = 
    {
     {
      results["Full House"][1][1],
      results["Full House"][1][2],
      results["Full House"][1][4],
      results["Full House"][1][5]
     }
    }
  end
  results["Straight"] = get_straight(hand)
  if next(results["Straight"]) then
    results["Straight Flush"] = (next(results["Straight"][1]) and next(results["Flush"])) and results["Straight"] or {nil}
  end
  local new_top = nil
  for k, v in pairs(order) do
    --sendDebugMessage(v..": "..((results[v] ~= nil and #results[v] > 0) and "Yes" or "No"))
    if new_top == nil and next(results[v]) then
      new_top = v
      results.top = results[v]
      G.GAME.blind.old_level = G.GAME.hands[v].level
    end
    for k2, v2 in pairs(results[v]) do
      for k3, v3 in pairs(v2) do
        --sendDebugMessage(" - "..v3.base.name.." ("..v3.ability.effect..")")
      end
    end
  end
  return results
end

local get_straight_ref = get_straight
function get_straight(hand)
  --sendDebugMessage("Override successful.")
  local postage = {}
  local results = {}
  local can_loop = next(find_joker('Superposition'))
  local four = next(find_joker('Four Fingers'))
  local can_skip = next(find_joker('Shortcut'))
  local skipped = false
  if can_loop then
    --sendDebugMessage("Superposition detected.")
  end
  if can_skip then
    --sendDebugMessage("Shortcut detected.")
  end
  if #hand < (four and 4 or 5) then
    return postage
  end

  table.sort(hand,
    function(a,b)
      if a:get_id() == b:get_id() then
        return a.T.x < b.T.x
      end
      return a:get_id() < b:get_id()
    end
  )
  local mail = ""
  local postcard = ""
  for k, v in pairs(hand) do
    mail = mail..SMODS.Ranks[v.base.value].shorthand
  end
  for k, v in ipairs(SMODS.Rank.obj_buffer) do
    postcard = postcard..SMODS.Ranks[v].shorthand
  end
  mail = string.gsub(mail,"10","T")
  postcard = string.gsub(postcard,"10","T")
  mail = mail..(can_loop and mail or "")
  postcard = string.sub(postcard,-1)..(can_loop and postcard or "")..postcard
  --sendDebugMessage(tostring(string.match(mail:sub(-2):sub(1,1),"%D")))
  if mail:sub(-1) == postcard:sub(-1) and mail:sub(-2):sub(1,1):match("%d") then
    mail = mail:sub(-1)..mail:sub(1,mail:len()-1)
  end
  local found = postcard:find(mail) ~= nil
  if found and mail:len() >= (four and 4 or 5) then
    --sendDebugMessage(mail.." is a straight.")
    postage = hand
    if four and mail:len() == 5 and not postcard:find(mail) then
      postage:remove(((postcard:find(mail:sub(2))) and 1 or 5))
    end
  elseif can_skip then
    local offset = 1
    for i=2, mail:len() do
      local prev = mail:sub(offset,i+offset-2)
      local curr = mail:sub(offset,i+offset-1)
      if postcard:find(mail)~=nil and (mail:len() == (four and 4 or 5)) then
        --sendDebugMessage(postcard:sub(postcard:find(mail),mail:len()))
        --sendDebugMessage(mail.." is a straight.")
        postage = hand
        break
      elseif four and mail:len() == 5 and (postcard:find(mail:sub(2)) or postcard:find(mail:sub(1,4))) then
        postage = hand
        postage:remove((postcard:find(mail:sub(2)) and 1 or 5))
        mail = (postcard:find(mail:sub(2)) and mail:sub(2) or mail:sub(1,4))
        --sendDebugMessage(mail:sub(2).." and "..mail:sub(1,4))
        --sendDebugMessage(mail.." is a four-fingered straight.")
        break
      elseif postcard:find(prev) and not postcard:find(curr) then
        postcard = string.sub(postcard,1,postcard:find(prev)+i+offset-3)..string.sub(postcard,postcard:find(prev)+i+offset-1)
        sendDebugMessage(postcard)
        if postcard:find(mail)~=nil and (mail:len() == (four and 4 or 5)) then
          --sendDebugMessage(postcard:sub(postcard:find(mail),mail:len()))
          --sendDebugMessage(mail.." is a straight.")
          postage = hand
        end
      elseif not postcard:find(curr) then
        --sendDebugMessage("No.")
        offset = offset + 1
      end
    end
  elseif can_loop then
    for i = 1, mail:len() do
      mail = string.sub(mail,2)..string.sub(mail,1,1)
      hand:insert(hand[1])
      hand:remove(1)
      if (postcard:find(mail) and mail:len() == four and 4 or 5) or (four and mail:len() == 5 and (postcard:find(mail:sub(2)) or postcard:find(mail:sub(1,4)))) then
        --sendDebugMessage(mail.." is a"..((four and not postcard:find(mail)) and " four-fingered " or " ").."straight.")
        postage = hand
        if four and not postcard:find(mail) then
          postage:remove((postcard:find(mail:sub(2)) and 1 or 5))
        end
        break
      end
    end
  end
  table.sort(hand, function(a,b) return a.T.x < b.T.x end)
  table.sort(postage, function(a,b) return a.T.x < b.T.x end)
  sendDebugMessage(#postage)
  if #postage == 0 then
    --sendDebugMessage(mail.." is not a straight.")
    --sendDebugMessage(mail:sub(2).." and "..mail:sub(1,4).." are not four-fingered straights.")
    postage = nil
  end
  return {postage}
end

local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
    local function _mod(mod)
        ease_dollars_ref(mod, true)
    end
    local function search()
        for k, v in pairs(G.jokers.cards) do
          if v.ability.name == "To the Moon" and mod > 0 then
            card_eval_status_text(v, 'extra', nil, nil, nil, {message = "Stocks up!", colour = G.C.GREEN, instant=true})
            v.ability.x_mult = v.ability.x_mult + v.ability.increase
          end
        end
    end
    if instant then
        _mod(mod)
        for k, v in pairs(G.jokers.cards) do
          if v.ability.name == "To the Moon" and mod > 0 then
            delay(0.7)
          end
        end
        search()
    else
        _delay = 0
        for k, v in pairs(G.jokers.cards) do
          if v.ability.name == "To the Moon" and mod > 0 then
            _delay = 0.7
            break
          end
        end
        G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = _delay,
        func = function()
          _mod(mod)
          return true
        end
        }))
        G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          search()
          return true
        end
        }))
    end
end

local remove_from_deck_ref = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
  remove_from_deck_ref(self,from_debuff)
  if G.hand and self.ability.name == 'Brothers Hamm' then
    G.hand:change_size(-self.ability.h_size)
  end
end

function payout_small(card, delay, other_card)
  if other_card then
    G.E_MANAGER:add_event(Event({
      trigger = "immediate",
      blocking = true,
      func = function()
        other_card:juice_up()
        return true
      end
    }))
  end
  G.E_MANAGER:add_event(Event({
    trigger = "before",
    delay = delay or 0.7,
    blocking = true,
    func = (function()
      if G.GAME.blind:get_type() ~= 'Boss' then return true end
      --sendDebugMessage("Small trigger detected, should pay out $"..card.ability.small_payout)
      ease_dollars(card.ability.small_payout, true)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.small_payout
      card_eval_status_text(card, 'dollars', card.ability.small_payout, nil, nil, {instant = true})
      G.GAME.dollar_buffer = 0;
      return true
    end
  )}))
end

function payout_big(card)
  G.E_MANAGER:add_event(Event({
    trigger = "before",
    delay = 0.7,
    blocking = true,
    func = (function()
      if G.GAME.blind:get_type() ~= "Boss" then return true end
      --sendDebugMessage("Big trigger detected, should pay out $"..card.ability.big_payout)
      ease_dollars(card.ability.big_payout, true)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.big_payout
      card_eval_status_text(card, 'dollars', card.ability.big_payout, nil, nil, {instant = true})
      G.GAME.dollar_buffer = 0;
      return true
    end
  )}))
end

draw_from_deck_to_hand_ref = G.FUNCS.draw_from_deck_to_hand
G.FUNCS.draw_from_deck_to_hand = function(e)
  local postage = draw_from_deck_to_hand_ref(e)
  if G.GAME.blind.name == 'The Serpent' and not G.GAME.blind.disabled and (G.GAME.current_round.hands_played > 0 or G.GAME.current_round.discards_used > 0) then
    for k, v in pairs(find_joker("Matador")) do
      payout_big(v)
    end
  end
  return postage
end

local modify_hand_ref = Blind.modify_hand
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips)
  local old_chips = hand_chips
  local old_mult = mult
  local modded = false
  mult, hand_chips, modded = modify_hand_ref(self, cards, poker_hands, text, mult, hand_chips)
  if (mult < old_mult and mult > 0) and (hand_chips < old_chips and hand_chips > 0) then
    for k, v in pairs(find_joker("Matador")) do
      payout_big(v)
    end
  end
  return mult, hand_chips, modded
end
----------------------------------------------
------------MOD CODE END----------------------