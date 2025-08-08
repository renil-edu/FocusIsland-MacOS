//
//  FocusSettings.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


//
//  FocusSettings.swift
//  FocusIsland
//
//  Created by UT Austin on 8/4/25.
//

import Foundation
import Combine

/// All tunable numbers live here and persist automatically.
final class FocusSettings: ObservableObject, Codable {
    // MARK: – Tunables (defaults match the spec)
    @Published var focusMinutes: Int          = 20   // F
    @Published var standardBreakMinutes: Int  = 10   // B
    @Published var scalingFactor: Double      = 1.0/6.0 // S (1⁄6)

    private enum CodingKeys: CodingKey {
        case focusMinutes, standardBreakMinutes, scalingFactor
    }

    // MARK: – Persistence
    private static let key = "FocusSettings.v1"

    static func load() -> FocusSettings {
        if let data = UserDefaults.standard.data(forKey: key),
           let model = try? JSONDecoder().decode(FocusSettings.self, from: data) {
            return model
        }
        return FocusSettings()
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    // Encode / decode so @Published vars persist.
    init() {}
    init(from decoder: Decoder) throws {
        let c  = try decoder.container(keyedBy: CodingKeys.self)
        focusMinutes          = try c.decode(Int.self,    forKey: .focusMinutes)
        standardBreakMinutes  = try c.decode(Int.self,    forKey: .standardBreakMinutes)
        scalingFactor         = try c.decode(Double.self, forKey: .scalingFactor)
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(focusMinutes,         forKey: .focusMinutes)
        try c.encode(standardBreakMinutes, forKey: .standardBreakMinutes)
        try c.encode(scalingFactor,        forKey: .scalingFactor)
    }
}
