import Foundation

//Модель GeoJSON

class GeoJSONModel: Codable {
    let type: String
    let features: [Feature]

    init(type: String, features: [Feature]) {
        self.type = type
        self.features = features
    }
}

class Feature: Codable {
    let type: String
    let geometry: Geometry

    init(type: String, geometry: Geometry) {
        self.type = type
        self.geometry = geometry
    }
}

class Geometry: Codable {
    let type: String
    let coordinates: [[[[Double]]]]

    init(type: String, coordinates: [[[[Double]]]]) {
        self.type = type
        self.coordinates = coordinates
    }
}
