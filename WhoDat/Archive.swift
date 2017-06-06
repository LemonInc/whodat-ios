////
////  Archive.swift
////  WhoDat
////
////  Created by Alan Lau on 06/06/2017.
////  Copyright © 2017 WotDat. All rights reserved.
////
//
//import Foundation
//
//func setNavigationBarStyle() {
//    
//    let navBar = self.navigationController?.navigationBar
//    
//    navBar?.isTranslucent = true
//    navBar?.setBackgroundImage(UIImage(), for: .default)
//    navBar?.shadowImage = UIImage()
//    navBar?.backgroundColor = UIColor.clear
//    
//    let colorTop = UIColor(red:0.39, green:0.84, blue:0.26, alpha:1.0).cgColor
//    let colorBottom = UIColor(red:0.17, green:0.71, blue:0.45, alpha:1.0).cgColor
//    let gradientLayer = CAGradientLayer()
//    gradientLayer.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height)
//    gradientLayer.colors = [colorTop, colorBottom]
//    gradientLayer.locations = [0.0, 1.0]
//    self.view.layer.addSublayer(gradientLayer)
//    self.view.backgroundColor = UIColor.clear
//}




//// Move view up by keyboard height when keyboard is shown
//func keyboardWillShow(_ notification: NSNotification) {
//    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//        self.view.frame.origin.y = 0
//        if self.view.frame.origin.y == 0 {
//            self.view.frame.origin.y -= keyboardSize.height
//        }
//    }
//}
//
//// Move view down by keyboard height when keyboard is hidden
//func keyboardWillHide(_ notification: NSNotification) {
//    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y += keyboardSize.height
//        }
//    }
//}
