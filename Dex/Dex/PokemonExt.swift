//
//  PokemonExt.swift
//  Dex
//
//  Created by Sergio J. on 09/09/25.
//

import SwiftUI

extension Pokemon {
    // extensions only computed properties
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
}
