import Foundation

// MARK: - Localization
// Supports: zh-Hans, en, ja, ko, fr, de, es, pt-BR, ru, ar
// Falls back to English for any missing key.

enum L10n {

    // MARK: - Public API

    static func tr(_ key: String) -> String {
        if let value = strings[preferredLanguage]?[key], !value.isEmpty {
            return value
        }
        return strings["en"]?[key] ?? key
    }

    static let supportedLanguages: [(label: String, locale: String)] = [
        ("简体中文",   "zh-Hans"),
        ("English",    "en"),
        ("日本語",     "ja"),
        ("한국어",     "ko"),
        ("Français",   "fr"),
        ("Deutsch",    "de"),
        ("Español",   "es"),
        ("Português", "pt-BR"),
        ("Русский",   "ru"),
        ("العربية",   "ar"),
    ]

    static var preferredLanguage: String {
        get { UserDefaults.standard.string(forKey: "preferredLanguage") ?? systemLocale }
        set { UserDefaults.standard.set(newValue, forKey: "preferredLanguage") }
    }

    static func currentDisplayName() -> String {
        supportedLanguages.first { $0.locale == preferredLanguage }?.label ?? "English"
    }

    static var isRTL: Bool { preferredLanguage == "ar" }

    // MARK: - System Locale Detection

    private static var systemLocale: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        switch preferred.prefix(2) {
        case "zh": return "zh-Hans"
        case "ja": return "ja"
        case "ko": return "ko"
        case "fr": return "fr"
        case "de": return "de"
        case "es": return "es"
        case "pt": return "pt-BR"
        case "ru": return "ru"
        case "ar": return "ar"
        default:   return "en"
        }
    }

    // MARK: - String Tables

    private static let strings: [String: [String: String]] = [
        "en": [
            "app_name":        "NoSleep",
            "header_active":   "Mac stays awake · Screen on",
            "header_inactive": "Normal sleep settings",
            "toggle_title":    "Prevent Sleep & Lock Screen",
            "toggle_subtitle": "Block system sleep, screen off and locking",
            "status_running":  "Running · Screen always on",
            "quit_button":     "Quit NoSleep",
            "menu_about":      "About NoSleep",
            "menu_quit":       "Quit NoSleep",
            "about_text":      "Version 1.0.0\nKeep your Mac awake and prevent screen lock with one click",
            "lang_title":      "Language",
            "lang_subtitle":   "Select your preferred language",
        ],
        "zh-Hans": [
            "app_name":        "NoSleep",
            "header_active":   "Mac 保持唤醒 · 屏幕常亮",
            "header_inactive": "系统按正常设置休眠",
            "toggle_title":    "防止睡眠与锁屏",
            "toggle_subtitle": "阻止系统休眠、屏幕关闭和锁定",
            "status_running":  "运行中 · 屏幕常亮",
            "quit_button":     "退出 NoSleep",
            "menu_about":      "关于 NoSleep",
            "menu_quit":       "退出 NoSleep",
            "about_text":      "版本 1.0.0\n一键保持 Mac 唤醒并防止锁屏",
            "lang_title":      "语言",
            "lang_subtitle":   "选择你偏好的语言",
        ],
        "ja": [
            "app_name":        "NoSleep",
            "header_active":   "Macは起動中 · 画面は常時点灯",
            "header_inactive": "通常のスリープ設定",
            "toggle_title":    "スリープとロック画面を防止",
            "toggle_subtitle": "システムのスリープ、画面オフ、ロックを防止",
            "status_running":  "実行中 · 画面は常時点灯",
            "quit_button":     "NoSleepを終了",
            "menu_about":      "NoSleepについて",
            "menu_quit":       "NoSleepを終了",
            "about_text":      "バージョン 1.0.0\nワンクリックでMacのスリープと画面ロックを防止",
            "lang_title":      "言語",
            "lang_subtitle":   "言語を選択してください",
        ],
        "ko": [
            "app_name":        "NoSleep",
            "header_active":   "Mac 대기 방지 · 화면 켜짐",
            "header_inactive": "일반 절전 모드 설정",
            "toggle_title":    "절전 및 화면 잠금 방지",
            "toggle_subtitle": "시스템 절전, 화면 끄기, 잠금 방지",
            "status_running":  "실행 중 · 화면 항상 켜짐",
            "quit_button":     "NoSleep 종료",
            "menu_about":      "NoSleep 정보",
            "menu_quit":       "NoSleep 종료",
            "about_text":      "버전 1.0.0\n원클릭으로 Mac 대기 방지 및 화면 잠금 방지",
            "lang_title":      "언어",
            "lang_subtitle":   "선호하는 언어를 선택하세요",
        ],
        "fr": [
            "app_name":        "NoSleep",
            "header_active":   "Mac reste éveillé · Écran allumé",
            "header_inactive": "Mise en veille normale",
            "toggle_title":    "Empêcher la mise en veille et le verrouillage",
            "toggle_subtitle": "Bloquer la mise en veille, l'extinction et le verrouillage de l'écran",
            "status_running":  "En cours · Écran toujours allumé",
            "quit_button":     "Quitter NoSleep",
            "menu_about":      "À propos de NoSleep",
            "menu_quit":       "Quitter NoSleep",
            "about_text":      "Version 1.0.0\nGardez votre Mac éveillé et empêchez le verrouillage en un clic",
            "lang_title":      "Langue",
            "lang_subtitle":   "Sélectionnez votre langue préférée",
        ],
        "de": [
            "app_name":        "NoSleep",
            "header_active":   "Mac bleibt wach · Bildschirm an",
            "header_inactive": "Normaler Ruhezustand",
            "toggle_title":    "Ruhezustand und Sperrbildschirm verhindern",
            "toggle_subtitle": "System-Ruhezustand, Bildschirmabschaltung und Sperren blockieren",
            "status_running":  "Läuft · Bildschirm bleibt an",
            "quit_button":     "NoSleep beenden",
            "menu_about":      "Über NoSleep",
            "menu_quit":       "NoSleep beenden",
            "about_text":      "Version 1.0.0\nHalten Sie Ihren Mac wach und verhindern Sie die Sperrung mit einem Klick",
            "lang_title":      "Sprache",
            "lang_subtitle":   "Wählen Sie Ihre bevorzugte Sprache",
        ],
        "es": [
            "app_name":        "NoSleep",
            "header_active":   "Mac despierto · Pantalla encendida",
            "header_inactive": "Ajustes normales de suspensión",
            "toggle_title":    "Evitar suspensión y bloqueo de pantalla",
            "toggle_subtitle": "Bloquear suspensión del sistema, apagado y bloqueo de pantalla",
            "status_running":  "En ejecución · Pantalla siempre encendida",
            "quit_button":     "Salir de NoSleep",
            "menu_about":      "Acerca de NoSleep",
            "menu_quit":       "Salir de NoSleep",
            "about_text":      "Versión 1.0.0\nMantén tu Mac despierto y evita el bloqueo de pantalla con un clic",
            "lang_title":      "Idioma",
            "lang_subtitle":   "Selecciona tu idioma preferido",
        ],
        "pt-BR": [
            "app_name":        "NoSleep",
            "header_active":   "Mac permanece ativo · Tela ligada",
            "header_inactive": "Configuração normal de suspensão",
            "toggle_title":    "Impedir suspensão e bloqueio de tela",
            "toggle_subtitle": "Bloquear suspensão do sistema, desligamento e bloqueio de tela",
            "status_running":  "Em execução · Tela sempre ligada",
            "quit_button":     "Sair do NoSleep",
            "menu_about":      "Sobre o NoSleep",
            "menu_quit":       "Sair do NoSleep",
            "about_text":      "Versão 1.0.0\nMantenha seu Mac ativo e evite o bloqueio de tela com um clique",
            "lang_title":      "Idioma",
            "lang_subtitle":   "Selecione seu idioma preferido",
        ],
        "ru": [
            "app_name":        "NoSleep",
            "header_active":   "Mac не засыпает · Экран включён",
            "header_inactive": "Обычный режим сна",
            "toggle_title":    "Предотвратить сон и блокировку экрана",
            "toggle_subtitle": "Блокировать спящий режим, выключение и блокировку экрана",
            "status_running":  "Работает · Экран всегда включён",
            "quit_button":     "Выйти из NoSleep",
            "menu_about":      "О программе NoSleep",
            "menu_quit":       "Выйти из NoSleep",
            "about_text":      "Версия 1.0.0\nНе давайте Mac заснуть и предотвращайте блокировку экрана одним нажатием",
            "lang_title":      "Язык",
            "lang_subtitle":   "Выберите предпочтительный язык",
        ],
        "ar": [
            "app_name":        "NoSleep",
            "header_active":   "الجهاز مستيقظ · الشاشة مُضاءة",
            "header_inactive": "إعدادات السكون العادية",
            "toggle_title":    "منع السكون وقفل الشاشة",
            "toggle_subtitle": "منع سكون النظام وإطفاء الشاشة والقفل",
            "status_running":  "قيد التشغيل · الشاشة مضاءة",
            "quit_button":     "إنهاء NoSleep",
            "menu_about":      "حول NoSleep",
            "menu_quit":       "إنهاء NoSleep",
            "about_text":      "الإصدار 1.0.0\nأبقِ جهازك مستيقظًا ومنع قفل الشاشة بنقرة واحدة",
            "lang_title":      "اللغة",
            "lang_subtitle":   "اختر لغتك المفضلة",
        ],
    ]
}
