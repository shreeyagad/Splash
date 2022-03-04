//
//  RoutePickerCardView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//

import SwiftUI

struct RoutePickerCardView: View {
    let route: Route
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4).foregroundColor(.white)
            
            HStack {
                Label(route.name ?? "", systemImage: "map").padding(4)
                Spacer()
            }
        }
            .fixedSize(horizontal: false, vertical: true)
    }
}
