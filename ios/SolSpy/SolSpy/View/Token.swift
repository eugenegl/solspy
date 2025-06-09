//
//  Token.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Token: View {
    // Адрес токена.
    var address: String = ""
    
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    // View-model для загрузки и хранения данных о токене
    @StateObject private var viewModel: TokenViewModel
    // Координатор навигации (пока не используется, но пригодится для связи)
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    // Sheet flags
    @State private var showAuthoritySheet = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(address: String = "") {
        self.address = address
        _viewModel = StateObject(wrappedValue: TokenViewModel(address: address))
    }
    
    var body: some View {
        ZStack {
            
            background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                RefreshControl(coordinateSpace: .named("tokenRefresh"), onRefresh: {
                    viewModel.refreshData()
                })

                Spacer().frame(height: 40)

                VStack(spacing: 20) {
                    
                    //Token title
                    HStack {
                        TokenLogoView(logoUrl: viewModel.logoURL, symbol: viewModel.tokenSymbol, size: 32)
                        Text("Token")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(viewModel.tokenName)
                            .font(.system(size: 20, weight: .regular, design: .default))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    marketOverviewCard
                    
                    profileSummaryCard
                    
                    miscCard
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Gradient overlay behind header
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        background.opacity(1),
                        background.opacity(1),
                        background.opacity(0.9),
                        background.opacity(0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
                Spacer()
            }
            .ignoresSafeArea()
            .zIndex(1)
            
            // Header action bar pinned
            VStack {
                HStack {
                    Button(action: {
                        if dismiss != nil {
                            dismiss()
                        } else {
                            viewModel.goBack()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { viewModel.shareToken() }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                        
                        Button(action: { viewModel.copyTokenLink() }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                Spacer()
            }
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 70)
            )
            .zIndex(3)

            // Toast on copy
            if viewModel.showCopiedToast {
                VStack {
                    Spacer()
                    Text("Link copied")
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.7)))
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
                .animation(.easeInOut, value: viewModel.showCopiedToast)
                .zIndex(10)
            }

            // Toast for refresh errors
            if viewModel.showToast {
                VStack {
                    Spacer()
                    
                    Text(viewModel.toastMessage)
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
                .animation(.easeInOut, value: viewModel.showToast)
                .zIndex(11) // Higher z-index than copy toast
            }

        }
        .foregroundStyle(.white)
        .sheet(isPresented: $showAuthoritySheet) {
            AuthoritySheet(authorityAddress: viewModel.fullAuthorityAddress)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(items: viewModel.getShareItems())
        }
        .coordinateSpace(name: "tokenRefresh")
    }
}

// MARK: - Sub-views extracted to help the typechecker
private extension Token {
    var marketOverviewCard: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Market Overview")
                            .foregroundStyle(Color.white)
                            .font(.subheadline)
                    }
                    
                    // Price занимает всю ширину
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Price")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                        Text(viewModel.priceFormatted)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Market Cap занимает всю ширину
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Market Cap")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                        Text(viewModel.marketCapFormatted)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Current Supply занимает всю ширину
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Current Supply")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                        Text(viewModel.currentSupplyFormatted)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
            }
            .background(Color.white.opacity(0.02))
            
            Circle()
                .fill(Color.green.opacity(0.4))
                .frame(width: 150, height: 150)
                .blur(radius: 60)
                .offset(x: 150, y: -100)
        }
        .clipped()
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
    
    var profileSummaryCard: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Profile Summary")
                            .foregroundStyle(Color.white)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Token Name")
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                            Text("\(viewModel.tokenName) (\(viewModel.tokenSymbol))")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                        .frame(width: 160, alignment: .leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Decimals")
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                            Text(viewModel.decimalsFormatted)
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                        .frame(width: 160, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Token Extensions")
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                            if !(viewModel.tokenData?.tokenExtensions.isEmpty ?? true) {
                                Text("TRUE")
                                    .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                                    .font(.subheadline)
                            } else {
                                Text("FALSE")
                                    .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145))
                                    .font(.subheadline)
                            }
                        }
                        .frame(width: 160, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Authority")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                        Button(action: { showAuthoritySheet = true }) {
                            HStack {
                                Text(viewModel.authorityShort)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "plus")
                                    .foregroundStyle(.white.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(10)
            }
            .background(Color.white.opacity(0.02))
        }
        .clipped()
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
    
    var miscCard: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Misc")
                        .foregroundStyle(Color.white)
                        .font(.subheadline)
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("Token Adress")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                    HStack {
                        Text(viewModel.tokenAddressShort)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                        Image(systemName: "document.on.document")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.system(size: 12))
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Owner Program")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                    HStack {
                        ZStack {
                            Image(systemName: "")
                                .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                                .font(.system(size: 12))
                            Circle()
                                .foregroundStyle(Color.white.opacity(0.1))
                                .frame(width: 20, height: 20)
                        }
                        Text(viewModel.tokenData?.ownerProgram ?? "Token Program")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                        Image(systemName: "document.on.document")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.system(size: 12))
                    }
                }
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.02))
        .clipped()
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}

#Preview {
    Token()
        .environmentObject(NavigationCoordinator())
}
