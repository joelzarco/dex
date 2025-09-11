//
//  Stats.swift
//  Dex
//
//  Created by Sergio J. on 10/09/25.
//

import SwiftUI
import Charts

struct Stats: View {
    // no need to import envObject since whe won't modify anything
    var pokemon : Pokemon
    
    var body: some View {
        //like a forEach
        Chart(pokemon.stats) { stat in
            BarMark(
                x: .value("Value", stat.value),
                y: .value("Stat", stat.name)
            )
            .annotation(position: .trailing) {
                Text("\(stat.value)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, -4)
            }
        }
        .frame(height: 200)
        .padding()
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.highestStat.value+10)
    }
}

#Preview {
    Stats(pokemon: PersistenceController.previewPokemon)
}
