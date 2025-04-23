// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "jeu-aventure",
    platforms: [
        .macOS(.v10_15), // ou ajustez la version macOS si nécessaire
    ],
    products: [
        .executable(name: "jeu-aventure", targets: ["jeu-aventure"]),
    ],
    targets: [
        .executableTarget(
            name: "jeu-aventure",
            path: "Sources/jeu-aventure"
        ),
        // Si vous avez des tests à l'avenir, vous pouvez ajouter un bloc comme ceci :
        // .testTarget(
        //     name: "jeu-aventureTests",
        //     dependencies: ["jeu-aventure"],
        //     path: "Tests"
        // )
    ]
)
