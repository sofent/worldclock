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

import SwiftUI
import MapKit
import Solar

struct DaytimeGraphicsView: View {
  var date: Date
  var location: ClockLocation

  func sunriseDecimalTime(for time: Date, at location: CLLocationCoordinate2D, timeZone: TimeZone) -> Double {
    let solar = Solar(for: time, coordinate: location)
    guard let sunrise = solar?.sunrise else {
      return 0.0
    }
    let components = Calendar.current.dateComponents(in: timeZone, from: sunrise)
    guard
      let hour = components.hour,
      let minute = components.minute
    else {
      return 0.0
    }
    let decimalTime = Double(hour) + Double(minute) / 60.0
    return decimalTime
  }

  func sunsetDecimalTime(for time: Date, at location: CLLocationCoordinate2D, timeZone: TimeZone) -> Double {
    let solar = Solar(for: time, coordinate: location)
    guard let sunset = solar?.sunset else {
      return 24.0
    }

    let components = Calendar.current.dateComponents(in: timeZone, from: sunset)
    guard
      let hour = components.hour,
      let minute = components.minute
    else {
      return 24.0
    }
    let decimalTime = Double(hour) + Double(minute) / 60.0
    return decimalTime
  }

  var body: some View {
    Canvas { context, size in
      let sunrisePosition = sunriseDecimalTime(
        for: date,
        at: location.location,
        timeZone: location.timeZone) * size.width / 24.0
      let sunsetPosition = sunsetDecimalTime(
        for: date,
        at: location.location,
        timeZone: location.timeZone) * size.width / 24.0
      // 1
      let preDawnRect = CGRect(
        x: 0,
        y: 0,
        width: sunrisePosition,
        height: size.height)
      // 2
      context.fill(
        // 3
        Path(preDawnRect),
        // 4
        with: .color(.black))
      let dayRect = CGRect(
        x: sunrisePosition,
        y: 0,
        width: sunsetPosition - sunrisePosition,
        height: size.height)
      context.fill(
        Path(dayRect),
        with: .color(.blue))
      let eveningRect = CGRect(
        x: sunsetPosition,
        y: 0,
        width: size.width - sunsetPosition,
        height: size.height)
      context.fill(
        Path(eveningRect),
        with: .color(.black))
      // 1
      for hour in [0, 12] {
        // 2
        var hourPath = Path()
        // 3
        let position = Double(hour) / 24.0 * size.width
        // 4
        hourPath.move(to: CGPoint(x: position, y: 0))
        // 5
        hourPath.addLine(to: CGPoint(x: position, y: size.height))
        // 6
        context.stroke(
          hourPath,
          with: .color(.yellow),
          lineWidth: 3.0)
      }
    }
  }
}

struct DaytimeView_Previews: PreviewProvider {
  static var previews: some View {
    DaytimeGraphicsView(
      date: Date(),
      location: ClockLocation.locationChicago)
      .frame(height: 30)
      .padding()
  }
}
