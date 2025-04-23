// Importation du module Foundation, nécessaire pour utiliser certaines fonctionnalités de base de Swift (comme les chaînes de caractères, collections, etc.).
import Foundation

// Déclaration de la classe Item, représentant un objet dans le jeu.
class Item {
    
    // Propriété contenant le nom de l'objet.
    var name: String
    
    // Propriété contenant la description de l'objet.
    var description: String
    
    // Booléen indiquant si l'objet peut être pris (ajouté à l'inventaire) ou non.
    var isTakable: Bool

    // Initialisateur pour créer un nouvel objet avec un nom, une description et une information de "prenable".
    init(name: String, description: String, isTakable: Bool) {
        self.name = name
        self.description = description
        self.isTakable = isTakable
    }
}
