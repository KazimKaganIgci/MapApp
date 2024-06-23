//
//  ContentView.swift
//  MapApp
//
//  Created by Kazım Kağan İğci on 28.12.2023.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var result = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetail = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?

    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            Annotation("Location", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue.opacity(0.25))
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(result, id: \.self) { item in
                if routeDisplaying {
                    if item == routeDestination {
                        let placeMark = item.placemark
                        Marker(placeMark.name ?? "",coordinate: placeMark.coordinate)
                    }
                } else {
                    let placeMark = item.placemark
                    Marker(placeMark.name ?? "",coordinate: placeMark.coordinate)
                }

            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue ,lineWidth: 7)
            }
        }
        .overlay(alignment: .top, content: {
            TextField("Search for a location...", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .shadow(radius: 10)
        })
        .onSubmit(of: .text) {
            Task { await searchPlaces() }
        }
        .onChange(of: getDirections, { oldValue, newValue in
            if newValue {
                fetchRoute()
            }
        })
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetail = newValue != nil
        })
        .sheet(isPresented: $showDetail, content: {
            LocationDetailView(
                mapSelection:  $mapSelection,
                show: $showDetail,
                getDirections: $getDirections )
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
        .mapControls{
            MapCompass()// kuzey güney
            MapUserLocationButton() // user location button
            
            
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

extension ContentView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        let result = try? await MKLocalSearch(request: request).start()
        self.result = result?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetail = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
}













//struct MapLocation: Identifiable {
//    let id = UUID()
//    let name: String
//    let latitude: Double
//    let longitude: Double
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//}
//
//struct ContentView: View {
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//    
//    let MapLocations = [
//            MapLocation(name: "St Francis Memorial Hospital", latitude: 37.789467, longitude: -122.416772),
//            MapLocation(name: "The Ritz-Carlton, San Francisco", latitude: 37.791965, longitude: -122.406903),
//            MapLocation(name: "Honey Honey Cafe & Crepery", latitude: 37.787891, longitude: -122.411223)
//            ]
//    
//    var body: some View {
//        Map(
//           coordinateRegion: $region,
//           interactionModes: MapInteractionModes.all,
//           showsUserLocation: true,
//           annotationItems: MapLocations,
//           annotationContent: { location in
//               MapAnnotation(
//                  coordinate: location.coordinate,
//                  content: {
//                      VStack {
//                          Image(systemName: "circle.fill")
//                              .resizable()
//                              .frame(width: 40, height: 40)
//                              .foregroundColor(Color(red: Double.random(in: 0...1),
//                                                     green: Double.random(in: 0...1),
//                                                     blue: Double.random(in: 0...1)))
//                          Image(systemName: "camera.fill")
//                              .resizable()
//                              .frame(width: 20, height: 20)
//                              .foregroundColor(Color(red: Double.random(in: 0...1),
//                                                     green: Double.random(in: 0...1),
//                                                     blue: Double.random(in: 0...1)))
//                              .background(Circle().fill(Color.blue).frame(width: 30, height: 30))
//                              .offset(x: 15, y: -15)
//                          
//                      }
//                  }
//               )
//           }
//        )
//    }
//}




















//import SwiftUI
//import MapKit
//
//struct City: Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//}
//
//struct ContentView: View {
//    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
//
//    let annotations = [
//        City(name: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)),
//        City(name: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508)),
//        City(name: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)),
//        City(name: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667))
//    ]
//
//    var body: some View {
//        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) { location in
//            MapAnnotation(coordinate: location.coordinate) {
//                VStack {
//                    Image(systemName: "circle.fill")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(Color(red: Double.random(in: 0...1),
//                                               green: Double.random(in: 0...1),
//                                               blue: Double.random(in: 0...1)))
//                    Image(systemName: "camera.fill")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(Color(red: Double.random(in: 0...1),
//                                               green: Double.random(in: 0...1),
//                                               blue: Double.random(in: 0...1)))
//                        .background(Circle().fill(Color.blue).frame(width: 30, height: 30))
//                        .offset(x: 15, y: -15)
//                }
//            }
//        }
//    }
//}

//struct ContentView: View {
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//    
//    struct LocationInfo: Identifiable {
//        let id = UUID()
//        let name: String
//        let coordinate: CLLocationCoordinate2D
//    }
//    
//    let locations: [LocationInfo] = [
//        LocationInfo(name: "Location 1", coordinate: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597)),
//        LocationInfo(name: "Location 2", coordinate: CLLocationCoordinate2D(latitude: 39.9300, longitude: 32.8550)),
//        LocationInfo(name: "Location 3", coordinate: CLLocationCoordinate2D(latitude: 39.9350, longitude: 32.8600)),
//        LocationInfo(name: "Location 4", coordinate: CLLocationCoordinate2D(latitude: 39.9310, longitude: 32.8580)),
//        LocationInfo(name: "Location 5", coordinate: CLLocationCoordinate2D(latitude: 39.9340, longitude: 32.8570))
//    ]
//    
//    var body: some View {
//        Map {
//            ForEach(locations) { location in
//                Annotation(location.name, coordinate: location.coordinate) {
//                    VStack {
//                        Image(systemName: "circle.fill")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(Color(red: Double.random(in: 0...1),
//                                                   green: Double.random(in: 0...1),
//                                                   blue: Double.random(in: 0...1)))
//                        Image(systemName: "camera.fill")
//                            .resizable()
//                            .frame(width: 20, height: 20)
//                            .foregroundColor(Color(red: Double.random(in: 0...1),
//                                                   green: Double.random(in: 0...1),
//                                                   blue: Double.random(in: 0...1)))   
//                            .background(Circle().fill(Color.blue).frame(width: 30, height: 30))
//                            .offset(x: 15, y: -15)
//                        
//                    }
//                }
//            }
//            .annotationTitles(.hidden)
//        }
//        
//    }
//}


