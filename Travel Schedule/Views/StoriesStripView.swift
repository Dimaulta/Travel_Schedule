//
//  StoriesStripView.swift
//  Travel Schedule
//
//  Created by Ульта on 02.11.2025.
//

import SwiftUI

struct StoriesStripView: View {
    @ObservedObject var viewModel: StoriesViewModel
    let onOpen: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                    Button(action: { onOpen(index) }) {
                        ZStack(alignment: .bottomLeading) {
                            if item.imageName.isEmpty {
                                Color("GrayUniversal")
                            } else {
                                Image(item.imageName)
                                    .resizable()
                                    .scaledToFill()
                            }
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: 40)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            
                            Text(item.title)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .padding(.horizontal, 6)
                                .padding(.bottom, 6)
                        }
                        .frame(width: 92, height: 140)
                        .clipped()
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
    }
}


