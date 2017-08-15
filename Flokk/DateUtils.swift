//
//  DateUtils.swift
//  Flokk
//
//  Created by Gannon Prudomme on 8/14/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation

// Get the different components of the date
extension Date {
    func getYear() -> Int {
        return Calendar.current.component(.year, from: self)
    }
    
    func getMonth() -> Int {
        return Calendar.current.component(.month, from: self)
    }
    
    func getDay() -> Int {
        return Calendar.current.component(.day, from: self)
    }
    
    func getHour() -> Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    func getMinute() -> Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    func getSecond() -> Int {
        return Calendar.current.component(.second, from: self)
    }
}

// Get the differences between a date and the current date in different units
extension Date {
    /// Returns the amount of years from another date
    func getYearsDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func getMonthsDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func getWeeksDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func getDaysDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func getHoursDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func getMinutesDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func getSecondsDifference(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
