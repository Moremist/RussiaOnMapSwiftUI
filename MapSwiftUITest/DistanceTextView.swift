import SwiftUI

struct DistanceTextView: View {
    
    @Binding var routeInMeters: Double
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [.pink, .blue], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 280,height: 50)
                    .shadow(color: .black, radius: 10, x: 5, y: 5)
                Text("\(Int(routeInMeters)) meters")
                    .foregroundColor(.white)
                    .font(.system(size: 25, weight: .semibold))
                
            }
            
        }
    }
}

struct DistanceTextView_Previews: PreviewProvider {
    static var previews: some View {
        DistanceTextView(routeInMeters: .constant(100000000))
    }
}
