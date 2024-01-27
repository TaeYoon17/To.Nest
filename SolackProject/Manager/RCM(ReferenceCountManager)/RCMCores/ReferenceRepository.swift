//
//  ReferenceRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
// Realm DB 시스템에서 CRUD를 도와주는 Repository... RCMTable과 직접 소통할 수 있다.
typealias RCMRepository = ReferenceRepository
@BackgroundActor class ReferenceRepository<T>where T: RCMTable{
    var realm: Realm!
    private(set) var tasks: Results<T>!
    var getTasks:Results<T>{ realm.objects(T.self) }
    func getAllTable()->[RCMTable]{
        return getTasks.map { $0 }
    }
    enum ClearType{
        case all
        case emptyBT
    }
    enum FormatType{
        case jpg
    }
    
    func insert(item: any RCMTableConvertable)async{
        if let table = realm.object(ofType: T.self, forPrimaryKey: item.name){
            try! await realm.asyncWrite({ table.count = item.count })
        }else{
            let newTable = T.init(fileName: item.name)
            do{
                try await realm.asyncWrite{ realm.add(newTable) }
                tasks = realm.objects(T.self)
                try await realm.asyncWrite({ newTable.count = item.count})
            }catch{
                print("생성 문제")
            }
        }
    }
    
    func clearTable(type: ClearType = .emptyBT,format: FormatType) async{
        let allTables = self.getTasks
        switch type{
        case .all:
            try! await realm.asyncWrite{
                realm.delete(allTables)
            }
        case .emptyBT:
            let emptyTables = allTables.where { $0.count <= 0 }
            emptyTables.forEach { tables in
                switch format{
                case .jpg:
                    FileManager.removeFromDocument(fileName: tables.name, type: .jpg)
                }
            }
            try! await realm.asyncWrite{
                realm.delete(emptyTables)
            }
        }
    }
}

