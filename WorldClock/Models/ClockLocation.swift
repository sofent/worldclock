/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MapKit
import Solar

struct ClockLocation: Identifiable {
  var id = UUID()
  var name: String
  var location: CLLocationCoordinate2D
  var timeZone: TimeZone

  init(name: String, location: CLLocationCoordinate2D, timeZone: TimeZone) {
    self.name = name
    self.location = location
    self.timeZone = timeZone
  }

  init(name: String, latitude: String, longitude: String, timezone: String) {
    self.name = name
    let lat = Double(latitude) ?? 0.0
    let lng = Double(longitude) ?? 0.0
    self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    self.timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
  }

  var asString: String {
    "\(id)|\(name)|\(location.latitude)|\(location.longitude)|\(String(describing: timeZone.identifier))"
  }

  func timeZoneAbbreviation(on date: Date) -> String {
    timeZone.abbreviation(for: date) ?? "GMT"
  }

  func stringTimeInLocalTimeZone(_ time: Date) -> String {
    let tzFormatter = DateFormatter()
    tzFormatter.timeZone = timeZone
    tzFormatter.dateStyle = .none
    tzFormatter.timeStyle = .short
    return tzFormatter.string(from: time)
  }

  func sunRiseOn(_ date: Date) -> Date? {
    let solar = Solar(for: date, coordinate: location)
    return solar?.sunrise
  }

  func sunSetOn(_ date: Date) -> Date? {
    let solar = Solar(for: date, coordinate: location)
    return solar?.sunset
  }

  func isDaytime(at date: Date) -> Bool {
    guard let solar = Solar(for: date, coordinate: location) else {
      return false
    }
    return solar.isDaytime
  }

  func timeDifferenceString(_ date: Date, to remoteTz: TimeZone) -> String {
    guard let diff = timeDifference(date, to: remoteTz) else {
      return ""
    }

    let dcFormatter = DateComponentsFormatter()
    dcFormatter.allowedUnits = [.hour, .minute]
    let timeString = dcFormatter.string(from: diff) ?? ""
    if diff.hour ?? 0 > 0 {
      return "+\(timeString)"
    } else {
      return timeString
    }
  }

  func timeDifference(_ date: Date, to remoteTz: TimeZone) -> DateComponents? {
    let localComponents = Calendar.current.dateComponents(in: timeZone, from: date)
    let remoteComponents = Calendar.current.dateComponents(in: remoteTz, from: date)

    guard
      let localHour = localComponents.hour,
      let localMinute = localComponents.minute,
      let localSecond = localComponents.second,
      let localDay = localComponents.day,
      let localMonth = localComponents.month,
      let localYear = localComponents.year,
      let remoteHour = remoteComponents.hour,
      let remoteMinute = remoteComponents.minute,
      let remoteSecond = remoteComponents.second,
      let remoteDay = remoteComponents.day,
      let remoteMonth = remoteComponents.month,
      let remoteYear = remoteComponents.year
    else {
      return nil
    }

    let localCompareDate = DateComponents(
      calendar: Calendar.current,
      year: localYear,
      month: localMonth,
      day: localDay,
      hour: localHour,
      minute: localMinute,
      second: localSecond)
    let remoteCompareDate = DateComponents(
      calendar: Calendar.current,
      year: remoteYear,
      month: remoteMonth,
      day: remoteDay,
      hour: remoteHour,
      minute: remoteMinute,
      second: remoteSecond)

    let difference = Calendar.current.dateComponents(
      [.hour, .minute, .day],
      from: localCompareDate,
      to: remoteCompareDate)

    return difference
  }

  static var locationChicago: ClockLocation {
    ClockLocation(
      name: "Chicago, IL",
      latitude: "41.8781",
      longitude: "-87.6298",
      timezone: "America/Chicago")
  }

  static var locationSanFrancisco: ClockLocation {
    ClockLocation(
      name: "San Francisco, CA",
      latitude: "37.779379",
      longitude: "-122.418433",
      timezone: "America/Los_Angeles")
  }
}

extension ClockLocation: Equatable {
  static func == (lhs: ClockLocation, rhs: ClockLocation) -> Bool {
    lhs.id == rhs.id && lhs.name == rhs.name && lhs.location.latitude == rhs.location.latitude
    && lhs.location.longitude == rhs.location.longitude && lhs.timeZone == rhs.timeZone
  }
}
