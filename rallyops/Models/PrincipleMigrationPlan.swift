//
//  PrincipleMigrationPlan.swift
//  rallyops
//
//  Created by Cameron Rivers on 3/19/24.
//

import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [
            PrincipleV1Schema.self
        ]
    }

    static var stages: [MigrationStage] {
        []
    }
}
