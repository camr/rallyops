# Theme Design System

The rallyops app uses a cohesive design system defined in `AppTheme.swift` to ensure visual consistency across all views.

## Colors

All colors are defined in `AppTheme.Colors` and automatically adapt to light/dark mode.

### Brand Colors

```swift
AppTheme.Colors.accent          // Teal (0.26, 0.55, 0.55) - Primary brand color
AppTheme.Colors.accentLight     // 15% opacity teal - Subtle highlights
```

### Text Colors

```swift
AppTheme.Colors.textPrimary     // Color.primary - Adapts to system theme
AppTheme.Colors.textSecondary   // Color.secondary - Muted text
```

### Semantic Colors

```swift
AppTheme.Colors.success         // Green (0.2, 0.65, 0.4) - Success states
AppTheme.Colors.warning         // Orange (0.85, 0.55, 0.2) - Warning states
```

### Surface Colors

These colors automatically adapt to the platform and light/dark mode:

```swift
AppTheme.Colors.background      // System grouped background
AppTheme.Colors.card            // Secondary grouped background
AppTheme.Colors.cardStroke      // Separator color for borders
```

**Platform-specific behavior:**
- **iOS:** Uses `UIColor.systemGroupedBackground` and `secondarySystemGroupedBackground`
- **macOS:** Uses `NSColor.windowBackgroundColor` and `controlBackgroundColor`

## Typography

All typography uses rounded system fonts with semantic weights.

### Type Scale

```swift
AppTheme.Typography.largeTitle   // Large title, bold rounded
AppTheme.Typography.title        // Title, semibold rounded
AppTheme.Typography.title2       // Title 2, semibold rounded
AppTheme.Typography.title3       // Title 3, medium rounded
AppTheme.Typography.headline     // Headline, semibold
AppTheme.Typography.body         // Body text, regular
AppTheme.Typography.callout      // Callout, regular
AppTheme.Typography.caption      // Caption, regular
AppTheme.Typography.sectionHeader // Caption, semibold uppercase
```

### Design Choices

- **Large titles and titles** use `.rounded` design for a friendly, approachable feel
- **Body text** uses default design for optimal readability
- **Section headers** are uppercase with letter-spacing for hierarchy

## Spacing

Consistent spacing scale for padding, margins, and gaps:

```swift
AppTheme.Spacing.xs    // 4pt - Tight spacing
AppTheme.Spacing.sm    // 8pt - Small gaps
AppTheme.Spacing.md    // 16pt - Standard spacing
AppTheme.Spacing.lg    // 24pt - Large spacing
AppTheme.Spacing.xl    // 32pt - Extra large spacing
```

## Corner Radius

```swift
AppTheme.Radius.sm    // 8pt - Buttons, small elements
AppTheme.Radius.md    // 12pt - Cards, standard UI
AppTheme.Radius.lg    // 16pt - Large containers
```

## View Modifiers

### Card Style

Creates a consistent card appearance with padding, background, rounded corners, and stroke.

```swift
// Usage
VStack {
    Text("Content")
}
.cardStyle()

// Equivalent to:
content
    .padding(AppTheme.Spacing.md)
    .background(AppTheme.Colors.card)
    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    .overlay(
        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
            .stroke(AppTheme.Colors.cardStroke, lineWidth: 0.5)
    )
```

### Section Header Style

Formats text as an uppercase section header with accent color and letter-spacing.

```swift
// Usage
Text("Milestones")
    .sectionHeaderStyle()

// Equivalent to:
content
    .font(AppTheme.Typography.sectionHeader)
    .foregroundStyle(AppTheme.Colors.accent)
    .textCase(.uppercase)
    .tracking(0.8)
```

## Usage Examples

### Creating a Card

```swift
VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
    Text("Milestone Name")
        .font(AppTheme.Typography.headline)

    Text("Due: March 15, 2024")
        .font(AppTheme.Typography.caption)
        .foregroundStyle(AppTheme.Colors.textSecondary)
}
.cardStyle()
```

### Section with Header

```swift
VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
    Text("Upcoming Actions")
        .sectionHeaderStyle()

    ForEach(actions) { action in
        ActionRow(action: action)
    }
}
```

### Custom Spacing

```swift
VStack(spacing: AppTheme.Spacing.lg) {
    HeaderView()
    ContentView()
    FooterView()
}
.padding(AppTheme.Spacing.md)
```

## Design Principles

1. **Consistency** — Use theme tokens instead of hard-coded values
2. **Adaptability** — Colors automatically adjust to light/dark mode
3. **Hierarchy** — Typography and spacing create clear visual hierarchy
4. **Platform-aware** — Surface colors respect platform conventions

## Extending the Theme

When adding new UI elements:

1. Use existing theme tokens where possible
2. Add new semantic tokens to `AppTheme` if needed
3. Prefer view modifiers for reusable patterns
4. Document new additions in this file
