//
//  ViewController.swift
//  HuliPizzaNotification
//
//  Created by Thien Le quang on 3/21/18.
//  Copyright © 2018 Thien Le quang. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
  var pizzaNumber = 0
  
  let pizzaSteps = ["Make Pizza",
                    "Roll Dough",
                    "Add Sauce",
                    "Add Chese",
                    "Add Ingredients",
                    "Bake",
                    "Done"]
  
  var isGrantedNotificationAccess = false
  
  func updatePizzaStep(request: UNNotificationRequest) {
    if request.identifier.hasPrefix("message.pizza") {
      var stepNumber = request.content.userInfo["step"] as! Int
      stepNumber = (stepNumber + 1) % pizzaSteps.count
      let updatedContent = makePizzaContent()
      updatedContent.body = pizzaSteps[stepNumber]
      updatedContent.userInfo["step"] = stepNumber
      updatedContent.subtitle = request.content.subtitle
      updatedContent.attachments = pizzaStepImage(step: stepNumber)
      addNotification(trigger: request.trigger, content: updatedContent, identifier: request.identifier)
    }
  }
  
  func makePizzaContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "A Timed Pizza Step"
    content.body = "Making Pizza"
    content.userInfo = ["step": 0]
    
    content.categoryIdentifier = "pizza.steps.category"
//    content.attachments = pizzaStepImage(step: 0)
    content.attachments = pizzGif()
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
      content.categoryIdentifier = "snooze.category"
      let attachment = notificationAttachment(for: "pizza.video", resource: "PizzaMovie", type: "mp4")
//      let attachment = notificationAttachment(for: "EHuliUke.music", resource: "EHuliUke", type: "mp3")
      content.attachments = attachment
      let unitFlags: Set<Calendar.Component> = [.minute, .hour, .second]
      var date = Calendar.current.dateComponents(unitFlags, from: Date())
      date.second = date.second! + 15
      
//      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
      addNotification(trigger: trigger, content: content, identifier: "message.schedule")
    }
  }
  
  @IBAction func makeAPizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      
      let content = makePizzaContent()
      pizzaNumber += 1
      content.subtitle = "(Pizza \(pizzaNumber)"
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
//      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
      addNotification(trigger: trigger, content: content, identifier: "message.pizza.\(pizzaNumber)")
    }
  }
  
  @IBAction func nextPizzaStep(_ sender: UIButton) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
      if let request = requests.first {
        if request.identifier.hasPrefix("message.pizza") {
          self.updatePizzaStep(request: request)
        } else {
          let content = request.content.mutableCopy() as!UNMutableNotificationContent
          self.addNotification(trigger: request.trigger!, content: content, identifier: request.identifier)
        }
      }
    }
  }
  
  
  @IBAction func viewPendingNotifications(_ sender: UIButton) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requestList) in
      print("\(Date()) -> \(requestList.count) requests pending")
      for request in requestList {
        print("\(request.identifier) body: \(request.content.body)")
      }
    }
  }
  
  @IBAction func viewDeliveredNotifications(_ sender: UIButton) {
    UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
      print("\(Date()) -> \(notifications.count) notifications delivered")
      for notification in notifications {
        print("\(notification.request.identifier) body: \(notification.request.content.body)")
      }
    }
  }
  
  @IBAction func removeNotification(_ sender: UIButton) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
      if let request = requests.first {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
      }
    }
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UNUserNotificationCenter.current().delegate = self
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
  
  // MARK: -Delegates
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let action = response.actionIdentifier
    let request = response.notification.request
    
    if action == "next.step.action" {
      updatePizzaStep(request: request)
    }
    
    if action == "stop.action" {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
    }
    
    if action == "snooze.action" {
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
      let newRequest = UNNotificationRequest(identifier: request.identifier, content: request.content, trigger: trigger)
      UNUserNotificationCenter.current().add(newRequest, withCompletionHandler: { (error) in
        if error != nil {
          print(error?.localizedDescription)
        }
      })
    }
    if action == "text.input" {
      let textResponse = response as! UNTextInputNotificationResponse
      let newContent = request.content.mutableCopy() as! UNMutableNotificationContent
      newContent.subtitle = textResponse.userText
      addNotification(trigger: request.trigger, content: newContent, identifier: request.identifier)
    }
    completionHandler()
  }
  
  func notificationAttachment(for identifier: String, resource: String, type: String) -> [UNNotificationAttachment] {
    let extendedIdentifier = identifier + "." + type
    guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
      print("The file \(resource).\(type) was not found")
      return []
    }
    
    let videoURL = URL(fileURLWithPath: path)
    do {
      let attachment = try UNNotificationAttachment(identifier: extendedIdentifier, url: videoURL, options: nil)
      return [attachment]
    } catch {
      print("The attachment was not loaded.")
      return []
    }
    
  }
  
  func pizzGif() -> [UNNotificationAttachment] {
    let extendedIdentifier = "pizza.gif"
    guard let path = Bundle.main.path(forResource: "MakePizza_0", ofType: "gif") else {
      print("The file  was not found")
      return []
    }
    
    let videoURL = URL(fileURLWithPath: path)
    do {
//      let attachment = try UNNotificationAttachment(identifier: extendedIdentifier, url: videoURL, options: nil)
      let attachment = try UNNotificationAttachment(identifier: extendedIdentifier, url: videoURL, options: [UNNotificationAttachmentOptionsThumbnailTimeKey: 11])
      return [attachment]
    } catch {
      print("The attachment was not loaded.")
      return []
    }
    
  }
  
  func pizzaStepImage(step: Int) -> [UNNotificationAttachment] {
    let stepString = String(format: "%i", step)
    let identifier = "pizza.step."+stepString
    let resource = "MakePizza_"+stepString
    
    let type = "jpg"
    return notificationAttachment(for: identifier, resource: resource, type: type)
  }
}

