local C = {}

-- Window
C.WIDTH  = 900
C.HEIGHT = 900

-- Player
C.PLAYER_ACCEL      = 10
C.PLAYER_IFRAMES    = 2.0   -- seconds of immunity after taking damage
C.MAX_BULLETS       = 3
C.BULLET_COOLDOWN   = 0.5   -- seconds between shots

-- Bullet
C.BULLET_SPEED      = 700
C.BULLET_LIFE       = 1.0

-- Enemy speeds
C.ENEMY_L_SPEED     = 80    -- large asteroid max speed (random -X to X)
C.ENEMY_M_SPEED     = 120
C.ENEMY_S_SPEED     = 150

-- Boss
C.BOSS_HP           = 35
C.BOSS_HP_PHASE_MID = 24    -- switch to beam attack phase
C.BOSS_HP_PHASE_LOW = 12    -- switch to bomb attack phase

-- Stage 1: how many large asteroids to spawn
C.STAGE1_ASTEROID_COUNT = 5

-- Stage 2 enemy ship spawn X positions
C.STAGE2_SHIP_XS  = {250, 450, 650}
C.STAGE2_SHIPL_XS = {150, 350, 550, 750}

-- Health pickup drop chances (1-100 random; drop if roll <= chance)
C.PICKUP_CHANCE_SHIP       = 40
C.PICKUP_CHANCE_BOSS_SPAWN = 25
C.PICKUP_CHANCE_SMALL      = 20

-- UI positions
C.HEALTH_X   = 30
C.HEALTH_Y   = 80
C.HEALTH_GAP = 40   -- pixels between each heart icon
C.BOSS_HP_X  = 180
C.BOSS_HP_Y  = 35
C.BOSS_HP_GAP = 18
C.SCORE_X    = 15
C.SCORE_Y    = 15

-- Menu button layout (centre Y of each button, and hitbox bounds)
C.BTN_START_CY  = 556
C.BTN_OPTION_CY = 687
C.BTN_EXIT_CY   = 818
C.BTN_BACK_CY   = 818
C.BTN_X_MIN     = 225   -- left edge of button hitbox
C.BTN_X_MAX     = 675   -- right edge
C.BTN_HALF_H    = 50.5  -- half-height used for origin offset when drawing

-- Win / game-over timing
C.BOSS_DEATH_WIN_DELAY = 3.0  -- seconds after boss death before win screen
C.DEATH_MENU_DELAY     = 3.0  -- seconds after player death before returning to menu

return C
