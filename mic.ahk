#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; --- Глобальные переменные ---
global iniPath := A_ScriptDir "\settings.ini"
global volStep := 10               ; Шаг по умолчанию
global activeCorner := "Top-Right" ; Угол по умолчанию
global selectedDevice := "Auto"    ; Устройство по умолчанию

; --- Переменные состояния ---
global oGui := ""
global textCtrl := ""
global progressCtrl := ""
global isGuiVisible := false
global deviceList := []
global micMenu := ""
global fadeTimer := 0
global lastVolumeChangeTime := 0

; Загрузка сохраненных настроек из INI-файла
LoadSettings()

; Инициализация графического интерфейса и контекстного меню
CreateOSD()
SetupTrayMenu()

; --- Проверка положения мыши ---
IsInCorner() {
    CoordMode "Mouse", "Screen"
    MouseGetPos &mx, &my
    sw := A_ScreenWidth
    sh := A_ScreenHeight

    if (activeCorner == "Top-Left")
        return (mx <= cornerSize && my <= cornerSize)
    else if (activeCorner == "Top-Right")
        return (mx >= sw - cornerSize && my <= cornerSize)
    else if (activeCorner == "Bottom-Left")
        return (mx <= cornerSize && my >= sh - cornerSize)
    else if (activeCorner == "Bottom-Right")
        return (mx >= sw - cornerSize && my >= sh - cornerSize)
    return false
}

global cornerSize := 15 ; Размер чувствительной зоны угла (в пикселях)

; --- Горячие клавиши в углу экрана ---
#HotIf IsInCorner()
WheelUp::AdjustVolume(volStep)
WheelDown::AdjustVolume(-volStep)
MButton::ToggleMute()
#HotIf

; --- ГЛОБАЛЬНЫЕ ГОРЯЧИЕ КЛАВИШИ (СТРОГО ПРАВЫЙ ALT) ---

; Установка точной громкости (Right Alt + 1..0)
RAlt & 1::SetDirectVolume(10)
RAlt & 2::SetDirectVolume(20)
RAlt & 3::SetDirectVolume(30)
RAlt & 4::SetDirectVolume(40)
RAlt & 5::SetDirectVolume(50)
RAlt & 6::SetDirectVolume(60)
RAlt & 7::SetDirectVolume(70)
RAlt & 8::SetDirectVolume(80)
RAlt & 9::SetDirectVolume(90)
RAlt & 0::SetDirectVolume(100)

; Плавное изменение за 1.5 секунды (Виртуальные коды нижнего ряда)
; vkBC = Кома (,) / Буква Б
; vkBE = Точка (.) / Буква Ю
; vkBF = Слэш (/) / Точка (.) в русс. раскладке
RAlt & vkBC::FadeToVolume(10, 1000)
RAlt & vkBE::FadeToVolume(25, 1000)
RAlt & vkBF::FadeToVolume(75, 1000)


; --- Чтение и сохранение настроек (INI-файл) ---
LoadSettings() {
    global selectedDevice, activeCorner, volStep, iniPath
    
    selectedDevice := IniRead(iniPath, "Settings", "Microphone", "Auto")
    activeCorner   := IniRead(iniPath, "Settings", "Corner", "Top-Right")
    volStep        := Integer(IniRead(iniPath, "Settings", "Step", "10"))
}

SaveSettings() {
    global selectedDevice, activeCorner, volStep, iniPath
    try {
        IniWrite(selectedDevice, iniPath, "Settings", "Microphone")
        IniWrite(activeCorner, iniPath, "Settings", "Corner")
        IniWrite(volStep, iniPath, "Settings", "Step")
    }
}

; --- Определение целевого устройства ---
GetTargetDevice() {
    global selectedDevice, deviceList
    if (selectedDevice != "Auto")
        return selectedDevice
        
    for devName in deviceList {
        if (RegExMatch(devName, "i)(mic|мик|codec|input|droidcam|headset|audio|запис)"))
            return devName
    }
    
    return "Microphone"
}

; --- Функции управления громкостью ---
GetMicVolume() {
    dev := GetTargetDevice()
    try {
        return Round(SoundGetVolume(, dev))
    } catch {
        return 0
    }
}

SetMicVolume(val) {
    val := Max(0, Min(100, val))
    dev := GetTargetDevice()
    try {
        SoundSetVolume(val, , dev)
    }
}

GetMicMute() {
    dev := GetTargetDevice()
    try {
        return SoundGetMute(, dev)
    } catch {
        return false
    }
}

SetMicMute(status) {
    dev := GetTargetDevice()
    try {
        SoundSetMute(status, , dev)
    }
}

AdjustVolume(step) {
    StopFade()
    current := GetMicVolume()
    SetMicVolume(current + step)
    UpdateOSD()
}

SetDirectVolume(targetVol) {
    StopFade()
    SetMicVolume(targetVol)
    UpdateOSD()
}

ToggleMute() {
    StopFade()
    currentMute := GetMicMute()
    SetMicMute(!currentMute)
    UpdateOSD()
}

; --- Функция плавного угасания/нарастания громкости ---
FadeToVolume(targetVol, durationMs := 1500) {
    global fadeTimer
    StopFade()
    
    startVol := GetMicVolume()
    if (startVol == targetVol) {
        UpdateOSD()
        return
    }
    
    startTime := A_TickCount
    
    fadeStep() {
        global fadeTimer
        elapsed := A_TickCount - startTime
        
        if (elapsed >= durationMs) {
            SetMicVolume(targetVol)
            UpdateOSD()
            StopFade()
            return
        }
        
        ; Линейная интерполяция громкости
        progress := elapsed / durationMs
        current := startVol + (targetVol - startVol) * progress
        SetMicVolume(Round(current))
        UpdateOSD()
    }
    
    fadeTimer := fadeStep
    SetTimer(fadeTimer, 30) ; Обновление каждые 30 мс
}

StopFade() {
    global fadeTimer
    if (fadeTimer) {
        SetTimer(fadeTimer, 0)
        fadeTimer := 0
    }
}

; --- Создание и обновление OSD ---
CreateOSD() {
    global oGui, textCtrl, progressCtrl
    
    oGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    oGui.BackColor := "1A1A1A"
    oGui.MarginX := 0
    oGui.MarginY := 12
    
    oGui.SetFont("s10 cWhite Bold", "Segoe UI")
    textCtrl := oGui.AddText("x0 w300 Center", "Микрофон: 100%")
    
    progressCtrl := oGui.AddProgress("x20 w260 h12 Background333333 c00FF00", 50)
    
    oGui.SetFont("s8 cGray", "Consolas")
    oGui.AddText("x20 w260 Left -Wrap", "0   10  20  30  40  50  60  70  80  90  100")
}

UpdateOSD() {
    global oGui, textCtrl, progressCtrl, isGuiVisible, lastVolumeChangeTime
    
    vol := GetMicVolume()
    muted := GetMicMute()
    
    if (muted) {
        textCtrl.Text := "Микрофон: ВЫКЛЮЧЕН"
        progressCtrl.Value := 0
        progressCtrl.Opt("+cRed")
    } else {
        textCtrl.Text := "Микрофон: " . vol . "%"
        progressCtrl.Value := vol
        progressCtrl.Opt("+c00FF00")
    }
    
    lastVolumeChangeTime := A_TickCount
    
    if (!isGuiVisible) {
        gx := (A_ScreenWidth - 300) / 2
        gy := A_ScreenHeight - 160
        oGui.Show("w300 x" . gx . " y" . gy . " NoActivate")
        isGuiVisible := true
        SetTimer(CheckMousePosition, 100)
    }
}

CheckMousePosition() {
    global isGuiVisible, oGui, lastVolumeChangeTime, fadeTimer
    
    inCorner := IsInCorner()
    fadeActive := (fadeTimer != 0)
    recentChange := (A_TickCount - lastVolumeChangeTime < 1500)
    
    if (!inCorner && !fadeActive && !recentChange) {
        oGui.Hide()
        isGuiVisible := false
        SetTimer(CheckMousePosition, 0)
    }
}

; --- Настройка контекстного меню и сканирование устройств ---
SetupTrayMenu() {
    A_TrayMenu.Delete()
    
    ; Подменю выбора микрофона
    BuildMicrophoneMenu()
    A_TrayMenu.Add("Выбор микрофона", micMenu)
    
    A_TrayMenu.Add() ; Разделитель
    
    ; Подменю выбора угла
    global cornerMenu := Menu()
    global cornerItems := Map(
        "Top-Left", "Верхний левый",
        "Top-Right", "Верхний правый",
        "Bottom-Left", "Нижний левый",
        "Bottom-Right", "Нижний правый"
    )
    for key, val in cornerItems {
        cornerMenu.Add(val, MenuSelectCorner.Bind(key))
        if (key == activeCorner)
            cornerMenu.Check(val)
    }
    A_TrayMenu.Add("Активный угол", cornerMenu)
    
    ; Подменю выбора шага
    global stepMenu := Menu()
    global stepOptions := [5, 10, 20, 30, 40, 50]
    for step in stepOptions {
        stepMenu.Add(step . "%", MenuSelectStep.Bind(step))
        if (step == volStep)
            stepMenu.Check(step . "%")
    }
    A_TrayMenu.Add("Шаг изменения", stepMenu)
    
    A_TrayMenu.Add()
    A_TrayMenu.AddStandard()
}

BuildMicrophoneMenu() {
    global micMenu, selectedDevice, deviceList
    micMenu := Menu()
    deviceList := []
    
    ; Пункт автоматического выбора
    micMenu.Add("Автоматически (По умолчанию)", (*) => SelectMicrophone("Auto"))
    if (selectedDevice == "Auto")
        micMenu.Check("Автоматически (По умолчанию)")
        
    micMenu.Add() ; Разделитель
    
    ; Сканирование аудиоустройств системы
    Loop 30 {
        try {
            devName := SoundGetName(, A_Index)
            if (devName != "") {
                alreadyExists := false
                for existing in deviceList {
                    if (existing == devName) {
                        alreadyExists := true
                        break
                    }
                }
                
                if (!alreadyExists) {
                    deviceList.Push(devName)
                    micMenu.Add(devName, MenuSelectMic.Bind(devName))
                    if (selectedDevice == devName)
                        micMenu.Check(devName)
                }
            }
        } catch {
            continue
        }
    }
    
    micMenu.Add()
    micMenu.Add("Обновить список устройств", (*) => SetupTrayMenu())
}

MenuSelectMic(devName, itemName, itemPos, menuObj) {
    SelectMicrophone(devName)
}

SelectMicrophone(devName) {
    global selectedDevice
    selectedDevice := devName
    SaveSettings()  ; Сохранение в файл
    SetupTrayMenu() ; Обновление галочек в меню
    UpdateOSD()     ; Обновление индикатора
}

MenuSelectCorner(cornerName, itemName, itemPos, menuObj) {
    global activeCorner, cornerItems, cornerMenu
    for key, val in cornerItems {
        cornerMenu.Uncheck(val)
    }
    activeCorner := cornerName
    cornerMenu.Check(cornerItems[cornerName])
    SaveSettings()  ; Сохранение в файл
}

MenuSelectStep(stepValue, itemName, itemPos, menuObj) {
    global volStep, stepOptions, stepMenu
    for step in stepOptions {
        stepMenu.Uncheck(step . "%")
    }
    volStep := stepValue
    stepMenu.Check(stepValue . "%")
    SaveSettings()  ; Сохранение в файл
}

; Инициализация состояния при старте
AdjustVolume(0)