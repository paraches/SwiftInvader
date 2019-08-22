//
//  Array+removeObject.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/12.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(object: Element) -> Element? {
        guard let index = firstIndex(of: object) else { return nil}
        return remove(at: index)
    }
}
