//
//  Token.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Token: View {
    
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
                    
                    //Token title
                    HStack {
                        Circle() //token image
                            .foregroundStyle(Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Text("Token")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Jupiter")
                            .font(.system(size: 20, weight: .regular, design: .default))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    //Market Overview
                    ZStack {
                        
                        VStack {
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Market Overview")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Price")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("$0.5107")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Holders")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("983,945")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                    
                                }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Market Cup")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("$3,596,896,884.09")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Current Supply")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("6,999,978,367.16")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Social Channels")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    HStack {
                                        Text("jup.ag")
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Image(systemName: "plus")
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
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
                    
                    //Profile Summary
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
                                        Text("Jupiter (JUP)")
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
                                        Text("6")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Token Extensions")
                                            .foregroundStyle(Color.gray)
                                            .font(.caption)
                                        Text("FALSE")
                                            .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145))
                                            .font(.subheadline)
                                    }
                                    .frame(width: 160, alignment: .leading)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Authority")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    HStack {
                                        Text("Jupiter Team Cold Wal...")
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Image(systemName: "plus")
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Creator")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                    HStack {
                                        Text("JUPhop...cewFbq")
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Image(systemName: "plus")
                                            .foregroundStyle(.white.opacity(0.5))
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
                    
                    //Misc
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
                                    Text("JUPyiw...NsDvCN")
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
                                    Text("Token Program")
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
    Token()
}
