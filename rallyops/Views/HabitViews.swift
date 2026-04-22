//
//  HabitViews.swift
//  rallyops
//
//  Created by Cameron Rivers on 4/9/24.
//

import SwiftUI
import SwiftData

// MARK: Habit List
struct HabitListView: View {
    @Environment(\.modelContext) private var context
    let habits: [Habit]
    var emphasizeToday: Bool = false

    @State private var habitToEdit: Habit?
    @State private var habitToDelete: Habit?

    var body: some View {
        ForEach(habits) { habit in
            HabitRowView(habit: habit, emphasizeToday: emphasizeToday) {
                habitToEdit = habit
            } onDelete: {
                habitToDelete = habit
            }
        }
        .sheet(item: $habitToEdit, onDismiss: { habitToEdit = nil }) { habit in
            EditHabitView(habit: habit)
        }
        .confirmationDialog("Delete Habit", isPresented: Binding(
            get: { habitToDelete != nil },
            set: { if !$0 { habitToDelete = nil } }
        ), titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    context.delete(habit)
                    habitToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                habitToDelete = nil
            }
        } message: {
            if let habit = habitToDelete {
                Text("Are you sure you want to delete \"\(habit.name)\"? This cannot be undone.")
            }
        }
    }
}

private struct HabitRowView: View {
    @Environment(\.appAccentColor) var accentColor
    @Bindable var habit: Habit
    var emphasizeToday: Bool = false
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var isTimed: Bool { habit.time >= 0 }

    private var amPmTime: String {
        let h = habit.time / 60
        let m = habit.time % 60
        let ampm = h < 12 ? "AM" : "PM"
        let h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return String(format: "%d:%02d %@", h12, m, ampm)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isTimed {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(accentColor)
                        .frame(width: 4)

                    NavigationLink(value: habit) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(amPmTime)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(accentColor)
                            Text(habit.name)
                                .font(AppTheme.Typography.callout)
                                .lineLimit(2)
                        }
                    }
                    .accessibilityLabel(habit.name)
                    .accessibilityHint("Tap to view habit details")
                }
            } else {
                NavigationLink(value: habit) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(AppTheme.Typography.callout)
                                .lineLimit(3)

                            if let milestone = habit.milestone {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(accentColor)
                                        .frame(width: 7, height: 7)
                                    Text(milestone.name)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundStyle(accentColor)
                                        .lineLimit(1)
                                }
                            }
                        }

                        Spacer()

                        if habit.currentStreak > 0 {
                            HStack(spacing: 2) {
                                Text("\(habit.currentStreak)")
                                    .font(.caption2.weight(.bold))
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(accentColor, in: Capsule())
                            .accessibilityLabel("\(habit.currentStreak) day streak")
                        }
                    }
                }
                .accessibilityLabel(habit.name)
                .accessibilityHint("Tap to view habit details")

                HabitWeekList(habit: habit, emphasizeToday: emphasizeToday)
                    .padding(.vertical, 5)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("habit-card-\(habit.name)")
        .listRowBackground(
            Group {
                if #available(iOS 26, *) {
                    Color.clear
                        .glassEffect(in: RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                }
            }
        )
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(habit.hasCheckedIn() ? "Mark\nIncomplete" : "Mark\nComplete") {
                withAnimation {
                    habit.toggleCheckin()
                }
            }
            .tint(habit.hasCheckedIn() ? .gray : .green)
            .accessibilityLabel(habit.hasCheckedIn() ? "Mark \(habit.name) incomplete" : "Mark \(habit.name) complete")
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            .tint(.red)
            .accessibilityLabel("Delete \(habit.name)")

            Button("Edit") {
                onEdit()
            }
            .tint(.blue)
            .accessibilityLabel("Edit \(habit.name)")
        }
    }
}

// MARK: Habit Detail
struct HabitDetailView: View {
    @Bindable var habit: Habit
    @State private var showingEdit: Bool = false

    var thisWeekCheckins: Int {
        let cal = Calendar.current
        return habit.checkins.filter {
            cal.isDate($0.date, equalTo: Date.now, toGranularity: .weekOfYear)
        }.count
    }

    var scheduledDaysPerWeek: Int {
        habit.days.filter { $0 }.count
    }

    var body: some View {
        List {
            Section {
                Text(habit.name)
                    .font(AppTheme.Typography.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
            }

            Section {
                AltWeekList(habit: habit)
                    .listRowInsets(EdgeInsets())
            } header: {
                Text("Check-in History").sectionHeaderStyle()
            }

            Section {
                HStack {
                    Label("Streak", systemImage: "flame")
                    Spacer()
                    Text(habit.currentStreak == 1 ? "1 day" : "\(habit.currentStreak) days")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                HStack {
                    Label("This Week", systemImage: "checkmark.circle")
                    Spacer()
                    Text("\(thisWeekCheckins) / \(scheduledDaysPerWeek)")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                if !habit.timeDisplay.isEmpty {
                    HStack {
                        Label("Scheduled Time", systemImage: "clock")
                        Spacer()
                        Text(habit.timeDisplay)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            } header: {
                Text("Stats").sectionHeaderStyle()
            }

            Section {
                HabitWeekList(habit: habit, emphasizeToday: true)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            } header: {
                Text("This Week").sectionHeaderStyle()
            }

            if let milestone = habit.milestone {
                Section {
                    NavigationLink(value: milestone) {
                        Text(milestone.name)
                            .font(AppTheme.Typography.callout)
                    }
                } header: {
                    Text("Milestone").sectionHeaderStyle()
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("habit-detail-view")
        .listStyle(.insetGrouped)
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditHabitView(habit: habit)
        }
    }
}

// MARK: HabitWeekList
struct HabitDay: Identifiable {
    var id: String
    var symbol: String
    var shouldDo: Bool
    var done: Bool
    var isToday: Bool = false
    var date: Date
}

struct HabitWeekList: View {
    @Environment(\.appAccentColor) var accentColor
    let habit: Habit
    let emphasizeToday: Bool
    let fadeValue = 0.15

    @AppStorage("settings.startWeekOnMonday") private var startWeekOnMonday = false

    var habitDays: [HabitDay] { weekOfDaysWithHabit(habit: habit, startWeekOnMonday: startWeekOnMonday) }

    private func dayCircleIdentifier(for date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)
        let names = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
        let name = (weekday >= 1 && weekday <= 7) ? names[weekday - 1] : "unknown"
        return "habit-day-circle-\(name)"
    }

    var body: some View {
        HStack {
            ForEach(0..<habitDays.count, id: \.self) { idx in
                let day = habitDays[idx]
                let highlightToday = emphasizeToday && day.isToday
                Button {
                    withAnimation {
                        habit.toggleCheckin(date: day.date)
                    }
                } label: {
                    Circle()
                        .fill(
                            day.done
                                ? accentColor
                                : (highlightToday ? accentColor.opacity(0.15) : Color.clear)
                        )
                        .stroke(
                            highlightToday
                                ? accentColor
                                : (day.done ? accentColor : AppTheme.Colors.textPrimary),
                            lineWidth: highlightToday ? 2.0 : 1.0
                        )
                        .frame(width: highlightToday ? 30 : 24, height: highlightToday ? 30 : 24)
                        .padding(.horizontal, 5)
                        .overlay {
                            Text(day.symbol)
                                .font(
                                    highlightToday
                                        ? AppTheme.Typography.caption.weight(.bold)
                                        : AppTheme.Typography.caption
                                )
                                .foregroundStyle(
                                    day.done
                                        ? Color.white
                                        : (highlightToday
                                            ? accentColor
                                            : AppTheme.Colors.textPrimary)
                                )
                        }
                        .opacity((day.shouldDo || day.done) ? 1.0 : fadeValue)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(dayCircleIdentifier(for: day.date))
                .accessibilityLabel(
                    day.date.formatted(Date.FormatStyle().weekday(.wide).month(.wide).day())
                        + (day.done ? " — completed" : " — not completed")
                )
            }
        }
    }
}

struct AltWeekList: View {
    @Environment(\.appAccentColor) var accentColor
    let habit: Habit

    @State var source: HabitCheckinSource
    @State private var selectedId: String? = "today"

    init(habit: Habit) {
        self._source = State(wrappedValue: HabitCheckinSource(habit: habit))
        self.habit = habit
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(source.days, id: \.id) { checkin in
                        let isSelected = checkin.id == selectedId
                        Button {
                            withAnimation {
                                habit.toggleCheckin(date: checkin.date)
                                source.refresh(id: checkin.id)
                                selectedId = checkin.id
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(checkin.done ? accentColor : Color.clear)
                                    .stroke(
                                        isSelected
                                            ? accentColor
                                            : (checkin.done ? accentColor : AppTheme.Colors.textPrimary),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Text(checkin.symbol)
                                            .font(.caption)
                                            .fontWeight(isSelected ? .semibold : .regular)
                                            .foregroundStyle(
                                                checkin.done
                                                    ? Color.white
                                                    : (isSelected ? accentColor : AppTheme.Colors.textPrimary)
                                            )
                                    }
                                    .opacity((checkin.shouldDo || checkin.done) ? 1.0 : 0.15)

                                Text(checkin.date.formatted(.dateTime.month(.abbreviated).day()))
                                    .font(.system(size: 10))
                                    .foregroundStyle(isSelected ? accentColor : AppTheme.Colors.textSecondary)
                                    .frame(width: 44)
                                    .multilineTextAlignment(.center)
                                    .opacity((checkin.shouldDo || checkin.done) ? 1.0 : 0.4)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            checkin.date.formatted(Date.FormatStyle().weekday(.wide).month(.wide).day())
                                + (checkin.done ? " — completed" : " — not completed")
                        )
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Double tap to toggle check-in")
                        .onAppear {
                            source.loadMoreContentIfNeeded(current: checkin)
                        }
                    }
                    .onAppear {
                        if let checkin = source.days.first(where: {
                            Calendar.autoupdatingCurrent.compare(
                                $0.date,
                                to: Date.now,
                                toGranularity: .day
                            ) == .orderedSame
                        }) {
                            scrollProxy.scrollTo(checkin.id, anchor: .center)
                        }
                    }
                }
                .padding(.vertical)
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.center)
            .scrollPosition(id: $selectedId)
        }
    }
}

typealias HabitCheckin = (id: String, date: Date, symbol: String, shouldDo: Bool, done: Bool)

struct HabitDraft {
    var name: String
    var days: [Bool]
    var time: Int
}

func applyHabitDays(_ sourceDays: [Bool], to habit: Habit) {
    let normalized = (0..<7).map { idx in
        idx < sourceDays.count ? sourceDays[idx] : false
    }

    if habit.days.count > 7 {
        habit.days.removeLast(habit.days.count - 7)
    } else if habit.days.count < 7 {
        habit.days.append(contentsOf: Array(repeating: false, count: 7 - habit.days.count))
    }

    guard habit.days.count == 7 else { return }
    for idx in 0..<7 {
        habit.days[idx] = normalized[idx]
    }
}

@Observable class HabitCheckinSource {
    @ObservationIgnored private var searchDate = Date.now
    @ObservationIgnored private var searchDirection = Calendar.SearchDirection.forward

    var days = [HabitCheckin]()
    var isLoadingPage = false

    let habit: Habit

    init(habit: Habit) {
        self.habit = habit
        preloadDays()
    }

    func preloadDays() {
        guard !isLoadingPage else {
            return
        }

        isLoadingPage = true

        if let start = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -100, to: Date()) {
            let components = DateComponents(hour: 0, minute: 0)
            var newDays = [HabitCheckin]()

            Calendar.current.enumerateDates(
                startingAfter: start,
                matching: components,
                matchingPolicy: .strict,
                direction: .forward
            ) { (date, _, stop) in
                guard let date = date else {
                    self.days = newDays
                    stop = true
                    return
                }

                let id = Calendar.autoupdatingCurrent.isDateInToday(date) ? "today" : UUID().uuidString
                let symbol = Date.weekSymbols[date.weekday - 1]
                let shouldDo = habit.shiftedDays[date.weekday - 1]
                let done = habit.hasCheckedIn(date: date)

                newDays.append(HabitCheckin(id: id, date: date, symbol: symbol, shouldDo: shouldDo, done: done))

                if newDays.count >= 200 {
                    self.isLoadingPage = false
                    self.days = newDays
                    stop = true
                }
            }
        }
    }

    func refresh(id: String) {
        guard let idx = days.firstIndex(where: { $0.id == id }) else { return }
        let day = days[idx]
        days[idx] = HabitCheckin(
            id: day.id,
            date: day.date,
            symbol: day.symbol,
            shouldDo: day.shouldDo,
            done: habit.hasCheckedIn(date: day.date)
        )
    }

    func loadMoreContentIfNeeded(current: HabitCheckin) {
        // Check if we need to load more days in the future
        var thresholdIndex = self.days.index(self.days.endIndex, offsetBy: -1)
        if self.days[thresholdIndex].id == current.id {
            searchDate = self.days[thresholdIndex].date
            searchDirection = Calendar.SearchDirection.forward
            loadMoreContent()
        }

        // Check if we need to load more days in the past
        thresholdIndex = 0
        if self.days[thresholdIndex].id == current.id {
            searchDate = self.days[0].date
            searchDirection = Calendar.SearchDirection.backward
            loadMoreContent()
        }
    }

    func loadMoreContent() {
        guard !isLoadingPage else {
            return
        }

        isLoadingPage = true

        let components = DateComponents(hour: 0, minute: 0)
        var newDays = [HabitCheckin]()

        Calendar.current.enumerateDates(
            startingAfter: searchDate,
            matching: components,
            matchingPolicy: .strict,
            direction: searchDirection
        ) { (date, _, stop) in
            guard let date = date else {
                stop = true
                return
            }

            let id = Calendar.autoupdatingCurrent.isDateInToday(date) ? "today" : UUID().uuidString
            let symbol = Date.weekSymbols[date.weekday - 1]
            let shouldDo = habit.shiftedDays[date.weekday - 1]
            let done = habit.hasCheckedIn(date: date)

            newDays.append(HabitCheckin(id: id, date: date, symbol: symbol, shouldDo: shouldDo, done: done))

            if newDays.count >= 100 {
                self.isLoadingPage = false
                if searchDirection == .forward {
                    self.days += newDays
                } else {
                    self.days = newDays.reversed() + self.days
                }

                stop = true
            }
        }
    }
}

// MARK: HabitEditFields
struct HabitEditFields: View {
    @Query(sort: \Milestone.name) private var milestones: [Milestone]

    @Bindable var habit: Habit

    let onDraftChange: ((HabitDraft) -> Void)?
    var isCreating: Bool = false

    @State var days: [Date]
    @State var canSetMilestone: Bool = true
    @State var habitName: String
    @State var doDays: [Bool]
    @State var hasScheduledTime: Bool = false
    @State var scheduledTimeDate: Date = Date()

    init(habit: Habit, canSetMilestone: Bool = false, isCreating: Bool = false, onDraftChange: ((HabitDraft) -> Void)? = nil) {
        self.isCreating = isCreating
        self.habit = habit
        self.canSetMilestone = canSetMilestone
        self.onDraftChange = onDraftChange
        let startWeekOnMonday = UserDefaults.standard.bool(forKey: "settings.startWeekOnMonday")
        self.days = weekOfDays(startWeekOnMonday: startWeekOnMonday)
        self._habitName = State(initialValue: habit.name)
        let wd = weekOfDays()
        let defaultDays = [false, false, false, false, false, false, false]
        let hd = habit.days.count == 7 ? habit.days : defaultDays
        self._doDays = State(initialValue: (0..<7).map { idx in
            guard idx < wd.count else { return false }
            let rawWeekday = Calendar.current.component(.weekday, from: wd[idx])
            return hd[rawWeekday - 1]
        })
        self._hasScheduledTime = State(initialValue: habit.time >= 0)
        let timeDate: Date = habit.time >= 0
            ? (Calendar.current.date(
                bySettingHour: habit.time / 60,
                minute: habit.time % 60,
                second: 0,
                of: Date()
            ) ?? Date())
            : Date()
        self._scheduledTimeDate = State(initialValue: timeDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Habit", text: $habitName)
                    .padding()
                    .background(Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 10)))
                    .font(.headline)
                    .padding(.vertical, 32)
                    .accessibilityIdentifier(isCreating ? "habit-create-name-field" : "habit-edit-name-field")

                if canSetMilestone {
                    HStack {
                        Text("Milestone:").padding(.leading, 10)
                        Spacer()
                        Picker("Milestone", selection: $habit.milestone) {
                            Text("No Milestone Selected").tag(nil as Milestone?)
                            Divider()
                            ForEach(milestones) { milestone in
                                Text(milestone.name).tag(milestone)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                HStack {
                    ForEach(Array(zip(days.indices, days)), id: \.0) { idx, day in
                        let weekday = Calendar.current.component(.weekday, from: day)
                        let names = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
                        let name = (weekday >= 1 && weekday <= 7) ? names[weekday - 1] : "unknown"
                        
                        Circle()
                            .stroke(.primary)
                            .padding(.horizontal, 5)
                            .overlay {
                                Text(Date.weekSymbols[day.weekday - 1])
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                            .opacity(doDays[idx] ? 1.0 : 0.15)
                            .onTapGesture {
                                doDays[idx] = !doDays[idx]
                            }
                            .accessibilityIdentifier("habit-edit-day-\(name)")
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Scheduled time", isOn: $hasScheduledTime)
                    if hasScheduledTime {
                        DatePicker("Time", selection: $scheduledTimeDate, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: doDays) { _, _ in
            syncDraftToTarget()
        }
        .onChange(of: hasScheduledTime) { _, _ in
            syncDraftToTarget()
        }
        .onChange(of: scheduledTimeDate) { _, _ in
            syncDraftToTarget()
        }
        .onChange(of: habitName) { _, _ in
            syncDraftToTarget()
        }
    }

    private func buildDraft() -> HabitDraft {
        var normalizedDays = [Bool](repeating: false, count: 7)
        for (idx, day) in days.enumerated() where idx < doDays.count {
            let rawWeekday = Calendar.current.component(.weekday, from: day)
            if rawWeekday >= 1 && rawWeekday <= 7 {
                normalizedDays[rawWeekday - 1] = doDays[idx]
            }
        }

        let normalizedTime: Int
        if hasScheduledTime {
            normalizedTime = Calendar.current.component(.hour, from: scheduledTimeDate) * 60
                + Calendar.current.component(.minute, from: scheduledTimeDate)
        } else {
            normalizedTime = -1
        }

        return HabitDraft(name: habitName, days: normalizedDays, time: normalizedTime)
    }

    private func syncDraftToTarget() {
        let draft = buildDraft()

        if let onDraftChange {
            onDraftChange(draft)
            return
        }

        habit.name = draft.name
        applyHabitDays(draft.days, to: habit)
        habit.time = draft.time
    }
}

// MARK: EditHabitView
struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var habit: Habit

    @State private var draft = HabitDraft(name: "", days: [Bool](repeating: false, count: 7), time: -1)
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                HabitEditFields(habit: habit) { newDraft in
                    draft = newDraft
                }
            }
            .onAppear {
                draft = HabitDraft(
                    name: habit.name,
                    days: habit.days.count == 7 ? habit.days : [Bool](repeating: false, count: 7),
                    time: habit.time
                )
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("habit-edit-cancel-button")
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete Habit", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("habit-edit-delete-button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    let nameValid = !draft.name.trimmingCharacters(in: .whitespaces).isEmpty
                    let daysValid = draft.days.contains(true)
                    let isValid = nameValid && daysValid
                    Button("Save") {
                        habit.name = draft.name
                        applyHabitDays(draft.days, to: habit)
                        habit.time = draft.time
                        dismiss()
                    }
                    .disabled(!isValid)
                    .accessibilityHint(
                        !nameValid
                            ? "Enter a habit name to save"
                            : (!daysValid ? "Select at least one day to save" : "")
                    )
                    .accessibilityIdentifier("habit-edit-save-button")
                }
            }
            .confirmationDialog("Delete Habit", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    context.delete(habit)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    showingDeleteConfirmation = false
                }
            } message: {
                Text("Are you sure you want to delete \"\(habit.name)\"? This cannot be undone.")
            }
        }
    }
}

func weekOfDays(startWeekOnMonday: Bool = false) -> [Date] {
    var days = [Date]()

    var cal = Calendar.autoupdatingCurrent
    cal.firstWeekday = startWeekOnMonday ? 2 : 1

    guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: Date()),
          let start = cal.date(byAdding: .day, value: -1, to: weekInterval.start)
    else {
        return days
    }

    cal.enumerateDates(
        startingAfter: start,
        matching: DateComponents(hour: 0),
        matchingPolicy: .strict,
        direction: .forward
    ) { (date, _, stop) in
        guard let date = date else {
            stop = true
            return
        }

        days.append(date)
        if days.count >= 7 {
            stop = true
        }
    }

    return days
}

func weekOfDaysWithHabit(habit: Habit, startWeekOnMonday: Bool = false) -> [HabitDay] {
    let days = weekOfDays(startWeekOnMonday: startWeekOnMonday)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return days.map { day in
        let isToday = Calendar.autoupdatingCurrent.isDateInToday(day)
        let id = isToday ? "today" : formatter.string(from: day)
        let symbol = Date.weekSymbols[day.weekday - 1]
        let shouldDo = habit.shiftedDays[day.weekday - 1]
        let done = habit.hasCheckedIn(date: day)

        return HabitDay(id: id, symbol: symbol, shouldDo: shouldDo, done: done, isToday: isToday, date: day)
    }
}

// MARK: Previews
#Preview {
    do {
        let previewer = try Previewer()
        let habits = try previewer.container.mainContext.fetch(Habit.allHabits)

        return HabitListView(habits: habits)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Alternate Week View") {
    do {
        let previewer = try Previewer()
        let habit = try previewer.container.mainContext.fetch(Habit.firstByName).first

        return VStack(alignment: .center) {
            AltWeekList(habit: habit!)
        }
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")

    }
}
