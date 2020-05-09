//
//  NetworkingService.swift
//  VintishYalantisWeather
//
//  Created by Roman Vintish on 07.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
import MobileCoreServices

enum NetworkingServiceRestType:String {
    
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case delete = "DELETE"
    
}

enum NetworkingServiceMimeType:String {
    
    case none = ""
    case json = "application/json"
    case xml = "application/xml"
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case html = "text/html"
    case text = "text/plain"

    static func typeForString(_ type:String) -> NetworkingServiceMimeType? {
        return NetworkingServiceMimeType.init(rawValue: type)
    }
    
}

enum NetworkingServiceImageType {
    
    case jpeg
    case png
    case gif
    
}

fileprivate enum NetworkingServiceHeaderType:String {
    
    case authorization = "Authorization"
    case locale = "Local"
    case content = "Content-Type"
    
}

fileprivate class NetworkingServiceTaskHandlersContainer {
    
    var data:Data?
    var completion:((_ data:Any?, _ response:URLResponse?, _ error:Error?)->())?
    var sendProgress:((_ part:Int64?, _ total:Int64?)->())?
    var receiveProgress:((_ part:Int64?, _ total:Int64?)->())?
    
}

class NetworkingService: NSObject {
    
    static let shared = NetworkingService()
    var locale:(()->(String))? = {return "en"}
    var authorization:(()->(String?))?
    var authoriationErrorHandler:(()->())?
    var internetConnectionReachableHandler:((_ connected:Bool)->())?
    private var session:URLSession?
    private var tasksHandlers:[URLSessionTask:NetworkingServiceTaskHandlersContainer] = Dictionary.init()
    private var previousInternetConnectionReachability:Bool = true
    
    var downloadCache = NSCache<NSString, NSString>()

    override init() {
        
        super.init()
        
        prepare()
        
    }
    
    deinit {
        
        invalidate()
        
    }
    
    let mimeTypes = [
        "html": "text/html",
        "htm": "text/html",
        "shtml": "text/html",
        "css": "text/css",
        "xml": "text/xml",
        "gif": "image/gif",
        "jpeg": "image/jpeg",
        "jpg": "image/jpeg",
        "js": "application/javascript",
        "atom": "application/atom+xml",
        "rss": "application/rss+xml",
        "mml": "text/mathml",
        "txt": "text/plain",
        "jad": "text/vnd.sun.j2me.app-descriptor",
        "wml": "text/vnd.wap.wml",
        "htc": "text/x-component",
        "png": "image/png",
        "tif": "image/tiff",
        "tiff": "image/tiff",
        "wbmp": "image/vnd.wap.wbmp",
        "ico": "image/x-icon",
        "jng": "image/x-jng",
        "bmp": "image/x-ms-bmp",
        "svg": "image/svg+xml",
        "svgz": "image/svg+xml",
        "webp": "image/webp",
        "woff": "application/font-woff",
        "jar": "application/java-archive",
        "war": "application/java-archive",
        "ear": "application/java-archive",
        "json": "application/json",
        "hqx": "application/mac-binhex40",
        "doc": "application/msword",
        "pdf": "application/pdf",
        "ps": "application/postscript",
        "eps": "application/postscript",
        "ai": "application/postscript",
        "rtf": "application/rtf",
        "m3u8": "application/vnd.apple.mpegurl",
        "xls": "application/vnd.ms-excel",
        "eot": "application/vnd.ms-fontobject",
        "ppt": "application/vnd.ms-powerpoint",
        "wmlc": "application/vnd.wap.wmlc",
        "kml": "application/vnd.google-earth.kml+xml",
        "kmz": "application/vnd.google-earth.kmz",
        "7z": "application/x-7z-compressed",
        "cco": "application/x-cocoa",
        "jardiff": "application/x-java-archive-diff",
        "jnlp": "application/x-java-jnlp-file",
        "run": "application/x-makeself",
        "pl": "application/x-perl",
        "pm": "application/x-perl",
        "prc": "application/x-pilot",
        "pdb": "application/x-pilot",
        "rar": "application/x-rar-compressed",
        "rpm": "application/x-redhat-package-manager",
        "sea": "application/x-sea",
        "swf": "application/x-shockwave-flash",
        "sit": "application/x-stuffit",
        "tcl": "application/x-tcl",
        "tk": "application/x-tcl",
        "der": "application/x-x509-ca-cert",
        "pem": "application/x-x509-ca-cert",
        "crt": "application/x-x509-ca-cert",
        "xpi": "application/x-xpinstall",
        "xhtml": "application/xhtml+xml",
        "xspf": "application/xspf+xml",
        "zip": "application/zip",
        "bin": "application/octet-stream",
        "exe": "application/octet-stream",
        "dll": "application/octet-stream",
        "deb": "application/octet-stream",
        "dmg": "application/octet-stream",
        "iso": "application/octet-stream",
        "img": "application/octet-stream",
        "msi": "application/octet-stream",
        "msp": "application/octet-stream",
        "msm": "application/octet-stream",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "mid": "audio/midi",
        "midi": "audio/midi",
        "kar": "audio/midi",
        "mp3": "audio/mpeg",
        "ogg": "audio/ogg",
        "m4a": "audio/x-m4a",
        "ra": "audio/x-realaudio",
        "3gpp": "video/3gpp",
        "3gp": "video/3gpp",
        "ts": "video/mp2t",
        "mp4": "video/mp4",
        "mpeg": "video/mpeg",
        "mpg": "video/mpeg",
        "mov": "video/quicktime",
        "webm": "video/webm",
        "flv": "video/x-flv",
        "m4v": "video/x-m4v",
        "mng": "video/x-mng",
        "asx": "video/x-ms-asf",
        "asf": "video/x-ms-asf",
        "wmv": "video/x-ms-wmv",
        "avi": "video/x-msvideo"
    ]
    
    func fileExtension(forMimeType mimeType: String) -> String? {
        for (key, value) in mimeTypes {
            if value == mimeType {
                return key
            }
        }
        return nil
    }
    
    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        
        return "application/octet-stream"
    }
    
}

extension NetworkingService {
    
    class var isConnectedToNetwork:Bool {
        get {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            
            return (isReachable && !needsConnection)
            
        }
    }
    
    private func checkInternetConnectionReachable() {
        
        let isReachable = NetworkingService.isConnectedToNetwork
        
        if isReachable != previousInternetConnectionReachability {
            
            internetConnectionReachableHandler?(isReachable)
            
        }
        
    }
    
}

extension NetworkingService {
    
    private func prepare() {
        
        let config = URLSessionConfiguration.ephemeral
        
        #if os(tvOS)
        if #available(tvOS 11.0, *) {
            config.waitsForConnectivity = true
        }
        #endif
        
        #if os(iOS)
        if #available(iOS 11.0, *) {
            config.waitsForConnectivity = true
        }
        #endif
        
        config.allowsCellularAccess = true
        
        session = URLSession.init(configuration: config, delegate: self, delegateQueue: nil)
        
    }
    
    private func invalidate() {
        
        session?.invalidateAndCancel()
        
    }
    
}

extension NetworkingService {
    
    private var urlError:Error {
        get {
            return generateError(code: 0, description: "Url invalid")
        }
    }
    
    private func generateError(code:Int, description:String) -> Error {
        
        return NSError.init(domain: "NetworkingService",
                            code: code,
                            userInfo: [NSLocalizedDescriptionKey :  NSLocalizedString("Fail", value: description, comment: "")])
        
    }
    
}

extension NetworkingService {
    
    func removeAllTasks() {
        
        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                item.cancel()
            }
        })
        
    }
    
    func removeAllRequestTasks() {
        
        session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            for item in dataTasks {
                item.cancel()
            }
        })
        
    }
    
    func removeAllDownloadFileTasks() {
        
        session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            for item in downloadTasks {
                item.cancel()
            }
        })
        
    }
    
    func removeTasks(containingPath path:String) {
        
        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                if let url = item.originalRequest?.url {
                    if url.absoluteString.contains(path) == true {
                        item.cancel()
                    }
                }
            }
        })
        
    }
    
}

extension NetworkingService {
    
    func file(url: String,
              inPathParameters pathParameters: [String:String]? = nil,
              inBodyParameters bodyParameters: [String:Any]? = nil,
              completion: ((_ error:Error?, _ fileUrl:URL?, _ mimeType:String?)->())? = nil,
              progress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        var jsonData:Data?
        
        if let bodyParameters = bodyParameters {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch {
                DispatchQueue.main.async {
                    completion?(error, nil, .none)
                }
                return
            }
        }
        
        file(url: url,
             inPathParameters: pathParameters,
             body: jsonData,
             mimeType: .json,
             completion: completion,
             progress: progress)
        
    }
    
    func file(url: String,
              inPathParameters pathParameters: [String:String]? = nil,
              body: Data? = nil,
              mimeType: NetworkingServiceMimeType = .json,
              completion: ((_ error:Error?, _ fileUrl:URL?, _ mimeType:String?)->())? = nil,
              progress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        if let cachedUrl = downloadCache.object(forKey: url as NSString) {
            completion?(nil, URL.init(fileURLWithPath: cachedUrl as String), mimeTypeForPath(path: cachedUrl as String))
            return
        }
        
        checkInternetConnectionReachable()
        
        guard let url = URL(string: add(toPath: url, parameters: pathParameters)) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, .none)
            }
            return
        }
        
        var request = URLRequest.init(url: url)
        request.setValue(mimeType.rawValue, forHTTPHeaderField: NetworkingServiceHeaderType.content.rawValue)
        
        addHeaderToRequest(&request)
        
        if let body = body {
            request.httpBody = body
        }
        
        let task = session?.downloadTask(with: request)
        
        let completion:((Any?, URLResponse?, Error?)->()) = { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion?(error, nil, .none)
                }
                return
            }
            
            guard let fileUrl = data as? URL else {
                DispatchQueue.main.async {
                    completion?(self.generateError(code: 0, description: "Saved path is wrong!"), nil, .none)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion?(self.generateError(code: 0, description: "HTTP request error"), fileUrl, .none)
                }
                return
            }
            
            let mimeType = httpResponse.mimeType ?? ""
            
            do {
                
                let documentsURL = try FileManager.default.url(for: .cachesDirectory,
                                                               in: .userDomainMask,
                                                               appropriateFor: nil,
                                                               create: true)
                
                let savedURL = documentsURL.appendingPathComponent(fileUrl.lastPathComponent)
                
                try FileManager.default.moveItem(at: fileUrl, to: savedURL)
                
                self.downloadCache.setObject(savedURL.path as NSString, forKey: url.absoluteString as NSString)

                DispatchQueue.main.async {
                    completion?(nil, savedURL, mimeType)
                }
                
                return
                
            } catch {
                
                DispatchQueue.main.async {
                    completion?(error, nil, mimeType)
                }
                
                return
                
            }
            
        }
        
        if let task = task {
            let handler = NetworkingServiceTaskHandlersContainer.init()
            handler.receiveProgress = progress
            handler.completion = completion
            tasksHandlers[task] = handler
        }
        
        task?.resume()
        
    }
    
    func connect(type: NetworkingServiceRestType,
                 url: String,
                 inPathParameters pathParameters: [String:String]? = nil,
                 inBodyParameters bodyParameters: [String:Any]? = nil,
                 completion: ((_ error:Error?, _ data:Data?, _ mimeType:NetworkingServiceMimeType?)->())?,
                 sendProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil,
                 receiveProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        var jsonData:Data?
        
        if let bodyParameters = bodyParameters {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch {
                DispatchQueue.main.async {
                    completion?(error, nil, .none)
                }
                return
            }
        }
        
        connect(type: type,
                url: url,
                inPathParameters: pathParameters,
                body: jsonData,
                mimeType: .json,
                completion: completion,
                sendProgress: sendProgress,
                receiveProgress: receiveProgress)
        
    }
    
    func connect(type: NetworkingServiceRestType,
                 url: String,
                 inPathParameters pathParameters: [String:String]? = nil,
                 body: Data? = nil,
                 mimeType: NetworkingServiceMimeType = .json,
                 completion: ((_ error:Error?, _ data:Data?, _ mimeType:NetworkingServiceMimeType?)->())?,
                 sendProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil,
                 receiveProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        guard let url = URL(string: add(toPath: url, parameters: pathParameters)) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, .none)
            }
            return
        }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = type.rawValue
        request.setValue(mimeType.rawValue, forHTTPHeaderField: NetworkingServiceHeaderType.content.rawValue)
        
        addHeaderToRequest(&request)
        
        if let body = body {
            request.httpBody = body
        }
        
        let task = session?.dataTask(with: request)
        
        let completion:((Any?, URLResponse?, Error?)->()) = { data, response, error in
            self.process(data: data as? Data, response: response, error: error, completion: completion)
        }
        
        if let task = task {
            let handler = NetworkingServiceTaskHandlersContainer.init()
            handler.sendProgress = sendProgress
            handler.receiveProgress = receiveProgress
            handler.completion = completion
            tasksHandlers[task] = handler
        }
        
        task?.resume()
        
    }
    
    func connect(url: String,
                 image: UIImage,
                 imageParameterName: String,
                 inPathParameters pathParameters: [String:String]? = nil,
                 inBodyParameters bodyParameters: [String:Any]? = nil,
                 completion: ((_ error:Error?, _ data:Data?, _ mimeType:NetworkingServiceMimeType?)->())?,
                 sendProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil,
                 receiveProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        guard let imageData = image.pngData() else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, description: "Image is empty"), nil, .none)
            }
            return
        }
        
        connect(url: url,
                fileData: imageData,
                fileName: "photo.png",
                fileParameterName: imageParameterName,
                fileMimeType: .png,
                inPathParameters: pathParameters,
                inBodyParameters: bodyParameters,
                completion: completion,
                sendProgress: sendProgress,
                receiveProgress: receiveProgress)
        
    }
    
    func connect(url: String,
                 jsonObject: Any,
                 jsonPropertyName: String,
                 inPathParameters pathParameters: [String:String]? = nil,
                 inBodyParameters bodyParameters: [String:Any]? = nil,
                 completion: ((_ error:Error?, _ data:Data?, _ mimeType:NetworkingServiceMimeType?)->())?,
                 sendProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil,
                 receiveProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        var jsonData: Data?
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, description: "Create json file fail"), nil, .none)
            }
            return
        }
        
        guard let data = jsonData else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, description: "Create json file fail"), nil, .none)
            }
            return
        }
        
        connect(url: url,
                fileData: data,
                fileName: "file.json",
                fileParameterName: jsonPropertyName,
                fileMimeType: .json,
                inPathParameters: pathParameters,
                inBodyParameters: bodyParameters,
                completion: completion,
                sendProgress: sendProgress,
                receiveProgress: receiveProgress)
        
    }
    
    func connect(url: String,
                 fileData: Data,
                 fileName: String,
                 fileParameterName: String,
                 fileMimeType: NetworkingServiceMimeType,
                 inPathParameters pathParameters: [String:String]? = nil,
                 inBodyParameters bodyParameters: [String:Any]? = nil,
                 completion: ((_ error:Error?, _ data:Data?, _ mimeType:NetworkingServiceMimeType?)->())?,
                 sendProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil,
                 receiveProgress: ((_ part:Int64?, _ total:Int64?)->())? = nil) {
        
        guard let url = URL(string: add(toPath: url, parameters: pathParameters)) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, .none)
            }
            return
        }
        
        var request = createMultipartRequest(url: url,
                                             inBodyParameters: bodyParameters,
                                             fileData: fileData,
                                             fileName: fileName,
                                             fileParameterName: fileParameterName,
                                             fileMimeType: fileMimeType)
        
        addHeaderToRequest(&request)
        
        let task = session?.dataTask(with: request)
        
        let completion:((Any?, URLResponse?, Error?)->()) = { data, response, error in
            self.process(data: data as? Data, response: response, error: error, completion: completion)
        }
        
        if let task = task {
            let handler = NetworkingServiceTaskHandlersContainer.init()
            handler.sendProgress = sendProgress
            handler.receiveProgress = receiveProgress
            handler.completion = completion
            tasksHandlers[task] = handler
        }
        
        task?.resume()
        
    }
    
}

extension NetworkingService {
    
    private func addHeaderToRequest(_ request: inout URLRequest) {
        
        var needLocale:String?
        
        if let locale = self.locale {
            needLocale = locale()
        }
        
        request.setValue(needLocale, forHTTPHeaderField: NetworkingServiceHeaderType.locale.rawValue)
        
        var needAuthorization:String?
        
        if let authorization = self.authorization {
            needAuthorization = authorization()
        }
        
        request.setValue(needAuthorization, forHTTPHeaderField: NetworkingServiceHeaderType.authorization.rawValue)
        
    }
    
    private func add(toPath path: String, parameters:[String:String]?) -> String{
        
        var newPath = path
        
        if let parameters = parameters {
            for (index, item) in parameters.enumerated() {
                newPath +=  index == 0 ? "?" : "&"
                newPath += item.key
                newPath += "="
                newPath += item.value
            }
        }
        
        return newPath
        
    }
    
    private func process(data:Data?,
                         response:URLResponse?,
                         error:Error?,
                         completion: ((Error?, Data?, NetworkingServiceMimeType?)->())?) {
        
        checkInternetConnectionReachable()
        
        if let error = error {
            DispatchQueue.main.async {
                completion?(error, data, .none)
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, description: "HTTP request error"), data, .none)
            }
            return
        }
        
        let mimeType = NetworkingServiceMimeType.init(rawValue: httpResponse.mimeType ?? "")
        let statusCode = httpResponse.statusCode
        
        if !(200...299).contains(statusCode) {
            if statusCode == 401 {
                self.authoriationErrorHandler?()
            }
            DispatchQueue.main.async {
                completion?(self.generateError(code: statusCode, description: "Unknown error"), data, mimeType)
            }
            return
        } else {
            DispatchQueue.main.async {
                completion?(nil, data, mimeType)
            }
            return
        }
        
    }
    
    private func createMultipartRequest(url: URL,
                                        inBodyParameters bodyParameters: [String:Any]? = nil,
                                        fileData: Data,
                                        fileName: String,
                                        fileParameterName: String,
                                        fileMimeType: NetworkingServiceMimeType) -> URLRequest {
        
        let appendString:(_ data: inout Data,_ string: String)->() = { data, string in
            if let stringData = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                data.append(stringData)
            }
        }
        
        var body = Data()
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if let bodyParameters = bodyParameters {
            for (key, value) in bodyParameters {
                
                var parse:((String, Any)->([[String:Any]])) = {key, value in return Array.init()}
                
                parse = { key, value in
                    
                    var items:[[String:Any]] = Array.init()
                    
                    if let dictionary = value as? Dictionary<String, Any> {
                        for (key2, value2) in dictionary {
                            items += parse(key+"[\(key2)]", value2)
                        }
                    } else if let array = value as? Array<Any> {
                        for i in 0..<array.count {
                            items += parse(key+"[\(i)]", array[i])
                        }
                    } else {
                        var keyValue:[String:Any] = Dictionary.init()
                        keyValue[key] = value
                        items.append(keyValue)
                    }
                    
                    return items
                    
                }
                
                for item in parse(key, value) {
                    for (key, value) in item {
                        appendString(&body, boundaryPrefix)
                        appendString(&body, "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                        appendString(&body, "\(value)\r\n")
                    }
                }
                
            }
        }
        
        
        appendString(&body, boundaryPrefix)
        appendString(&body, "Content-Disposition: form-data; name=\"\(fileParameterName)\"; filename=\"\(fileName)\"\r\n")
        appendString(&body, "Content-Type: \(fileMimeType.rawValue)\r\n\r\n")
        body.append(fileData)
        appendString(&body, "\r\n")
        appendString(&body, "--".appending(boundary.appending("--")))
        
        var request = URLRequest.init(url: url)
        request.httpMethod = NetworkingServiceRestType.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return request
        
    }
    
}

extension NetworkingService: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        guard let handlers = tasksHandlers[task] else {
            return
        }
        
        handlers.sendProgress?(task.countOfBytesSent, task.countOfBytesExpectedToSend)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if task is URLSessionDownloadTask {
            return
        }
        
        guard let handlers = tasksHandlers[task] else {
            return
        }
        
        handlers.completion?(handlers.data, task.response, error)
        
        tasksHandlers.removeValue(forKey: task)
        
    }
    
}

extension NetworkingService: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let handlers = tasksHandlers[dataTask] else {
            return
        }
        
        if handlers.data == nil {
            handlers.data = Data.init()
        }
        
        handlers.data?.append(data)
        
        if let response = dataTask.response {
            handlers.receiveProgress?(Int64(handlers.data?.count ?? 0), (response.expectedContentLength == -1 ? 0 : response.expectedContentLength))
        }
        
    }
    
}

extension NetworkingService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let handlers = tasksHandlers[downloadTask] else {
            return
        }
        
        handlers.completion?(location, downloadTask.response, downloadTask.error)
        
        tasksHandlers.removeValue(forKey: downloadTask)
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let handlers = tasksHandlers[downloadTask] else {
            return
        }
        
        handlers.receiveProgress?(totalBytesWritten, totalBytesExpectedToWrite)
        
    }
    
}

