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
      let centerOffsetX = min(size.width, size.height) * 0.05 +  (size.width -  min(size.width, size.height))/2
      let centerOffsetY = min(size.width, size.height) * 0.05 +  (size.height -  min(size.width, size.height))/2
      // 3
      let clockCenterX = size.width / 2.0
      let clockCenterY = size.height / 2.0
      // 4
      let frameRect = CGRect(
        x: centerOffsetX,
        y: centerOffsetY,
        width: clockSize,
        height: clockSize)
      let outframeRect = CGRect(
        x: centerOffsetX-10,
        y: centerOffsetY-10 ,
        width: clockSize+20,
        height: clockSize+20)
      // 1
      gContext.withCGContext { cgContext in
       
        // 2
        cgContext.setStrokeColor(
          location.isDaytime(at: time) ?
            UIColor.black.cgColor : UIColor.white.cgColor)
        // 3
        cgContext.setFillColor(UIColor.brown.cgColor)
        cgContext.setLineWidth(5.0)
        // 4
        cgContext.addEllipse(in: outframeRect)
        // 5
        cgContext.drawPath(using: .fillStroke)
        
        cgContext.setFillColor(location.isDaytime(at: time) ? dayColor : nightColor)
        cgContext.setLineWidth(2.0)
        
        cgContext.addEllipse(in: frameRect)
        // 5
        cgContext.drawPath(using: .fillStroke)
        drawTickMarks(
          gcontext: gContext,
          context: cgContext,
          size: clockSize,
          offset: CGPoint(x: centerOffsetX, y: centerOffsetY))
        
        // 1
        cgContext.setFillColor(location.isDaytime(at: time) ?
          UIColor.black.cgColor : UIColor.white.cgColor)
        // 2
        cgContext.translateBy(x: clockCenterX, y: clockCenterY)
        
        if let dayView = dayView {
          gContext.draw(
            dayView,
            at: CGPoint(x: clockCenterX * 1.5, y: clockCenterY))
        }
        
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
        addArc(context: cgContext, size: clockSize)
        addCurve(cgContext, clockSize)
      }
      

    } symbols: {
      ClockDayView(time: time, location: location)
        .tag(0)
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

  func addCurve(_ context: CGContext,  _ size: Double){
    context.saveGState()
    context.setStrokeColor(UIColor.red.cgColor)
    context.setLineWidth(5)
    let clockRadius = size / 2.0 + 10
    let angle = 1 / 12.0 * 2.0 * Double.pi
    let arcRadius = clockRadius * sin(angle / 2)
    let arcCenterX = clockRadius * cos(angle / 2)
    let buttonDiameter = size * 0.06
    let leftX = (arcCenterX+arcRadius+buttonDiameter/2) * cos(15/24*2.0*Double.pi)
    let leftY = (arcCenterX+arcRadius+buttonDiameter/2) * sin(15/24*2.0*Double.pi)
    let RightX = (arcCenterX+arcRadius+buttonDiameter/2) * cos(21/24*2.0*Double.pi)
    let RithtY = (arcCenterX+arcRadius+buttonDiameter/2) * sin(21/24*2.0*Double.pi)
    context.move(to: CGPoint(x: leftX, y: leftY))
    context.addCurve(to: CGPoint(x: RightX, y: RithtY), control1: CGPoint(x: (arcCenterX+arcRadius*2) * cos(17/24*2.0*Double.pi), y:  (arcCenterX+arcRadius*2) * sin(17/24*2.0*Double.pi)), control2: CGPoint(x: (arcCenterX+arcRadius*2) * cos(19/24*2.0*Double.pi), y: (arcCenterX+arcRadius*2) * sin(19/24*2.0*Double.pi)))
    context.strokePath()
    context.restoreGState()
  }
  fileprivate func addEar(_ context: CGContext,  _ size: Double) {
    let clockRadius = size / 2.0 + 10
    let angle = 1 / 12.0 * 2.0 * Double.pi
    let arcRadius = clockRadius * sin(angle / 2)
    let arcCenterX = clockRadius * cos(angle / 2)
    context.addArc(center: CGPoint(x: 0, y: arcCenterX), radius: arcRadius, startAngle:   Double.pi, endAngle:  Double.pi*2, clockwise: true)
    context.addArc(center: CGPoint(x: 0, y: 0), radius: clockRadius, startAngle: Double.pi*0.5-angle/2, endAngle:  Double.pi*0.5+angle/2, clockwise: false)
    context.fillPath()
    let buttonDiameter = size * 0.06
    let buttonOffset = buttonDiameter / 2.0
    let buttonRect = CGRect(
      x: -buttonOffset,
      y: -buttonOffset+arcCenterX+arcRadius,
      width: buttonDiameter,
      height: buttonDiameter)
    context.addEllipse(in: buttonRect)
    context.fillPath()
  }
  
  func addArc(context: CGContext,size :Double){
  
    context.saveGState()
    context.setFillColor(UIColor.darkGray.cgColor)
    context.rotate(by: Double.pi*0.75)
    addEar(context, size)
    
    context.rotate(by: Double.pi*0.5)
    addEar(context, size)
    context.restoreGState()
    
  }
  
  func drawTickMarks(gcontext: GraphicsContext,context: CGContext, size: Double, offset : CGPoint) {
    // 1
    let clockCenterX = size / 2.0 + offset.x
    let clockCenterY = size / 2.0 + offset.y
    let clockRadius = size / 2.0
    context.saveGState()
    context.setStrokeColor(UIColor.gray.cgColor)
    context.setLineWidth(1.5)
    for minitMark in 0..<60 {
      // 3
      let angle = Double(minitMark) / 60.0 * 2.0 * Double.pi
      // 4
      let startX = cos(angle) * clockRadius + clockCenterX
      let startY = sin(angle) * clockRadius + clockCenterY
      // 5
      let endX = cos(angle) * clockRadius * 0.95 + clockCenterX
      let endY = sin(angle) * clockRadius * 0.95 + clockCenterY
      // 6
      context.move(to: CGPoint(x: startX, y: startY))
      // 7
      context.addLine(to: CGPoint(x: endX, y: endY))
      
      // 8
      context.strokePath()
    }
    context.restoreGState()
    // 2
    for hourMark in 0..<12 {
      // 3
      let angle = Double(hourMark) / 12.0 * 2.0 * Double.pi
      // 4
      let startX = cos(angle) * clockRadius + clockCenterX
      let startY = sin(angle) * clockRadius + clockCenterY
      // 5
      let endX = cos(angle) * clockRadius * 0.9 + clockCenterX
      let endY = sin(angle) * clockRadius * 0.9 + clockCenterY
      // 6
      context.move(to: CGPoint(x: startX, y: startY))
      // 7
      context.addLine(to: CGPoint(x: endX, y: endY))
      
      // 8
      context.strokePath()
      let tX = cos(angle) * clockRadius * 0.8 + clockCenterX
      let tY = sin(angle) * clockRadius * 0.8 + clockCenterY
      var hour = (hourMark+3)%12
      hour = hour == 0 ? 12 : hour
      gcontext.draw(Text("\(hour)").font(.title.bold()).foregroundColor(.secondary), at: CGPoint(x: tX,y: tY))
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
