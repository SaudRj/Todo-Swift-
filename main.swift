//
//  main.swift
//  To-do Project
//
//  Created by Saud Rajhi on 6/6/2024 .
//

import Foundation

protocol Cache{
    func save(todos: [Todo] ) -> Bool
    func load() -> [Todo]?
}

struct Todo: CustomStringConvertible, Codable{
    var id: UUID
    var description: String // i changed the attribute name from "title" to "description", this is needed to conform to CustomStringConvertible
    var isCompleted: Bool
}

class TodosManager
{
    var todos: [Todo] = []
    var cache : Cache
    
    init(cache: Cache) {
        self.cache = cache
        self.todos = cache.load() ?? []
    }
    
    func add(_ title: String)
    {
        let newElement = Todo(id: UUID(), description: title, isCompleted: false)
        todos.append(newElement)
        if cache.save(todos: todos)
        {print("📌 \(newElement.description) Todo added!")}
        else
        {print("error cache")}
    }
    func listTodos()
    {
        if todos.isEmpty
        {
            print("It is Empty")
        }
        else{
            print("📝 Your todos:")
            var count = 1
            for i in todos
            {
                print((count),".", terminator:"")
                if i.isCompleted
                {
                    print("✅" , i.description)
                }else
                {
                    print("❌" , i.description)
                }
                count += 1
            }
        }
    }
    func toggleCompletion(at index: Int)
    {
        if index >= 0 && index <= todos.count
        {
            todos[index-1].isCompleted = true
            if cache.save(todos: todos)
            {print(todos[index-1].description, "Todo has been toggled ✅")}
            else
            {print("error cache")}
        }
        else
        {
            print("Inalid index!")
        }
    }
    func delete(at index: Int)
    {
        if index >= 0 && index <= todos.count
        {
            let deleted = todos.remove(at: index-1)
            if cache.save(todos: todos)
            {print(deleted.description, "todo successfully deleted!") }
            else
            {print("error cache")}
        }
    }
}


class FileSystemCache: Cache {

  private let fileName: String

  init(fileName: String) {
    self.fileName = fileName
  }

    func save(todos: [Todo]) -> Bool {
        do {
            let data = try JSONEncoder().encode(todos)
            FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
            print("Todos saved successfully!")
            return true
        } catch {
            print("Error saving todos to file")
            return false
        }
    }

  func load() -> [Todo]? {
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
      return try JSONDecoder().decode([Todo].self, from: data)
    } catch {
      print("Error loading todos from file")
      return nil
    }
  }
}


class InMemoryCache: Cache
{
    var todos: [Todo] = []
    func save(todos: [Todo]) -> Bool
    {
        self.todos = todos
        return true
    }
    
    func load() -> [Todo]? {
        return todos
    }
    
    
}
class App
{
    var t1 : TodosManager
    init(cache: Cache) {
        self.t1 = TodosManager(cache: cache)
    }
    
    enum Commands: String
    {
        case add = "add"
        case list = "list"
        case toggle = "toggle"
        case delete = "delete"
        case exit = "exit"
    }

    func run()
    {
        print("⭐⭐⭐ Welcome to Todo CLI ⭐⭐⭐")
        print("What would you like to do? (add, list, toggle, delete, exit): ")
        while let input = readLine()
        {
            guard let command = Commands(rawValue: input) else {
                print("Please enter a valid input 😀")
                continue
            }
            if command.rawValue == "exit"
            { 
                print("Have a nice day  🚀")
                break
            }
            switch command
            {
                case .add:
                    print("Enter todo title: ")
                    if let title = readLine()
                    {
                        t1.add(title)
                    }
                break
                case .list:
                    t1.listTodos()
                break
                case .toggle:
                    print("Enter the number of the todo to toggle: ")
                    if let indexInString = readLine()
                    {
                        guard let indexInInt = Int(indexInString) else
                        { return print("❌ Invalid Index ") }
                        
                        t1.toggleCompletion(at: indexInInt)
                    }
                break
                case .delete:
                print("Enter the number of the todo to delete: ")
                if let indexInString = readLine()
                {
                    guard let indexInInt = Int(indexInString) else
                    { return print("❌ Invalid Index") }
                    
                    t1.delete(at: indexInInt)
                }
                break
                case .exit:
                    print("Have a nice day!")
                break
            }

            print("What would you like to do? (add, list, toggle, delete, exit")
        }
    }
}

   var f1 = FileSystemCache(fileName: "todos.json")
   var m1 = InMemoryCache()
   var a1 = App(cache: m1)
   a1.run()
