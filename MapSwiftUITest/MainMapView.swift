import SwiftUI
import MapKit

struct MainMapView: View {
    @State var vm = MapModel()
    
    @State var zonesArray: [Zone] = []
    
    @State var isLoading = true
    
    @State var routeInMeters: Double = 0
    
    var body: some View {
        
        VStack {
            if isLoading {
                LoadingView()
            } else {
                ZStack {
                    MapViewCustom(region: vm.centerRegion, lineCoordinates: zonesArray)
                        .ignoresSafeArea()
                    DistanceTextView(routeInMeters: $routeInMeters)
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear(perform: prepareDataForView)
    }
    
    
    //Подготавливает данные для отображения на view
    private func prepareDataForView() {
        vm.downloadAndPrepareCoordsArray(from: vm.url) { array in
            zonesArray = array
            routeInMeters = vm.getZonesPerimetr(of: zonesArray)
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
    }
}




