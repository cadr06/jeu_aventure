import Foundation

class GameTimer {
    private var timer: DispatchSourceTimer?
    private var timeRemaining: Int
    private let totalTime: Int
    private let onTick: ((String) -> Void)?
    private let onTimeUp: (() -> Void)?

    init(duration: Int, onTick: ((String) -> Void)? = nil, onTimeUp: (() -> Void)? = nil) {
        self.totalTime = duration
        self.timeRemaining = duration
        self.onTick = onTick
        self.onTimeUp = onTimeUp
    }

    func start() {
        let queue = DispatchQueue.global() // Utilisation d'une queue en background
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        // Définition de l'intervalle de répétition (chaque seconde)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        
        // Gestion de l'événement qui sera appelé à chaque tick (chaque seconde)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.timeRemaining -= 1
            let formatted = self.formatTime(self.timeRemaining)
            self.onTick?(formatted)
            
            if self.timeRemaining <= 0 {
                self.stop()
                self.onTimeUp?()
            }
        }
        
        // Démarre le timer
        timer?.resume()
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }

    public func getTimeRemaining() -> Int {
        return timeRemaining
    }

    func saveTimeRemaining() -> Int {
        return timeRemaining
    }

    func restoreTimeRemaining(_ time: Int) {
        timeRemaining = time
    }
}
