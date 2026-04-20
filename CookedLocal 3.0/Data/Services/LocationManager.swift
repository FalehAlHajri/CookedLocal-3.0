//
//  LocationManager.swift
//  Cooked Local
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    @Published var locationString: String = ""
    @Published var isLoading: Bool = false

    private let manager = CLLocationManager()
    private let cacheKey = "cachedLocationString"

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        if let cached = UserDefaults.standard.string(forKey: cacheKey) {
            locationString = cached
        }

        requestLocation()
    }

    func requestLocation() {
        let status = manager.authorizationStatus

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isLoading = true
            manager.requestLocation()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                isLoading = true
                manager.requestLocation()
            case .denied, .restricted:
                isLoading = false
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            await reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isLoading = false
        }
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(_ location: CLLocation) async {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let parts = [placemark.subLocality, placemark.locality].compactMap { $0 }
                let result = parts.joined(separator: ", ")
                locationString = result
                UserDefaults.standard.set(result, forKey: cacheKey)
            }
        } catch {
            // Keep cached value if reverse geocoding fails
        }
        isLoading = false
    }
}
