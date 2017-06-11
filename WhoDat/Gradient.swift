import UIKit

extension CAGradientLayer {
    
    func backgroundGradientColor() -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        let colorTop = UIColor(red:0.39, green:0.84, blue:0.26, alpha:1.0).cgColor
        let colorBottom = UIColor(red:0.17, green:0.71, blue:0.45, alpha:1.0).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return gradientLayer
        
    }
}
