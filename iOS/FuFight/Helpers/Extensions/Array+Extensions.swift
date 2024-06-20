//
//  Array+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/19/24.
//

import Foundation

extension Array where Element == Attack {
    func getIndexWithId(_ id: String) -> Int {
        return firstIndex { $0.id == id }!
    }

    func getAttack(with id: String) -> Attack {
        return self[getIndexWithId(id)]
    }

    func getAttack(at position: AttackPosition) -> Attack {
        return first { $0.position == position }!
    }

    func getAnimation(at position: AttackPosition) -> AnimationType {
        return getAttack(at: position).animationType
    }
}

extension Array where Element == Defense {
    func getIndexWithId(_ id: String) -> Int {
        return firstIndex { $0.id == id }!
    }

    func getDefense(with id: String) -> Defense {
        return self[getIndexWithId(id)]
    }

    func getDefense(at position: DefensePosition) -> Defense {
        return first { $0.position == position }!
    }

    func getAnimation(at position: DefensePosition) -> AnimationType {
        return getDefense(at: position).animationType
    }
}
