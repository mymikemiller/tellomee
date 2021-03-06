//
//  ThreadsTableViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ThreadsTableVC: UITableViewController {

    // This is set to the selected thread when the user selects a row. This is used to prepare for the segue.
    var selectedThread: Thread?
    
    let threadManager = ThreadManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        threadManager.fillThreads(onThreadUpdate: onThreadUpdate) {
            () in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func onThreadUpdate(thread: Thread) {
        threadManager.bump(threadId: thread.threadId)
        // This is quite a heavy hammer
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If we came back from the settings page, we need to refresh the image. Also refresh when coming back from a message so the threads appear in the correct order.
        tableView.reloadData()
    }
    
    func startChat(thread:Thread) {
        selectedThread = thread
        // If we're on a different view (e.g. already in a thread, and the user loaded a new thread by clicking on the user in Receipts), move back to the thread list before segueing into a new thread
        if (navigationController?.visibleViewController != self) {
            navigationController?.popToRootViewController(animated: true)
        }
        self.performSegue(withIdentifier: "showChatView", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadManager.threads.count
    }

    override func tableView(_ tableViewS: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ThreadTableViewCell

        let thread = threadManager.threads[indexPath.row]
        cell.cellImage.image = thread.user.getProfileImage()
        
        cell.cellName.text = thread.user.firstName
        // Display the name in bold if the thread hasn't been read
        if (thread.read) {
            cell.cellName.font = UIFont.systemFont(ofSize: 16.0)
        } else {
            cell.cellName.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChat(thread: threadManager.threads[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatView",
        let destinationViewController = segue.destination as? ChatVC {
            destinationViewController.thread = selectedThread
        }
    }
}
