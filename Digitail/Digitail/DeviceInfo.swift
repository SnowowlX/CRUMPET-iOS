//
//  DeviceInfo.swift
//  CRUMPET
//
//  Created by Andrew Shoben on 19/02/2024.
//  Copyright © 2024 Iottive. All rights reserved.
//

import Foundation
import RealmSwift

public class DeviceInfo: Object {
//    @Persisted(primaryKey: true) var id = 0
    @Persisted(primaryKey: true) var btIdentifier: String
    @Persisted var name: String

//    //Incrementa ID
//    func IncrementaID() -> Int{
//        let realm = try! Realm()
//        if let retNext = realm.objects(DeviceInfo.self).sorted(byKeyPath: "id").last?.id {
//            return retNext + 1
//        }else{
//            return 1
//        }
//    }
}
