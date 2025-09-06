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
    
    @State private var searchText : String = ""
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
        
        // Combine predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        // this component is the link(cell)
                        AsyncImage(url: pokemon.sprite){ image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            Text(pokemon.name?.capitalized ?? "😴") // or force unwrapped it
                                .fontWeight(.bold)
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
                } // ForE
            } // Lst
            .navigationTitle(Text("Pokedex"))
            .searchable(text: $searchText, prompt: "Find a pokemon")
            .autocorrectionDisabled(true)
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .navigationDestination(for: Pokemon.self){ pokemon in
                // another way to do navigation, this compnent is the destination
                Text(pokemon.name ?? "No name :( ")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                    }
                }
            }
        }
        .onAppear{
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
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    try viewContext.save()
                    
                    
                }
                catch{
                    print("Error: \(error)")
                }
            }
        }
        
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
