import SwiftUI

struct RefreshControl: View {
    var coordinateSpace: CoordinateSpace
    var onRefresh: () -> Void
    
    @State private var refresh: Bool = false
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            if !refresh && geo.frame(in: coordinateSpace).midY > 50 {
                Spacer()
                    .onAppear {
                        refresh = true
                    }
            } else if refresh && geo.frame(in: coordinateSpace).midY <= 0 {
                Spacer()
                    .onAppear {
                        refresh = false
                        onRefresh()
                    }
            }
            
            ZStack(alignment: .center) {
                if geo.frame(in: coordinateSpace).midY > 0 {
                    ProgressView()
                        .scaleEffect(min(geo.frame(in: coordinateSpace).midY / 50, 1.5))
                        .offset(y: min(geo.frame(in: coordinateSpace).midY / 2, 50))
                }
            }
            .frame(width: geo.size.width)
        }
        .padding(.top, -50)
    }
} 