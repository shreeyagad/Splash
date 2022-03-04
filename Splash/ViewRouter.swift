//
//  ViewRouter.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//

import Foundation
import SwiftUI

class ViewRouter: ObservableObject {
    
    @Published var currentPage: Page = .signInPage
}

enum Page {
    case signInPage
    case homePage
}

