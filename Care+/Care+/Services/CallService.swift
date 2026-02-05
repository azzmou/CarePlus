//
//  CallService.swift
//  Care+
//
//  Call + date helpers (Rome timezone)
//

import Foundation
import UIKit

enum CallService {
    static let romeTZ: TimeZone = TimeZone(identifier: "Europe/Rome") ?? .current

    static func romeCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = romeTZ
        return cal
    }

    static func startOfDayRome(for date: Date) -> Date {
        romeCalendar().startOfDay(for: date)
    }

    static func startOfNextDayRome(for date: Date) -> Date {
        let cal = romeCalendar()
        let start = cal.startOfDay(for: date)
        return cal.date(byAdding: .day, value: 1, to: start)!
    }

    /// Range covering the last 30 days including today, using Europe/Rome boundaries.
    /// `to` is exclusive.
    static func last30DaysRangeEndingToday(now: Date = .now) -> (from: Date, to: Date) {
        let cal = romeCalendar()
        let todayStart = cal.startOfDay(for: now)
        let from = cal.date(byAdding: .day, value: -29, to: todayStart)! // includes today => 30 days
        let to = cal.date(byAdding: .day, value: 1, to: todayStart)!    // exclusive end (tomorrow start)
        return (from, to)
    }

    static func normalizeDigits(_ phone: String) -> String {
        phone.filter(\.isNumber)
    }

    static func makeTelURL(phone: String) -> URL? {
        let digits = normalizeDigits(phone)
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }
}
