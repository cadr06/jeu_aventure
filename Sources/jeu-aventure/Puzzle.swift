// Puzzle.swift
import Foundation
//classe puzzle pour les enigmes
class Puzzle {
    var id: String
    var question: String
    var correctAnswer: String
    var solved: Bool

    init(id: String, question: String, correctAnswer: String) {
        self.id = id
        self.question = question
        self.correctAnswer = correctAnswer
        self.solved = false
    }

    // Affiche la question du puzzle
    func askQuestion() {
        print(question)
    }

    // Vérifie la réponse donnée par le joueur
    func checkAnswer(_ answer: String) -> Bool {
        if answer.lowercased() == correctAnswer.lowercased() {
            solved = true
            print("\nBonne réponse !")
            return true
        } else {
            print("\nMauvaise réponse, essayez encore.")
            return false
        }
    }

    // Pose la question et lit la réponse depuis la console
    func checkAnswer() -> Bool {
        askQuestion()
        print("Votre réponse : ", terminator: "")
        if let input = readLine() {
            return checkAnswer(input)
        } else {
            print("Erreur de lecture.")
            return false
        }
    }
}
