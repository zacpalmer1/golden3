
//
//  ContentView.swift
//  SearchBar15
//
//  Created by Federico on 20/11/2021.
//
import SwiftUI

struct SearchView: View {
    private var listOfCountry = userNames
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(countries, id: \.self) { country in
                    HStack {
                        Text(country.capitalized)
                        //Spacer()
                        //Image(systemName: "figure.walk")
                           // .foregroundColor(Color.blue.opacity(0.8))
                    }
                    //.padding()
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Search User")
        }
    }
    
    // Filter countries
    var countries: [String] {
        // Make countries lowercased
        let lcCountries = listOfCountry.map { $0.lowercased() }
        
        return searchText == "" ? lcCountries : lcCountries.filter { $0.contains(searchText.lowercased()) }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
