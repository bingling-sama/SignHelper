//
//  LearningView.swift
//  SignHelper
//
//  Created by Lucas Liu on 2026/1/20.
//

import SwiftUI

struct Lesson: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let difficulty: String
    let progress: Double
}

struct LearningView: View {
    let categories: [Lesson] = [
        Lesson(title: "Greetings", icon: "hand.wave.fill", difficulty: "Easy", progress: 0.8),
        Lesson(title: "Numbers", icon: "number.circle.fill", difficulty: "Easy", progress: 0.3),
        Lesson(title: "Family", icon: "person.2.fill", difficulty: "Medium", progress: 0.0),
        Lesson(title: "Emergency", icon: "exclamationmark.triangle.fill", difficulty: "Hard", progress: 0.0),
        Lesson(title: "Common Phrases", icon: "bubble.left.and.bubble.right.fill", difficulty: "Medium", progress: 0.1)
    ]
    
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
                        
                        Text("Learn how to sign 'Good Morning'")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button(action: {}) {
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
                    ForEach(categories) { lesson in
                        NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                            HStack(spacing: 15) {
                                Image(systemName: lesson.icon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(lesson.title)
                                        .font(.headline)
                                    
                                    HStack {
                                        Text(lesson.difficulty)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(4)
                                        
                                        Spacer()
                                        
                                        // Simple Progress Bar
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: 80, height: 4)
                                                .foregroundColor(.gray.opacity(0.2))
                                            Rectangle()
                                                .frame(width: 80 * lesson.progress, height: 4)
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
    let lesson: Lesson
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image Placeholder
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: lesson.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                    )
                    .background(Color(UIColor.secondarySystemBackground)) // Added for better dark mode blend

                
                VStack(alignment: .leading, spacing: 20) {
                    Text(lesson.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(lesson.difficulty, systemImage: "speedometer")
                        Spacer()
                        Label("\(Int(lesson.progress * 100))% Completed", systemImage: "chart.bar.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("In this lesson, you will learn the basic signs for \(lesson.title.lowercased()). Follow the video tutorials below and practice with your camera.")
                        .font(.body)
                        .lineSpacing(5)
                    
                    Text("Content")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                        // Lesson Steps Placeholder
                    ForEach(1...3, id: \.self) { i in
                        HStack(spacing: 15) {
                            Text("\(i)")
                                .font(.headline)
                                .frame(width: 30, height: 30)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Circle())
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading) {
                                Text("Step \(i): Basic Handshape")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Learn the correct hand positioning.")
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