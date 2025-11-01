//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

private let TITLE_KEY = "title"
private let URL_KEY = "url"
private let DATE_STRING_KEY = "dateString"
private let TIME_STRING_KEY = "timeString"

class THMemo: NSObject, NSCoding {

    let title: String
    let url: URL
    let dateString: String
    let timeString: String

    class func memo(title: String, url: URL) -> THMemo {
        return THMemo(title: title, url: url)
    }

    init(title: String, url: URL) {
        self.title = title
        self.url = url

        let date = Date()
        self.dateString = THMemo.dateString(date: date)
        self.timeString = THMemo.timeString(date: date)

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: TITLE_KEY)
        coder.encode(url, forKey: URL_KEY)
        coder.encode(dateString, forKey: DATE_STRING_KEY)
        coder.encode(timeString, forKey: TIME_STRING_KEY)
    }

    required init?(coder decoder: NSCoder) {
        guard let title = decoder.decodeObject(forKey: TITLE_KEY) as? String,
              let url = decoder.decodeObject(forKey: URL_KEY) as? URL,
              let dateString = decoder.decodeObject(forKey: DATE_STRING_KEY) as? String,
              let timeString = decoder.decodeObject(forKey: TIME_STRING_KEY) as? String else {
            return nil
        }

        self.title = title
        self.url = url
        self.dateString = dateString
        self.timeString = timeString

        super.init()
    }

    private class func dateString(date: Date) -> String {
        let formatter = self.formatter(template: "MMddyyyy")
        return formatter.string(from: date)
    }

    private class func timeString(date: Date) -> String {
        let formatter = self.formatter(template: "HHmmss")
        return formatter.string(from: date)
    }

    private class func formatter(template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let format = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        formatter.dateFormat = format
        return formatter
    }

    func deleteMemo() -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("Unable to delete: \(error.localizedDescription)")
            return false
        }
    }
}
