//
//  URLWithMetadatas.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import Alamofire
import AppKit
import Foundation
import SwiftSoup

class URLWithMetadatas: ObservableObject {
    @Published var previewImage: NSImage?
    @Published var title: String?
    @Published var description: String?
    var url: String

    init(url: String) {
        if !url.starts(with: "http") {
            self.url = "https://\(url)"
        } else {
            self.url = url
        }
        DispatchQueue.global(qos: .default).async {
            let headers: HTTPHeaders = [
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Safari/605.1.15",
                "Accept": "*/*"
            ]
            AF.request(self.url, headers: headers).responseString { response in
                guard let html = response.value,
                      let doc: Document = try? SwiftSoup.parse(html),
                      let head = doc.head() else { return }

                if let title = try? head.select("title").first() {
                    self.title = try? title.text()
                }

                if let links = try? head.select("link") {
                    for link in links {
                        if let rel = try? link.attr("rel"),
                           rel == "icon",
                           let urlString = try? link.attr("href"),
                           self.setImage(urlString: urlString, headers: headers)
                        {
                            break
                        }
                    }
                }

                if let metas = try? head.select("meta") {
                    for meta in metas {
                        if let name = try? meta.attr("name") {
                            switch name {
                            case "title":
                                self.title = try? meta.attr("content")
                                continue
                            case "description":
                                self.description = try? meta.attr("content")
                                continue
                            case "og:description":
                                self.description = try? meta.attr("content")
                                continue
                            case "og:image":
                                if let urlString = try? meta.attr("content") {
                                    _ = self.setImage(urlString: urlString, headers: headers)
                                }
                                continue
                            default: break
                            }
                        }
                        if let name = try? meta.attr("property"),
                           name == "og:image",
                           let urlString = try? meta.attr("content"),
                           self.setImage(urlString: urlString, headers: headers)
                        {
                            continue
                        }
                    }
                }
            }
        }
    }

    private func setImage(urlString: String, headers: HTTPHeaders) -> Bool {
        var url: URL?
        if !urlString.validateUrl() {
            if var urlResult = URL(string: self.url) {
                urlResult.appendPathComponent(urlString)
                url = urlResult
            }
        } else {
            if let urlResult = URL(string: urlString) {
                url = urlResult
            }
        }
        if let urlResult = url {
            DispatchQueue.main.async {
                AF.download(urlResult, headers: headers).responseData { response in
                    if let data = response.value {
                        if let nsImage = NSImage(data: data) {
                            self.previewImage = nsImage
                        }
                    }
                }
            }
            return true
        }
        return false
    }
}
