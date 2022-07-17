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

struct PickerView: View {
    @Binding public var seconds: Int
    
    var daysArray = [Int](0..<30)
    var hoursArray = [Int](0..<24)
    var minutesArray = [Int](0..<60)
    var secondsArray = [Int](0..<60)
    
    private let hoursInDay = 24
    private let secondsInMinute = 60
    private let minutesInHour = 60
    private let secondsInHour = 3600
    private let secondsInDay = 86400
    
    @State private var daySelection = 0
    @State private var hourSelection = 0
    @State private var minuteSelection = 1
    @State private var secondSelection = 0
    
    private let frameHeight: CGFloat = 160
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Picker(selection: self.$daySelection, label: Text("")) {
                    ForEach(0 ..< self.daysArray.count) { index in
                        Text("\(self.daysArray[index]) d").tag(index)
                    }
                }
                .onChange(of: self.daySelection) { newValue in
                    seconds = totalInSeconds
                }
                .frame(width: geometry.size.width/4, height: frameHeight, alignment: .center)
                .clipped()
                
                Picker(selection: self.$hourSelection, label: Text("")) {
                    ForEach(0 ..< self.hoursArray.count) { index in
                        Text("\(self.hoursArray[index]) h").tag(index)
                    }
                }
                .onChange(of: self.hourSelection) { newValue in
                    seconds = totalInSeconds
                }
                .frame(width: geometry.size.width/4, height: frameHeight, alignment: .center)
                .clipped()
                
                Picker(selection: self.$minuteSelection, label: Text("")) {
                    ForEach(0 ..< self.minutesArray.count) { index in
                        Text("\(self.minutesArray[index]) m").tag(index)
                    }
                }
                .onChange(of: self.minuteSelection) { newValue in
                    seconds = totalInSeconds
                }
                .frame(width: geometry.size.width/4, height: frameHeight, alignment: .center)
                .clipped()
                
                Picker(selection: self.self.$secondSelection, label: Text("")) {
                    ForEach(0 ..< self.secondsArray.count) { index in
                        Text("\(self.secondsArray[index]) s").tag(index)
                    }
                }
                .onChange(of: self.secondSelection) { newValue in
                    seconds = totalInSeconds
                }
                .frame(width: geometry.size.width/4, height: frameHeight, alignment: .center)
                .clipped()
            }
        }
        .onAppear(perform: { updatePickers() })
    }
    
    func updatePickers() {
        daySelection = seconds.secondsToDays
        hourSelection = seconds.secondsToHours
        minuteSelection = seconds.secondsToMinutes
        secondSelection = seconds.secondsRemainder
    }
    
    var totalInSeconds: Int {
        return daySelection * self.secondsInDay + hourSelection * self.secondsInHour + minuteSelection *     self.secondsInMinute + secondSelection
    }
}

extension Int {
  var secondsToDays:Int {
    self/86400
  }
  var secondsToHours:Int {
    (self%86400)/3600
  }
  var secondsToMinutes:Int {
    (self%86400)/60
  }
  var secondsRemainder:Int {
    self%86400
  }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
      PickerView(seconds: .constant(50))
    }
}
