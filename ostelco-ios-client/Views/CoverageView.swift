//
//  CoverageView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import UIKit
import OstelcoStyles
import ostelco_core

struct RegionGroupViewModel: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let backgroundColor: RegiounGroupBackgroundColor
    let isPreview: Bool
    
    enum RegiounGroupBackgroundColor {
        case lipstick
        case azul
        
        var toColor: Color {
            switch self {
            case .lipstick:
                return OstelcoColor.lipstick.toColor
            case .azul:
                return OstelcoColor.azul.toColor
            }
        }
    }
}

struct CoverageView: View {
    
    @EnvironmentObject var store: AppStore
    
    let controller: CoverageViewController
    
    let regionGroups = [
        RegionGroupViewModel(name: "Asia", description: "Southeast asia & pacific", backgroundColor: .lipstick, isPreview: false),
        RegionGroupViewModel(name: "The Americas", description: "Latin & north america", backgroundColor: .azul, isPreview: true)
    ]
    
    @State private var showModal: Bool = false
    
    init(controller: CoverageViewController) {
        self.controller = controller
        UINavigationBar.appearance().backgroundColor = OstelcoColor.background.toUIColor
    }
    
    private func renderRegionGroup(_ regionGroup: RegionGroupViewModel) -> AnyView {
        if regionGroup.isPreview {
           return AnyView(
               RegionGroupCardView(label: regionGroup.name, description: regionGroup.description, centerText: regionGroup.isPreview ? "Coming Soon" : nil, backgroundColor: regionGroup.backgroundColor.toColor)
               .cornerRadius(28)
               .clipped()
               .shadow(color: OstelcoColor.regionShadow.toColor, radius: 16, x: 0, y: 6)
           )
        } else {
            return AnyView(
               Button(action: {
                   debugPrint(self.showModal)
                   self.showModal = true
               }) {
                   RegionGroupCardView(label: regionGroup.name, description: regionGroup.description, backgroundColor: regionGroup.backgroundColor.toColor)
               }.cornerRadius(28)
               .clipped()
               .shadow(color: OstelcoColor.regionShadow.toColor, radius: 16, x: 0, y: 6)
           )
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    OstelcoTitle(label: "Location", image: "location.fill")
                    
                    RegionListByLocation(controller: controller)
                    
                    OstelcoTitle(label: "All Destinations")
                    
                    ForEach(regionGroups, id: \.id) { self.renderRegionGroup($0) }
                    
                }.padding()
            }
        }.sheet(isPresented: $showModal) {
            RegionGroupView(countrySelected: { country in
                // TODO: Change RegionView presentation from modal to either animation or navigation, then we can remove the below hack
                self.showModal = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.controller.startOnboardingForCountry(country)
                })
            })
        }
    }
}

struct CoverageView_Previews: PreviewProvider {
    static var previews: some View {
        CoverageView(controller: CoverageViewController())
    }
}
