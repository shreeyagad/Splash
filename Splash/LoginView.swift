//
//  LoginView.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var username: String
    
    var body: some View {
        ZStack {
            Image("Splash").resizable()
                .frame(width: 350, height: 350).opacity(1).offset(x: 0, y: -50)
            VStack {
                Text("Splash").font(.system(.title, design: .rounded)).fontWeight(.bold).foregroundColor(.white).offset(x: 0, y: -50)
                Text("Hoboken").font(.system(.caption2, design: .rounded)).foregroundColor(.white).offset(x: 0, y: -50)
            }
            VStack {
                Spacer()
                FBLoginView(username: $username).frame(width: 200, height: 50).environmentObject(viewRouter).padding([.bottom], 150)
            }
        }    }
}

