//
//  AppTheme.swift
//  rallyops
//
//  A cohesive design system for the app.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppTheme {
    // MARK: - Colors

    enum Colors {
        static let accent = Color(red: 0.26, green: 0.55, blue: 0.55)      // Teal
        static let accentLight = Color(red: 0.26, green: 0.55, blue: 0.55).opacity(0.15)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let success = Color(red: 0.2, green: 0.65, blue: 0.4)
        static let warning = Color(red: 0.85, green: 0.55, blue: 0.2)

        /// Background that adapts to light/dark mode. White in light mode, grouped background in dark mode.
        static var background: Color {
            #if canImport(UIKit)
            Color(uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? .systemGroupedBackground
                    : .white
            })
            #else
            Color(NSColor.windowBackgroundColor)
            #endif
        }

        /// Card/section background. Adapts to light/dark mode.
        static var card: Color {
            #if canImport(UIKit)
            Color(uiColor: .secondarySystemGroupedBackground)
            #else
            Color(NSColor.controlBackgroundColor)
            #endif
        }

        /// Subtle stroke for cards. Adapts to light/dark mode.
        static var cardStroke: Color {
            #if canImport(UIKit)
            Color(uiColor: .separator)
            #else
            Color(NSColor.separatorColor)
            #endif
        }
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title, design: .rounded).weight(.semibold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.medium)
        static let headline = Font.system(.headline, design: .default).weight(.semibold)
        static let body = Font.system(.body, design: .default)
        static let callout = Font.system(.callout, design: .default)
        static let caption = Font.system(.caption, design: .default)
        static let sectionHeader = Font.system(.caption, design: .default).weight(.semibold)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.cardStroke, lineWidth: 0.5)
            )
    }
}

struct SectionHeaderStyle: ViewModifier {
    @Environment(\.appAccentColor) var accentColor

    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.sectionHeader)
            .foregroundStyle(accentColor)
            .textCase(.uppercase)
            .tracking(0.8)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}

// MARK: - Accent Color Environment

struct AppAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = AppTheme.Colors.accent
}

extension EnvironmentValues {
    var appAccentColor: Color {
        get { self[AppAccentColorKey.self] }
        set { self[AppAccentColorKey.self] = newValue }
    }
}
