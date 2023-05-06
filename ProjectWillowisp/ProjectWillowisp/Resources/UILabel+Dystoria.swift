//
//  UILabel+Dystoria.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 10/23/21.
//

import UIKit

extension UILabel {
    convenience init(text: String? = nil, textColor: UIColor, font: UIFont) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font ?? .body1], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    func getAttributedString(input : String) -> NSMutableAttributedString {

        let matches = getURLRange(input: input)
        let attributedString = NSMutableAttributedString(string:input)

        for match in matches {
            let url = (input as NSString).substring(with: match.range)

            let linkText = NSMutableAttributedString(string:url, attributes:[NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor.systemBlue])
            attributedString.replaceCharacters(in: match.range, with: linkText)
        }

        return attributedString
    }

    func getURLRange(input : String) -> [NSTextCheckingResult] {

        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

        return matches
    }

    //function to get index Of selected Character in string
    func didTapAttributedTextInLabel(tapLocation: CGPoint) -> Int  {


        //here myLabel is the object of UILabel
        //added this from @warly's answer
        //set font of attributedText
        let attributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        attributedText.addAttributes([NSAttributedString.Key.font: self.font ?? .body2], range: NSMakeRange(0, (self.attributedText?.string.count)!))

        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: self.frame.width, height: self.frame.height+100))
        let textStorage = NSTextStorage(attributedString: attributedText)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        let labelSize = self.bounds.size
        textContainer.size = labelSize

        // get the index of character where user tapped
        let indexOfCharacter = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return indexOfCharacter
    }


    // function to check if URL is taped
    @objc func tapLabel(gesture: UITapGestureRecognizer) {

        let matches = getURLRange(input: (self.text)!)

        let tapLocation = gesture.location(in: self)

        let indexOfCharacter = didTapAttributedTextInLabel(tapLocation: tapLocation)

        for match in matches {

            if NSLocationInRange(indexOfCharacter, match.range) {

                //open selected URL
                let mainText = self.text as NSString?
                if let urlToOpen = URL(string: (mainText?.substring(with: match.range))!) {
                    UIApplication.shared.open(urlToOpen)
                } else {
                    print("We have error with URL")
                }
                break
            } else {
                print("Tapped none")
            }

        }
    }
    
    func addURLGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
}
