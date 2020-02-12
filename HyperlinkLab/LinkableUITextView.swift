//
//  LinkableUITextView.swift
//  HyperlinkLab
//
//  Created by wizard on 2/6/20.
//  Copyright © 2020 wizard. All rights reserved.
//

import UIKit

class TextLink {
    var text = ""
    var url = ""
    var range = NSRange( location:0, length:0 )
    var activeHyperlinkAttributes:[ NSAttributedString.Key:Any ] = [:]
    var inactiveHyperlinkAttributes:[ NSAttributedString.Key:Any ] = [:]
}

@IBDesignable class LinkableUITextView: UITextView {
    var linkStore:[TextLink] = []
    var attributedString = NSMutableAttributedString( string:"", attributes:nil )
    
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
    
    @IBInspectable var enabled:Bool = true {
        didSet {
            for textLink in linkStore {
                if enabled {
                    attributedString.setAttributes( activeHyperlinkAttributes, range:textLink.range )
                    attributedString.addAttribute( .link, value:textLink.url, range:textLink.range )
                } else {
                    attributedString.setAttributes( inactiveHyperlinkAttributes, range:textLink.range )
                }
            }
            text = ""
            attributedText = attributedString
            print( "### \(linkableText) ###" )
        }
    }

    var baseAttributes:[ NSAttributedString.Key:Any ]
    var activeHyperlinkAttributes:[ NSAttributedString.Key:Any ]
    var inactiveHyperlinkAttributes:[ NSAttributedString.Key:Any ]

    override func prepareForInterfaceBuilder() {
        textFont = UIFont( name:fontName, size:fontSize ) ?? UIFont.systemFont(ofSize: fontSize)
        
        baseAttributes = [
            .font:textFont as Any
        ]
        
        activeHyperlinkAttributes = [
            .font:textFont as Any,
            .foregroundColor:UIColor(named:"activeHyperlink") as Any,
            .underlineStyle:1
        ]
        
        inactiveHyperlinkAttributes = [
            .font:textFont as Any,
            .foregroundColor:UIColor(named:"inactiveHyperlink") as Any,
            .underlineStyle:1
        ]

        makeLink()
    }
    
    
    override init( frame: CGRect, textContainer: NSTextContainer? ) {
        baseAttributes = [:]
        activeHyperlinkAttributes = [:]
        inactiveHyperlinkAttributes = [:]

        super.init( frame:frame, textContainer:textContainer )

        makeLink()
    }
    
    required init?( coder:NSCoder ) {
        baseAttributes = [:]
        activeHyperlinkAttributes = [:]
        inactiveHyperlinkAttributes = [:]

        super.init( coder:coder )
 
        makeLink()
    }

    
    func makeLink() {
        var source  = linkableText
        let value = UIApplication.openSettingsURLString
        source = source.replacingOccurrences( of:"UIApplication.openSettingsURLString", with:value )

        linkStore.removeAll()
        
        attributedText = parseHyperlink( source )
        
        print( "linkStore = \(linkStore)" )
        
        for textLink in linkStore {
            print( attributedText.attributedSubstring( from:textLink.range ))
        }
        
    }
    
    
    func parseHyperlink( _ string:String ) -> NSAttributedString {
        baseAttributes = [
            .font:textFont as Any
        ]
        
        activeHyperlinkAttributes = [
            .font:textFont as Any,
            .foregroundColor:UIColor(named:"activeHyperlink") as Any,
            .underlineStyle:1
        ]
        
        inactiveHyperlinkAttributes = [
            .font:textFont as Any,
            .foregroundColor:UIColor(named:"inactiveHyperlink") as Any,
            .underlineStyle:1
        ]

        let errorStringReturn = NSAttributedString( string:string, attributes:baseAttributes )

        var position = string.startIndex
        var startText:Int = 0
        var endText:Int = 0
        var startURL:Int = 0
        var endURL:Int = 0
        var firstPart:String = ""
        var secondPart:String = ""
        var urlPart:String = ""
        
        attributedString = NSMutableAttributedString( string:"", attributes:baseAttributes )
        
        var done = false

        while (!done) {
            var occurance = "<a "
            if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1

                firstPart = String( string[position..<range.lowerBound] )
                
                guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                      return errorStringReturn
                }
                position = string.index( after:after )
            } else {
                firstPart = String( string[position..<string.endIndex] )
                done = true
            }
            
            if( !done ) {
                // TODO: Make Delimiter tolerant of single and double quotes
                occurance = "href='"
                if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                    startURL = string.distance( from:string.startIndex, to:range.upperBound )
                    let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1
                    
                    guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                            return errorStringReturn
                        }
                    position = string.index( after:after )
                } else {
                    done = true
                }
            }

            if( !done ) {
                // TODO: Make Delimiter tolerant of single and double quotes
                occurance = "'"
                if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                    endURL = string.distance( from:string.startIndex, to:range.lowerBound ) - 1
                    let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1

                    urlPart = String( string[ string.index(string.startIndex, offsetBy:startURL )...string.index(string.startIndex, offsetBy:endURL ) ] )
                    
                    guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                        return errorStringReturn
                    }
                    position = string.index( after:after )
                } else {
                    done = true
                }
            }

            if( !done ) {
                occurance = ">"
                if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                    startText = string.distance( from:string.startIndex, to:range.lowerBound ) + 1
                    let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1
                    
                    guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                        return errorStringReturn
                    }
                    position = string.index( after:after )
                } else {
                    done = true
                }
            }

            if( !done ) {
                occurance = "</a>"
                if let range = string.range( of:occurance, options: .caseInsensitive, range:position..<string.endIndex ) {
                    let start = string.distance( from:string.startIndex, to:range.lowerBound )
                    endText = start - 1
                    let offset = occurance.distance( from:occurance.startIndex, to:occurance.endIndex ) - 1

                    guard let after = string.index( range.lowerBound, offsetBy:offset, limitedBy:string.endIndex ) else {
                         return errorStringReturn
                    }
                    position = string.index( after:after )
     
                    secondPart = String( string[ string.index(string.startIndex, offsetBy:startText )...string.index(string.startIndex, offsetBy:endText ) ] )

                } else {
                    done = true
                }
            }

            print( "urlPart = \(urlPart)")
            attributedString.append( NSAttributedString( string:firstPart, attributes:baseAttributes ) )
        
            var linkPart = NSMutableAttributedString( string:secondPart, attributes:activeHyperlinkAttributes )
            if enabled {
                linkPart.addAttribute( .link, value:urlPart, range:NSRange( location:0, length:secondPart.count ) )
            } else {
                linkPart = NSMutableAttributedString( string:secondPart, attributes:inactiveHyperlinkAttributes )
            }
            

            if(( secondPart != "" ) && (urlPart != "" )) {
                let range = NSRange( location:attributedString.string.count, length:secondPart.count )
                let textLink = TextLink()
                textLink.text  = secondPart
                textLink.url   = urlPart
                textLink.range = range
                textLink.activeHyperlinkAttributes = activeHyperlinkAttributes
                textLink.inactiveHyperlinkAttributes = inactiveHyperlinkAttributes
                linkStore.append( textLink)
            }
            
            attributedString.append( linkPart )
            
            firstPart = ""
            secondPart = ""
            urlPart = ""
        }
        
        let returnString:NSAttributedString = attributedString
        return returnString
    }

}
