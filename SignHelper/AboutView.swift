import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                Text("SignHelper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Changed from .gray for better adaptability
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 15) {
                    InfoRow(icon: "person.fill", title: "Developer", value: "Lucas Liu")
                    InfoRow(icon: "envelope.fill", title: "Contact", value: "contact@signhelper.app")
                    InfoRow(icon: "doc.text.fill", title: "License", value: "MIT")
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                Text("About the App")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text("SignHelper is designed to bridge the communication gap using AI-powered sign language recognition and translation tools.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("About")
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AboutView()
}
