//
//  ViewController.swift
//  TODO_realm
//
//  Created by Eugene on 07.09.2022.
//

import UIKit
import RealmSwift

class TasksList: Object {
    @objc dynamic var task = ""
    @objc dynamic var completed = false
}


class ToDoViewController: UIViewController {
    
    let realm = try! Realm() // Доступ к хранилищу
    var items: Results<TasksList>!
    
    var ToDoTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(displayP3Red: 21/255,
                                       green: 101/255,
                                       blue: 192/255,
                                       alpha: 1)
        
        
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 21/255,
                                                                   green: 101/255,
                                                                   blue: 192/255,
                                                                   alpha: 1)
        navigationController?.navigationBar.backgroundColor = UIColor(displayP3Red: 21/255,
                                                                      green: 101/255,
                                                                      blue: 192/255,
                                                                      alpha: 1)
        // Цвет текста для кнопки
        navigationController?.navigationBar.tintColor = .yellow
        // Добавляем кнопку "Добавить" в навигейшин бар
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addTask)) // Вызов метода для кнопки

        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ToDoCell.self, forCellReuseIdentifier: ToDoCell.identifier)
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        ToDoTableView = table
        
        items = realm.objects(TasksList.self)
        
    }

    @objc func addTask() {
        createAlert()
    }
    
    func createAlert() {
        let alertController = UIAlertController(title: "Новая Задаяа", message: "Пожалуйста заполните поле", preferredStyle: .alert)
        var alertTextField = UITextField()
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новая задача"
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { action in
            guard let text = alertTextField.text, !text.isEmpty else { return }
            
            let task = TasksList()
            task.task = text
            try! self.realm.write({
                self.realm.add(task) // Сохранение данных в базу
                self.ToDoTableView.reloadData()
            })
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            ToDoTableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            ToDoTableView.topAnchor.constraint(equalTo: navigationController?.navigationBar.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor),
            ToDoTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ToDoTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

extension ToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count != 0 {
            return items.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoCell.identifier, for: indexPath) as? ToDoCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configureCell(with: item.task)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let itemToDelete = items[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, completionHandler) in
            
            try! self.realm.write({
                self.realm.delete(itemToDelete)
                self.ToDoTableView.reloadData()
            })
            
            
            
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    
}

