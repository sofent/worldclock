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

struct DayGraphView: View {
  var date: Date
  var location: ClockLocation

  func dateDecimalTime(for dte: Date, timeZone: TimeZone) -> Double {
    let components = Calendar.current.dateComponents(in: timeZone, from: dte)
    guard
      let hour = components.hour,
      let minute = components.minute
    else {
      return 0.0
    }
    let decimalTime = Double(hour) + Double(minute) / 60.0
    return decimalTime
  }

  var body: some View {
    GeometryReader { proxy in
      Group {
        DaytimeGraphicsView(
          date: date,
          location: location)
        // swiftlint:disable:next force_unwrapping
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        DaytimeGraphicsView(
          date: tomorrow,
          location: location)
          .offset(x: proxy.size.width)
        Path { path in
          let position = dateDecimalTime(for: date, timeZone: location.timeZone) * proxy.size.width / 24.0
          path.move(to: CGPoint(x: position, y: 0))
          path.addLine(to: CGPoint(x: position, y: proxy.size.height))
        }
        .stroke(.white)
      }
      .offset(x: -(dateDecimalTime(for: date, timeZone: location.timeZone) - 1) * proxy.size.width / 24.0)
    }
  }
}

struct DayGraphView_Previews: PreviewProvider {
  static var previews: some View {
    DayGraphView(
      date: Date(),
      location: ClockLocation.locationChicago
    ).frame(height: 25)
  }
}
