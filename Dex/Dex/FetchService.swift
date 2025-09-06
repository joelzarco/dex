//
//  FetchService.swift
//  Dex
//
//  Created by Sergio J. on 06/09/25.
//

import Foundation

struct FetchService {
    enum FectchError: Error {
        case badResponse
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    func fetchPokemon(_ id: Int) async throws -> FetchedPokemon {
        
        let fetchURL = baseURL.appendingPathComponent(String(id))
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FectchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(FetchedPokemon.self, from: data)
        
        print(pokemon.id, pokemon.name.capitalized)
        
        return pokemon
    }
    
    
}
