import Defaults
import SwiftUI

struct NextMeetingProgressBorder: View {
    let topCornerRadius: CGFloat
    let bottomCornerRadius: CGFloat

    @ObservedObject var calendarManager = CalendarManager.shared

    private var nextEvent: EventModel? {
        let now = Date()
        return calendarManager.events
            .filter { $0.startDate > now }
            .min { $0.startDate < $1.startDate }
    }

    private var progress: Double {
        guard let event = nextEvent else { return 0 }
        let now = Date()
        let totalDuration = event.endDate.timeIntervalSince(event.startDate)
        let elapsed = now.timeIntervalSince(event.startDate)
        return max(0, min(1, elapsed / totalDuration))
    }

    private var timeUntilNextEvent: TimeInterval? {
        guard let event = nextEvent else { return nil }
        return event.startDate.timeIntervalSinceNow
    }

    private var timeString: String {
        guard let interval = timeUntilNextEvent, interval > 0 else { return "" }
        let minutes = Int(interval / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 2)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * progress, height: 2)

                if let event = nextEvent, !timeString.isEmpty {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 6, height: 6)
                        .offset(x: width * progress - 3, y: -2)
                }
            }
            .offset(y: height - 2)
        }
    }
}

struct NightTimelineBorder: View {
    @ObservedObject var calendarManager = CalendarManager.shared
    @State private var currentTime = Date()

    private let nightStartHour = 22
    private let nightEndHour = 6

    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: currentTime)
        return hour >= nightStartHour || hour < nightEndHour
    }

    private var nextEvent: EventModel? {
        let now = Date()
        return calendarManager.events
            .filter { $0.startDate > now }
            .min { $0.startDate < $1.startDate }
    }

    private var timeUntilNextEvent: TimeInterval? {
        guard let event = nextEvent else { return nil }
        return event.startDate.timeIntervalSinceNow
    }

    private var progressToNextEvent: Double {
        guard let event = nextEvent, let remaining = timeUntilNextEvent, remaining > 0 else {
            return isNightTime ? 1.0 : 0.0
        }
        let totalDuration: TimeInterval = 4 * 60 * 60
        return min(1.0, max(0, 1.0 - (remaining / totalDuration)))
    }

    private var timeString: String {
        if let interval = timeUntilNextEvent, interval > 0 {
            let minutes = Int(interval / 60)
            if minutes < 60 {
                return "\(minutes)m"
            } else {
                let hours = minutes / 60
                let mins = minutes % 60
                return "\(hours)h \(mins)m"
            }
        }
        return ""
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 3)

                if isNightTime || nextEvent != nil {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: isNightTime 
                                    ? [Color.orange.opacity(0.8), Color.orange.opacity(0.4), Color.orange.opacity(0.8)]
                                    : [Color.blue.opacity(0.6), Color.cyan.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * progressToNextEvent, height: 3)
                        .animation(.linear(duration: 60), value: progressToNextEvent)

                    if !timeString.isEmpty {
                        Text(timeString)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(isNightTime ? .orange : .cyan)
                            .offset(x: width * progressToNextEvent + 8, y: -8)
                    }

                    Circle()
                        .fill(isNightTime ? Color.orange : Color.cyan)
                        .frame(width: 5, height: 5)
                        .offset(x: width * progressToNextEvent - 2.5, y: 0)
                }
            }
            .offset(y: geometry.size.height - 4)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}
