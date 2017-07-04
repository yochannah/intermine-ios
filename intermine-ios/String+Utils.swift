//
//  File.swift
//  intermine-ios
//
//  Created by Nadia on 5/9/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    public static func localize(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    public static func localizeWithArg(_ key: String, arg: String) -> String {
        return String(format: NSLocalizedString(key, comment: ""), arg)
    }
    
    static func findMatches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    static func formStringWithBoldText(boldText: String, separatorText: String, normalText: String) -> NSMutableAttributedString {
        let attributedString = String.makeBold(text: boldText.capitalized)
        let separator = NSMutableAttributedString(string: separatorText)
        let normal = NSMutableAttributedString(string: normalText.capitalized)
        attributedString.append(separator)
        attributedString.append(normal)
        return attributedString
    }
    
    static func makeBold(text: String) -> NSMutableAttributedString {
        let boldAttrs = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)]
        return NSMutableAttributedString(string: text, attributes: boldAttrs)
    }

    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isEqualTo(comparedTo: String?) -> Bool {
        if comparedTo != nil {
            return self == comparedTo
        }
        return false
    }
    

    func isAboveVersion(version: String) -> Bool {
        
        // TODO: - to remove if not used
        // compares versions with format x.x.x
        // "1.7.1".isAboveVersion(version: "1.6.6") -> True
        // "1.6.6".isAboveVersion(version: "1.7.1") -> False
        
        let baseArray = self.components(separatedBy: ".")
        let arrayToCompare = version.components(separatedBy: ".")
        assert(baseArray.count == arrayToCompare.count)
        for i in 0..<baseArray.count {
            if let baseElem = Int(baseArray[i]), let comparedElem = Int(arrayToCompare[i]) {
                if baseElem >= comparedElem {
                    return true
                }
            }
        }
        return false
    }
}
