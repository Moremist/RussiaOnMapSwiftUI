import SwiftUI
import MapKit

struct MainMapView: View {
    @State var vm = MapModel()
    
    @State var zonesArray: [[CLLocationCoordinate2D]] = [[]]
    
    @State var isLoading = true
    
    @State var routeInMeters: Double = 0
    
    var body: some View {
        
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                ZStack {
                    MapViewCustom(region: vm.centerRegion, lineCoordinates: zonesArray)
                        .ignoresSafeArea()
                    VStack {
                        Text("\(Int(routeInMeters)) meters")
                            .font(.system(size: 21, weight: .semibold))
                        Spacer()
                    }
                }
            }
        }
        .onAppear(perform: preparePins)
    }
    
    private func preparePins() {
        vm.downloadAndPrepareCoordsArray(from: vm.url) { array in
            zonesArray = array
            routeInMeters = vm.getDistanceOfRoutes(routes: zonesArray)
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
    }
}


