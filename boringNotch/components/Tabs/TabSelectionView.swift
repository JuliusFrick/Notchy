//
//  TabSelectionView.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-25.
//

import Defaults
import SwiftUI

struct TabModel: Identifiable {
    let label: String
    let icon: String
    let view: NotchViews

    var id: String { label }
}

struct TabSelectionView: View {
    @ObservedObject var coordinator = BoringViewCoordinator.shared
    @Namespace var animation

    private var tabs: [TabModel] {
        var result: [TabModel] = [
            TabModel(label: "Home", icon: "house.fill", view: .home)
        ]

        if Defaults[.boringShelf] {
            result.append(TabModel(label: "Shelf", icon: "tray.fill", view: .shelf))
        }

        if Defaults[.showSuperTab] {
            result.append(TabModel(label: "Super", icon: "sparkles", view: .superDashboard))
        }

        return result
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                    TabButton(label: tab.label, icon: tab.icon, selected: coordinator.currentView == tab.view) {
                        withAnimation(.smooth) {
                            coordinator.currentView = tab.view
                        }
                    }
                    .frame(height: 26)
                    .foregroundStyle(tab.view == coordinator.currentView ? .white : .gray)
                    .background {
                        if tab.view == coordinator.currentView {
                            Capsule()
                                .fill(coordinator.currentView == tab.view ? Color(nsColor: .secondarySystemFill) : Color.clear)
                                .matchedGeometryEffect(id: "capsule", in: animation)
                        } else {
                            Capsule()
                                .fill(coordinator.currentView == tab.view ? Color(nsColor: .secondarySystemFill) : Color.clear)
                                .matchedGeometryEffect(id: "capsule", in: animation)
                                .hidden()
                        }
                    }
            }
        }
        .clipShape(Capsule())
        .onAppear {
            if !tabs.contains(where: { $0.view == coordinator.currentView }) {
                coordinator.currentView = .home
            }
        }
    }
}

#Preview {
    BoringHeader().environmentObject(BoringViewModel())
}
