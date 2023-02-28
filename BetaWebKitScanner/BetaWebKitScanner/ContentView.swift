//
//  ContentView.swift
//  BetaWebKitScanner
//
//  Created by Tim Sonner on 2/27/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var statusCodes: [String] = []
    
    var body: some View {
        NavigationView {
            List(statusCodes, id: \.self) { code in
                Text(code)
            }
            .navigationBarTitle(Text("IP Scanner"))
            .onAppear {
                self.scanIPRange()
            }
        }
    }
    
    private func scanIPRange() {
        for i in 1...9 {
            let ipAddress = "1.1.1.\(i)"
            guard let url = URL(string: "http://\(ipAddress)") else {
                continue
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        self.statusCodes.append("\(ipAddress): \(httpResponse.statusCode)")
                    } else {
                        self.statusCodes.append("\(ipAddress): Error")
                    }
                }
            }.resume()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
