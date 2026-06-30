//
//  Extension+Realm.swift
//  Diary Recorder
//
//  Created by Masoud on 5/11/26.
//

import Foundation
import RealmSwift

extension Realm {
    
    func safeWrite(_ block: (() throws -> Void)) throws {
        try autoreleasepool {
            try self.write {
                try block()
            }
        }
    }
}
