//
//  SignData.swift
//  SignHelper
//
//  Created by Lucas Liu on 2026/1/20.
//

import Foundation

struct SignCategory: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let icon: String
    let difficulty: String
    let signs: [SignItem]
}

struct SignItem: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let demoImageName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, imageName, demoImageName
    }
    
    init(id: String, title: String, description: String, imageName: String, demoImageName: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.demoImageName = demoImageName
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        description = try c.decode(String.self, forKey: .description)
        imageName = try c.decode(String.self, forKey: .imageName)
        demoImageName = try c.decodeIfPresent(String.self, forKey: .demoImageName)
    }
}

private struct SignDataRoot: Codable {
    let categories: [SignCategory]
}

class SignDataManager {
    static let shared = SignDataManager()
    
    let categories: [SignCategory]
    
    private init() {
        if let loaded = Self.loadFromJSON() {
            categories = loaded
        } else {
            // Fallback to a minimal in-memory dataset to avoid crash if JSON is missing
            categories = [
                SignCategory(
                    id: "fallback_greetings",
                    title: "Greetings",
                    icon: "hand.wave.fill",
                    difficulty: "Easy",
                    signs: [
                        SignItem(
                            id: "hello",
                            title: "Hello",
                            description: "Raise hand and wave side to side.",
                            imageName: "hand.wave.fill"
                        )
                    ]
                )
            ]
        }
    }
    
    private static func loadFromJSON() -> [SignCategory]? {
        guard let url = Bundle.main.url(forResource: "signs", withExtension: "json") else {
            print("SignDataManager: signs.json not found in bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let root = try decoder.decode(SignDataRoot.self, from: data)
            return root.categories
        } catch {
            print("SignDataManager: Failed to decode signs.json - \(error)")
            return nil
        }
    }
    
    func getAllSigns() -> [SignItem] {
        return categories.flatMap { $0.signs }
    }
}
