// Déclaration de la classe Character, représentant un personnage dans le jeu.
class Character {
    
    // Propriété pour le nom du personnage.
    var name: String
    
    // Propriété pour la description du personnage.
    var description: String
    
    // Booléen indiquant si le personnage est présent dans la salle ou non.
    var isPresent: Bool
    
    // Tableau de chaînes représentant les dialogues possibles du personnage.
    var dialogue: [String]

    // Initialisateur de la classe, utilisé pour créer une instance de Character avec les valeurs données.
    init(name: String, description: String, isPresent: Bool = true, dialogue: [String]) {
        // Affectation des valeurs aux propriétés de l'instance.
        self.name = name
        self.description = description
        self.isPresent = isPresent  // Par défaut à true si non spécifié.
        self.dialogue = dialogue
    }
}
