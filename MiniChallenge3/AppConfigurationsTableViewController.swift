//
//  AppConfigurationsTableViewController.swift
//  MiniChallenge3
//
//  Created by Erick Borges on 17/06/17.
//  Copyright © 2017 Guilherme Paciulli. All rights reserved.
//

import UIKit

class AppConfigurationsTableViewController: UITableViewController {

    //MARK: - Outlets
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    @IBOutlet weak var dailyNotificationsSwitch: UISwitch!
    @IBOutlet weak var infoNotificationSwitch: UISwitch!
    
    //MARK: - Atributes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // -- SETUP
        datePickerOutlet.datePickerMode = .time
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        infoNotificationSwitch.isOn = UserDefaults.standard.bool(forKey: "isEnabledInfoNotification")
        
        datePickerOutlet.isEnabled = UserDefaults.standard.bool(forKey: "isEnabledDailyReminder")
        dailyNotificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "isEnabledDailyReminder")
        
        if let date = UserDefaults.standard.object(forKey: "reminderHour") as? Date {
            datePickerOutlet.date = date
        }

    }
    
    //MARK: - Actions
    
    // -- SWITCH DID CHANGE VALUE
    @IBAction func notificationSwitchChangeValue(_ sender: UISwitch) {
        // -- NOTIFICAÇÃO LEMBRETE
        
        if sender.isOn {
            
            var hour = 21
            var minute = 0
            
            if let date = UserDefaults.standard.object(forKey: "reminderHour") as? Date {
                hour = Calendar.current.component(.hour, from: date)
                minute = Calendar.current.component(.minute, from: date)
            }
            
            UserDefaults.standard.set(at(hour: hour, minute: minute), forKey: "reminderHour")
            UserDefaults.standard.set(true, forKey: "isEnabledDailyReminder")
            UserDefaults.standard.synchronize()
            
            NotificationController.sendNotificationDaily(["lembreteNoturno",
                                                          messageBy(hour: hour),
                                                          "Não se esqueça de inserir toda a quantia de cigarros que você consumiu hoje."],
                                                          at(hour: hour, minute: minute))
            datePickerOutlet.isEnabled = true
        } else {
            datePickerOutlet.isEnabled = false
            UserDefaults.standard.set(false,
                                      forKey: "isEnabledDailyReminder")
            UserDefaults.standard.synchronize()
            NotificationController.center.removePendingNotificationRequests(withIdentifiers: ["lembreteNoturno"])
        }
        
    }

    @IBAction func informativeNotificationDidChangeValue(_ sender: UISwitch){
        // -- NOTIFICAÇÕES INFORMATIVAS

        if sender.isOn {
            NotificationController.prepareAll(daysFromToday: LineChartData().getDaysUntilTheZeroPoint())
        } else {
            let notifications = NotificationsDatabase.notifications.map({ $0.identifier })
            NotificationController.center.removePendingNotificationRequests(withIdentifiers: notifications)
        }
        UserDefaults.standard.set(sender.isOn, forKey: "isEnabledInfoNotification")
        UserDefaults.standard.synchronize()
    }
    @IBAction func pickerDidChangeValue(_ sender: UIDatePicker) {
        
        NotificationController.getPendingNotifications()
        
        let datePicker = Calendar.current.dateComponents([.hour,.minute,.second,], from:sender.date)
        
        UserDefaults.standard.set(at(hour: datePicker.hour!, minute: datePicker.minute!), forKey: "reminderHour")
        UserDefaults.standard.synchronize()
        
        
        NotificationController.sendNotificationDaily(["lembreteNoturno",
                                                      messageBy(hour: datePicker.hour!),
                                                      "Não se esqueça de inserir toda a quantia de cigarros que você consumiu hoje."],
                                                      at(hour: datePicker.hour!, minute: datePicker.minute!))
    }
    
    private func messageBy(hour: Int) -> String {
        return hour < 12 ? "Bom dia" : hour < 18 ? "Boa tarde" : "Boa noite"
    }
    
    private func at(hour: Int, minute: Int) -> Date {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
}
