//
//  TransactionDetails.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct TransactionDetails: View {
    
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
                    .padding(.horizontal, 20)
                    
                    //Transaction title
                    Text("Transaction Details")
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    //Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Text("Overview")
                                .foregroundStyle(Color.black)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .padding(10)
                                .background(Color.white.opacity(1))
                                .cornerRadius(10)
                            
                            Text("SOL Balance Change")
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .padding(10)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                            
                            Text("Token Balance Change")
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .padding(10)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 10)
                    
                    //Signature
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Signature")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                        Text("4UqZh...pvDVS")
                            .font(.system(size: 36, weight: .regular, design: .default))
                        Text("4UqZhyrQgBEnTbD24N1LuPmzLasH8acdjkEEd4XpvDVS")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                        .opacity(0.5)
                    
                    //Result
                    VStack(alignment: .leading) {
                        Text("Result")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .padding(.bottom, 10)
                        HStack {
                            Text("SUCCESS")
                                .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                                .font(.subheadline)
                            Text("|")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                            Text("Finalized (MAX Confirmations)")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                        .opacity(0.5)
                    
                    //Timestamp
                    VStack(alignment: .leading) {
                        Text("Timestamp")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .padding(.bottom, 10)
                        HStack {
                            Text("4 days ago")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            Text("|")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                            Text("March 08, 2025 09:09:20 +UTC")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                        .opacity(0.5)
                    
                    //Singer
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Singer")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .padding(.bottom, 10)
                        HStack {
                            Text("4UqZh...pvDVS")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Image(systemName: "document.on.document")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(.system(size: 12))
                            
                        }
                        HStack {
                            Text("7hsnB...ONB31")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Image(systemName: "document.on.document")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(.system(size: 12))
                            
                        }
                        HStack {
                            Text("89hNj...1h9an")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Image(systemName: "document.on.document")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(.system(size: 12))
                            
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                        .opacity(0.5)
                    
                    //Block
                    VStack(alignment: .leading) {
                        Text("Block")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .padding(.bottom, 10)
                        HStack {
                            Text("325364972")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                        .opacity(0.5)
                    
                    //Transaction Actions
                    VStack(spacing: 10) {
                        HStack() {
                            Text("Transaction Actions")
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
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
            }
            
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    TransactionDetails()
}
