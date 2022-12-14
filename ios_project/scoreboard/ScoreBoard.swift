//
//  ScoreBoard.swift
//  ios_project
//
//  Created by Dinh Phi Long Nguyen on 2022-11-23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct ScoreBoard: View {
    
    @State var users = [User]()
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color(red: 242/255, green: 225/255, blue: 207/255).edgesIgnoringSafeArea(.all)
                List(users.indices, id: \.self) { index in
                    
                    if users[index].email == Auth.auth().currentUser?.email {
                        HStack {
                            Text("\(index + 1).")
                            Text(users[index].email)
                            Spacer()
                            Text("\(users[index].score)")
                        }.foregroundColor(.green)
                            .listRowBackground(Color.indigo)
                            .listRowSeparator(.visible)
                    } else {
                        HStack {
                            Text("\(index + 1).")
                            Text(users[index].email)
                            Spacer()
                            Text("\(users[index].score)")
                        }.foregroundColor(.white)
                        .listRowBackground(Color.indigo)
                        
                    }
                    
                }
                
                .scrollContentBackground(.hidden)
                
                .navigationTitle("Score Board")
                .onAppear(perform: loadData)
                
            }
            
        }
        
    }
    
    func loadData() {
        let db = Firestore.firestore()
        db.collection("users").order(by: "score", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.users = documents.map { (queryDocumentSnapshot) -> User in
                let data = queryDocumentSnapshot.data()
                let email = data["email"] as? String ?? ""
                let score = data["score"] as? Int ?? 0
                let id = data["id"] as? String ?? ""
                return User(id: id, email: email, score: score)
            }
        }
    }
    
}

struct ScoreBoard_Previews: PreviewProvider {
    static var previews: some View {
        ScoreBoard()
    }
}
