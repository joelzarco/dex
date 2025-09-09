//
//  PokemonDetail.swift
//  Dex
//
//  Created by Sergio J. on 08/09/25.
//

import SwiftUI

struct PokemonDetail: View {
    @Environment(\.managedObjectContext) private var viewContext // we'll need to save to favs
    // to bring the pokemon from the db
    @EnvironmentObject private var pokemon: Pokemon
    
    @State private var showShiny: Bool = false
    
    var body: some View {
        ScrollView{
            ZStack{
                Image(pokemon.background) // .backgroung comes from extension
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 5)
                AsyncImage(url: pokemon.sprite){ image in
                    image
                        .interpolation(.none) // looks shaper :)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black, radius: 5)
                    
                } placeholder: {
                    ProgressView()
                }
            } // Zs
            
            HStack{
                ForEach(pokemon.types!, id: \.self){ type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(type.capitalized)) // Colors match name in assets to rgb
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Button{
                    pokemon.favorite.toggle()
                    do{
                        try viewContext.save()
                    }
                    catch {
                        print("Error saving favorite: \(error)")
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
                
            } // Hs
            .padding()
            
        }
        .navigationTitle(pokemon.name!.capitalized)
    }
}

#Preview {
NavigationStack {
    PokemonDetail()
        .environmentObject(PersistenceController.previewPokemon)
    }
}
