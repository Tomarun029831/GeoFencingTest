import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.and.ellipse")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text(locationManager.geofenceStatus)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Geofence: Lat \(locationManager.geofenceCenter.latitude, specifier: "%.5f"), Lon \(locationManager.geofenceCenter.longitude, specifier: "%.5f")")
                .font(.subheadline)
            
            if let currentLocation = locationManager.currentLocation {
                Text("Current Location: Lat \(currentLocation.latitude, specifier: "%.5f"), Lon \(currentLocation.longitude, specifier: "%.5f")")
                    .font(.subheadline)
            } else {
                Text("Current Location: Not available")
                    .font(.subheadline)
            }
        }
        .padding()
        .onAppear {
            locationManager.requestLocationAuthorization()
        }
    }
}

#Preview {
    ContentView()
}
