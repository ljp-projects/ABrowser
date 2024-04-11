//
//  ContentView.swift
//  ABrowser
//
//  Created by Lucas on 5/4/2024.
//

import SwiftUI
import WebKit

var urlString = "ecosia.org"
let domainRegex = /\.(com|net|org|be|codes|io|co|us|ru|de|br|uk|jp|fr|it|edu|me|cn|ly|in|tv|ai|int|gov|app|mil)/
let protocolRegex = /^\w+:\/\//

struct ContentView: View, Hashable {
    static func == (lhs: ContentView, rhs: ContentView) -> Bool {
        lhs.webView == rhs.webView
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(webView)
    }
    
    let webView = WebView()
    
    @State private var degrees = 0.0
    @State private var loadingExt = false
    @State private var prevExt = ""
    var totalDuration = 0.25
    
    private var urlStringBind = Binding {
        urlString
    } set: { newValue in
        urlString = newValue
    }
    
    var body: some View {
        VStack {
#if os(macOS)
            HStack {
                Button(action: {
                    webView.goBack()
                }){
                    Image(systemName: "arrow.backward")
                        .font(.title)
                        .padding()
                }.buttonStyle(PlainButtonStyle())
                
                TextField("Enter url", text: urlStringBind)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                    .onSubmit {
                        webView.loadURL(urlString)
                    }
                
                Button(action: {
                    webView.reload()
                    
                    withAnimation(.easeOut(duration: totalDuration)) {
                        degrees -= 360
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .padding()
                        .rotationEffect(.degrees(degrees))
                    
                    
                }.buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    webView.goForward()
                }) {
                    Image(systemName: "arrow.forward")
                        .font(.title)
                        .padding()
                    
                    
                }.buttonStyle(PlainButtonStyle())
            }.onDrag {
                NSItemProvider(object: webView.createURL(urlString)! as NSURL)
            } preview: {
                Text(urlString)
            }
            
#endif
            
            // main webview
            webView
            
#if os(iOS)
            HStack {
                Button(action: {
                    webView.goBack()
                }){
                    Image(systemName: "arrow.backward")
                        .font(.title)
                        .padding()
                }.buttonStyle(PlainButtonStyle())
                
                TextField("Enter url", text: urlStringBind)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        webView.loadURL(urlString)
                    }
                
                Button(action: {
                    webView.reload()
                    
                    withAnimation(.easeOut(duration: totalDuration)) {
                        degrees -= 360
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .padding()
                }.buttonStyle(PlainButtonStyle())
                    .rotationEffect(Angle.degrees(degrees))
                
                Button(action: {
                    webView.goForward()
                }) {
                    Image(systemName: "arrow.forward")
                        .font(.title)
                        .padding()
                    
                    
                }.buttonStyle(PlainButtonStyle())
            }.onDrag {
                NSItemProvider(object: webView.createURL(urlString)! as NSURL)
            } preview: {
                Text(urlString)
            }
            
#endif
        }
        .onAppear() {
            webView.loadURL(urlString)
        }
    }
}
#Preview {
    ContentView()
}

#if os(macOS)
struct WebView: NSViewRepresentable, Hashable {
    typealias NSViewType = WKWebView
    
    
    let webView: WKWebView
    
    init() {
        self.webView = WKWebView()
    }
    
    func makeNSView(context: Context) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.upgradeKnownHostsToHTTPS = true
        webView.configuration.allowsAirPlayForMediaPlayback = true
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15"
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func goBack() {
        webView.goBack()
        
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func goForward() {
        webView.goForward()
        
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func reload() {
        webView.reload()
        
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func loadURL(_ loadString: String) {
        webView.load(URLRequest(url: self.createURL(loadString)!))
        
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func createURL(_ loadString: String) -> URL? {
        if urlString.contains(protocolRegex) {
            return URL(string: urlString)
        } else if urlString.contains(domainRegex) {
            return URL(string: "https://\(urlString)")
        } else {
           return URL(string: "https://ecosia.org/search?q=\(urlString)")
        }
    }
}
#else
struct WebView: UIViewRepresentable, Hashable {
    
    let webView: WKWebView
    
    init() {
        self.webView = WKWebView()
        
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func goBack() {
        webView.goBack()
        
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func goForward(){
        webView.goForward()
        
        if let url = webView.url {
            urlString = url.absoluteString
        }
    }
    
    func reload() {
        webView.reload()
        
        webView.evaluateJavaScript(
"""
console.log(":D")
""")
    }
    
    
    func loadURL(_ loadString: String) {
        urlString = loadString
        
        webView.load(URLRequest(url: self.createURL(loadString)!))
    }
    
    func createURL(_ loadString: String) -> URL? {
        if urlString.contains(protocolRegex) {
            return URL(string: urlString)
        } else if urlString.contains(domainRegex) {
            return URL(string: "https://\(urlString)")
        } else {
           return URL(string: "https://ecosia.org/search?q=\(urlString)")
        }
    }
    
    func loadURL(_ loadURL: URL) {
        urlString = loadURL.absoluteString
        
        webView.load(URLRequest(url: loadURL))
    }
}

#endif
