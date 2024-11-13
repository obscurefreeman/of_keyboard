if CLIENT then
    -- 创建语言表
    local lang = GetConVar("gmod_language"):GetString()

    -- 添加简体中文本地化
    if lang == "zh-CN" then
        language.Add("of_keyboard.title", "键位显示器")
        language.Add("of_keyboard.enabled", "显示键位显示器")
        language.Add("of_keyboard.locked", "锁定键位显示器")
        language.Add("of_keyboard.settings", "键盘设置")
        language.Add("of_keyboard.presets", "个性化")
        language.Add("of_keyboard.preset.lambda", "拉姆达")
        language.Add("of_keyboard.preset.pink", "活力粉")
        language.Add("of_keyboard.preset.green", "翠绿色")
        language.Add("of_keyboard.preset.violet", "紫罗兰")
        language.Add("of_keyboard.preset.yellow", "丰收黄")
        language.Add("of_keyboard.show", "显示键盘")
        language.Add("of_keyboard.lock", "锁定键盘")
    elseif lang == "ru" then
        language.Add("of_keyboard.title", "Отображение клавиш")
        language.Add("of_keyboard.enabled", "Показать отображение клавиш")
        language.Add("of_keyboard.locked", "Заблокировать отображение клавиш")
        language.Add("of_keyboard.settings", "Настройки клавиатуры")
        language.Add("of_keyboard.presets", "Персонализация")
        language.Add("of_keyboard.preset.lambda", "Лямбда")
        language.Add("of_keyboard.preset.pink", "Яркий розовый")
        language.Add("of_keyboard.preset.green", "Изумрудный")
        language.Add("of_keyboard.preset.violet", "Фиолетовый")
        language.Add("of_keyboard.preset.yellow", "Золотой урожай")
        language.Add("of_keyboard.show", "Показать клавиатуру")
        language.Add("of_keyboard.lock", "Заблокировать клавиатуру")
    else
        language.Add("of_keyboard.title", "Key Display")
        language.Add("of_keyboard.enabled", "Show Key Display")
        language.Add("of_keyboard.locked", "Lock Key Display")
        language.Add("of_keyboard.settings", "Keyboard Settings")
        language.Add("of_keyboard.presets", "Personalization")
        language.Add("of_keyboard.preset.lambda", "Lambda")
        language.Add("of_keyboard.preset.pink", "Vibrant Pink")
        language.Add("of_keyboard.preset.green", "Emerald")
        language.Add("of_keyboard.preset.violet", "Violet")
        language.Add("of_keyboard.preset.yellow", "Harvest Gold")
        language.Add("of_keyboard.show", "Show Keyboard")
        language.Add("of_keyboard.lock", "Lock Keyboard")
    end

    -- 创建ConVars
    local keyboard_enabled = CreateConVar("of_keyboard_enabled", "0", FCVAR_ARCHIVE, "显示/隐藏键位显示器")
    local keyboard_locked = CreateConVar("of_keyboard_locked", "0", FCVAR_ARCHIVE, "锁定/解锁键位显示器")
    local keyboard_pos_x = CreateConVar("of_keyboard_pos_x", "-1", FCVAR_ARCHIVE, "键位显示器X坐标")
    local keyboard_pos_y = CreateConVar("of_keyboard_pos_y", "-1", FCVAR_ARCHIVE, "键位显示器Y坐标")
    local keyboard_color_r = CreateConVar("of_keyboard_color_r", "100", FCVAR_ARCHIVE, "键位显示器按键高亮颜色R")
    local keyboard_color_g = CreateConVar("of_keyboard_color_g", "100", FCVAR_ARCHIVE, "键位显示器按键高亮颜色G") 
    local keyboard_color_b = CreateConVar("of_keyboard_color_b", "255", FCVAR_ARCHIVE, "键位显示器按键高亮颜色B")

    -- 设置预设颜色的函数
    local function SetPresetColor(r, g, b)
        keyboard_color_r:SetInt(r)
        keyboard_color_g:SetInt(g)
        keyboard_color_b:SetInt(b)
    end

    -- 创建虚拟键盘窗口
    local FRAME = {}
    
    function FRAME:Init()
        self:SetSize(810, 310)
        
        -- 如果有保存的位置则使用,否则居中显示
        local saved_x = keyboard_pos_x:GetInt()
        local saved_y = keyboard_pos_y:GetInt()
        if saved_x >= 0 and saved_y >= 0 then
            self:SetPos(saved_x, saved_y)
        else
            self:Center()
        end
        
        self:SetTitle(language.GetPhrase("of_keyboard.title"))
        -- 默认启用鼠标输入
        self:MakePopup()
        
        -- 隐藏最大化和最小化按钮
        self:SetSizable(false)
        self:ShowCloseButton(true)
        
        -- 存储所有按键状态
        self.KeyStates = {}
        
        -- 创建键盘布局
        self.Keys = {
            {{"ESC", KEY_ESCAPE}, {"F1", KEY_F1}, {"F2", KEY_F2}, {"F3", KEY_F3}, {"F4", KEY_F4}, {"F5", KEY_F5}, {"F6", KEY_F6}, {"F7", KEY_F7}, {"F8", KEY_F8}, {"F9", KEY_F9}, {"F10", KEY_F10}, {"F11", KEY_F11}, {"F12", KEY_F12}},
            {{"~", KEY_TILDE}, {"1", KEY_1}, {"2", KEY_2}, {"3", KEY_3}, {"4", KEY_4}, {"5", KEY_5}, {"6", KEY_6}, {"7", KEY_7}, {"8", KEY_8}, {"9", KEY_9}, {"0", KEY_0}, {"-", KEY_MINUS}, {"=", KEY_EQUAL}, {"BKSP", KEY_BACKSPACE}},
            {{"TAB", KEY_TAB}, {"Q", KEY_Q}, {"W", KEY_W}, {"E", KEY_E}, {"R", KEY_R}, {"T", KEY_T}, {"Y", KEY_Y}, {"U", KEY_U}, {"I", KEY_I}, {"O", KEY_O}, {"P", KEY_P}, {"[", KEY_LBRACKET}, {"]", KEY_RBRACKET}, {"\\", KEY_BACKSLASH}},
            {{"CAPS", KEY_CAPSLOCK}, {"A", KEY_A}, {"S", KEY_S}, {"D", KEY_D}, {"F", KEY_F}, {"G", KEY_G}, {"H", KEY_H}, {"J", KEY_J}, {"K", KEY_K}, {"L", KEY_L}, {";", KEY_SEMICOLON}, {"'", KEY_APOSTROPHE}, {"ENTER", KEY_ENTER}},
            {{"SHIFT", KEY_LSHIFT}, {"Z", KEY_Z}, {"X", KEY_X}, {"C", KEY_C}, {"V", KEY_V}, {"B", KEY_B}, {"N", KEY_N}, {"M", KEY_M}, {",", KEY_COMMA}, {".", KEY_PERIOD}, {"/", KEY_SLASH}, {"SHIFT", KEY_RSHIFT}},
            {{"CTRL", KEY_LCONTROL}, {"WIN", KEY_LWIN}, {"ALT", KEY_LALT}, {"SPACE", KEY_SPACE}, {"ALT", KEY_RALT}, {"CTRL", KEY_RCONTROL}}
        }

        -- 监听ConVar变化
        cvars.AddChangeCallback("of_keyboard_locked", function(_, _, new)
            -- 确保self是有效的面板
            if not IsValid(self) then return end
            
            if new == "1" then
                -- 保存当前位置
                local x, y = self:GetPos()
                keyboard_pos_x:SetInt(x)
                keyboard_pos_y:SetInt(y)
                
                self:ShowCloseButton(false)
                self:SetDraggable(false)
                self:SetMouseInputEnabled(false)
                self:SetKeyboardInputEnabled(false)
                self:DockPadding(0, 0, 0, 0) -- 移除标题栏空间
                self:SetTitle("")  -- 移除标题文本
                self:SetSize(810, 285) -- 减小窗口高度以适应移除的标题栏
            else
                self:ShowCloseButton(true)
                self:SetDraggable(true)
                self:MakePopup()
                self:DockPadding(5, 24, 5, 5) -- 恢复标题栏空间
                self:SetTitle(language.GetPhrase("of_keyboard.title"))  -- 恢复标题文本
                self:SetSize(810, 310) -- 恢复原始窗口大小
            end
        end)
        
        -- 设置窗口为非焦点模式
        self:SetFocusTopLevel(false)
        self:SetKeyboardInputEnabled(false)

        -- 添加关闭事件处理
        function self:OnClose()
            keyboard_enabled:SetBool(false)
        end
    end
    
    function FRAME:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 200))
        
        local x, y = 10, keyboard_locked:GetBool() and 10 or 40  -- 锁定时调整起始Y坐标
        local keyWidth, keyHeight = 50, 40
        local spacing = 5
        
        for row, keys in ipairs(self.Keys) do
            for _, key in ipairs(keys) do
                local text, keyCode = key[1], key[2]
                local width = keyWidth
                
                -- 特殊按键宽度调整
                if text == "SPACE" then width = 300
                elseif text == "ENTER" then width = 75
                elseif text == "SHIFT" then width = 100
                elseif text == "BKSP" then width = 75
                elseif text == "TAB" then width = 75
                end
                
                -- 绘制按键背景
                local keyColor = Color(50, 50, 50, 200)
                if keyCode and input.IsKeyDown(keyCode) then
                    keyColor = Color(keyboard_color_r:GetInt(), keyboard_color_g:GetInt(), keyboard_color_b:GetInt(), 200)
                end
                draw.RoundedBox(4, x, y, width, keyHeight, keyColor)
                
                -- 绘制按键文字
                draw.SimpleText(text, "DermaDefault", x + width/2, y + keyHeight/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                x = x + width + spacing
            end
            x = 10
            y = y + keyHeight + spacing
        end
    end
    
    vgui.Register("KeyboardDisplay", FRAME, "DFrame")
    
    -- 监听ConVar变化来显示/隐藏键盘
    cvars.AddChangeCallback("of_keyboard_enabled", function(_, _, new)
        if new == "1" then
            if not IsValid(keyboardFrame) then
                keyboardFrame = vgui.Create("KeyboardDisplay")
                -- 确保面板创建成功
                if IsValid(keyboardFrame) and keyboard_locked:GetBool() then
                    keyboardFrame:ShowCloseButton(false)
                    keyboardFrame:SetDraggable(false)
                    keyboardFrame:SetMouseInputEnabled(false)
                    keyboardFrame:SetKeyboardInputEnabled(false)
                    keyboardFrame:DockPadding(0, 0, 0, 0)
                    keyboardFrame:SetTitle("")
                    keyboardFrame:SetSize(810, 285)
                end
            end
        else
            if IsValid(keyboardFrame) then
                keyboardFrame:Remove()
                keyboardFrame = nil
            end
        end
    end)

    -- 游戏载入时检查是否需要显示键位显示器
    hook.Add("InitPostEntity", "CheckKeyboardDisplay", function()
        if keyboard_enabled:GetBool() then
            keyboardFrame = vgui.Create("KeyboardDisplay")
            if keyboard_locked:GetBool() then
                keyboardFrame:ShowCloseButton(false)
                keyboardFrame:SetDraggable(false)
                keyboardFrame:SetMouseInputEnabled(false)
                keyboardFrame:SetKeyboardInputEnabled(false)
                keyboardFrame:DockPadding(0, 0, 0, 0)
                keyboardFrame:SetTitle("")
                keyboardFrame:SetSize(810, 285)
            end
        end
    end)

    -- 设置预设颜色方案
    local presets = {
        [language.GetPhrase("of_keyboard.preset.lambda")] = {255, 140, 0},
        [language.GetPhrase("of_keyboard.preset.pink")] = {238, 130, 238},
        [language.GetPhrase("of_keyboard.preset.green")] = {50, 205, 50},
        [language.GetPhrase("of_keyboard.preset.violet")] = {100, 100, 255},
        [language.GetPhrase("of_keyboard.preset.yellow")] = {255, 215, 0}
    }

    list.Set("DesktopWindows", "ofkb", {
        title = language.GetPhrase("of_keyboard.settings"),
        icon = "icon16/keyboard.png",
        init = function()
            local menu = DermaMenu()
            menu:AddCVar(language.GetPhrase("of_keyboard.show"), "of_keyboard_enabled", "0", "1"):SetIcon("icon16/eye.png")
            menu:AddCVar(language.GetPhrase("of_keyboard.lock"), "of_keyboard_locked", "0", "1"):SetIcon("icon16/lock.png")
            
            -- 添加颜色子菜单
            local colorSubMenu, colorBtn = menu:AddSubMenu(language.GetPhrase("of_keyboard.presets"))
            colorBtn:SetIcon("icon16/color_wheel.png")
            
            -- 添加预设颜色选项
            for name, color in pairs(presets) do
                colorSubMenu:AddOption(name, function()
                    SetPresetColor(color[1], color[2], color[3])
                end)
            end
            
            menu:Open()
        end
    })
end
