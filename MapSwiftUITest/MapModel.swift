import Foundation
import MapKit
import SwiftUI

//Примем массив координат за зону
typealias Zone = [CLLocationCoordinate2D]

struct MapModel {
    
    let url = URL(string: "https://waadsu.com/api/russia.geo.json")!
    
    //Примерно центр страны
    @State var centerRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 64.66890367425933, longitude: 95.74478061855717), span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
      )
    
    //Мой стандартный метод для работы с URLSession
    
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
    
    //Метод для обработки и анварпа полученных данных по URL
    
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
    
    
    // Декодер даты в экземпляр модели
    
    private func decodeDataIntoMapData(from data: Data) -> GeoJSONModel {
        do {
            let decodedData = try JSONDecoder().decode(GeoJSONModel.self, from: data)
            return decodedData
        } catch let error {
            print("Find error while decode data into MapData model", error)
            fatalError()
        }
    }
    
    
    //Я оставил эту часть кода, так как понимаю, что GeoJSON можно распарсить обычным MKGeoJSONDecoder, но по данному GeoJSON находились координаты 180+, на что парсер ругался. Поэтому принято решение парсить самостоятельно.
    
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
    
    //Метод для преобразования экземпляра модели в набор зон координат.
    
    private func convertMapDataToZonesCoordinates(from data: GeoJSONModel) -> [Zone] {
        var coordinatesArray: [Zone] = []
        data.features.first?.geometry.coordinates.flatMap { $0 }.map({ doubleArray in
            doubleArray.map { array in
                //longitude в GeoJSON по ссылке, как я писал выше, почему то бывает больше 180, хотя его диапазон -180 +180. Соответственно тут я это пытаюсь нивелировать.
                let correctedLongitude = array[0] < 180 ? array[0] : array[0] - 360
                return CLLocationCoordinate2D(latitude: array[1], longitude: correctedLongitude)
            }
        }).forEach({ cord in
            coordinatesArray.append(cord)
        })
        return coordinatesArray
    }
    
    
    //Комплексный метод преображения URL в набор координат зон
    func downloadAndPrepareCoordsArray(from url: URL, complitionHandler: @escaping ([Zone]) -> ()) {
        networkDataHandler(from: url) { [self] downloadedData in
            let decodedData = decodeDataIntoMapData(from: downloadedData)
            let preparedArray = convertMapDataToZonesCoordinates(from: decodedData)
            complitionHandler(preparedArray)
        }
    }
    
    //Функции подсчета длинны границ
    
    func getZonesPerimetr(of arrayOfZones: [Zone]) -> Double {
        var total: Double = 0.0
        for zone in arrayOfZones {
            total += getZonePerimetr(of: zone)
        }
        return total
    }
    
    private func getZonePerimetr(of zone: Zone) -> Double {
        var total: Double = 0.0
        if zone.count < 2 {
            return 0
        }
        for i in 0..<zone.count - 1 {
            let start = zone[i]
            let end = zone[i + 1]
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
