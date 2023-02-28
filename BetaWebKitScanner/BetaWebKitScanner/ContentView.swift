//
//  ContentView.swift
//  BetaWebKitScanner
//
//  Created by Tim Sonner on 2/27/23.
//

import SwiftUI

struct ContentView: View {
    @State private var lowerIP = "1.1.1.1"
    @State private var upperIP = "1.1.1.9"
    @State private var results = [String]()
    @State private var selectedOption = 0
    
    var filteredResults: [String] {
        switch selectedOption {
        case 0:
            return results
        case 1:
            return results.filter { $0.hasSuffix(": 200") }
        case 2:
            return results.filter { !$0.hasSuffix(": 200") }
        default:
            return results
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Lower IP")
                TextField("Enter lower IP", text: $lowerIP)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Text("Upper IP")
                TextField("Enter upper IP", text: $upperIP)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            Button("Scan") {
                results.removeAll()
                scan()
            }
            .padding()
            
            Picker("Filter", selection: $selectedOption) {
                Text("All").tag(0)
                Text("200").tag(1)
                Text("Not 200").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List(filteredResults, id: \.self) { result in
                Text(result)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func scan() {
        let lowerBound = ipToNumber(lowerIP)
        let upperBound = ipToNumber(upperIP)
        
        for ipNumber in lowerBound...upperBound {
            let ip = numberToIP(ipNumber)
            let url = URL(string: "http://\(ip)")!
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    let result = "\(ip): \(statusCode)"
                    DispatchQueue.main.async {
                        results.append(result)
                    }
                }
            }.resume()
        }
    }
    
    func ipToNumber(_ ip: String) -> Int {
        let octets = ip.components(separatedBy: ".").compactMap { Int($0) }
        return (octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3]
    }
    
    func numberToIP(_ number: Int) -> String {
        let octet1 = (number >> 24) & 0xff
        let octet2 = (number >> 16) & 0xff
        let octet3 = (number >> 8) & 0xff
        let octet4 = number & 0xff
        return "\(octet1).\(octet2).\(octet3).\(octet4)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
