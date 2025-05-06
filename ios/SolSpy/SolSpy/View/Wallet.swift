//
//  Wallet.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Wallet: View {
    
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    var body: some View {
        ZStack {
            
            background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    //Header action bar
                    HStack {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        HStack {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            
                            HStack {
                                Image(systemName: "document.on.document")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    
                    //Wallet title
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Wallet")
                            .font(.system(size: 20, weight: .regular, design: .default))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("4UqZh...pvDVS")
                                .font(.system(size: 36, weight: .regular, design: .default))
                            Text("4UqZhyrQgBEnTbD24N1LuPmzLasH8acdjkEEd4XpvDVS")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    //Account Balance
                    ZStack {
                        
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Account Balance")
                                        .foregroundStyle(Color.gray)
                                        .font(.subheadline)
                                    
                                    Text("$33,549.00")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 32, weight: .regular))
                                }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("SOL Balance")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("525 SOL ($27,549)")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                    
                                    
                                    VStack(alignment: .leading) {
                                        Text("Token Balance")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("15 Tokens ($6,442)")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                }
                                
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Text("6.35K USDC (~$6.35K)")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    
                    //More info
                    VStack {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("More info")
                                .foregroundStyle(Color.white)
                                .font(.subheadline)
                            
                            VStack(alignment: .leading) {
                                Text("Owner")
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
                                    Text("System Program")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "document.on.document")
                                        .foregroundStyle(.white.opacity(0.5))
                                        .font(.system(size: 12))
                                }
                                
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("isOnCurve")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    Text("TRUE")
                                        .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                                        .font(.subheadline)
                                    
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("Stake")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    Text("0 SOL")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                            }
                            
                        }
                        .padding(10)
                    }
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
                    
                    //All Transactions
                    VStack(spacing: 10) {
                        HStack() {
                            Text("Transactions")
                                .font(.system(size: 20, weight: .regular, design: .default))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        
                        //Transaction card Transfer - example
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Transfer")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    ZStack {
                                        Image(systemName: "plus")
                                            .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                                            .font(.system(size: 12))
                                        Circle()
                                            .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286).opacity(0.1))
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text("0.00026")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Text("SOL")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Text("2 days ago")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("5KV9...Syhn")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 13))
                                    }
                                }
                                
                            }
                            .padding(10)
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
                        
                        //Transaction card Burn - example
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Burn")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    Text("Burned")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Text("0.00026")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Text("SOL")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Text("2 days ago")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("5KV9...Syhn")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 13))
                                    }
                                }
                                
                            }
                            .padding(10)
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
                        
                        //Transaction card Swap - example
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Swap")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    Text("6.94")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Text("JUP")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "arrow.left.arrow.right")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 12))
                                    Text("0.00026")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Text("SOL")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Text("2 days ago")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("5KV9...Syhn")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 13))
                                    }
                                }
                                
                            }
                            .padding(10)
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
                        
                        //Transaction card Failed - example
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Failed")
                                        .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145))
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    Text("Transaction failed")
                                        .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145))
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Text("2 days ago")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("5KV9...Syhn")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 13))
                                    }
                                }
                                
                            }
                            .padding(10)
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
                        
                        //Transaction card Generic - example
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Generic")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    Text("---")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Text("2 days ago")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("5KV9...Syhn")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 13))
                                    }
                                }
                                
                            }
                            .padding(10)
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

                        //Transaction card Universal type - example
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Universal type")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    ZStack {
                                        Image(systemName: "minus")
                                            .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145))
                                            .font(.system(size: 12))
                                        Circle()
                                            .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145).opacity(0.1))
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    
                                    Text("0.00026")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(.white)
                                    Text("SOL")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Text("2 days ago")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("5KV9...Syhn")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 13))
                                    }
                                }
                                
                            }
                            .padding(10)
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
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    Wallet()
}
