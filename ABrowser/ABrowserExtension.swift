//
//  ABrowserExtension.swift
//  ABrowser
//
//  Created by Lucas on 7/4/2024.
//

/*
 URL to load from
 
 E.g extension
 */

import Foundation
import WebKit

struct ABrowserExtensionInfo {
    let name: String
    let author: String
    let code: String
    let description: String
    let appliesTo: Regex<AnyRegexOutput>
    
    static func fromText(_ text: String) -> ABrowserExtensionInfo? {
        
        // Define regex patterns for each field
        let nameRegex = try? Regex(#"name:\s*(.+)"#)
        let authorRegex = try? Regex(#"author\(s\):\s*(.+)"#)
        let appliesToRegex = try? Regex(#"applies-to:\s*(.+)"#)
        
        guard let nameMatch = try? nameRegex?.firstMatch(in: text),
              let authorMatch = try? authorRegex?.firstMatch(in: text),
              let appliesToMatch = try? appliesToRegex?.firstMatch(in: text) else {
            return nil
        }
        
        // Convert extracted values to appropriate types
        let name = String(nameMatch[1].substring ?? "ABrowserExtension")
        let author = String(authorMatch[1].substring ?? "")
        let appliesTo = try? Regex(String(appliesToMatch[0].substring ?? ""))
        
        // Return the parsed struct
        return ABrowserExtensionInfo(name: name, author: author, code: String(text.split(separator: "------")[1]), description: String(text.split(separator: "------")[2]), appliesTo: appliesTo!)
    }
}


class ABrowserExtension {
    var url: URL
    let info: ABrowserExtensionInfo
    
    init(_ url: URL) {
        self.url = url
        self.info = .fromText(try! String(contentsOf: self.url))!
    }
    
    func evaluate(_ webView: WKWebView) {
        self.loadText { result in
            switch result {
            case .success(let result):
                webView.evaluateJavaScript(result)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    @discardableResult
    private func loadText(_ completionHandler: @escaping (Result<String, (any Error)>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: URLRequest(url: self.url)) { data, response, error in
            if error != nil {
                // Client error
                completionHandler(.failure(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // Server error
                completionHandler(.failure(URLError(.unknown, userInfo: ["Code" : "520 UNKOWN", "Type" : "Server"])))
                return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "text/plain",
               let data = data,
               let string = String(data: data, encoding: .utf8) {
                completionHandler(.success(string))
            }
        }
        
        task.resume()
        
        return task
    }
}
