//
//  Date.swift
//  Dropneed
//
//  Created by Raman on 10/05/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension Date {

    func string(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    func formattedRelativeString() -> String
    {
        print(self)
        var calender = Calendar.current
        calender.locale = Locale.current
        calender.timeZone = TimeZone.current
        if(calender.isDateInToday(self)) {
            return self.string("hh:mm a")
        }
        else if(calender.isDateInYesterday(self)) {
            return "Yesterday"
        }
        else if(calender.isDateInWeekend(self)) {
            return self.string("EEEE")
        }
        return self.string("dd-MMM-YYYY")
    }
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        return calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    func isInSameWeek(as date: Date) -> Bool {
        return isEqual(to: date, toGranularity: .weekday)
    }
    
    func isInSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }

    func getAgoTimeForStories() -> (Int,Int,Int) {
        
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.hour, .minute, .second], from:
            self, to: Date())
        return (dateComponent.hour!, dateComponent.minute!, dateComponent.second!)
    }

    func feedTime() -> String {

        var calender = Calendar.current
        calender.locale = Locale.current
        calender.timeZone = TimeZone.current
        let min = self.getAgoTimeForStories().1
        let hour = self.getAgoTimeForStories().0
      //  let sec = self.getAgoTimeForStories().2
        if(calender.isDateInToday(self)) {
            if(hour >= 1){
                return "\(hour.string) hour ago"
            }
            else if(min >= 1) {
                return "\(min.string) min ago"
            }
            return "Now"
        }
        else if(calender.isDateInYesterday(self)) {
            return "Yesterday"
        }
        else if(calender.isDateInWeekend(self)) {
            return self.string("EEEE")
        }
        return self.string("dd-MMM-YYYY")
        
    }
}

//////////////////////////////////////////////////////////////////////////////////////////

/*
 String extension only for date methods
 */
extension String {
    
    func date(_ format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)!
    }
    func getAgeFromDOB() -> (Int,Int,Int) {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd-MMM-YYYY"
        let dateOfBirth = dateFormater.date(from: self)
        
        let calender = Calendar.current
        
        let dateComponent = calender.dateComponents([.year, .month, .day], from:
            dateOfBirth!, to: Date())
        return (dateComponent.year!, dateComponent.month!, dateComponent.day!)
    }
    
    
}


