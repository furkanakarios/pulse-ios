import Foundation

actor NutritionService {
    static let shared = NutritionService()
    private init() {}

    // Local Turkish food DB: (keywords, kcal/birim, kcal/100g, gram/birim)
    private let localDB: [(keywords: [String], kcalPerUnit: Double, kcalPer100g: Double, gramsPerUnit: Double)] = [
        (["yumurta"], 70, 147, 60),
        (["süzme peynir"], 70, 105, 30),
        (["beyaz peynir", "peynir"], 90, 260, 30),
        (["kaşar"], 110, 380, 30),
        (["zeytin"], 7, 145, 5),
        (["ekmek", "tam buğday ekmek"], 80, 265, 30),
        (["salatalık", "hıyar"], 15, 12, 120),
        (["domates"], 20, 18, 120),
        (["biber"], 10, 20, 60),
        (["muz"], 90, 89, 100),
        (["elma"], 70, 52, 130),
        (["portakal"], 60, 47, 130),
        (["çilek"], 30, 32, 100),
        (["tavuk göğsü", "tavuk"], 165, 165, 100),
        (["kıyma", "dana kıyma", "kuzu kıyma"], 250, 250, 100),
        (["biftek", "dana eti", "et"], 200, 200, 100),
        (["levrek", "çipura", "somon", "balık"], 120, 120, 100),
        (["ton balığı", "ton baligi"], 110, 110, 100),
        (["pirinç", "pilav"], 130, 130, 100),
        (["bulgur"], 110, 110, 100),
        (["makarna", "spagetti"], 150, 150, 100),
        (["yoğurt"], 60, 60, 150),
        (["süt"], 50, 42, 150),
        (["kefir"], 65, 43, 150),
        (["ceviz"], 185, 654, 30),
        (["badem"], 170, 579, 30),
        (["fıstık", "yer fıstığı"], 160, 567, 30),
        (["tereyağ", "tereyağı"], 72, 717, 10),
        (["zeytinyağ", "zeytinyağı"], 90, 884, 10),
        (["patates"], 80, 77, 100),
        (["tatlı patates"], 90, 86, 100),
        (["havuç"], 25, 41, 60),
        (["ıspanak"], 20, 23, 100),
        (["brokoli", "karnabahar"], 35, 34, 100),
        (["fasulye", "yeşil fasulye"], 35, 31, 100),
        (["mercimek"], 120, 116, 100),
        (["nohut"], 160, 164, 100),
        (["barbunya", "kuru fasulye"], 125, 127, 100),
        (["çorba"], 80, 32, 250),
        (["börek", "sigara böreği"], 200, 250, 80),
        (["mantı"], 300, 150, 200),
        (["döner"], 280, 280, 100),
        (["köfte"], 120, 220, 50),
        (["sosis", "salam"], 100, 300, 30),
        (["avokado"], 160, 160, 100),
        (["limon"], 5, 29, 25),
        (["bal"], 60, 304, 20),
        (["reçel"], 50, 250, 20),
        (["fındık ezmesi", "fıstık ezmesi"], 95, 590, 16),
        (["granola", "müsli"], 200, 380, 50),
        (["yulaf", "yulaf ezmesi"], 150, 389, 40),
    ]

    // MARK: - Public API

    func estimateCalories(name: String, quantity: String) async -> Double? {
        let lower = name.lowercased().trimmingCharacters(in: .whitespaces)
        let (value, isGrams) = parseQuantity(quantity)

        // 1. Local DB
        if let match = searchLocal(name: lower) {
            if isGrams {
                return (match.kcalPer100g * value / 100).rounded()
            } else {
                return (match.kcalPerUnit * value).rounded()
            }
        }

        // 2. Open Food Facts fallback
        if let kcalPer100g = await searchOpenFoodFacts(name: lower) {
            let grams = isGrams ? value : 100.0
            return (kcalPer100g * grams / 100).rounded()
        }

        return nil
    }

    // MARK: - Private

    private func searchLocal(name: String) -> (kcalPerUnit: Double, kcalPer100g: Double)? {
        for entry in localDB {
            if entry.keywords.contains(where: { name.contains($0) }) {
                return (entry.kcalPerUnit, entry.kcalPer100g)
            }
        }
        return nil
    }

    // Returns kcal/100g from the first matching product
    private func searchOpenFoodFacts(name: String) async -> Double? {
        guard let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(encoded)&search_simple=1&action=process&json=1&page_size=5&fields=nutriments") else {
            return nil
        }
        do {
            var request = URLRequest(url: url, timeoutInterval: 5)
            request.setValue("PulseApp/1.0", forHTTPHeaderField: "User-Agent")
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let products = json["products"] as? [[String: Any]] else { return nil }
            for product in products {
                if let nutriments = product["nutriments"] as? [String: Any] {
                    if let kcal = nutriments["energy-kcal_100g"] as? Double, kcal > 0 {
                        return kcal
                    }
                    if let kcal = nutriments["energy-kcal_100g"] as? Int, kcal > 0 {
                        return Double(kcal)
                    }
                }
            }
        } catch {}
        return nil
    }

    // Parses quantity string like "3 adet", "150g", "2 dilim"
    // Returns (numeric value, isGrams)
    private func parseQuantity(_ quantity: String) -> (value: Double, isGrams: Bool) {
        let q = quantity.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return (1, false) }

        // Extract first number
        var numStr = ""
        var rest = q
        for char in q {
            if char.isNumber || char == "," || char == "." {
                numStr.append(char == "," ? "." : char)
                rest = String(rest.dropFirst())
            } else { break }
        }
        let value = max(1, Double(numStr) ?? 1)

        // Check for gram indicators
        let isGrams = rest.trimmingCharacters(in: .whitespaces).hasPrefix("g") &&
                      !rest.trimmingCharacters(in: .whitespaces).hasPrefix("gr") == false ||
                      q.contains(" g ") || q.contains(" gr") || q.contains("gram")

        let simpleGram = rest.trimmingCharacters(in: .whitespaces).first == "g"
        return (value, simpleGram)
    }
}
