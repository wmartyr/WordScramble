//
//  ContentView.swift
//  WordScramble
//
//  Created by Woodrow Martyr on 8/1/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var allWordsArray = [String]()
    @State private var wordScore = 0
    @State private var letterScore = 0
    @State private var averageScore = 0.0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    Text("Number of words: \(wordScore)")
                    Text("Total letters: \(letterScore)")
                    Text("Average letters per word: \(averageScore, specifier: "%.2f")")
                }
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK"){}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart", action: restartGame)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isLong(word: answer) else {
            wordError(title: "Word is too short", message: "Words have to be at least 3 letters.")
            return
        }
         
        guard isDifferent(word: answer) else {
            wordError(title: "Word is the same", message: "You cannot use the root word.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        wordScore += 1
        letterScore += answer.count
        averageScore = Double(letterScore) / Double(wordScore)
        newWord = ""
        
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWordsArray = startWords.components(separatedBy: "\n")
                rootWord = allWordsArray.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLong(word: String) -> Bool {
        !(word.count < 3)
    }
    
    func isDifferent(word: String) -> Bool {
        rootWord != word
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func restartGame() {
        rootWord = allWordsArray.randomElement() ?? "silkworm"
        usedWords = []
        wordScore = 0
        letterScore = 0
        averageScore = 0
    }
}

#Preview {
    ContentView()
}
