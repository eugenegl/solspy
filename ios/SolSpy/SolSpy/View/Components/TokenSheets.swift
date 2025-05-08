import SwiftUI

struct SocialChannelsSheet: View {
    let website: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Заголовок с кнопкой закрытия
                HStack {
                    Text("Social Channels")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Содержимое
                ScrollView {
                    VStack(spacing: 12) {
                        if let site = website, let url = URL(string: site.hasPrefix("http") ? site : "https://" + site) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(site)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.gray)
                                
                                Text("No social links available")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundStyle(.white)
    }
}

struct AuthoritySheet: View {
    let authorityAddress: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Заголовок с кнопкой закрытия
                HStack {
                    Text("Authority")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Содержимое
                ScrollView {
                    VStack(spacing: 20) {
                        Text(authorityAddress)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        
                        Button(action: {
                            UIPasteboard.general.string = authorityAddress
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.white)
                                Text("Copy Address")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundStyle(.white)
    }
}

struct CreatorSheet: View {
    let creators: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Заголовок с кнопкой закрытия
                HStack {
                    Text("Creators")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Содержимое
                ScrollView {
                    VStack(spacing: 12) {
                        if !creators.isEmpty {
                            ForEach(creators, id: \.self) { creator in
                                HStack {
                                    Text(creator)
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Button(action: { UIPasteboard.general.string = creator }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.gray)
                                
                                Text("No creators found")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    Group {
        SocialChannelsSheet(website: "jup.ag")
        CreatorSheet(creators: ["5KV9Z32iNZoDLSzBg8xzBB7JkvKUgvjSyhn", "9AhKqLR67hwapvG8SA2JFXaCshXc9nALJjpKaHZrsbkw"])
            .previewDisplayName("Creators")
        AuthoritySheet(authorityAddress: "9AhKqLR67hwapvG8SA2JFXaCshXc9nALJjpKaHZrsbkw")
            .previewDisplayName("Authority")
    }
}
