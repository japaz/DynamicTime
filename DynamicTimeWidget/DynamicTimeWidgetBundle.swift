//
//  DynamicTimeWidgetBundle.swift
//  DynamicTimeWidget
//
//  Created by Alberto Paz on 19/4/25.
//

import WidgetKit
import SwiftUI

@main
struct DynamicTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        DynamicTimeWidget()
        DynamicTimeWidgetControl()
        DynamicTimeWidgetLiveActivity()
    }
}
