import SwiftUI

struct GoalView: View {
    // In a real app, this would come from a ViewModel with persistence
    @State private var goals: [Goal] = [
        Goal(title: "유럽 여행", targetAmount: 3000000, currentAmount: 1200000, deadline: Date().addingTimeInterval(86400 * 90), type: .savings, color: "blue"),
        Goal(title: "맥북 프로 구매", targetAmount: 2500000, currentAmount: 500000, deadline: Date().addingTimeInterval(86400 * 30), type: .savings, color: "purple")
    ]
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(goals) { goal in
                        GoalCard(goal: goal)
                    }
                    
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("새 목표 추가")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("목표")
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goals: $goals)
            }
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(goal.title)
                .font(.title3)
                .fontWeight(.bold)
            
            HStack {
                Text("₩\(Int(goal.currentAmount))")
                    .foregroundColor(.primary)
                Spacer()
                Text("목표: ₩\(Int(goal.targetAmount))")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                        .cornerRadius(5)
                    
                    Rectangle()
                        .fill(Color.blue) // Use goal.color in real app
                        .frame(width: CGFloat(goal.progress) * geometry.size.width, height: 10)
                        .cornerRadius(5)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Text("D-\(daysUntil(goal.deadline))")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return max(0, components.day ?? 0)
    }
}

struct AddGoalView: View {
    @Binding var goals: [Goal]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var currentAmount = ""
    @State private var deadline = Date()
    @State private var type: GoalType = .savings
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("목표 정보")) {
                    TextField("목표 이름", text: $title)
                    Picker("유형", selection: $type) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("금액")) {
                    TextField("목표 금액", text: $targetAmount)
                        .keyboardType(.decimalPad)
                    TextField("현재 모은 금액", text: $currentAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("기한")) {
                    DatePicker("완료 목표일", selection: $deadline, displayedComponents: .date)
                }
            }
            .navigationTitle("새 목표")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    saveGoal()
                }
                .disabled(title.isEmpty || targetAmount.isEmpty)
            )
        }
    }
    
    private func saveGoal() {
        guard let target = Double(targetAmount) else { return }
        let current = Double(currentAmount) ?? 0
        
        let newGoal = Goal(
            title: title,
            targetAmount: target,
            currentAmount: current,
            deadline: deadline,
            type: type,
            color: "blue"
        )
        
        goals.append(newGoal)
        presentationMode.wrappedValue.dismiss()
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView()
    }
}
