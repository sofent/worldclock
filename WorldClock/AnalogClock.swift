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

struct AnalogClock: View {
  var time: Date
  var location: ClockLocation

  var dayColor: CGColor {
    CGColor(red: 192.0 / 255.0, green: 217.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
  }

  var nightColor: CGColor {
    UIColor.black.cgColor
  }

  func drawTickMarks(context: CGContext, size: Double, offset: Double) {
    // 1
    let clockCenter = size / 2.0 + offset
    let clockRadius = size / 2.0
    // 2
    for hourMark in 0..<12 {
      // 3
      let angle = Double(hourMark) / 12.0 * 2.0 * Double.pi
      // 4
      let startX = cos(angle) * clockRadius + clockCenter
      let startY = sin(angle) * clockRadius + clockCenter
      // 5
      let endX = cos(angle) * clockRadius * 0.9 + clockCenter
      let endY = sin(angle) * clockRadius * 0.9 + clockCenter
      // 6
      context.move(to: CGPoint(x: startX, y: startY))
      // 7
      context.addLine(to: CGPoint(x: endX, y: endY))
      // 8
      context.strokePath()
    }
  }

  func drawClockHand(
    context: CGContext,
    angle: Double,
    width: Double,
    length: Double
  ) {
    // 1
    context.saveGState()
    // 2
    context.rotate(by: angle)
    // 3
    context.move(to: CGPoint(x: 0, y: 0))
    context.addLine(to: CGPoint(x: -width, y: -length * 0.67))
    context.addLine(to: CGPoint(x: 0, y: -length))
    context.addLine(to: CGPoint(x: width, y: -length * 0.67))
    context.closePath()
    // 4
    context.fillPath()
    // 5
    context.restoreGState()
  }

  var clockDecimalHourInLocalTz: Double {
    // 1
    let dateComponents = Calendar.current.dateComponents(in: location.timeZone, from: time)
    // 2
    guard
      let hour = dateComponents.hour,
      let minute = dateComponents.minute
    else {
      return 0.0
    }
    // 3
    let decimalHour = Double(hour) + Double(minute) / 60.0
    // 4
    return decimalHour > 12 ? decimalHour - 12 : decimalHour
  }

  var clockMinuteInLocalTz: Double {
    let dateComponents = Calendar.current.dateComponents(in: location.timeZone, from: time)
    guard
      let minute = dateComponents.minute,
      let second = dateComponents.second
    else {
      return 0.0
    }
    let decimalMinute = Double(minute) + Double(second) / 60.0
    return decimalMinute
  }

  var clockSecondInLocalTz: Double {
    let dateComponents = Calendar.current.dateComponents(in: location.timeZone, from: time)
    guard
      let second = dateComponents.second,
      let nanoSecond = dateComponents.nanosecond
    else {
      return 0.0
    }
    return Double(second) + Double(nanoSecond) / 1e9
  }

  var body: some View {
    Canvas { gContext, size in
      let dayView = gContext.resolveSymbol(id: 0)
      // 1
      let clockSize = min(size.width, size.height) * 0.9
      // 2
      let centerOffset = min(size.width, size.height) * 0.05
      // 3
      let clockCenter = min(size.width, size.height) / 2.0
      // 4
      let frameRect = CGRect(
        x: centerOffset,
        y: centerOffset,
        width: clockSize,
        height: clockSize)
      // 1
      gContext.withCGContext { cgContext in
        // 2
        cgContext.setStrokeColor(
          location.isDaytime(at: time) ? UIColor.black.cgColor : UIColor.white.cgColor)
        // 3
        cgContext.setFillColor(location.isDaytime(at: time) ? dayColor : nightColor)
        cgContext.setLineWidth(2.0)
        // 4
        cgContext.addEllipse(in: frameRect)
        // 5
        cgContext.drawPath(using: .fillStroke)
        drawTickMarks(
          context: cgContext,
          size: clockSize,
          offset: centerOffset)
        // 1
        cgContext.setFillColor(
          location.isDaytime(at: time) ?
          UIColor.black.cgColor : UIColor.white.cgColor)
        // 2
        cgContext.translateBy(x: clockCenter, y: clockCenter)
        // 3
        let angle = clockDecimalHourInLocalTz / 12.0 * 2 * Double.pi
        let hourRadius = clockSize * 0.65 / 2.0
        // 4
        drawClockHand(
          context: cgContext,
          angle: angle,
          width: 7.5,
          length: hourRadius)
        let minuteRadius = clockSize * 0.75 / 2.0
        let minuteAngle = clockMinuteInLocalTz / 60.0 * 2 * Double.pi
        drawClockHand(
          context: cgContext,
          angle: minuteAngle,
          width: 5.0,
          length: minuteRadius)
        cgContext.saveGState()
        cgContext.setFillColor(UIColor.red.cgColor)
        let secondRadius = clockSize * 0.85 / 2.0
        let secondAngle = clockSecondInLocalTz / 60.0 * 2 * Double.pi
        drawClockHand(
          context: cgContext,
          angle: secondAngle,
          width: 2.0,
          length: secondRadius)
        cgContext.restoreGState()
        let buttonDiameter = clockSize * 0.05
        let buttonOffset = buttonDiameter / 2.0
        let buttonRect = CGRect(
          x: -buttonOffset,
          y: -buttonOffset,
          width: buttonDiameter,
          height: buttonDiameter)
        cgContext.addEllipse(in: buttonRect)
        cgContext.fillPath()
      }
      if let dayView = dayView {
        gContext.draw(
          dayView,
          at: CGPoint(x: clockCenter * 1.6, y: clockCenter))
      }
    } symbols: {
      ClockDayView(time: time, location: location)
        .tag(0)
    }
  }
}

struct AnalogClock_Previews: PreviewProvider {
  static var previews: some View {
    AnalogClock(
      time: Date(),
      location: ClockLocation.locationChicago)
  }
}
