/// Copyright (c) 2022 Razeware LLC
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

struct CountdownAnalogView: View {
  let countDown:Double
  
  var dayColor: CGColor {
    CGColor(red: 192.0 / 255.0, green: 217.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
  }
  
    var body: some View {
      Canvas { gContext, size in
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
        gContext.withCGContext { cgContext in
          
          // 2
          cgContext.setStrokeColor(UIColor.black.cgColor)
          // 3
          cgContext.setFillColor(UIColor.brown.cgColor)
          cgContext.setLineWidth(5.0)
          // 4
          cgContext.addEllipse(in: outframeRect)
          // 5
          cgContext.drawPath(using: .fillStroke)
          
          cgContext.setFillColor(dayColor)
          cgContext.setLineWidth(2.0)
          
          cgContext.addEllipse(in: frameRect)
          // 5
          cgContext.drawPath(using: .fillStroke)
         
          
          // 1
          cgContext.setFillColor(UIColor.black.cgColor)
          // 2
          cgContext.translateBy(x: clockCenterX, y: clockCenterY)
          
          // 3
          let angle = 12 / 12.0 * 2 * Double.pi
          let hourRadius = clockSize * 0.65 / 2.0
          
          let minuteRadius = clockSize * 0.75 / 2.0
          let minuteAngle = countDown / 60.0 * 2 * Double.pi
          
          
          addCountDownArc(context: cgContext, angle: minuteAngle, width: 0, length: clockSize/2*0.85)
          
          drawTickMarks(
            gcontext: gContext,
            context: cgContext,
            size: clockSize,
            offset: CGPoint(x: 0, y: 0))
          
          // 4
          drawClockHand(
            context: cgContext,
            angle: angle,
            width: 7.5,
            length: hourRadius)
         
          drawClockHand(
            context: cgContext,
            angle: minuteAngle,
            width: 5.0,
            length: minuteRadius)
          
          
        }
      }
    }
  
  func addCountDownArc( context: CGContext,
                        angle: Double,
                        width: Double,
                        length: Double){
    context.saveGState()
    context.setFillColor(UIColor.red.cgColor)
    context.setAlpha(0.7)
    context.move(to:  CGPoint(x: 0, y: 0))
    context.rotate(by: -Double.pi/2)
    context.addArc(center: CGPoint(x: 0, y: 0), radius: length, startAngle: 0, endAngle: angle, clockwise: false)
    context.fillPath()
    context.restoreGState()
    
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
  
  fileprivate func drawMark(_ angle: Double, _ clockRadius: Double, _ clockCenterX: CGFloat, _ clockCenterY: CGFloat,_ lenthP :CGFloat, _ context: CGContext) {
    // 4
    let startX = cos(angle) * clockRadius + clockCenterX
    let startY = sin(angle) * clockRadius + clockCenterY
    // 5
    let endX = cos(angle) * clockRadius * lenthP + clockCenterX
    let endY = sin(angle) * clockRadius * lenthP + clockCenterY
    // 6
    context.move(to: CGPoint(x: startX, y: startY))
    // 7
    context.addLine(to: CGPoint(x: endX, y: endY))
    
    // 8
    context.strokePath()
  }
  
  func drawTickMarks(gcontext: GraphicsContext,context: CGContext, size: Double, offset : CGPoint) {
    // 1
    let clockCenterX = offset.x
    let clockCenterY = offset.y
    let clockRadius = size / 2.0
    context.saveGState()
    context.setStrokeColor(UIColor.gray.cgColor)
    context.setLineWidth(1.5)
    for minitMark in 0..<60 {
      // 3
      let angle = Double(minitMark) / 60.0 * 2.0 * Double.pi
      drawMark(angle, clockRadius, clockCenterX, clockCenterY,0.95, context)
    }
    context.restoreGState()
    // 2
    for hourMark in 0..<12 {
      // 3
      let angle = Double(hourMark) / 12.0 * 2.0 * Double.pi
      drawMark(angle, clockRadius, clockCenterX, clockCenterY,0.90, context)
      let tX = cos(angle) * clockRadius * 0.8
      let tY = sin(angle) * clockRadius * 0.8
      var hour = (hourMark+3)%12
      hour = (hour == 0 ? 12 : hour) * 5
      /*gcontext.draw(Text("\(hour)").font(.title.bold()).foregroundColor(.secondary), at: CGPoint(x: tX,y: tY))*/
      draw("\(hour)",in: context, at: CGPoint(x: tX,y: tY))
    }
  }
  
  func draw(_ str:String,in ctx: CGContext,at point:CGPoint) {
     UIGraphicsPushContext(ctx)
      let font = UIFont.systemFont(ofSize: 24)
    let string = NSAttributedString(string: str, attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.strokeColor:UIColor.gray.cgColor])
    string.draw(at: CGPoint(x: point.x-12, y: point.y-12))
     UIGraphicsPopContext()
  }
}

struct CountdownAnalogView_Previews: PreviewProvider {
    static var previews: some View {
      CountdownAnalogView(countDown: 5.0)
    }
}
