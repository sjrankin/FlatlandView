//
//  AppIntent.swift
//  FlatlandView Widget
//
//  Created by Stuart Rankin on 9/26/23.
//  Copyright © 2023 Stuart Rankin. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
