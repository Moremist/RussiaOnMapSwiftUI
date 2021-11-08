import Foundation
import MapKit
import SwiftUI

struct MapModel {
    
    let url = URL(string: "https://waadsu.com/api/russia.geo.json")!
    @State var coordsArray: [CLLocationCoordinate2D] = []
    
    @State var centerRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 64.66890367425933, longitude: 95.74478061855717), span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
      )
    
    private func downloadData(from url: URL, complitionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, responce, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    complitionHandler(data, responce, nil)
                } else {
                    complitionHandler(nil, responce, error)
                }
            }
        }.resume()
    }
    
    private func networkDataHandler(from url: URL, complitionHandler: @escaping (Data) -> ()) {
        downloadData(from: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("Data == nil ", response as Any, error)
                } else {
                    print("Data == nil, error undefined ", response as Any)
                }
                fatalError()
            }
            complitionHandler(data)
        }
    }
    
    private func decodeDataIntoMapData(from data: Data) -> MapData {
        do {
            let decodedData = try JSONDecoder().decode(MapData.self, from: data)
            return decodedData
        } catch let error {
            print("Find error while decode data into MapData model", error)
            fatalError()
        }
    }
    
//    func decodeGeoJSON(data: Data) -> [MKOverlay] {
//
//        var geoJson : [MKGeoJSONObject] = []
//        do {
//            geoJson = try MKGeoJSONDecoder().decode(data)
//        } catch let error {
//            print("GeoJSON decoding error: ", error)
//        }
//        var overlays : [MKOverlay] = []
//        for item in geoJson {
//            if let feature = item as? MKGeoJSONFeature {
//                for geo in feature.geometry {
//                    if let polygon = geo as? MKPolygon {
//                        overlays.append(polygon)
//                    }
//                }
//            }
//        }
//        return overlays
//    }
    
    private func convertMapDataToZonesCoordinates(from data: MapData) -> [[CLLocationCoordinate2D]] {
        var coordinatesArray: [[CLLocationCoordinate2D]] = [[]]
        data.features.first?.geometry.coordinates.flatMap { $0 }.map({ doubleArray in
            doubleArray.map { array in
                return CLLocationCoordinate2D(latitude: array[1], longitude: array[0] < 180 ? array[0] : 180)
            }
        }).forEach({ cord in
            coordinatesArray.append(cord)
        })
        return coordinatesArray
    }
    
    func downloadAndPrepareCoordsArray(from url: URL, complitionHandler: @escaping ([[CLLocationCoordinate2D]]) -> ()) {
        networkDataHandler(from: url) { [self] downloadedData in
            let decodedData = decodeDataIntoMapData(from: downloadedData)
            let preparedArray = convertMapDataToZonesCoordinates(from: decodedData)
            complitionHandler(preparedArray)
        }
    }
    
    func getDistanceOfRoutes(routes: [[CLLocationCoordinate2D]]) -> Double {
        var total: Double = 0.0
        for route in routes {
            total += getDistanceOfRoute(route: route)
        }
        return total
    }
    
    private func getDistanceOfRoute(route: [CLLocationCoordinate2D]) -> Double {
        var total: Double = 0.0
        if route.count < 2 {
            return 0
        }
        for i in 0..<route.count - 1 {
            let start = route[i]
            let end = route[i + 1]
            let distance = getDistance(from: start, to: end)
            total += distance
        }
        return total
    }
    
    private func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
}


extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
