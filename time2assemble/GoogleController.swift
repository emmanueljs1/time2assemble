//
//  GoogleController.swift
//  time2assemble
//
//  Created by Hana Pearlman on 4/11/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import Foundation
import Firebase
import GoogleAPIClientForREST
import GoogleSignIn

class GoogleController {
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
}
