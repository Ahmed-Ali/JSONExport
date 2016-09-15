//
//  NetworkRequestViewController.swift
//  JSONExport
//
//  Created by king on 16/9/15.
//  Copyright © 2016年 Ahmed Ali. All rights reserved.
//

import Cocoa
import Alamofire

class NetworkRequestViewController: NSViewController {

    override var nibName: String? {
        
        return "\(type(of: self))"
    }
    
    @IBOutlet weak var requestMethodSegmented: NSSegmentedControl!
    
    @IBOutlet weak var inputRequestAddress: NSTextField!
    
    @IBOutlet weak var requestBtn: NSButton!
    
    @IBOutlet weak var requestInfo: NSTextField!
    
    @IBOutlet var infoTextView: NSTextView!
    
    @IBOutlet weak var automaticallyCloses: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        infoTextView.font = NSFont.systemFont(ofSize: 14)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        var frame = NSScreen.main()?.visibleFrame
        frame?.size.width = 600
        frame?.size.height = 400
        view.window?.setFrame(frame!, display: true)
        view.window?.center()
        

    }
    
    @IBAction func requestClick(_ sender: NSButton) {
        
        if inputRequestAddress.stringValue.isEmpty {
            infoTextView.textColor = NSColor.red
            infoTextView.string = "Please enter the request address!"
            return
        }
        
        if inputRequestAddress.stringValue =~ "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]" {
            
            infoTextView.textColor = NSColor.black
        } else {
            infoTextView.textColor = NSColor.red
            infoTextView.string = "Request the address is not correct, please check whether the input is correct, correct format!"
            return
        }
        
        guard let url = NSURL(string: inputRequestAddress.stringValue) else { return }

        let urlstr = "\(url.scheme!)://\(url.host!)\(url.path!)"
        var parameterStr: String = ""
        var parameterDict: [String : Any]! = [:]
        
        if let parameter = url.query {
            
            let parameterArr = parameter.components(separatedBy: "&")
            
            for str in parameterArr {
                
                let strArr = str.components(separatedBy: "=")
                parameterDict[strArr.first!] = strArr.last!
                parameterStr += "    " + str.replacingOccurrences(of:
                    "=", with: "  =  ") + "\n"
            }
        }
        
        let requestMethod = requestMethodSegmented.selectedSegment == 0 ? "GET" : "POST"
        let tips = "Request Method: \(requestMethod)\n\n" + "Request Parameter: \n{\n\(parameterStr)}"
        infoTextView.string =  tips

        requestBtn.isEnabled = false
        
        if parameterDict.isEmpty {
            parameterDict = nil
        }
        Alamofire.request(urlstr, method: requestMethodSegmented.selectedSegment == 0 ? .get : .post, parameters: parameterDict)
            .responseString { [weak self] response in
                
                guard let `self` = self else { return }

                if response.result.isSuccess {
                    
                    if let str = response.result.value {
    
                        self.requestBtn.isEnabled = true
                        self.infoTextView.string = "\(tips)\n" + "\nRequest Result:\n\(str)"
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkRequestDataNotification), object: nil, userInfo: [NetworkRequestDataKey : str])
                        
                        if self.automaticallyCloses.state == 1 {
                            
                            self.view.window?.close()
                        }
                    }
                    
                } else {
                    
                    self.requestBtn.isEnabled = true
                    self.infoTextView.string = "\(tips)\n" + "\nRequest Error:\n\(response.result.error?.localizedDescription)"
                }
        }
        
    }
    
}



struct MyRegex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {

        regex = try? NSRegularExpression(pattern: pattern,
                                    options: NSRegularExpression.Options.caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,
                                                options: [],
                                                range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}

infix operator =~ {
    associativity none
    precedence 130
}

func =~ (lhs: String, rhs: String) -> Bool {
    return MyRegex(rhs).match(input: lhs)
}
