//
//  ContentView.swift
//  ios_project
//
//  Created by Dinh Phi Long Nguyen on 2022-10-11.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class GlobalString: ObservableObject {
    @Published var tempWords: [String] = [String]()
    @Published var wordToGuess: String = ""
    @Published var guessedWord: [String] = [String]()
    @Published var definition : String = ""

    @Published var ScoreSystem : [Int : Int] =
    [
        1 : 5,
        2 : 10,
        3 : 30,
        4 : 50,
        5 : 100,
    ]
    
    @Published var guessCount : Int = 5;
    @Published var gameContinue : Bool = true;
    @Published var win: Bool = false;

    @Published var userScore: Int = 0;
    @Published var userEmail: String = "";
    
    func newGame() {
        WordAPI().loadData(completion: { word in
            self.wordToGuess = word.word.uppercased()
            self.tempWords = [String]()
            for _ in self.wordToGuess {
                self.tempWords.append("_")
            }
            DefinitionAPI().loadData(completion: {def in
                self.definition = def.definition
            }, word: self.wordToGuess)
        })
        
        self.gameContinue = true
        self.win = false
        self.guessedWord = [String]()
        self.guessCount = 5

        fetchUserScoreAndEmail()
    }

    func fetchUserScoreAndEmail() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser

        // check if user is logged in
        if user == nil {
            print("User is not logged in")
        } else {
            print("User is logged in")
        }

        // get user email and scor
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            let email = currentUser.email
            let uid = currentUser.uid
            self.userEmail = email!
            db.collection("users").document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    self.userScore = document.data()?["score"] as? Int ?? 0
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject var globalString: GlobalString = GlobalString()
    
    @State private var moves: [String] = ["", "", "", "", "", "", "", "", ""]
    // there are 9 possible views
    @State private var endGameText: String = "TicTacToe"
    // when the game ends this is the message
    @State private var gameEnded: Bool = false
    // Boolean to see if the game has ended or not
    private var ranges: [Range<Int>] = [(0..<3), (3..<6), (6..<9)]
    // ranges 1 row 2 row 3 row
    
    var body: some View {
        
        TabView {
            NavigationView {
                VStack {
                    HStack {
                        //Hang man
                        NavigationLink(destination: {
                            HangmanGame(hangmanVariables: globalString, showingAlert: false)

                        }){VStack{
                            Image(systemName: "w.square.fill")
                            Text("Hangman")
                        }
                        }.padding(20)

                        // TicTacToe
                        NavigationLink(destination: {
                            VStack{
                                Text(endGameText)
                                    .alert(endGameText, isPresented: $gameEnded){
                                        Button("Reset", role: .destructive, action: resetGame)
                                    }
                                Spacer()
                                // Grid
                                ForEach(ranges, id: \.self){
                                    range in HStack{
                                        ForEach(range, id: \.self){
                                            i in XOButton(letter: $moves[i])
                                                .simultaneousGesture(
                                                    TapGesture()
                                                        .onEnded{
                                                            _ in playerTap(index: i)
                                                        }
                                                )
                                        }
                                    }
                                }
                                Spacer()
                                // Grid
                                Button("Reset", action: resetGame)
                            }
                        }) {
                            VStack{
                                Image(systemName: "x.circle.fill")
                                Text("TikTacToe")
                            }
                        }.padding(20)
                        Spacer()
                        Spacer()
                    }.padding(20)
                    Spacer()
                }
//                .navigationTitle("Main Menu")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            VStack {
                                Text("Welcome").font(.headline)
                                Text("hello " + globalString.userEmail)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .tabItem{
                Text("Hello")
            }
            
            ScoreBoard()
                .tabItem{
                    Text("Scoreboard")
                }
            
            LoginView()
                .tabItem{
                    Text("Hi")
                }
        }
        .onAppear(perform: {
            globalString.fetchUserScoreAndEmail()
        })
        
    }
    
    func playerTap(index: Int){
        if moves[index] == ""{
            moves[index] = "X"
            botMove()
        }
        
        for letter in ["X", "O"]{
            if checkWinner(list: moves, letter: letter){
                endGameText = "\(letter) has won!"
                gameEnded = true
                break
            }
        }
    }
    
    func botMove(){
        var availableMoves: [Int] = []
        var movesLeft = 0
        
        for move in moves{
            if move == ""{
                availableMoves.append(movesLeft)
            }
            movesLeft += 1
        }
        
        if availableMoves.count != 0{
            moves[availableMoves.randomElement()!] = "0"
        }
    }
    
    func resetGame(){
        endGameText = "TicTacToe"
        moves = ["", "", "", "", "", "", "", "", ""]
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



