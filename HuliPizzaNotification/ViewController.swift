//
//  ViewController.swift
//  HuliPizzaNotification
//
//  Created by Thien Le quang on 3/21/18.
//  Copyright © 2018 Thien Le quang. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
  
  var isGrantedNotificationAccess = false
  
  func makePizzaContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "A Timed Pizza Step"
    content.body = "Making Pizza"
    
    content.userInfo = ["step": 0]
    return content
  }
  
  func addNotification(trigger: UNNotificationTrigger?, content: UNMutableNotificationContent, identifier: String) {
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error) in
      if error != nil {
        print("error adding notification: \(error?.localizedDescription)")
      }
    }
  }
  
  @IBAction func schedulePizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      let content = UNMutableNotificationContent()
      content.title = "A Schedule Pzza."
      content.body = "Time to make a Pizza!!!"
      let unitFlags: Set<Calendar.Component> = [.minute, .hour, .second]
      var date = Calendar.current.dateComponents(unitFlags, from: Date())
      date.second = date.second ?? 0 + 15
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      addNotification(trigger: trigger, content: content, identifier: "message.schedule")
    }
  }
  
  @IBAction func makeAPizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      let content = makePizzaContent()
      
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
      addNotification(trigger: trigger, content: content, identifier: "message.pizza")
    }
  }
  
  @IBAction func nextPizzaStep(_ sender: UIButton) {
  }
  
  
  @IBAction func viewPendingNotifications(_ sender: UIButton) {
  }
  
  @IBAction func viewDeliveredNotifications(_ sender: UIButton) {
  }
  
  @IBAction func removeNotification(_ sender: UIButton) {
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      self.isGrantedNotificationAccess = granted
      
      if !granted {
        // add alert to complain to user
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

