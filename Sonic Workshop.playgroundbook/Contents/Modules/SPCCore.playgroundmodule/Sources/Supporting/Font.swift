//
//  Font.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit

/// An enumeration of the different fonts you may use.
///
/// Some examples include: Academy Engraved LET, Arial, Arial Rounded MT Bold, Avenir, Avenir Next, Avenir Next Condensed, Baskerville, Bodoni 72, Bradley Hand, Chalkboard SE, Chalkduster, Cochin, Copperplate, Courier, Courier New, Didot, Futura, Optima, Palatino, Verdana, and Zapfino.
///
/// - localizationKey: Font
public enum Font: String {

    case AcademyEngravedLET = "Academy Engraved LET"
    case AmericanTypewriter = "American Typewriter"
    case Arial = "Arial"
    case ArialRoundedMTBold = "Arial Rounded MT Bold"
    case Avenir = "Avenir"
    case AvenirNext = "Avenir Next"
    case AvenirNextCondensed = "Avenir Next Condensed"
    case Baskerville = "Baskerville"
    case Bodoni72 = "Bodoni 72"
    case BradleyHand = "Bradley Hand"
    case ChalkboardSE = "Chalkboard SE"
    case ChalkDuster = "Chalkduster"
    case Cochin = "Cochin"
    case Copperplate = "Copperplate"
    case Courier = "Courier"
    case CourierNew = "Courier New"
    case Didot = "Didot"
    case Futura = "Futura"
    case Georgia = "Georgia"
    case GillSans = "Gill Sans"
    case Helvetica = "Helvetica"
    case HelveticaNeue = "Helvetica Neue"
    case Impact = "Impact"
    case MarkerFelt = "Marker Felt"
    case Menlo = "Menlo"
    case Noteworthy = "Noteworthy"
    case Optima = "Optima"
    case Palatino = "Palatino"
    case Papyrus = "Papyrus"
    case PartyLET = "Party LET"
    case SavoyeLET = "Savoye LET"
    case SnellRoundhand = "Snell Roundhand"
    case Superclarendon = "Superclarendon"
    case TimesNewRoman = "Times New Roman"
    case TrebuchetMS = "Trebuchet MS"
    case Verdana = "Verdana"
    case Zapfino = "Zapfino"
    
    // System Fonts
    case SystemFontUltraLight = "System-0.80"
    case SystemFontThin = "System-0.60"
    case SystemFontLight = "System-0.40"
    case SystemFontRegular = "System0.00"
    case SystemFontMedium = "System0.23"
    case SystemFontSemibold = "System0.30"
    case SystemFontBold = "System0.40"
    case SystemFontHeavy = "System0.56"
    case SystemFontBlack = "System0.62"
    case SystemItalic = "SystemItalic"
    case SystemBoldItalic = "SystemBoldItalic"
    case SystemHeavyItalic = "SystemHeavyItalic"
    
    // Localization Fonts
    case PingFangSC = "Ping Fang SC"
    case PingFangTC = "Ping Fang TC"
    case AppleSDGothicNeo = "Apple SD Gothic Neo"
    case HiraginoMinchoProN = "Hiragino Mincho Pro N"
    case HiraginoSans = "Hiragino Sans"
    case Thonburi = "Thonburi"
}


public extension UIFont {
    var bold: UIFont {
        return with(traits: .traitBold)
    }
    
    var italic: UIFont {
        return with(traits: .traitItalic)
    }
    
    var boldItalic: UIFont {
        return with(traits: [.traitBold, .traitItalic])
    }
    
    
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        
        return UIFont(descriptor: descriptor, size: 0)
    }
}
