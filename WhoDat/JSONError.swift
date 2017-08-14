//
//  JSONError.swift
//  WhoDat
//
//  Created by Apple on 23/07/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation

enum JSONError: Error {
    case requestFailed
    case responseUnsuccessful
    case invalidData
    case jsonConversionFailure
}
