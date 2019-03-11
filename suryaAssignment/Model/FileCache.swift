
//
//  File.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import Foundation

class FileCache: NSObject {
    
    static var defaults = UserDefaults()
    
    class func cacheThis(key: String, object : AnyObject) throws {
        try defaults.set(NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false), forKey: key)
        defaults.synchronize()
    }
    
    class func getFromCache(key: String, type : AnyClass) throws -> [Users]? {
        if defaults.object(forKey: key) != nil {
            guard (try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(defaults.object(forKey: key) as! Data) as? [Users]) != nil else {
                fatalError("getFromCache - Can't get Array")
            }
        }
        return nil
    }
    
    class func deleteFromCache(key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
    
}
