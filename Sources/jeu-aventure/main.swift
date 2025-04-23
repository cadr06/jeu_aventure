import Foundation

// MARK: - Structs pour le modèle de données (en provenance du JSON)

struct ItemData: Decodable {
    var name: String
    var description: String
    var isTakable: Bool
}

struct CharacterData: Decodable {
    var name: String
    var description: String
    var dialogue: [String]
}

struct Coordinates: Decodable {
    var x: Int
    var y: Int
    
    init(from dictionary: [String: Int]) {
        self.x = dictionary["x"] ?? 0
        self.y = dictionary["y"] ?? 0
    }
}

struct RoomData: Decodable {
    var name: String
    var description: String
    var items: [ItemData]
    var characters: [CharacterData]
    var puzzles: [PuzzleData]
    var exits: [String: String]
    var requiredItems: [String]? // les ID d'objets requis
    var entryPuzzleId: String? // ID de l’énigme à résoudre pour entrer
    var coordinates: Coordinates

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case items
        case characters
        case puzzles
        case exits
        case requiredItems
        case entryPuzzleId
        case coordinates
    }
}

// Structure pour un puzzle
struct PuzzleData: Decodable {
    var id: String
    var question: String
    var correctAnswer: String
    var solved: Bool?  // Rendre "solved" optionnel
}




struct GameData: Decodable {
    var rooms: [RoomData]
    var inventory: [ItemData]?
    var solvedPuzzles: [String] 
}

struct SaveData: Codable {
    var name: String
    var score: Int
    //let solvedPuzzles: Int
    //let exploredRooms: Int
    //let inventory: [String]
    var visitedRooms: [String]
}


 
// MARK: - Chargement des données depuis le fichier JSON
func savePlayerInfoToFile(player: Player) {
    let saveData = SaveData(
        name: player.name,
        score: player.score,
        visitedRooms: Array(player.visitedRooms)
    )

    let fileURL = URL(fileURLWithPath: "/home/celine/jeu-aventure/save.json")

    var existingData: [SaveData] = []

    // Lire les données existantes
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            existingData = try decoder.decode([SaveData].self, from: data)
        } catch {
            print("⚠️ Erreur lors du chargement des données existantes : \(error)")
        }
    }

    // Vérifier si le joueur existe déjà
    if let index = existingData.firstIndex(where: { $0.name == player.name }) {
        // Si le joueur existe, mettre à jour ses données
        existingData[index].score = player.score
        existingData[index].visitedRooms = Array(player.visitedRooms)
        print("💾 Les informations du joueur \(player.name) ont été mises à jour.")
    } else {
        // Si le joueur n'existe pas, ajouter un nouveau joueur
        existingData.append(saveData)
        print("💾 Nouveau joueur ajouté : \(player.name)")
    }

    // Sauvegarder toutes les données
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(existingData)
        try jsonData.write(to: fileURL)
        print("💾 Les informations du joueur ont été sauvegardées dans save.json")
    } catch {
        print("❌ Erreur lors de la sauvegarde : \(error)")
    }
}



func loadGameData() -> ([Room], [String: Puzzle])? {
    // Spécifie le chemin du fichier JSON contenant les données du jeu
    let fileURL = URL(fileURLWithPath: "game.json")
    // Vérifie si le fichier existe
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("Fichier JSON non trouvé.")
        return nil
    }

    do {
        let data = try Data(contentsOf: fileURL)// Charge les données brutes depuis le fichier
        let decoder = JSONDecoder()// Initialise un décodeur JSON
        let gameData = try decoder.decode(GameData.self, from: data)// Décode les données en une structure GameData

        var rooms: [String: Room] = [:] // Dictionnaire temporaire pour les salles
        var allPuzzles: [Puzzle] = []  // Liste pour toutes les énigmes

        // Parcourt chaque salle décrite dans le JSON
        for roomData in gameData.rooms {
            // Convertit les objets JSON en instances d'Item
            let items = roomData.items.map {
                Item(name: $0.name, description: $0.description, isTakable: $0.isTakable)
            }
            // Convertit les énigmes JSON en instances de Puzzle
            let puzzles = roomData.puzzles.map {
                Puzzle(id: $0.id, question: $0.question, correctAnswer: $0.correctAnswer)
            }
            // Ajoute ces énigmes à la liste globale
            allPuzzles.append(contentsOf: puzzles)
            // Convertit les personnages JSON en instances de Character
            let characters = roomData.characters.map {
                Character(name: $0.name, description: $0.description, dialogue: $0.dialogue )
            }
            // Crée un objet Room avec tous les éléments
            let room = Room(
                name: roomData.name,
                description: roomData.description,
                items: items,
                characters: characters,
                puzzles: puzzles,
                exits: roomData.exits,
                requiredItems: roomData.requiredItems,
                entryPuzzleId: roomData.entryPuzzleId,
                coordinates: roomData.coordinates
            )
            // Ajoute la salle au dictionnaire des salles
            rooms[roomData.name] = room
        }

        // Création du dictionnaire des énigmes par ID
        let puzzlesById = allPuzzles.reduce(into: [:]) { $0[$1.id] = $1 }
         // Retourne toutes les salles sous forme de tableau + dictionnaire des énigmes
        return (Array(rooms.values), puzzlesById)


    } catch {
        // Affiche une erreur si le décodage échoue
        print("Erreur lors du chargement du JSON : \(error)")
        return nil
    }
}

// MARK: - Introduction et règles

 

// Fonction pour afficher l'introduction avec bordure et couleur
func printIntroduction() {
    let couleurBleue = "\u{001B}[34m"
    let couleurRouge = "\u{001B}[31m"
    let reset = "\u{001B}[0m"
    
    let bordure = "\n\n##################################################"
    
    print("\(bordure)")
    print("\(couleurBleue)\n\nBienvenue dans l'aventure !\(reset)\n")
    print("Vous êtes un aventurier courageux qui explore un ancien temple rempli de mystères.")
    print("Votre mission est de résoudre les énigmes, trouver des objets précieux et découvrir les secrets du temple.")
    print("Mais attention, il faut être prudent et rapide car le temps passe vite !\n")
    print("\(couleurRouge)Préparez-vous à une aventure épique.\(reset)\n")
    print("Appuyez sur 'Enter' pour commencer.")
    print("\(bordure)")
}

// Fonction pour afficher les règles avec bordure et couleur
func printRules() {
    let bleu = "\u{001B}[34m"
    let vert = "\u{001B}[32m"
    let reset = "\u{001B}[0m"
    
    let bordure = String(repeating: "#", count: 70)
    
    print("\n\(bordure)")
    print("#\(String(repeating: " ", count: 68))#")
    print("#\(String(repeating: " ", count: 25))\(vert)📜 RÈGLES DU JEU\(reset)\(String(repeating: " ", count: 26))#")
    print("#\(String(repeating: " ", count: 68))#")
    print("\(bordure)\n")
    
    print("\(bleu)- Vous vous déplacez dans différentes salles avec : 'go [direction]'")
    print("- Pour observer votre environnement : 'look'")
    print("- Pour prendre un objet : 'take [objet]'")
    print("- Pour voir votre inventaire : 'inventory'")
    print("- Pour utiliser un objet : 'use [objet]'")
    print("- Pour voir votre position : 'showmap'")
    print("- Pour afficher l'aide : 'help'")
    print("- Pour quitter le jeu : 'quit'\(reset)\n")
    
    print("\(bordure)\n")
}


 
// MARK: - Fonctions de gestion du jeu
func startGame(rooms: [String: Room], startingRoomName: String, puzzlesById: [String: Puzzle]) {
    let couleurRouge = "\u{001B}[31m"
    let reset = "\u{001B}[0m"

    // Vérifie que la salle de départ existe dans le dictionnaire des salles.
// Si elle n'existe pas, affiche une erreur et termine l'exécution du programme.
    guard var currentRoom = rooms[startingRoomName] else {
    print("Erreur : la salle de départ '\(startingRoomName)' est introuvable.")
    exit(1)
}

    var inventory: [Item] = []
    // Définir une map (exemple 3x3, à adapter à ton jeu)
let map: [[String]] = [
    ["Salle9", "Salle2", "Salle3"],
    ["Salle8", "Salle1", "Salle4"],
    ["Salle7", "Salle6", "Salle5"]
]


 

// Trouver la position initiale du joueur dans la map
var playerX = 0
var playerY = 0
// Parcourt chaque ligne du tableau `map` avec son index `y`
for (y, row) in map.enumerated() {
    // Parcourt chaque élément (nom de salle) de la ligne avec son index `x`
    for (x, roomName) in row.enumerated() {
        // Si le nom de la salle correspond à la salle de départ
        if roomName == startingRoomName {
            // Enregistre les coordonnées de départ du joueur
            playerX = x
            playerY = y
        }
    }
}
// Demander le nom du joueur
    let playerName = askPlayerName()


//let startingRoomName = "Salle1"  // Nom fixe de la salle de départ
// Vérifie que la salle de départ existe dans le dictionnaire des salles.
// Si elle est introuvable, le programme s'arrête avec une erreur explicite.
guard let startingRoom = rooms[startingRoomName] else {
    fatalError("Salle de départ introuvable avec le nom \(startingRoomName)")
}

// Initialise le joueur avec son nom, la salle de départ et sa position sur la carte.
var player = Player(name: playerName, currentRoom: startingRoom, xPosition: playerX, yPosition: playerY)
// Fonction pour effacer un certain nombre de lignes précédentes dans la console (effet visuel)
func clearPreviousLines(_ count: Int) {
    for _ in 0..<count {
        // Déplace le curseur d'une ligne vers le haut et efface cette ligne
        print("\u{001B}[1A\u{001B}[2K", terminator: "")
    }
}


printIntroduction()
 _ = readLine() // Attente d'une touche pour commencer
printRules()

// Création d’un minuteur de jeu avec une durée de 300 secondes (5 minutes)
let timer = GameTimer(duration: 300,
                          onTick: { formattedTime in
        print("\u{001B}[s", terminator: "")
        print("\u{001B}[H", terminator: "")
        print("\u{001B}[2K", terminator: "")

         // Création des chaînes à afficher : le temps restant et le score
        let timeString = "⏳ Temps restant : \(formattedTime)"
        let scoreString = "🏅 Score : \(player.score)"
        let totalWidth = 80
        let padding = max(totalWidth - timeString.count - scoreString.count, 1)
        let spaces = String(repeating: " ", count: padding)

        print("\(timeString)\(spaces)\(scoreString)")
        print("\u{001B}[u", terminator: "")
        fflush(stdout)
    },

    // Callback appelé lorsque le temps est écoulé
    onTimeUp: {
        // Si le joueur n’est pas dans la salle finale ("Salle9"), il perd
        if player.currentRoom.name != "Salle9" {
            print("\n⌛\(couleurRouge) Vous avez perdu ! le temps est écoulé. Fin de la partie.\(reset)")
            savePlayerInfoToFile(player: player)// Sauvegarde les infos du joueur
        } else {
             // Sinon, il a gagné à temps
            print("\n🎉\(couleurRouge) Vous avez gagné avant que le temps ne soit écoulé !\(reset)")
            savePlayerInfoToFile(player: player)
        }
        exit(0)// Termine le jeu
    })
    

    timer.start()

var firstLook = true


    while true {
        // Vérifie si le temps est écoulé avant chaque action
        if timer.getTimeRemaining() <= 0 {
            print("\n⌛ Le temps est écoulé ! Fin de la partie.")
            break
        }
       // clearConsole() // Effacer la console à chaque tour

        if firstLook {
            handleLookCommand(currentRoom: currentRoom)
            firstLook = false
        }


        // Vérifie si le joueur a trouvé le trésor dans son inventaire pour terminer l'aventure
        if inventory.contains(where: { $0.name.lowercased() == "trésor" }) {
            print("\n🏆 Félicitations ! Vous avez trouvé le trésor et terminé l'aventure !")
            savePlayerInfoToFile(player: player)
            break
        }

// Vérifie s'il y a des puzzles non résolus dans la salle actuelle
 if !currentRoom.puzzles.isEmpty {
    for i in 0..<currentRoom.puzzles.count {
        let puzzle = currentRoom.puzzles[i]
        if !puzzle.solved {
            // Affiche le puzzle et indique qu'il y a un temps limite
            print("\n🧩 Puzzle : \(puzzle.question)")
            print("⏳ Vous avez 30 secondes pour répondre.")
            
            let group = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 0)
            var userInput: String? = nil
            // Lance une tâche en parallèle pour lire la réponse de l'utilisateur
            group.enter()
            DispatchQueue.global().async {
                print("\n💬 Votre réponse : ", terminator: "")
                userInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines)
                semaphore.signal()
                group.leave()
            }

            // Attend la réponse pendant un maximum de 30 secondes
            let result = semaphore.wait(timeout: .now() + 30)

            // Gère les différents cas selon la réponse ou le dépassement de temps
            if result == .timedOut {
                print("\n⏱️ Trop lent ! Vous perdez 10 points.")
                player.addPoints(-10)
            } else if let answer = userInput, !answer.isEmpty {
                if puzzle.checkAnswer(answer) {
                    // Bonne réponse
                    puzzle.solved = true
                    currentRoom.puzzles[i] = puzzle
                    player.addPoints(5)
                    print("\n✅ Vous avez résolu le puzzle ! (+5 points)")
                } else {
                    // Mauvaise réponse
                    print("\n❌ Mauvaise réponse. (-10 points)")
                    player.addPoints(-10)
                }
            } else {
                // Aucune réponse donnée
                print("\n⚠️ Aucune réponse. Vous perdez 10 points.")
                player.addPoints(-10)
            }
            
        }
    }
}


         //print("\n⏳ Temps restant : \(timer.formatTime(timer.getTimeRemaining()))")

        
        print("\n\n####################################################################\n")

        print("\n📜 Que voulez-vous faire ? (go, look, take, inventory,showmap, use, talk, help, quit)\n")
        // Si l'entrée est vide, on recommence à la prochaine itération de la boucle
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !input.isEmpty else {
            continue
        }

        let parts = input.split(separator: " ", maxSplits: 1).map { String($0) }
        let command = parts[0]
        let argument = parts.count > 1 ? parts[1] : ""

        

// Traitement des commandes utilisateur
switch command {

case "showmap":
    // Affiche la carte du jeu avec la position actuelle du joueur
    showMap(player: player, map: map)

case "go":
    // Vérifie si la direction spécifiée est valide, puis déplace le joueur
    if ["nord", "sud", "est", "ouest"].contains(argument) {
        handleGoCommand(argument, currentRoom: &currentRoom, rooms: rooms, inventory: inventory, puzzlesById: puzzlesById, player: &player, map: map)
    } else {
        print("Direction invalide.")
    }

case "look":
    // Affiche les détails de la salle actuelle
    handleLookCommand(currentRoom: currentRoom)

case "take":
    // Permet au joueur de ramasser un objet dans la salle
    handleTakeCommand(argument, currentRoom: &currentRoom, inventory: &inventory, player: &player)

case "inventory":
    // Affiche l'inventaire du joueur
    handleInventoryCommand(inventory: inventory)

case "talk":
    // Permet de parler à un personnage dans la salle
    handleTalkCommand(argument, currentRoom: currentRoom)

case "use":
    // Tente d’utiliser un objet (ici, la "clé") dans la salle actuelle
    handleUseCommand("clé", currentRoom: &currentRoom, inventory: inventory, player: &player)

case "help":
    // Affiche l'aide avec la liste des commandes disponibles
    printHelp()

case "quit", "exit", "quitter":
    // Quitte le jeu proprement
    print("\n👋 Merci d’avoir joué. À bientôt !")
    return

default:
    // Gère les commandes non reconnues
    print("Commande inconnue. Tapez 'help' pour voir les commandes disponibles.")
}}
 

// Arrête le timer à la fin du jeu
timer.stop()

}
func movePlayerToNewRoom(_ direction: String, player: inout Player, map: [[String]], currentRoom: inout Room, rooms: [String: Room]) {
    // Mise à jour de la position du joueur selon la direction
    switch direction {
    case "nord":
        if player.yPosition > 0 {
            player.yPosition -= 1
        }
    case "sud":
        if player.yPosition < map.count - 1 {
            player.yPosition += 1
        }
    case "est":
        if player.xPosition < map[0].count - 1 {
            player.xPosition += 1
        }
    case "ouest":
        if player.xPosition > 0 {
            player.xPosition -= 1
        }
    default:
        print("Direction inconnue.")
    }

    // Mettez à jour la salle actuelle
    if let nextRoomName = currentRoom.exits[direction], let nextRoom = rooms[nextRoomName] {
        currentRoom = nextRoom
        print("n🚶‍♂️ Tu es maintenant dans la salle : \(currentRoom.name)")
    } else {
        print("🚪 Pas de sortie dans cette direction.")
    }

    // Affichage de la nouvelle carte
    showMap(player: player, map: map)
}

//afficher la carte du monde du jeu 
func showMap(player: Player, map: [[String]]) {
    print("\n🗺️ Carte du monde du jeu :\n")

    for y in 0..<map.count {
        for x in 0..<map[y].count {
            let roomName = map[y][x]

            // Si on est sur la position du joueur
            if x == player.xPosition && y == player.yPosition {
                print("[🚶‍♂️]", terminator: "")
            } else if roomName != "" {
                // Extraire un numéro depuis le nom (ex: "Salle1" → "S1")
                let shortName: String
                let number = roomName.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if !number.isEmpty {
                     shortName = "S\(number)"
                } else {
                      shortName = String(roomName.prefix(2)) // fallback
}

                print("[\(shortName.padding(toLength: 2, withPad: " ", startingAt: 0))]", terminator: "")
            } else {
                print("[  ]", terminator: "")
            }
        }
        print("")
    }

    // Affichage de la salle actuelle
    print("\n🧭 Vous êtes dans \(player.currentRoom.name).")
    print("📍 Description : \(player.currentRoom.description)")
}




// Fonction pour gérer le déplacement du joueur vers une nouvelle salle
func handleGoCommand(
    _ direction: String,
    currentRoom: inout Room,
    rooms: [String: Room],
    inventory: [Item],
    puzzlesById: [String: Puzzle],
    player: inout Player,
    map: [[String]]
) {
    // Vérifie si une sortie existe dans la direction donnée
    guard let nextRoomName = currentRoom.exits[direction] else {
        print("🚪 Pas de sortie dans cette direction.")
        return
    }

    // Vérifie si une clé est nécessaire pour accéder au nord depuis Salle1
    if direction == "nord", currentRoom.name == "Salle1", !player.keyUsed {
        print("❌ Tu ne peux pas accéder à cette salle sans résoudre l'énigme et utiliser la clé.")
        return
    }

    // Vérifie que la salle de destination existe
    guard let nextRoom = rooms[nextRoomName] else {
        print("❌ Salle introuvable.")
        return
    }

    // Vérifie les conditions d'entrée spécifiques à certaines salles (ex : score requis)
    if nextRoom.name == "Salle3", player.score < 20 {
        print("🔒 Vous devez avoir au moins 20 points pour entrer dans cette salle. (Actuel : \(player.score))")
        return
    }

    // Vérifie si l'entrée à la salle est bloquée par une énigme non résolue
    let playerItemNames = inventory.map { $0.name.lowercased() }
    if !nextRoom.canEnter(withPlayerItems: playerItemNames, puzzlesById: puzzlesById) {
        if let puzzleId = nextRoom.entryPuzzleId,
           let puzzle = puzzlesById[puzzleId],
           !puzzle.solved {

            // Pose l'énigme au joueur
            puzzle.askQuestion()
            print("Votre réponse : ", terminator: "")
            if let userAnswer = readLine(), puzzle.checkAnswer(userAnswer) {
                print("✅ Enigme résolue ! Vous pouvez entrer.")
            } else {
                player.addPoints(-10)  // Pénalité en cas de mauvaise réponse
                print("❌ Mauvaise réponse. L’énigme bloque l’entrée.")
                return
            }
        } else {
            return
        }
    }

    // Met à jour la salle actuelle du joueur
    currentRoom = nextRoom
    player.currentRoom = nextRoom
    updatePlayerPosition(for: &player, to: currentRoom, in: map)

    // Si la salle est visitée pour la première fois, accorde 10 points
    if !player.visitedRooms.contains(nextRoom.name) {
        player.visitedRooms.insert(nextRoom.name)
        player.addPoints(10)
        print("\n🎉 Nouvelle salle découverte ! Vous gagnez 10 points.\n")
    }

    // Débloque l'objet spécial si le joueur entre dans Salle8
    if nextRoom.name == "Salle8" {
        if let salle1 = rooms["Salle1"] {
            if let index = salle1.items.firstIndex(where: { $0.name.lowercased() == "miroir magique" }) {
                salle1.items[index].isTakable = true
                print("✨ Le miroir magique dans la Salle1 devient maintenant récupérable.")
            }
             
        }
    }

    print("\n🚶‍♂️ Tu es maintenant dans la salle : \(currentRoom.name)")
}


// Met à jour les coordonnées du joueur sur la carte en fonction de la salle
func updatePlayerPosition(for player: inout Player, to room: Room, in map: [[String]]) {
    for (y, row) in map.enumerated() {
        for (x, roomName) in row.enumerated() {
            if roomName == room.name {
                player.xPosition = x
                player.yPosition = y
                return
            }
        }
    }
}

//Fonction qui permet de visualiser la salle et tout ce qui a à l'interieur 
func handleLookCommand(currentRoom: Room) {
    print("\n\n🧭 Vous êtes dans \(currentRoom.name)")
    print("\n📍 Description : \(currentRoom.description)")
    
    if !currentRoom.items.isEmpty {
        print("\n🎒 Objets présents :")
        for item in currentRoom.items {
            print("- \(item.name) (Prenable : \(item.isTakable ? "oui" : "non"))")
        }
    }

    if !currentRoom.characters.isEmpty {
        print("\n🧑 Personnages présents :")
        for character in currentRoom.characters {
            print("- \(character.name): \(character.description)")
        }
    }

    let exits = currentRoom.exits.keys.joined(separator: ", ")
    print("\n🚪 Sorties disponibles : \(exits)")
}


func normalizeString(_ string: String) -> String {
    return string.applyingTransform(.toLatin, reverse: false)?
        .folding(options: .diacriticInsensitive, locale: .current) ?? string
}

func handleTakeCommand(_ itemName: String, currentRoom: inout Room, inventory: inout [Item], player: inout Player) {
    // Nettoyage de l'entrée, suppression des espaces et mise en minuscule
    let itemNameCleaned = itemName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    
    // Normalisation de l'entrée en supprimant les accents
    let normalizedItemName = itemNameCleaned.folding(options: .diacriticInsensitive, locale: .current)
    
    // Recherche de l'objet en normalisant les noms des objets également
    if let index = currentRoom.items.firstIndex(where: { $0.name.lowercased().folding(options: .diacriticInsensitive, locale: .current) == normalizedItemName }) {
        let item = currentRoom.items[index]
        
        if item.isTakable {
            inventory.append(item)
            currentRoom.items.remove(at: index)
            player.addPoints(5)
            print("✅ Vous avez pris : \(item.name)")
        } else {
            print("❌ Cet objet ne peut pas être pris.")
        }
    } else {
        print("❌ Objet non trouvé.")
    }
}

//fonction qui affiche l'inventaire
func handleInventoryCommand(inventory: [Item]) {
    print("🎒 Inventaire :")
    if inventory.isEmpty {
        print("- (vide)")
    } else {
        for item in inventory {
            print("- \(item.name)")
        }
    }
}

//fonction qui permet de discuter avec les personnages
func handleTalkCommand(_ characterName: String, currentRoom: Room) {
    if characterName.isEmpty {
        print("🗣️ Avec qui veux-tu parler ?")
        return
    }
    if let character = currentRoom.characters.first(where: {
        $0.name.compare(characterName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }) {
        if !character.dialogue.isEmpty {
            print("💬 \(character.name) :")
            for line in character.dialogue {
                print(line)
            }
        } else {
            print("🤐 \(character.name) n’a rien à dire.")
        }
    } else {
        print("❌ Personnage introuvable.")
    }
}

//fonction qui permet d'utiliser les objets
func handleUseCommand(_ itemName: String, currentRoom: inout Room, inventory: [Item], player: inout Player) {
    let lowerItem = itemName.lowercased()

    // Vérifie si l'objet est bien dans l'inventaire
    if lowerItem == "clé", inventory.contains(where: { $0.name.lowercased() == "clé" }) {
        switch currentRoom.name {
        case "Salle1":
            print("🔓 Vous utilisez la clé. Une porte s’ouvre au nord !")
            currentRoom.exits["nord"] = "Salle2"
            player.keyUsed = true
        
        case "Salle8":
            // Résolution du puzzle si nécessaire
            if let puzzle = currentRoom.puzzles.first(where: { !$0.solved }) {
                print("⚡ Résolvez l'énigme pour ouvrir la porte :")
                puzzle.askQuestion() // Affiche la question de l'énigme
                if let playerAnswer = readLine() {
                    if puzzle.checkAnswer(playerAnswer) {
                        print("✅ L'énigme est résolue ! Vous pouvez maintenant utiliser la clé.")
                        puzzle.solved = true  // Marque le puzzle comme résolu
                    } else {
                        print("❌ Mauvaise réponse, essayez encore.")
                    }
                }
            } else {
                print("🔓 Vous utilisez la clé. Une porte s'ouvre au nord vers la sortie !")
                currentRoom.exits["nord"] = "Salle9"
                player.keyUsed = true
            }
        
        default:
            print("❌ Vous ne pouvez pas utiliser cela ici.")
        }
    } else {
        print("❌ Vous n’avez pas cet objet dans votre inventaire.")
    }
}



//afficher l'aide
func printHelp() {
    print("""
    📘 Commandes disponibles :
    - go <direction> : Aller dans une direction (ex: go nord)
    - look : Observer la salle actuelle
    - take <objet> : Prendre un objet
    - inventory : Voir votre inventaire
    - showmap : Voir votre position dans le monde du jeu 
    - use <objet> : Utiliser un objet
    - talk <personnage> : Parler à un personnage
    - help : Afficher cette aide
    - quit : Quitter le jeu
    """)
}

func clearConsole() {
    print("\u{001B}[2J")
    print("\u{001B}[0;0H")
}


// MARK: - Programme principal
// Si les données du jeu sont correctement chargées...
if let (roomList, puzzlesById) = loadGameData() {

    // Crée un dictionnaire des salles avec leur nom comme clé
    let roomDict = Dictionary(uniqueKeysWithValues: roomList.map { ($0.name, $0) })

    // Démarre le jeu depuis la salle "Salle1"
    startGame(rooms: roomDict, startingRoomName: "Salle1", puzzlesById: puzzlesById)

} else {
    // Affiche une erreur si le chargement a échoué
    print("Échec du chargement des données du jeu.")
}


