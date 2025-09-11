//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Sergio J. on 05/09/25.
//

import Foundation

// to decode data comming from pokemon api

struct FetchedPokemon: Decodable {
    let id : Int16
    let name : String
    let types : [String]
    let hp : Int16
    let attack : Int16
    let defense : Int16
    let specialAttack : Int16
    let specialDefense : Int16
    let speed : Int16
    let sprite : URL
    let shiny: URL
    
    enum CodingKeys : CodingKey {
        case id
        case name
        case types
        case stats // renamed to match topNames in json
        case sprites
        
        // just to get to the info embedded into the dictionaries from json api
        enum TypeDictionaryKeys : CodingKey {
            case type
            
            enum TypeKeys : CodingKey {
                case name
            }
        }
        // We'll use decoding Strategy later
        enum StatDictionaryKeys : CodingKey {
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey {
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        // deep level problems start at types
        var decodedTypes: [String] = []
        // types is an array property at the top level, so we use a nestedUnkeyed
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        while !typesContainer.isAtEnd{ // while not at the end
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
            
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        // some items have two types "normal" and "Flying", but the desired order is "Flying" as the main type. The following types should change their order
        // unnecesary but :(
        if decodedTypes.count == 2 &&  decodedTypes[0] == "normal"{
            //let tempType = decodedTypes[0]
            //decodedTypes[0] = decodedTypes[1]
            //decodedTypes[1] = tempType
            // short version of this swap
            decodedTypes.swapAt(0, 1)
        }
        
        types = decodedTypes
        // now a similar process for stats, but we note they have an order and we only need its value not their name
        var decodedStats: [Int16] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd{
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
            let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
            decodedStats.append(stat)
        }
        
        self.hp = decodedStats[0]
        self.attack = decodedStats[1]
        self.defense = decodedStats[2]
        self.specialAttack = decodedStats[3]
        self.specialDefense = decodedStats[4]
        self.speed = decodedStats[5]
        
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        self.sprite = try spriteContainer.decode(URL.self, forKey: .sprite)
        self.shiny = try spriteContainer.decode(URL.self, forKey: .shiny)
    }
}
