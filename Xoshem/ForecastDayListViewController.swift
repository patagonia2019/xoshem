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

class ForecastDayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTableView: UITableView!
    var forecastResult: CDForecastResult?
    var fd = [DataStruct]()
    var segmentControl: UISegmentedControl?
    var offsetHour: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        offsetHour = 0
        
        updateForecast()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unobserveNotification()
    }
    
    ///
    /// UITableViewDataSource
    ///
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView {
            return fd.count
        }
        // headerTableView
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: Common.cell.identifier.forecastDayList,
                                                                   for: indexPath) as! ForecastDayListViewCell
            cell.backgroundColor = UIColor.clear
            let data = fd[(indexPath as NSIndexPath).row]
            cell.configure(data.iconData, key: data.keyData, value: data.valueData)
            return cell
        }
        
        // headerTableView

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierSteper, for: indexPath) as! ForecastDayStepViewCell
        cell.backgroundColor = UIColor.clear
        cell.configureCell (hour3(), limit:self.stepperLimit(), didUpdate: { [weak self] (value: Int) in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    func hour3() -> Int {
        var hour3 = hour()
        let remainder = hour3 % 3
        hour3 -= remainder
        return hour3
    }
    
    func hour24() -> Int {
        var hour24 = hour3()
        hour24 = hour24 % 24
        return hour24
    }
    
    func day24() -> Int {
        let day24 = day() + hour3() / 24
        return day24
    }
    
    func hour() -> Int {
        var hour = dateComponents().hour ?? 0
        if let oh = offsetHour {
            hour += oh
        }
        return hour
    }

    func weekday() -> String {
        let calendar = Calendar.current
        let weekday = calendar.shortWeekdaySymbols[self.dateComponents().weekday!-1]
        return weekday
    }
    
    func month() -> String {
        let calendar = Calendar.current
        let month = calendar.shortMonthSymbols[self.dateComponents().month!]
        return month
    }
    
    func day() -> Int {
        return dateComponents().day!
    }
    
    func dateComponents() -> DateComponents {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .weekday, .month, .day], from: date)
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
    
    func appendFd(_ icon: String, key: String, value: String) {
        let data = DataStruct(order: fd.count, icon: icon, key: key, value: value)
        fd.append(data)
    }

    func updateForecast() {
        
        fd = [DataStruct]()

        if let _fr = forecastResult {
            
            backgroundColorView.backgroundColor = _fr.color
            let wd = weekday()
            let m = month()
            appendFd("behance-heeyeun-jeong-14", key: "\(wd) \(day24()), \(m)", value: "\(hour24())h")
            if let nameCheck = _fr.namecheck() {
                appendFd("behance-heeyeun-jeong-14", key: "City", value: "\(nameCheck)")
            }
            if let country = _fr.country {
                appendFd("behance-heeyeun-jeong-14", key: "Country", value: "\(country)")
            }
            if let id_spot = _fr.id_spot {
                appendFd("behance-heeyeun-jeong-14", key: "Spot Id", value: "\(id_spot)")
            }
            if let spotname = _fr.name {
                appendFd("behance-heeyeun-jeong-14", key: "Spot name", value: "\(spotname)")
            }
            if let timezone = _fr.timezone {
                appendFd("behance-heeyeun-jeong-14", key: "Timezone", value: "\(timezone)")
            }
            if let spotowner = _fr.spotOwner,
                let spotname = spotowner.spotname {
                appendFd("behance-heeyeun-jeong-14", key: "Spot Owner", value: "\(spotname)")
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
            if let w = _fr.weather (hour()) {
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
        tableView.reloadData()
        headerTableView.reloadData()
    }
    
    func incrementHour() {
        offsetHour = offsetHour ?? 0 + 1
        if let oh = offsetHour {
            offsetHour = oh + 1
        }
    }
    
    func decrementHour() {
        if let oh = offsetHour {
            if oh - 1 > 0 {
                offsetHour = oh - 1
            }
        }
    }
    
    ///
    /// Notification
    ///
    
    fileprivate func observeNotification()
    {
        unobserveNotification()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Common.notification.forecast.updated),
                                               object: nil, queue: OperationQueue.main, using:
            {
                [weak self] (NSNotification) in
                guard let strong = self else { return }
                if let navigationController = strong.navigationController {
                    navigationController.popToRootViewController(animated: true)
                }
        })
    }
    
    fileprivate func unobserveNotification()
    {
        for notification in [Common.notification.forecast.updated] {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    

}
