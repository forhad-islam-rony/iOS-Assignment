import SwiftUI

struct Candidate: Identifiable {
    let id = UUID()
    let name: String
    var votes: Int
    var color: Color
}

struct VotingSystemView: View {
    @State private var candidates = [
        Candidate(name: "Candidate A", votes: 0, color: .blue),
        Candidate(name: "Candidate B", votes: 0, color: .green),
        Candidate(name: "Candidate C", votes: 0, color: .orange)
    ]
    @State private var showWinner = false
    @State private var winnerName = ""
    
    var totalVotes: Int {
        candidates.reduce(0) { $0 + $1.votes }
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Voting System")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Total Votes: \(totalVotes)")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                if totalVotes > 0 {
                    PieChartView(candidates: candidates)
                        .frame(height: 200)
                        .padding(.horizontal)
                }
                
                List {
                    ForEach($candidates) { $candidate in
                        CandidateRow(candidate: $candidate, totalVotes: totalVotes, showWinner: $showWinner, winnerName: $winnerName, candidates: $candidates)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .frame(maxWidth: .infinity, maxHeight: 300)
                .cornerRadius(12)
                .padding(.horizontal, 10)
                
                Button(action: {
                    withAnimation {
                        candidates.indices.forEach { candidates[$0].votes = 0 }
                        showWinner = false
                        winnerName = ""
                    }
                }) {
                    Text("Reset Votes")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
            }
            .padding()
            
            if showWinner {
                WinnerView(winnerName: winnerName)
            }
        }
    }
}

struct CandidateRow: View {
    @Binding var candidate: Candidate
    var totalVotes: Int
    @Binding var showWinner: Bool
    @Binding var winnerName: String
    @Binding var candidates: [Candidate]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(candidate.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Votes: \(candidate.votes)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                withAnimation {
                    candidate.votes += 1
                    if totalVotes + 1 >= 20 {
                        determineWinner()
                        showWinner = true
                    }
                }
            }) {
                Text("Vote")
                    .padding()
                    .frame(width: 80)
                    .background(candidate.color)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func determineWinner() {
        if let winner = candidates.max(by: { $0.votes < $1.votes }) {
            winnerName = winner.name
        }
    }
}

struct PieChartView: View {
    let candidates: [Candidate]
    
    var body: some View {
        let totalVotes = candidates.reduce(0) { $0 + $1.votes }
        let chartData = candidates.map { candidate -> ChartSlice in
            let percentage = totalVotes > 0 ? (Double(candidate.votes) / Double(totalVotes)) * 100 : 0
            return ChartSlice(value: candidate.votes, color: candidate.color, label: "\(candidate.name): \(Int(percentage))%")
        }
        
        return GeometryReader { geometry in
            ZStack {
                ForEach(0..<chartData.count) { index in
                    PieSliceView(slice: chartData[index], startAngle: startAngle(for: index, in: chartData), endAngle: endAngle(for: index, in: chartData))
                }
            }
        }
    }
    
    private func startAngle(for index: Int, in slices: [ChartSlice]) -> Angle {
        let total = slices.prefix(index).map { $0.value }.reduce(0, +)
        return .degrees(Double(total) / Double(slices.map { $0.value }.reduce(0, +)) * 360)
    }
    
    private func endAngle(for index: Int, in slices: [ChartSlice]) -> Angle {
        startAngle(for: index + 1, in: slices)
    }
}

struct ChartSlice {
    let value: Int
    let color: Color
    let label: String
}

struct PieSliceView: View {
    let slice: ChartSlice
    let startAngle: Angle
    let endAngle: Angle
    
    var body: some View {
        ZStack {
            Path { path in
                let center = CGPoint(x: 100, y: 100)
                path.move(to: center)
                path.addArc(center: center,
                            radius: 100,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false)
            }
            .fill(slice.color)
        }
    }
}

struct WinnerView: View {
    let winnerName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Congratulations! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("\(winnerName) is the winner!")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.green.opacity(0.8))
                .cornerRadius(12)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView: View {
    var body: some View {
        VotingSystemView()
    }
}

#Preview {
    ContentView()
}
