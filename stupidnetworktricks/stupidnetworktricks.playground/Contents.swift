//: Stupid network tricks. 
//: A small example showing how easy grabbing a collection from a 
//: microservice can be in iOS with dataTask and swift 3.

import Foundation
import PlaygroundSupport
import UIKit

/****
 Our tableview subclass for displaying the payload
****/
class TableViewController: UITableViewController {
    var tableViewData: [[String: Any]]
    
    init(style: UITableViewStyle, data: [[String:Any]]) {
        self.tableViewData = data
        super.init(style:style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tableViewData = [[:]]
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
// for apps, we would use the following method.
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        //note that this is only for playgrounds, for apps, we register the cell above
        if let queuedCell = tableView.dequeueReusableCell(withIdentifier:"cell"){
            cell = queuedCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
       
        
        //set the cell text
        if let cellText = self.tableViewData[indexPath.row]["name"] as? String{
            cell.textLabel?.text = cellText
        }else{
            cell.textLabel?.text = "No Data Found"
        }
        
        //set the cell description text
        if let cellSubtext = self.tableViewData[indexPath.row]["motto"] as? String{
            cell.detailTextLabel?.text = cellSubtext
        }else{
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}


/******************
 Lets get this thing going
 *******************/
let url = URL(string: "http://localhost:8080")
let controller = TableViewController(style:UITableViewStyle.plain, data:[[:]])
let navigationController = UINavigationController(rootViewController: controller)

//because of this you do not have to separately set the PlaygroundPage.current.needsPerpetualExecution to true
PlaygroundPage.current.liveView = navigationController.view

/***
 The next line eliminates the following error for REPL:
 2017-08-23 14:46:15.913 stupidnetworktricks[937:96237] Failed to obtain sandbox extension for path=/var/folders/vk/j27yj5gd1bgdjkm2d1slk_gw0000gn/T/com.apple.dt.Xcode.pg/containers/com.apple.dt.playground.stub.iOS_Simulator.stupidnetworktricks-C04B0159-C874-497E-9246-2E146446E821/Library/Caches/com.apple.dt.playground.stub.iOS_Simulator.stupidnetworktricks-C04B0159-C874-497E-9246-2E146446E821. Errno:1
***/
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

/** 
 called from the completion closure in the dataTask
 **/
func loadPGTV(events:[[String:Any]]){
    controller.tableViewData = events
    controller.tableView.reloadData()
}

/**
 This is all we have to do to make the network call and parse.  It's a small amount of code and can greatly reduce your 
 codebase size and number of dependencies.
 **/
let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
    do {
        if let data = data,
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let events = json["events"] as? [[String: Any]] {
            loadPGTV(events:events)
        }
    } catch {
        print("Error deserializing JSON: \(error)")
    }
}

task.resume()

