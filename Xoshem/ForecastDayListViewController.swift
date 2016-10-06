//
//  ForecastDayListViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/2/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

private let reuseIdentifierSteper = "ForecastDayStepViewCell"

struct DataStruct {
    var orderData: Int!
    var iconData: String!
    var keyData: String!
    var valueData: String!
    
    init(order: Int, icon: String, key: String, value: String) {
        orderData = order
        iconData = icon
        keyData = key
        valueData = value
    }
}

class ForecastDayListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTableView: UITableView!
    var forecastResult: CDForecastResult?
    var fd = [DataStruct]()
    var segmentControl: UISegmentedControl?
    var offsetHour: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.offsetHour = 0
        
        self.updateForecast()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        observeNotification()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unobserveNotification()
    }
    
    ///
    /// UITableViewDataSource
    ///
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return fd.count
        }
        // headerTableView
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(Common.cell.identifier.forecastDayList,
                                                                   forIndexPath: indexPath) as! ForecastDayListViewCell
            cell.backgroundColor = UIColor.clearColor()
            let data = fd[indexPath.row]
            cell.configure(data.iconData, key: data.keyData, value: data.valueData)
            return cell
        }
        
        // headerTableView

        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierSteper, forIndexPath: indexPath) as! ForecastDayStepViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.configureCell(self.hour3(), limit:self.stepperLimit(), didUpdate: { [weak self] (value: Int) in
            guard let strong = self else {
                return
            }
            strong.offsetHour = value
            strong.updateForecast()
        })
        return cell
    }

    ///
    /// UITableViewDataSource
    ///
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

    func hour3() -> Int {
        var hour3 = self.hour()
        let remainder = hour3 % 3
        hour3 -= remainder
        return hour3
    }
    
    func hour24() -> Int {
        var hour24 = self.hour3()
        hour24 = hour24 % 24
        return hour24
    }
    
    func day24() -> Int {
        let day24 = self.day() + self.hour3() / 24
        return day24
    }
    
    func hour() -> Int {
        var hour = self.dateComponents().hour
        if let oh = self.offsetHour {
            hour += oh
        }
        return hour
    }

    func weekday() -> String {
        let calendar = NSCalendar.currentCalendar()
        let weekday = calendar.shortWeekdaySymbols[self.dateComponents().weekday-1]
        return weekday
    }
    
    func month() -> String {
        let calendar = NSCalendar.currentCalendar()
        let month = calendar.shortMonthSymbols[self.dateComponents().month]
        return month
    }
    
    func day() -> Int {
        return self.dateComponents().day
    }
    
    func dateComponents() -> NSDateComponents {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Hour, .Weekday, .Month, .Day]
        let components = calendar.components(unitFlags, fromDate: date)
        return components
    }
    
    func stepperLimit() -> Int {
        var limit = 61
        if let _fr = forecastResult,
           let fm = _fr.currentForecastModel(),
            let f = fm.forecast,
            let tw = f.timeWeathers{
            limit = tw.allObjects.count
        }
        return limit
    }
    
    func appendFd(icon: String, key: String, value: String) {
        let data = DataStruct(order: fd.count, icon: icon, key: key, value: value)
        fd.append(data)
    }

    func updateForecast() {
        
        fd = [DataStruct]()

        if let _fr = forecastResult {
            
            self.backgroundColorView.backgroundColor = _fr.color
            let weekday = self.weekday()
            let month = self.month()
            appendFd("behance-heeyeun-jeong-14", key: "\(weekday) \(self.day24()), \(month)", value: "\(self.hour24())h")
            if let nameCheck = _fr.namecheck() {
                appendFd("behance-heeyeun-jeong-14", key: "City", value: "\(nameCheck)")
            }
            if let country = _fr.country {
                appendFd("behance-heeyeun-jeong-14", key: "Country", value: "\(country)")
            }
            if let identity = _fr.identity {
                appendFd("behance-heeyeun-jeong-14", key: "Spot Id", value: "\(identity)")
            }
            if let spotname = _fr.name {
                appendFd("behance-heeyeun-jeong-14", key: "Spot name", value: "\(spotname)")
            }
            if let timezone = _fr.timezone {
                appendFd("behance-heeyeun-jeong-14", key: "Timezone", value: "\(timezone)")
            }
            if let spotowner = _fr.spotOwner,
                let nickname = spotowner.nickname {
                appendFd("behance-heeyeun-jeong-14", key: "Spot Owner", value: "\(nickname)")
            }
            appendFd("behance-heeyeun-jeong-14", key: "Latitude", value: "\(_fr.latitude)")
            appendFd("behance-heeyeun-jeong-14", key: "Longitude", value: "\(_fr.longitude)")
            appendFd("behance-heeyeun-jeong-14", key: "Altitude", value: "\(_fr.altitude) m")
            if let sunrise = _fr.sunrise {
                appendFd("behance-heeyeun-jeong-54-copy-sunrise", key: "Sunrise", value: "\(sunrise)")
            }
            if let sunset = _fr.sunset {
                appendFd("behance-heeyeun-jeong-54-copy-sunset", key: "Sunset", value: "\(sunset)")
            }
            if let fm = _fr.currentForecastModel(),
                let model = fm.model,
                let f = fm.forecast,
                let modelName = f.modelName {
                appendFd("behance-heeyeun-jeong-14", key: "Init Date", value: "\(f.initDate)")
                appendFd("behance-heeyeun-jeong-14", key: "Init Stamp", value: "\(f.initStamp)")
                appendFd("behance-heeyeun-jeong-59", key: "Forecast Model", value: "\(model) : \(modelName)")
            }
            if let tides = _fr.tides {
                appendFd("behance-heeyeun-jeong-6", key: "Tides", value: "\(tides)")
            }
            if let w = _fr.weather(self.hour()) {
                appendFd("behance-heeyeun-jeong-85", key: "Temperature", value: "\(w.temperature) °C")
                appendFd("behance-heeyeun-jeong-86", key: "Temperature Real", value: "\(w.temperatureReal) °C")
                appendFd("behance-heeyeun-jeong-12", key: "Relative humidity", value: "\(w.relativeHumidity) %")
                if let wdn = w.windDirectionName {
                    appendFd("behance-heeyeun-jeong-75", key: "Wind direction", value: "\(wdn)")
                }
                appendFd("behance-heeyeun-jeong-9", key: "Wind Speed", value: "\(w.windSpeed) knots")
                appendFd("behance-heeyeun-jeong-13", key: "Wind Gusts", value: "\(w.windGust) knots")
                appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Total", value: "\(w.cloudCoverTotal) %")
                appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover High", value: "\(w.cloudCoverHigh) %")
                appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Mid", value: "\(w.cloudCoverMid) %")
                appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Low", value: "\(w.cloudCoverLow) %")
                appendFd("behance-heeyeun-jeong-23", key: "Precipitation", value: "\(w.precipitation) mm/3h")
                appendFd("behance-heeyeun-jeong-54", key: "Sea Level Pressure", value: "\(w.seaLevelPressure)")
                appendFd("behance-heeyeun-jeong-10", key: "Freezing Level", value: "\(w.freezingLevel) metters (0° isotherm)")
            }
        }
        self.tableView.reloadData()
        self.headerTableView.reloadData()
    }
    
    func incrementHour() {
        self.offsetHour = self.offsetHour ?? 0 + 1
        if let oh = self.offsetHour {
            self.offsetHour = oh + 1
        }
    }
    
    func decrementHour() {
        if let oh = self.offsetHour {
            if oh - 1 > 0 {
                self.offsetHour = oh - 1
            }
        }
    }
    
    ///
    /// Notification
    ///
    
    private func observeNotification()
    {
        self.unobserveNotification()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Common.notification.forecast.updated, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (NSNotification) in
            guard let strong = self else { return }
            if let navigationController = strong.navigationController {
                navigationController.popToRootViewControllerAnimated(true)
            }
        })
    }
    
    private func unobserveNotification()
    {
        for notification in [Common.notification.forecast.updated] {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification, object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }
    

}
