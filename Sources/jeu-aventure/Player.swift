import Foundation

class Player {
    var name: String
    var inventory: [Item]
    var solvedPuzzles: Int
    var exploredRooms: Int
    var currentRoom: Room
    var score: Int  // ✅ Nouveau : score du joueur
    var xPosition: Int  // Position sur l'axe X
    var yPosition: Int  // Position sur l'axe Y
    var keyUsed: Bool = false 
    var visitedRooms: Set<String> = [] 

    init(name: String, inventory: [Item] = [], solvedPuzzles: Int = 0, exploredRooms: Int = 0, currentRoom: Room, xPosition: Int = 0, yPosition: Int = 0) {
        self.name = name
        self.inventory = inventory
        self.solvedPuzzles = solvedPuzzles
        self.exploredRooms = exploredRooms
        self.currentRoom = currentRoom
        self.score = 0  // ✅ Initialisation du score
        self.xPosition = xPosition
        self.yPosition = yPosition
    }

    // Méthode pour ajouter des points
    func addPoints(_ points: Int) {
        score += points
        if points >= 0 {
            print("🟢 Vous gagnez \(points) points ! Score actuel : \(score)")
        } else {
            print("🔴 Vous perdez \(-points) points ! Score actuel : \(score)")
        }
    }

    //  Méthode pour afficher le score
    func displayScore() {
        print("🎯 Score actuel : \(score) points")
    }
}

//fonction pour demander au joueur d'entrer son nom et prenom avec gestion d'erreur
func askPlayerName() -> String {
    var firstName: String = ""
    var lastName: String = ""

    func isValidName(_ name: String) -> Bool {
        let pattern = "^[A-Za-zÀ-ÖØ-öø-ÿ\\- ]+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.firstMatch(in: name, options: [], range: range) != nil
    }

    repeat {
        print("👤 Entrez votre prénom : ", terminator: "")
        firstName = (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if firstName.isEmpty {
            print("⚠️ Le prénom ne peut pas être vide. Veuillez réessayer.")
        } else if !isValidName(firstName) {
            print("⚠️ Le prénom ne doit contenir que des lettres. Veuillez réessayer.")
            firstName = ""
        }
    } while firstName.isEmpty

    repeat {
        print("👤 Entrez votre nom : ", terminator: "")
        lastName = (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if lastName.isEmpty {
            print("⚠️ Le nom ne peut pas être vide. Veuillez réessayer.")
        } else if !isValidName(lastName) {
            print("⚠️ Le nom ne doit contenir que des lettres. Veuillez réessayer.")
            lastName = ""
        }
    } while lastName.isEmpty

    return "\(firstName) \(lastName)"
}

