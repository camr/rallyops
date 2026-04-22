//
//  FirstGoalWalkthrough.swift
//  rallyops
//
//  Created by Cameron Rivers on 11/14/24.
//

import SwiftUI
import SwiftData

// MARK: - App Root

struct AppRootView: View {
    @Query private var coreValues: [CoreValue]

    @AppStorage("settings.accentColorR") private var accentR: Double = 0.26
    @AppStorage("settings.accentColorG") private var accentG: Double = 0.55
    @AppStorage("settings.accentColorB") private var accentB: Double = 0.55

    private var accentColor: Color {
        Color(red: accentR, green: accentG, blue: accentB)
    }

    var body: some View {
        Group {
            if coreValues.isEmpty {
                FirstGoalWalkthroughContainer()
            } else {
                LandingPageView()
            }
        }
        .environment(\.appAccentColor, accentColor)
        .tint(accentColor)
    }
}

// MARK: - Walkthrough Data

@Observable
class WalkthroughData {
    var valueName = "Healthy Relationships"
    var milestoneName = "Reconnect with 3 lost friends by October"
    var taskName = "Text someone I haven't talked to in a while"
    var habitName = "Reach out to someone in my contact list each week"
}

// MARK: - Walkthrough Container

struct FirstGoalWalkthroughContainer: View {
    @Environment(\.modelContext) private var context
    @State private var data = WalkthroughData()

    var body: some View {
        FirstGoalWalkthroughStart(walkthroughData: data, onComplete: persistAndFinish)
    }

    private func persistAndFinish() {
        let valueName = data.valueName.trimmingCharacters(in: .whitespaces)
        let milestoneName = data.milestoneName.trimmingCharacters(in: .whitespaces)
        let taskName = data.taskName.trimmingCharacters(in: .whitespaces)
        let habitName = data.habitName.trimmingCharacters(in: .whitespaces)

        guard !valueName.isEmpty, !milestoneName.isEmpty, !taskName.isEmpty, !habitName.isEmpty else { return }

        let coreValue = CoreValue(valueName)
        context.insert(coreValue)

        let deadline = Calendar.current.date(byAdding: .day, value: 30, to: Date.now) ?? Date.now
        let milestone = Milestone(milestoneName, deadline: deadline)
        milestone.core_value = coreValue
        coreValue.addMilestone(milestone)
        context.insert(milestone)

        let due = Calendar.current.date(byAdding: .day, value: 7, to: Date.now)
        let action = Action(taskName, due: due, milestone: milestone)
        milestone.addAction(action)
        context.insert(action)

        let habit = Habit(habitName, days: [true, true, true, true, true, true, true], time: -1)
        habit.milestone = milestone
        milestone.addHabit(habit)
        context.insert(habit)

        try? context.save()
    }
}

// MARK: - Walkthrough Steps

struct FirstGoalWalkthroughStart: View {
    @Bindable var walkthroughData: WalkthroughData
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(alignment: .center) {
                    Text(
                        """
                        Welcome to RallyOps, your personal companion for turning dreams \
                        into reality. Here, you'll set meaningful life rallyops, track \
                        important milestones, and develop powerful habits that drive \
                        you toward success.
                        """
                    )
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)

                    Text("Ready to start shaping your future?\nLet's begin!")
                        .font(AppTheme.Typography.title2)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.bottom, 50)

                    NavigationLink(
                        destination: FirstGoalWalkthroughStep1(
                            walkthroughData: walkthroughData,
                            onComplete: onComplete
                        )
                    ) {
                        Text("Start My Journey")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("onboarding-next-button")

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

struct FirstGoalWalkthroughStep1: View {
    @Bindable var walkthroughData: WalkthroughData
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("Core Value")
                .font(AppTheme.Typography.largeTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("What is a core value?")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TextField("Friendship", text: $walkthroughData.valueName)
                .padding()
                .background(AppTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .accessibilityIdentifier("onboarding-name-field")

            Spacer()

            NavigationLink(
                destination: FirstGoalWalkthroughStep2(
                    walkthroughData: walkthroughData,
                    onComplete: onComplete
                )
            ) {
                Text("Create Your First Goal")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
            }
            .buttonStyle(.borderedProminent)
            .disabled(walkthroughData.valueName.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityIdentifier("onboarding-next-button")
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

struct FirstGoalWalkthroughStep2: View {
    @Bindable var walkthroughData: WalkthroughData
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("Milestone")
                .font(AppTheme.Typography.largeTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Establish a milestone you would like to reach")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TextField("Reconnect with 3 lost friends by October", text: $walkthroughData.milestoneName)
                .padding()
                .background(AppTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .accessibilityIdentifier("onboarding-milestone-field")

            Spacer()

            NavigationLink(
                destination: FirstGoalWalkthroughStep3(
                    walkthroughData: walkthroughData,
                    onComplete: onComplete
                )
            ) {
                Text("Create a Follow Up Task")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
            }
            .buttonStyle(.borderedProminent)
            .disabled(walkthroughData.milestoneName.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityIdentifier("onboarding-next-button")
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

struct FirstGoalWalkthroughStep3: View {
    @Bindable var walkthroughData: WalkthroughData
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("One-Time Task")
                .font(AppTheme.Typography.largeTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Create a task to help you achieve your goal")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TextField("Text someone you haven't talked to in a while", text: $walkthroughData.taskName)
                .padding()
                .background(AppTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .accessibilityIdentifier("onboarding-task-field")

            Spacer()

            NavigationLink(
                destination: FirstGoalWalkthroughStep4(
                    walkthroughData: walkthroughData,
                    onComplete: onComplete
                )
            ) {
                Text("Start a beneficial habit")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
            }
            .buttonStyle(.borderedProminent)
            .disabled(walkthroughData.taskName.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityIdentifier("onboarding-next-button")
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

struct FirstGoalWalkthroughStep4: View {
    @Bindable var walkthroughData: WalkthroughData
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("Recurring Habit")
                .font(AppTheme.Typography.largeTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Start a habit that will help you achieve your goal")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TextField("Reach out to people in your contact list", text: $walkthroughData.habitName)
                .padding()
                .background(AppTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .accessibilityIdentifier("onboarding-habit-field")

            Spacer()

            Button("Get Started") {
                onComplete()
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .buttonStyle(.borderedProminent)
            .disabled(walkthroughData.habitName.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityIdentifier("onboarding-next-button")
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

#Preview("Walkthrough Step 1") {
    FirstGoalWalkthroughStep1(walkthroughData: WalkthroughData(), onComplete: {})
}

#Preview("App Root with Walkthrough") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CoreValue.self, configurations: config)
        return AppRootView().modelContainer(container)
    } catch {
        return Text("Failed to load preview")
    }
}
