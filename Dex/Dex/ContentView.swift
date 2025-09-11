//
//  ContentView.swift
//  Dex
//
//  Created by Sergio J. on 03/09/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // Sort descriptor refactored from template code
    @FetchRequest<Pokemon>(sortDescriptors: [SortDescriptor(\.id)], animation: .default) private var pokedex
    
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all
    
    @State private var searchText : String = ""
    @State private var filterByFavourite : Bool = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate : NSPredicate {
        var predicates : [NSPredicate] = []
        // search predicate
        if !searchText.isEmpty {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText) // filter by name that contains searchText
            // [c] case insensitive
            predicates.append(predicate)
        }
        
        // Filter by favourite
        if filterByFavourite {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        // Combine predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        // this component is the link(cell)
                        AsyncImage(url: pokemon.spriteURL){ image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            HStack{
                                Text(pokemon.name?.capitalized ?? "😴") // or force unwrapped it
                                    .fontWeight(.bold)
                                if pokemon.favorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                            HStack{
                                ForEach(pokemon.types!, id: \.self){ type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color(type.capitalized)) // type match colors in resources
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    } // NavLikn
                    .swipeActions(edge: .leading){
                        Button(pokemon.favorite ? "Remove from favs" : "Add to favs", systemImage: "star"){
                            pokemon.favorite.toggle()
                            do{
                                try viewContext.save()
                            }
                            catch{
                                print(error)
                            }
                        }
                        .tint(pokemon.favorite ? .gray : .yellow)
                    }
                } // ForE
            } // Lst
            .navigationTitle(Text("Pokedex"))
            .searchable(text: $searchText, prompt: "Find a pokemon")
            .autocorrectionDisabled(true)
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .onChange(of: filterByFavourite) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .navigationDestination(for: Pokemon.self){ pokemon in
                // another way to do navigation, this compnent is the destination
                PokemonDetail()
                    .environmentObject(pokemon)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        filterByFavourite.toggle()
                    } label: {
                        Label("Favourite", systemImage: filterByFavourite ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                }
            }
        }
        .task{
            getPokemon()
        }
    } // View
    
    private func getPokemon(){
        Task{
            for id in 1..<152{
                do{
                    let fetchedPokemon = try await fetcher.fetchPokemon(id) // just the json pokemon
                    let pokemon = Pokemon(context: viewContext) // blank pokemon
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                    
                    // just to test fav filter
                    if pokemon.id % 2 == 0{
                        pokemon.favorite = true
                    }
                    
                    try viewContext.save()
                }
                catch{
                    print("Error: \(error)")
                }
            }
            // after all data has been downloaded then saved it
            storeSprites()
        }
    } // func getPok
    
    private func storeSprites(){
        Task{
            do{
                for pokemon in all{
                    // save actual image to coreData
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0 // .0 means just data, ignore response
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    try viewContext.save()
                }
            }
            catch{
                print(error)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
