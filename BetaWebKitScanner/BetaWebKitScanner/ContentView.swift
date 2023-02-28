//
//  ContentView.swift
//  BetaWebKitScanner
//
//  Created by Tim Sonner on 2/27/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.html = ""
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, error) in
                if let html = html as? String {
                    self.parent.html = html
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var html = ""
    @State private var selectedTab = 0
    let url = URL(string: "https://www.example.com")!
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WebView(url: url, html: $html)
                .tag(0)
                .navigationBarTitle("Site")
                .tabItem {
                    Image(systemName: "globe")
                    Text("Site")
                }
            
            ScrollView {
                Text(html)
                    .padding()
            }
            .tag(1)
            .navigationBarTitle("HTML")
            .tabItem {
                Image(systemName: "doc.text")
                Text("HTML")
            }
        }
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
