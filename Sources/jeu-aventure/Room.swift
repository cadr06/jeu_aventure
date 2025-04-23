class Room {
    var name: String
    var description: String
    var items: [Item]
    var characters: [Character]
    var puzzles: [Puzzle]
    var exits: [String: String] // Ex: "nord": "Salle suivante"
    var requiredItems: [String]?
    var entryPuzzleId: String?
     var coordinates: Coordinates // Ajouter les coordonnées

    init(name: String, description: String, items: [Item], characters: [Character], puzzles: [Puzzle], exits: [String: String], requiredItems: [String]? = nil, entryPuzzleId: String? = nil, coordinates: Coordinates) {
        self.name = name
        self.description = description
        self.items = items
        self.characters = characters
        self.puzzles = puzzles
        self.exits = exits
        self.requiredItems = requiredItems
        self.entryPuzzleId = entryPuzzleId
        self.coordinates = coordinates // Initialiser les coordonnées

    }

    // Affiche les connexions de la salle (carte)
    func displayRoomMap() {
        print("Carte de la salle \(name):")
        if exits.isEmpty {
            print("Aucune sortie.")
        } else {
            for (direction, roomName) in exits {
                print("- \(direction.capitalized) vers \(roomName)")
            }
        }
    }

    // Vérifie si le joueur peut entrer dans cette salle
    func canEnter(withPlayerItems playerItems: [String], puzzlesById: [String: Puzzle]) -> Bool {
    if let requiredItems = self.requiredItems {
        let missingItems = requiredItems.filter { !playerItems.contains($0) }

        if !missingItems.isEmpty {
            let itemsList = missingItems.joined(separator: ", ")
            print("Tune peux pas accéder à cette salle pour l'instant, tu as besoin de : \(itemsList)")
            return false
        }
    }

    // Afficher les coordonnées de la salle
    func displayCoordinates() {
        print("Coordonnées de la salle \(name): (\(coordinates.x), \(coordinates.y))")
    }


        // Vérifie si l'énigme d'entrée est résolue
        if let entryPuzzleId = self.entryPuzzleId, let entryPuzzle = puzzlesById[entryPuzzleId], !entryPuzzle.solved {
            print("Il faut résoudre l'énigme avant d'entrer.")
            return false
        }

        return true
    }
}
