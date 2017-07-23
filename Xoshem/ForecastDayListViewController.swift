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
    var spotForecast: RWSpotForecast?
    var fd = [DataStruct]()
    var segmentControl: UISegmentedControl?
    var offsetHour: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        offsetHour = 0
        title = spotForecast?.spotName()
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
        if tableView == self.tableView {
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
        cell.configureCell (hour3(), limit:stepperLimit(), didUpdate: { [weak self] (value: Int) in
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
    
    func hourIterator() -> Int {
        return hour3() / 3
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
        let weekday = calendar.shortWeekdaySymbols[dateComponents().weekday!-1]
        return weekday
    }
    
    func month() -> String {
        let calendar = Calendar.current
        let month = calendar.shortMonthSymbols[dateComponents().month!]
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
        guard let spotForecast = spotForecast,
              let fcst = spotForecast.fcst else { return 0 }
        return fcst.hours.count
    }
    
    func appendFd(_ icon: String, key: String, value: String) {
        let data = DataStruct(order: fd.count, icon: icon, key: key, value: value)
        fd.append(data)
    }

    func updateForecast() {
        
        fd = [DataStruct]()

        guard let spotForecast = spotForecast,
            let fcst = spotForecast.fcst else { return }
        let wd = weekday()
        let m = month()
        appendFd("behance-heeyeun-jeong-14", key: "\(wd) \(day24()), \(m)", value: "\(hour24())h")
        let name = spotForecast.spotName()
        appendFd("behance-heeyeun-jeong-14", key: "Spot Name", value: "\(name)")
        let id_spot = spotForecast.id_spot
        appendFd("behance-heeyeun-jeong-14", key: "Spot Id", value: "\(id_spot)")
        if let tz = spotForecast.tz {
            appendFd("behance-heeyeun-jeong-14", key: "Timezone", value: "\(tz)")
        }
        let spotowner = spotForecast.id_user
        appendFd("behance-heeyeun-jeong-14", key: "Spot Owner", value: "\(spotowner)")
        let lat = spotForecast.lat
        appendFd("behance-heeyeun-jeong-14", key: "Latitude", value: "\(lat)")
        let lon = spotForecast.lon
        appendFd("behance-heeyeun-jeong-14", key: "Longitude", value: "\(lon)")
        let alt = spotForecast.alt
        appendFd("behance-heeyeun-jeong-14", key: "Altitude", value: "\(alt)")
        if let sunrise = spotForecast.sunrise {
            appendFd("behance-heeyeun-jeong-54-copy-sunrise", key: "Sunrise", value: "\(sunrise)")
        }
        if let sunset = spotForecast.sunset {
            appendFd("behance-heeyeun-jeong-54-copy-sunset", key: "Sunset", value: "\(sunset)")
        }
        if let model = spotForecast.model {
            appendFd("behance-heeyeun-jeong-59", key: "Forecast Model", value: "\(model)")
        }
        let date = fcst.init_d
        appendFd("behance-heeyeun-jeong-14", key: "Init Date", value: "\(date)")
        let h = hourIterator()
        if let t = fcst.temperature(hour: h) {
            appendFd("behance-heeyeun-jeong-85", key: "Temperature", value: "\(t) °C")
        }
        if let tr = fcst.temperature(hour: h) {
            appendFd("behance-heeyeun-jeong-86", key: "Temperature Real", value: "\(tr) °C")
        }
        if let rh = fcst.relativeHumidity(hour: h) {
            appendFd("behance-heeyeun-jeong-12", key: "Relative humidity", value: "\(rh) %")
        }
        if let speed = fcst.windSpeed(hour: h) {
            appendFd("behance-heeyeun-jeong-9", key: "Wind Speed", value: "\(speed) knots")
        }
        if let gust = fcst.windGust(hour: h) {
            appendFd("behance-heeyeun-jeong-13", key: "Wind Gusts", value: "\(gust) knots")
        }
        if let cct = fcst.cloudCoverTotal(hour: h) {
            appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Total", value: "\(cct) %")
        }
        if let cch = fcst.cloudCoverHigh(hour: h) {
            appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover High", value: "\(cch) %")
        }
        if let ccm = fcst.cloudCoverMid(hour: h) {
            appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Mid", value: "\(ccm) %")
        }
        if let ccl = fcst.cloudCoverLow(hour: h) {
            appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Low", value: "\(ccl) %")
        }
        if let ppt = fcst.precipitation(hour: h) {
            appendFd("behance-heeyeun-jeong-23", key: "Precipitation", value: "\(ppt) mm/3h")
        }
        if let slp = fcst.seaLevelPressure(hour: h) {
            appendFd("behance-heeyeun-jeong-54", key: "Sea Level Pressure", value: "\(slp)")
        }
        if let fl = fcst.freezingLevel(hour: h) {
            appendFd("behance-heeyeun-jeong-10", key: "Freezing Level", value: "\(fl) metters (0° isotherm)")
        }
        let tides = spotForecast.tides
        appendFd("behance-heeyeun-jeong-6", key: "Tides", value: "\(tides)")
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
        
        NotificationCenter.default.addObserver(forName: ForecastDidUpdateNotification,
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
        for notification in [ForecastDidUpdateNotification] {
            NotificationCenter.default.removeObserver(self, name: notification, object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    

}
