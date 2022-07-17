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
import Combine

class LocationSearchService: NSObject, ObservableObject {
  @Published var searchText = ""
  @Published var searchResults: [MKLocalSearchCompletion] = []

  private var queryCancellable: AnyCancellable?
  private let searchCompleter: MKLocalSearchCompleter

  override init() {
    searchCompleter = MKLocalSearchCompleter()
    super.init()
    searchCompleter.region = MKCoordinateRegion(.world)
    searchCompleter.delegate = self

    queryCancellable = $searchText
      .receive(on: DispatchQueue.main)
      .debounce(
        for: .milliseconds(200),
        scheduler: RunLoop.main,
        options: nil)
      .sink { fragment in
        if fragment.isEmpty {
          self.searchResults = []
        } else {
          self.searchCompleter.queryFragment = self.searchText
        }
      }
  }
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    // No direct way to get only cities(why not Apple?), but filter for empty subtitle gets pretty close
    self.searchResults = completer.results.filter { !$0.subtitle.isEmpty }
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    print("Error: \(error.localizedDescription)")
  }
}
