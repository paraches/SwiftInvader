//
//  String+substring.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/15.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation

extension String {
    func substring (range: Range<Int>) -> String {
        return String(self[self.index(self.startIndex, offsetBy: range.lowerBound)..<self.index(self.startIndex, offsetBy: range.upperBound)])
    }
}
