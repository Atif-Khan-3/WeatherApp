//
//  testCaseLiveActivity.swift
//  testCase
//
//  Created by Atif Khan  on 10/07/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct testCaseAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct testCaseLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: testCaseAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension testCaseAttributes {
    fileprivate static var preview: testCaseAttributes {
        testCaseAttributes(name: "World")
    }
}

extension testCaseAttributes.ContentState {
    fileprivate static var smiley: testCaseAttributes.ContentState {
        testCaseAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: testCaseAttributes.ContentState {
         testCaseAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: testCaseAttributes.preview) {
   testCaseLiveActivity()
} contentStates: {
    testCaseAttributes.ContentState.smiley
    testCaseAttributes.ContentState.starEyes
}
