//
//  Stack.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

struct Stack {
    private var items: [String] = []
    
    func peek() -> String? {
        return items.first
    }
    
    mutating func pop() -> String {
        return items.removeFirst()
    }
    
    mutating func push(_ elem: String) {
        items.insert(elem, at: 0)
    }
}
