import SwiftUI

struct NoInternetView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var searchQuery: String = ""
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var noInternetConnection: String = "No network connection"
    
    var body: some View {
        
        VStack {
            Toggle("Dark Mode", isOn: $isDarkMode)
                .padding(.horizontal)
                .preferredColorScheme(isDarkMode ? .dark : .light)
            
            TextField("Search", text: $searchQuery)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
            DatePicker("Start Date", selection: $startDate)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
            
            DatePicker("End Date", selection: $endDate)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
            
            TextField("No Internet", text: $noInternetConnection)
                .padding()
            
        }
    }
    
}
