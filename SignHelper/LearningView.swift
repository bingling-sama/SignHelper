//
//  LearningView.swift
//  SignHelper
//
//  Created by Lucas Liu on 2026/1/20.
//

import SwiftUI

struct LearningView: View {
    // Use data from SignDataManager
    let categories = SignDataManager.shared.categories
    
    var body: some View {
        NavigationView {
            List {
                // Daily Challenge Card
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Daily Challenge")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("100 XP")
                                .font(.caption)
                                .padding(5)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(5)
                        }
                        
                        Text("Learn how to sign 'Hello'")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        NavigationLink(destination: LessonDetailView(category: categories[0])) {
                            Text("Start Now")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(15)
                    .listRowInsets(EdgeInsets()) // Remove default list padding for card
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Courses")) {
                    ForEach(categories) { category in
                        NavigationLink(destination: LessonDetailView(category: category)) {
                            HStack(spacing: 15) {
                                Image(systemName: category.icon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(category.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Text(category.difficulty)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.secondary.opacity(0.2))
                                            .cornerRadius(4)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        // Simple Progress Bar (Random for demo)
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: 80, height: 4)
                                                .foregroundColor(Color.secondary.opacity(0.2))
                                            Rectangle()
                                                .frame(width: 80 * 0.3, height: 4)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Learning")
        }
    }
}

struct LessonDetailView: View {
    let category: SignCategory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image Placeholder
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: category.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                    )
                    .background(Color(UIColor.secondarySystemBackground))
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(category.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label(category.difficulty, systemImage: "speedometer")
                        Spacer()
                        Label("30% Completed", systemImage: "chart.bar.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("In this lesson, you will learn the basic signs for \(category.title.lowercased()). Follow the video tutorials below and practice with your camera.")
                        .font(.body)
                        .lineSpacing(5)
                        .foregroundColor(.primary)
                    
                    Text("Content")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                        .foregroundColor(.primary)
                    
                    // Lesson Steps from Data Source
                    ForEach(Array(category.signs.enumerated()), id: \.element) { index, sign in
                        HStack(spacing: 15) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .frame(width: 30, height: 30)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Circle())
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading) {
                                Text("Step \(index + 1): \(sign.title)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(sign.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
