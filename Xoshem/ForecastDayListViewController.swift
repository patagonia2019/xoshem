//
//  ForecastDayListViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/2/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import SCLAlertView
import JFWindguru

private let reuseIdentifierSteper = "ForecastDayStepViewCell"

struct DataStruct {
    var orderData: Int!
    var iconData: String!
    var keyData: String!
    var valueData: String!
    var id: Int!
}

class ForecastDayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTableView: UITableView!
    var placemark: RPlacemark?
    var spotForecast: WSpotForecast?
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
            var identifier = "ForecastDayListViewCell1"
            let data = fd[indexPath.item]
            if let id = data.id {
                identifier = "ForecastDayListViewCell\(id)"
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ForecastDayListViewCell
            cell.backgroundColor = UIColor.clear
            cell.configure(data.iconData, key: data.keyData, value: data.valueData)
            return cell
        }
        
        // headerTableView

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierSteper, for: indexPath) as! ForecastDayStepViewCell
        cell.backgroundColor = UIColor.clear
        cell.configureCell (hour3(), limit:stepperLimit(),
            didUpdate: {
                [weak self] (value: Int) in
                self?.offsetHour = value
                self?.updateForecast()
            }, didTapConfigure: {
                [weak self] in
                self?.showConfigureAlert()
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
        let day24 = day()
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
        var weekday = dateComponents().weekday! + hour3() / 24 - 1
        weekday = weekday < 0 ? 0 : weekday > 6 ? 6 : weekday
        let strWeekDay = calendar.shortWeekdaySymbols[weekday]
        return strWeekDay
    }
    
    func month() -> String {
        let calendar = Calendar.current
        let month = dateComponents().month! + hour3() / 24 / 30 - 1
        let strMonth = calendar.shortMonthSymbols[month]
        return strMonth
    }
    
    func day() -> Int {
        return dateComponents().day! + hour3() / 24
    }
    
    func dateComponents() -> DateComponents {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .weekday, .month, .day], from: date)
        return components
    }
    
    func stepperLimit() -> Int {
        guard let spotForecast = spotForecast,
              let fcst = spotForecast.forecast() else { return 0 }
        return fcst.numberOfHours()
    }
    
    func appendFd(_ icon: String, _ key: String, _ value: String, _ id: Int) {
        let data = DataStruct(orderData: fd.count, iconData: icon, keyData: key, valueData: value, id: id)
        fd.append(data)
    }

    func updateForecast() {
        
        fd = [DataStruct]()

        guard let spotForecast = spotForecast,
            let fcst = spotForecast.forecast() else { return }
        let wd = weekday()
        let m = month()
        let h = hourIterator()
        
        let id_spot = spotForecast.spotId()
        let name = spotForecast.spotName()
        appendFd("behance-heeyeun-jeong-14", "\(wd) \(day24()), \(m)", "\(hour24())h", 1)
        appendFd("behance-heeyeun-jeong-14", "Spot \(id_spot)", "\(name)", 1)
        if let t = fcst.temperature(hour: h),
           let tr = fcst.temperatureReal(hour: h) {
            appendFd("behance-heeyeun-jeong-85", "Temperature", "\(t) °C", 2)
            appendFd("behance-heeyeun-jeong-86", "Temperature Real", "\(tr) °C", 2)
        }
        if let rh = fcst.relativeHumidity(hour: h) {
            appendFd("behance-heeyeun-jeong-12", "Relative humidity", "\(rh) %", 3)
        }
        if let dir = fcst.windDirectionName(hour: h) {
            appendFd("behance-heeyeun-jeong-9", "Wind Direction", "\(dir)", 3)
        }
        if let knots = fcst.windSpeedKnots(hour: h) {
            appendFd("behance-heeyeun-jeong-9", "Wind Speed", "\(knots) knots", 3)
        }
        if let gust = fcst.windGust(hour: h) {
            appendFd("behance-heeyeun-jeong-13", "Wind Gusts", "\(gust) knots", 3)
        }
        if let bft = fcst.windSpeedBft(hour: h),
            let effect = fcst.windSpeedBftEffect(hour: h),
            let onSea = fcst.windSpeedBftEffectOnSea(hour: h),
            let onLand = fcst.windSpeedBftEffectOnSea(hour: h) {
            appendFd("behance-heeyeun-jeong-9", "Wind Speed Effect \(bft) bft", "On Sea: \(effect)\n\(onSea)\nOn Land:\(onLand)", 1)
        }
        if let perpw = fcst.perpw(hour: h) {
            appendFd("behance-heeyeun-jeong-13", "Peak wave period", "\(perpw)", 3)
        }
        if let htsgw = fcst.htsgw(hour: h) {
            appendFd("behance-heeyeun-jeong-13", "Significant Wave Height", "\(htsgw)", 3)
        }
        if let smer = fcst.smer(hour: h),
            let smern = fcst.smern(hour: h) {
            appendFd("behance-heeyeun-jeong-9", "Wind SMER / SMERN", "\(smer) / \(smern)", 3)
        }

        if let cct = fcst.cloudCoverTotal(hour: h) {
            appendFd("behance-heeyeun-jeong-7", "Cloud Cover Total", "\(cct) %", 3)
        }
        if let cch = fcst.cloudCoverHigh(hour: h) {
            appendFd("behance-heeyeun-jeong-7", "Cloud Cover High", "\(cch) %", 3)
        }
        if let ccm = fcst.cloudCoverMid(hour: h) {
            appendFd("behance-heeyeun-jeong-7", "Cloud Cover Mid", "\(ccm) %", 3)
        }
        if let ccl = fcst.cloudCoverLow(hour: h) {
            appendFd("behance-heeyeun-jeong-7", "Cloud Cover Low", "\(ccl) %", 3)
        }
        let pcpt = fcst.pcpt(hour: h)
        if let ppt = fcst.precipitation(hour: h) {
            if let pcpt = pcpt {
                appendFd("behance-heeyeun-jeong-23", "Precipitation", "\(ppt) / \(pcpt) mm/3h", 3)
            }
            else {
                appendFd("behance-heeyeun-jeong-23", "Precipitation", "\(ppt) mm/3h", 3)
            }
        }
        if let slp = fcst.seaLevelPressure(hour: h) {
            appendFd("behance-heeyeun-jeong-54", "Sea Level Pressure", "\(slp) Pa", 3)
        }
        if let fl = fcst.freezingLevel(hour: h) {
            appendFd("behance-heeyeun-jeong-10", "Freezing Level", "\(fl) meters (0° isotherm)", 3)
        }
        if let tz = spotForecast.timezone() {
            appendFd("behance-heeyeun-jeong-14", "Timezone", "\(tz)", 3)
        }
        let coordinates = spotForecast.coordinates()
        appendFd("behance-heeyeun-jeong-14", "Coordinates", "\(coordinates)", 3)
        if let elapse = spotForecast.elapsedDay() {
            appendFd("behance-heeyeun-jeong-54-copy-sunrise", "Sunrise", "\(elapse.starting())", 3)
            appendFd("behance-heeyeun-jeong-54-copy-sunset", "Sunset", "\(elapse.ending())", 3)
        }
        if let model = spotForecast.modelInfo() {
            appendFd("behance-heeyeun-jeong-59", "Forecast Model", "\(model)", 3)
        }
        if let updated = fcst.lastUpdate() {
            appendFd("behance-heeyeun-jeong-14", "Updated", "\(updated)", 3)
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
    

    fileprivate func showConfigureAlert() {
        let alert = SCLAlertView()
        alert.addButton("Wind speed: knots") {
            [weak self] in
            self?.showConfigureWindAlert()
        }
        alert.addButton("Temperature: Celsius") {
            [weak self] in
            self?.showConfigureWindAlert()
        }
        alert.addButton("Wave: meters") {
            [weak self] in
            self?.showConfigureWindAlert()
        }
        alert.showEdit("Configure", subTitle: "Configure display options", closeButtonTitle: "Cancel")
    }

    fileprivate func showConfigureWindAlert() {
        let alert = SCLAlertView()
        alert.addButton("m/s") {
            
        }
        alert.addButton("knots") {
            
        }
        alert.addButton("km/h") {
            
        }
        alert.addButton("mph") {
            
        }
        alert.addButton("Bft") {
            
        }
    }
}
