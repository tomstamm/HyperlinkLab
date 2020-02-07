//
//  LinkableUITextView.swift
//  HyperlinkLab
//
//  Created by wizard on 2/6/20.
//  Copyright © 2020 wizard. All rights reserved.
//

import UIKit

@IBDesignable class LinkableUITextView: UITextView {
    
    @IBInspectable var linkableText:String = "Click <a href='https://www.google.com'>here</a> to go to link to Google." {
        didSet {
            makeLink()
        }
    }
    
    var textFont = UIFont( name:"Helvetica Neue", size:12 ) ?? UIFont.systemFont(ofSize: 12 )
    @IBInspectable var fontName:String = "Helvetica Neue" {
        didSet {
            textFont = UIFont( name:fontName, size:fontSize ) ?? UIFont.systemFont(ofSize: fontSize)
            makeLink()
        }
    }
    
    @IBInspectable var fontSize:CGFloat = 12.0 {
        didSet {
            textFont = UIFont( name:fontName, size:fontSize ) ?? UIFont.systemFont(ofSize: fontSize)
            makeLink()
        }
    }

    
    override func prepareForInterfaceBuilder() {
        textFont = UIFont( name:fontName, size:fontSize ) ?? UIFont.systemFont(ofSize: fontSize)
        makeLink()
    }
    
    
    override init( frame: CGRect, textContainer: NSTextContainer? ) {
        super.init( frame:frame, textContainer:textContainer )

        makeLink()
    }
    
    required init?( coder:NSCoder ) {
        super.init( coder:coder )
        
        makeLink()
    }

    func makeLink() {
        attributedText = parseHyperlink( linkableText )
    }
    
    
    func parseHyperlink( _ string:String ) -> NSAttributedString {

        let baseAttributes:[ NSAttributedString.Key: Any ] = [
            .font:textFont as Any
        ]
        
        let hyperlinkAttributes:[NSAttributedString.Key : Any ] = [
            .font:textFont as Any,
            .underlineStyle:1,
        ]
        
        let errorStringReturn = NSAttributedString( string:string, attributes:baseAttributes )


        var position = string.startIndex
        var startText:Int = 0
        var endText:Int = 0
        var startURL:Int = 0
        var endURL:Int = 0
        var firstPart:String = ""
        var secondPart:String = ""
        var lastPart:String = ""
        var urlPart:String = ""
        let attributedString = NSMutableAttributedString( string:"", attributes:baseAttributes )
        
        var done = false

        while (!done) {
            var occurance = "<a "
            if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1

                firstPart = String( string[position..<range.lowerBound] )
                
                guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                     return NSAttributedString( string:"1", attributes:baseAttributes )
                     return errorStringReturn
                }
                position = string.index( after:after )
                print(" position = \(position)")
            } else {
                firstPart = String( string[position..<string.endIndex] )
                done = true
            }
            
            occurance = "href='"
            if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                startURL = string.distance( from:string.startIndex, to:range.upperBound )
                let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1
                
                guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                        return NSAttributedString( string:"2", attributes:baseAttributes )
                        return errorStringReturn
                    }
                position = string.index( after:after )
                print(" position = \(position)")
            } else {
                done = true
            }
            
            occurance = "'"
            if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                endURL = string.distance( from:string.startIndex, to:range.lowerBound ) - 1
                let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1

                urlPart = String( string[ string.index(string.startIndex, offsetBy:startURL )...string.index(string.startIndex, offsetBy:endURL ) ] )
                
                guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                    return NSAttributedString( string:"3", attributes:baseAttributes )
                    return errorStringReturn
                }
                position = string.index( after:after )
                print(" position = \(position)")
            } else {
                done = true
            }
            
            occurance = ">"
            if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                startText = string.distance( from:string.startIndex, to:range.lowerBound ) + 1
                let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1
                
                guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                    return NSAttributedString( string:"4", attributes:baseAttributes )
                    return errorStringReturn
                }
                position = string.index( after:after )
                print(" position = \(position)")
            }else {
                done = true
            }

            
            occurance = "</a>"
            if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                let start = string.distance( from:string.startIndex, to:range.lowerBound )
                endText = start - 1
                let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1

                guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                     return NSAttributedString( string:"5", attributes:baseAttributes )
                     return errorStringReturn
                }
                position = string.index( after:after )
                print(" position = \(position)")

                secondPart = String( string[ string.index(string.startIndex, offsetBy:startText )...string.index(string.startIndex, offsetBy:endText ) ] )

            } else {
                done = true
            }

            print(" string.startIndex = \(string.startIndex)")
            print(" string.endIndex = \(string.endIndex)")
            print( "[" + firstPart + secondPart + lastPart + "]" )
            print( "{" + urlPart + "}"  )
//            done = ( position >= string.endIndex )
            
            attributedString.append( NSAttributedString( string:firstPart, attributes:baseAttributes ) )
            
            let linkPart = NSMutableAttributedString( string:secondPart, attributes:hyperlinkAttributes )
            linkPart.addAttribute( .link, value:urlPart, range:NSRange(location:0, length:secondPart.count ) )
            
            attributedString.append( linkPart )
            attributedString.append( NSAttributedString( string:lastPart, attributes:baseAttributes ))
            
            firstPart = ""
            secondPart = ""
            lastPart = ""
            urlPart = ""
        }
        
        let returnString:NSAttributedString = attributedString
        return returnString
        
    }

}

extension LinkableUITextView:UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }

    func textView(_ textView:UITextView, shouldInteractWith URL:URL, in characterRange:NSRange, interaction:UITextItemInteraction ) -> Bool {
        return true
    }
}
