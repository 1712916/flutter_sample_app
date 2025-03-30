//
//  NewsWidgetBundle.swift
//  NewsWidget
//
//  Created by Vinh Ngo on 30/3/25.
//

import WidgetKit
import SwiftUI

@main
struct NewsWidgetBundle: WidgetBundle {
    var body: some Widget {
        NewsWidget()
        NewsWidgetControl()
    }
}
