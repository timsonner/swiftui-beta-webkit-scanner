//
//  ContentView.swift
//  BetaWebKitScanner
//
//  Created by Tim Sonner on 2/27/23.
//

import SwiftUI

struct ContentView: View {
    @State private var lowerIP: String = "1.1.1.1"
    @State private var upperIP: String = "255.255.255.255"
    @State private var results: [String] = []
    @State private var selectedOption: Int = 0
    @State private var ipsToScan: [String] = []
    
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
                explodeRangeofIPV4s(lowerBounds: lowerIP, upperBounds: upperIP)
                print(ipsToScan)
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
        for ip in ipsToScan {
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
    
    func explodeRangeofIPV4s(lowerBounds: String, upperBounds: String) {
        var arrayOfIPV4Addresses: [String] = []
        for ip in stride(from:ipv4StringToInt(stringOfIPV4Address: lowerBounds), through: ipv4StringToInt(stringOfIPV4Address: upperBounds), by: 1) {
            arrayOfIPV4Addresses.append(ipv4IntToString(integer: ip))
        }
        self.ipsToScan = arrayOfIPV4Addresses
    }
    
    func ipv4IntToString(integer: Int) -> String {
        // int >> 24 performs a bitwise shift 24 places to the right
        // & 0xFF is a bitwise AND, and 0xFF in hex is 255 in decimal
        let section1 = String((integer >> 24) & 0xFF)
        let section2 = String((integer >> 16) & 0xFF)
        let section3 = String((integer >> 8) & 0xFF)
        let section4 = String((integer >> 0) & 0xFF)
        return section1 + "." + section2 + "." + section3 + "." + section4
    }
    
    func ipv4StringToInt(stringOfIPV4Address: String) -> Int {
        let arrayOfIntegers: [Int] = stringOfIPV4Address.split(separator: ".").map({Int($0)!})
        var integer: Int = 0
        for i in stride(from:3, through:0, by:-1) {
            // if ipv4 address does not contain 4 sections, you end up here with "Fatal error: Index out of range"
            integer += arrayOfIntegers[3-i] << (i * 8)
        }
        return integer
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
