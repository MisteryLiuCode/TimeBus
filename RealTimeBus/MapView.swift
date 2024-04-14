//
//  MapView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/4/13.
//
import MapKit
import SwiftUI


struct MapView: UIViewRepresentable {
    var latitude: Double
    var longitude: Double
    var description: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        updateAnnotations(mapView: mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        updateAnnotations(mapView: mapView)
    }

    func updateAnnotations(mapView: MKMapView) {
        // 移除所有现有标注
        mapView.removeAnnotations(mapView.annotations)

        // 创建新的标注点
        let annotation = MKPointAnnotation()
        annotation.title = description  // Set the title to the description for default usage
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)

        // 设置地图的焦点和缩放级别
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "marker"
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                // Configure the detail view to display description text
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = UIFont.systemFont(ofSize: 12)
                detailLabel.text = parent.description
                view.detailCalloutAccessoryView = detailLabel
            }
            return view
        }

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}


