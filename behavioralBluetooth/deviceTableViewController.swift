//
//  deviceTableViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 2/5/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import UIKit
import bluetoothBehave

class deviceTableViewController: UITableViewController, bluetoothBehaveLocalDelegate {

    var refreshController = UIRefreshControl()
    
    // Get a list of devices sorted by RSSI.
    var sortedDeviceArrayByRSSI = myLocal.getAscendingSortedArraysBasedOnRSSI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. Attach the LocalBehavioralSerialDeviceDelegate
        // 2. Create a refresh controller.
        // 3. Search for devices.
        myLocal.delegate = self
        
        // Setup pull-down-on-scroll-to-refresh controller
        refreshController.addTarget(self, action: Selector("refreshTableOnPullDown"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshController
        
        // Start search.
        myLocal.search(1)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // #warning Incomplete implementation, return the number of rows
        return sortedDeviceArrayByRSSI.nsuuids.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // 1. Get discovered devices' name, ID, and RSSI sorted by RSSI
        // 2. Set cell's label to name and detail-label to RSSI.
        // 3. Return cell.
        let deviceID = sortedDeviceArrayByRSSI.nsuuids[indexPath.row]
        let deviceRSSI = sortedDeviceArrayByRSSI.rssies[indexPath.row]
        let deviceName = myLocal.getDiscoveredDeviceNameByID(deviceID)

        cell.textLabel?.text = deviceName
        cell.detailTextLabel?.text = String(deviceRSSI)
        return cell
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        // 1. Get device at index NSUUID.
        // 2. Get remote device by ID.
        let deviceID = sortedDeviceArrayByRSSI.nsuuids[indexPath.row]
        if let device = myLocal.getDiscoveredRemoteDeviceByID(deviceID) {
            myLocal.connectToDevice(device)
        }

    }


    func searchTimerExpired() {
        
        // 1. Refresh the sorted device by RSSI list.
        // 2. Reload the tableView's data.
        // 3. End the refreshing animation.
        
        sortedDeviceArrayByRSSI = myLocal.getAscendingSortedArraysBasedOnRSSI()
        self.tableView.reloadData()
        refreshController.endRefreshing()
    }
    
    func refreshTableOnPullDown() {
        
        // 1. Start the search for BLE remotes.
        // 2. Disconnect from all devices.
        myLocal.search(1.0)
        myLocal.disconnectFromAllPeripherals()
    }
    
    func localDeviceStateChange() {
        print("Hardware" + String(myLocal.getHardwareState()))
        print("Connection" + String(myLocal.getConnectionState()))
        print("Search" + String(myLocal.getSearchState()))
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
}
