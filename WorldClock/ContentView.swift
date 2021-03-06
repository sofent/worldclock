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

struct ContentView: View {
  @AppStorage("Locations") var storedLocations = ""
  @StateObject var locations = ClockLocationStorage()
  @State var startDate :Date = .distantPast
  @State var curtab:Int = 1
  @State var countDownSec = 0
  var firstLocation: ClockLocation? {
    return locations.locations.first
  }
  
  var body: some View {
    TabView(selection:$curtab){
      NavigationView {
        TimelineView(.everyMinute) { context in
          List(locations.locations) { location in
            NavigationLink(
              destination: LocationDetailsView(
                location: location)) {
                  
                  LocationView(
                    location: location,
                    currentDate: context.date,
                    firstLocation: firstLocation)
                  
                  
                }
                .clipShape(Rectangle())
          }
          .onAppear {
            if !storedLocations.isEmpty {
              locations.loadLocations(stored: storedLocations)
            }
          }
          .onChange(of: locations.locations) { _ in
            storedLocations = locations.locationsAsString
            print("Updated stored location: \(storedLocations)")
          }
          .navigationTitle("World Clock")
          .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
              Spacer()
              NavigationLink {
                CitySearch(locations: locations)
              } label: {
                Image(systemName: "map")
              }
            }
          }
        }
        
      }.tabItem{
        Image(systemName: "clock.fill")
        Text("Clock")
      }.tag(0)
      
      NavigationView {
        TimelineView(.animation) { context in
          VStack{
           
            if startDate != .distantPast {
              let timeRemain = (Double(countDownSec) - context.date.timeIntervalSince(startDate))/60
              if timeRemain > 0{
                Text("\(Int(timeRemain*60))").padding(.vertical).font(.largeTitle)
               
                  
                  CountdownAnalogView(countDown: timeRemain)
                  
                
              }else{
                Text("time is over").font(.largeTitle.bold())
                Button("reset"){
                  self.startDate = .distantPast
                  self.countDownSec = 0
                }.buttonStyle(.borderedProminent).padding(.vertical)
              }
            }
          }.onAppear{
            //self.startDate = .now
          }
          .navigationTitle("Countdown Clock")
        }.frame(maxWidth:.infinity,maxHeight: .infinity)
        .overlay{
          if startDate == .distantPast{
            VStack{
              PickerView(seconds: $countDownSec)
              Button("start"){
                self.startDate = .now
              }.disabled(countDownSec==0)
            }}
        }
        
      }.tabItem{
        Image(systemName: "digitalcrown.arrow.counterclockwise.fill")
        Text("Countdown")
      }.tag(1)
      
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
