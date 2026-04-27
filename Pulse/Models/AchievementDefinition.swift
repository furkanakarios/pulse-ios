import SwiftUI

// MARK: - Category

enum AchievementCategory: String, CaseIterable {
    case water      = "Su"
    case exercise   = "Egzersiz"
    case nutrition  = "Beslenme"
    case habit      = "Alışkanlık"
    case general    = "Genel"

    var icon: String {
        switch self {
        case .water:     return "drop.fill"
        case .exercise:  return "figure.run"
        case .nutrition: return "fork.knife"
        case .habit:     return "checkmark.circle.fill"
        case .general:   return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .water:     return .pulseWater
        case .exercise:  return .pulseExercise
        case .nutrition: return .pulseNutrition
        case .habit:     return .pulseHabit
        case .general:   return Color(red: 1.0, green: 0.75, blue: 0.0) // altın
        }
    }
}

// MARK: - Definition

struct AchievementDefinition {
    let key: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    /// Streak / count bazlı başarımlarda kaçıncı adımda bildirim gönderilsin (0 = bildirim yok)
    let notifyAtProgress: Int
    /// Toplam gereken adım sayısı (streak veya count). Tek seferlik ise 1.
    let totalSteps: Int

    static let all: [AchievementDefinition] = water + exercise + nutrition + habit + general
}

// MARK: - Water

private extension AchievementDefinition {
    static let water: [AchievementDefinition] = [
        .init(
            key: "water_first",
            title: "İlk Yudum",
            description: "İlk kez su ekle.",
            icon: "drop.fill",
            category: .water,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "water_daily_goal",
            title: "Günlük Hedef",
            description: "Bir günde su hedefini tamamla.",
            icon: "drop.circle.fill",
            category: .water,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "water_streak_3",
            title: "3 Günlük Seri",
            description: "3 gün üst üste günlük su hedefini tamamla.",
            icon: "flame.fill",
            category: .water,
            notifyAtProgress: 2,
            totalSteps: 3
        ),
        .init(
            key: "water_streak_7",
            title: "Haftalık Su",
            description: "7 gün üst üste günlük su hedefini tamamla.",
            icon: "7.circle.fill",
            category: .water,
            notifyAtProgress: 6,
            totalSteps: 7
        ),
        .init(
            key: "water_streak_30",
            title: "Su Ustası",
            description: "30 gün üst üste günlük su hedefini tamamla.",
            icon: "crown.fill",
            category: .water,
            notifyAtProgress: 28,
            totalSteps: 30
        ),
        .init(
            key: "water_total_50L",
            title: "50 Litre",
            description: "Toplamda 50 litre su iç.",
            icon: "waterbottle.fill",
            category: .water,
            notifyAtProgress: 45,
            totalSteps: 50
        ),
        .init(
            key: "water_total_100L",
            title: "100 Litre",
            description: "Toplamda 100 litre su iç.",
            icon: "trophy.fill",
            category: .water,
            notifyAtProgress: 95,
            totalSteps: 100
        ),
    ]
}

// MARK: - Exercise

private extension AchievementDefinition {
    static let exercise: [AchievementDefinition] = [
        .init(
            key: "exercise_first",
            title: "İlk Hareket",
            description: "İlk egzersiz kaydını ekle.",
            icon: "figure.run",
            category: .exercise,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "exercise_daily_goal",
            title: "Günlük Antrenman",
            description: "Bir günde egzersiz hedefini tamamla.",
            icon: "bolt.circle.fill",
            category: .exercise,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "exercise_streak_3",
            title: "3 Günlük Ateş",
            description: "3 gün üst üste egzersiz hedefini tamamla.",
            icon: "flame.fill",
            category: .exercise,
            notifyAtProgress: 2,
            totalSteps: 3
        ),
        .init(
            key: "exercise_streak_7",
            title: "Haftalık Sporcu",
            description: "7 gün üst üste egzersiz hedefini tamamla.",
            icon: "medal.fill",
            category: .exercise,
            notifyAtProgress: 6,
            totalSteps: 7
        ),
        .init(
            key: "exercise_streak_30",
            title: "Egzersiz Efsanesi",
            description: "30 gün üst üste egzersiz hedefini tamamla.",
            icon: "crown.fill",
            category: .exercise,
            notifyAtProgress: 28,
            totalSteps: 30
        ),
        .init(
            key: "exercise_total_10h",
            title: "10 Saat Spor",
            description: "Toplamda 10 saat egzersiz yap.",
            icon: "clock.badge.checkmark",
            category: .exercise,
            notifyAtProgress: 9,
            totalSteps: 10
        ),
    ]
}

// MARK: - Nutrition

private extension AchievementDefinition {
    static let nutrition: [AchievementDefinition] = [
        .init(
            key: "nutrition_first",
            title: "İlk Öğün",
            description: "İlk kez bir öğünü tamamlandı olarak işaretle.",
            icon: "fork.knife",
            category: .nutrition,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "nutrition_daily_complete",
            title: "Tam Program",
            description: "Bir günde tüm öğünleri tamamla.",
            icon: "checkmark.seal.fill",
            category: .nutrition,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "nutrition_streak_3",
            title: "3 Günlük Düzen",
            description: "3 gün üst üste tüm öğünleri tamamla.",
            icon: "star.fill",
            category: .nutrition,
            notifyAtProgress: 2,
            totalSteps: 3
        ),
        .init(
            key: "nutrition_streak_7",
            title: "Beslenme Şampiyonu",
            description: "7 gün üst üste tüm öğünleri tamamla.",
            icon: "star.circle.fill",
            category: .nutrition,
            notifyAtProgress: 6,
            totalSteps: 7
        ),
        .init(
            key: "nutrition_streak_30",
            title: "Diyet Ustası",
            description: "30 gün üst üste tüm öğünleri tamamla.",
            icon: "crown.fill",
            category: .nutrition,
            notifyAtProgress: 28,
            totalSteps: 30
        ),
    ]
}

// MARK: - Habit

private extension AchievementDefinition {
    static let habit: [AchievementDefinition] = [
        .init(
            key: "habit_first_created",
            title: "İlk Alışkanlık",
            description: "İlk alışkanlığını oluştur.",
            icon: "plus.circle.fill",
            category: .habit,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "habit_daily_complete",
            title: "Tam Gün",
            description: "Bir günde tüm alışkanlıklarını tamamla.",
            icon: "checkmark.circle.fill",
            category: .habit,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "habit_streak_7",
            title: "7 Günlük Alışkanlık",
            description: "7 gün üst üste tüm alışkanlıklarını tamamla.",
            icon: "repeat.circle.fill",
            category: .habit,
            notifyAtProgress: 6,
            totalSteps: 7
        ),
        .init(
            key: "habit_streak_30",
            title: "Alışkanlık Ustası",
            description: "30 gün üst üste tüm alışkanlıklarını tamamla.",
            icon: "infinity.circle.fill",
            category: .habit,
            notifyAtProgress: 28,
            totalSteps: 30
        ),
    ]
}

// MARK: - General

private extension AchievementDefinition {
    static let general: [AchievementDefinition] = [
        .init(
            key: "general_perfect_day",
            title: "Mükemmel Gün",
            description: "Su, egzersiz, beslenme ve alışkanlık hedeflerini aynı günde tamamla.",
            icon: "sparkles",
            category: .general,
            notifyAtProgress: 0,
            totalSteps: 1
        ),
        .init(
            key: "general_perfect_week",
            title: "Mükemmel Hafta",
            description: "7 gün üst üste mükemmel gün kazan.",
            icon: "sun.max.fill",
            category: .general,
            notifyAtProgress: 6,
            totalSteps: 7
        ),
    ]
}
