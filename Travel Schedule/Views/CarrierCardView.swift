//
//  CarrierCardView.swift
//  Travel Schedule
//
//  Created by Ульта on 20.10.2025.
//

import SwiftUI

struct CarrierCardView: View {
    let trip: TripInfo
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        if let logo = trip.carrier.logo, let url = URL(string: logo) {
                            AsyncImage(url: url) { image in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color("GrayUniversal"))
                                        .frame(width: 38, height: 38)
                                    
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 38, height: 38)
                                        .offset(x: 100)
                                        .clipped()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("GrayUniversal"))
                                    .frame(width: 38, height: 38)
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("GrayUniversal"))
                                .frame(width: 38, height: 38)
                        }
                        
                        Text(trip.carrier.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("BlackUniversal"))
                    }
                    
                    if let transferInfo = trip.transferInfo {
                        Text(transferInfo)
                            .font(.system(size: 12))
                            .foregroundColor(Color("RedUniversal"))
                    }
                }
                
                Spacer()
                
                Text(trip.date)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("BlackUniversal"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            HStack {
                Text(trip.departureTime)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("BlackUniversal"))
                
                HStack {
                    Rectangle()
                        .fill(Color("GrayUniversal"))
                        .frame(height: 1)
                    
                    Text(trip.duration)
                        .font(.system(size: 12))
                        .foregroundColor(Color("BlackUniversal"))
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .fill(Color("GrayUniversal"))
                        .frame(height: 1)
                }
                
                Text(trip.arrivalTime)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("BlackUniversal"))
                
                if let transferInfo = trip.transferInfo {
                    Text(transferInfo)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("RedUniversal"))
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color("LightGray"))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CarrierCardView(trip: TripInfo(
        carrier: CarrierInfo(
            title: "РЖД",
            logo: nil,
            code: 1
        ),
        departureTime: "22:30",
        arrivalTime: "08:15",
        duration: "20 ч",
        date: "14 января",
        hasTransfers: true,
        transferInfo: "С пересадкой в Костроме",
        sortDate: Date()
    ))
    .padding()
    .background(Color("White"))
}
