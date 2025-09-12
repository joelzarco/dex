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
                Image(pokemon.background) // .background comes from extension
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 5)
                // check if images have been saved to db
                if pokemon.sprite == nil || pokemon.shiny == nil{
                    
                    AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL){ image in
                        image
                            .interpolation(.none) // looks shaper, pixelated as intended
                            .resizable()
                            .scaledToFit()
                            .shadow(color: .black, radius: 5)
                        
                    } placeholder: {
                        ProgressView()
                    }
                }
                else{
                    // use images from db
                    (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                        .interpolation(.none) //
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black, radius: 5)
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
            
            Text("Stats")
                .padding(.bottom, -10) // to bring closer the chart
            
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    showShiny.toggle()
                } label: {
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                        .tint(showShiny ? .yellow : .primary)
                }
            }
        }
    }
}

#Preview {
NavigationStack {
    PokemonDetail()
        .environmentObject(PersistenceController.previewPokemon)
    }
}
