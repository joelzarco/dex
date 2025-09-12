//
//  PokemonExt.swift
//  Dex
//
//  Created by Sergio J. on 09/09/25.
//

import SwiftUI

struct Stat : Identifiable {
    let id : Int
    let name : String
    let value : Int16
}

extension Pokemon {
    // extensions only computed properties
    
    var spriteImage : Image{
        // chech first if data has been downloaded
        if let data = sprite, let image = UIImage(data: data){
            return Image(uiImage: image)
        } else {
            return Image(.bulbasaur) // default from assets
        }
    }
    
    var shinyImage : Image{
        if let data = shiny, let image = UIImage(data: data){
            return Image(uiImage: image)
        } else {
            return Image(.shinybulbasaur)
        }
    }
    
    var background : ImageResource {
        switch types![0]{
            case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                    .rockgroundsteelfightingghostdarkpsychic
            case "fire", "dragon":
                    .firedragon
            case "flying", "bug":
                    .flyingbug
            case "ice":
                    .ice
            case "water":
                    .water
            default :
                    .normalgrasselectricpoisonfairy
        }
    }
    
    var typeColor : Color{
        return Color(types![0].capitalized)
    }
    
    var stats : [Stat]{
        return [
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "SpecialAttack", value: specialAttack),
            Stat(id: 5, name: "SpecialDefense", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)
        ]
    }
    
    // find highest stat to be able to chart all properly
    var highestStat : Stat{
        // one line version stats.max {$0.value < $1.value }!
        stats.max { stat1, stat2 in
            stat1.value < stat2.value
        }!
    }
}

