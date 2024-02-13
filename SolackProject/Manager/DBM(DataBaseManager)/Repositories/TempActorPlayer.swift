//
//  TempActorPlayer.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
// 1. 테이블 구성
class Todo: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var owner: String
    @Persisted var status: String
}
// 2. 리포지토리 구성
actor RealmActor {
    // An implicitly-unwrapped optional is used here to let us pass `self` to
    // `Realm(actor:)` within `init`
    var realm: Realm!
    init() async throws {
        realm = try await Realm(actor: self)
    }
    var count: Int {
        realm.objects(Todo.self).count
    }
    
    func createTodo(name: String, owner: String, status: String) async throws {
        try await realm.asyncWrite {
            realm.create(Todo.self, value: [
                "_id": ObjectId.generate(),
                "name": name,
                "owner": owner,
                "status": status
            ])
        }
    }
    
    func getTodoOwner(forTodoNamed name: String) -> String {
        let todo = realm.objects(Todo.self).where {
            $0.name == name
        }.first!
        return todo.owner
    }
    
    struct TodoStruct {
        var id: ObjectId
        var name, owner, status: String
    }
    
    func getTodoAsStruct(forTodoNamed name: String) -> TodoStruct {
        let todo = realm.objects(Todo.self).where {
            $0.name == name
        }.first!
        return TodoStruct(id: todo._id, name: todo.name, owner: todo.owner, status: todo.status)
    }
    
    func updateTodo(_id: ObjectId, name: String, owner: String, status: String) async throws {
        try await realm.asyncWrite {
            realm.create(Todo.self, value: [
                "_id": _id,
                "name": name,
                "owner": owner,
                "status": status
            ], update: .modified)
        }
    }
    
    func deleteTodo(id: ObjectId) async throws {
        try await realm.asyncWrite {
            let todoToDelete = realm.object(ofType: Todo.self, forPrimaryKey: id)
            realm.delete(todoToDelete!)
        }
    }
    
    func close() {
        realm = nil
    }
    
}

// A simple example of a custom global actor
@globalActor actor BackgroundActor: GlobalActor {
    static var shared = BackgroundActor()
}
@BackgroundActor
func backgroundThreadFunction() async throws {
    // Explicitly specifying the actor is required for anything that is not MainActor
    let realm = try await Realm(actor: BackgroundActor.shared)
    try await realm.asyncWrite {
        _ = realm.create(Todo.self, value: [
            "name": "Pledge fealty and service to Gondor",
            "owner": "Pippin",
            "status": "In Progress"
        ])
    }
    // Thread-confined Realms would sometimes throw an exception here, as we
    // may end up on a different thread after an `await`
    let todoCount = realm.objects(Todo.self).count
    print("The number of Realm objects is: \(todoCount)")
}
func createObject(in actor: isolated RealmActor) async throws {
    // Because this function is isolated to this actor, you can use
    // realm synchronously in this context without async/await keywords
    try actor.realm.write {
        actor.realm.create(Todo.self, value: [
            "name": "Keep it secret",
            "owner": "Frodo",
            "status": "In Progress"
        ])
    }
    let taskCount = actor.count
    print("The actor currently has \(taskCount) tasks")
}
func wow(){
    Task{
        let actor = try await RealmActor()
        try await createObject(in: actor)
    }
}

