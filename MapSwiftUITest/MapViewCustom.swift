import SwiftUI
import MapKit

struct MapViewCustom: UIViewRepresentable {
    
    let region: MKCoordinateRegion
    let lineCoordinates: [[CLLocationCoordinate2D]]
    let mapViewDelegate = MapViewDelegate()
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = mapViewDelegate
        view.translatesAutoresizingMaskIntoConstraints = false
        view.region = region
        
        addRoutes(coords: lineCoordinates, sender: view)
    }
}

class MapViewDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.black.withAlphaComponent(0.8)
        return renderer
    }
}

extension MapViewCustom {
    func addRoutes(coords: [[CLLocationCoordinate2D]], sender: MKMapView) {
        for coord in coords {
            var currentArea = coord
            
            //Из документации MKPolyline: The first and last points are not automatically connected to each other.
            //Ниже решил добавить в конец массива точек первую, чтобы получилось завершение зоны
            
            if !currentArea.isEmpty {
                currentArea.append(currentArea.first!)
            }
            
            let polyline = MKPolyline(coordinates: currentArea, count: currentArea.count)
            sender.addOverlay(polyline)
        }
    }
}
