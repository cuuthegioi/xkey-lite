//
//  AboutSection.swift
//  XKey
//
//  Shared About Settings Section
//

import SwiftUI

struct AboutSection: View {
    @State private var showDonationDialog = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // App Logo
                if let logo = NSImage(named: "XKeyLogo") {
                    Image(nsImage: logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(.top, 20)
                } else {
                    Image(systemName: "keyboard.badge.ellipsis")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)
                }
                
                // App Name & Version
                VStack(spacing: 4) {
                    Text(verbatim: "XKeyLite")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Vietnamese Input Method for lazy people")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(AppVersion.fullVersion)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                Divider()
                    .padding(.horizontal, 80)
                
                Text("Made with ❤️ & ☕")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Donations go to the original XKey author.
                Button(action: {
                    showDonationDialog = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "cup.and.saucer.fill")
                        Text("Support Original Author")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Text("Inspired by XKey \(AppVersion.upstreamVersion).")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showDonationDialog) {
            DonationView()
        }
    }
}
