//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Maksim Grischenko on 05.06.2022.
//

import UIKit
import CoreData


class TaskListViewController: UITableViewController {
    
    private let cellID = "Task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        StorageManager.shared.fetchData { fetchedTasks in
            self.taskList = fetchedTasks
        }
    }
    
    
    
    //MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    @objc private func addNewTask() {
        showAddAlert()
    }
    
    private func showAddAlert() {
        let alert = UIAlertController(
            title: "New Task",
            message: "What do you want to do?",
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            StorageManager.shared.save(task) { task in
                self.taskList.append(task)
                let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
                self.tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    private func showEditAlert(task: Task) {
        let alert = UIAlertController(
            title: "Edit Task",
            message: "Please edit your task",
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty else { return }
            StorageManager.shared.edit(task, newName: taskTitle)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
}


//MARK: - UITableViewDataSource
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, actionPerformed: (Bool) -> ()) in
            let task = self.taskList[indexPath.row]
            StorageManager.shared.delete(task)
            self.taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            actionPerformed(true)
        }
        deleteAction.backgroundColor = UIColor.red
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (_, _, actionPerformed: (Bool) -> ()) in
            let editTask = self.taskList[indexPath.row]
            self.showEditAlert(task: editTask)
            actionPerformed(true)
        }
        editAction.backgroundColor = UIColor.green
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}

