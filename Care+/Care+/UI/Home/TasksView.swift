import SwiftUI

struct TasksView: View {
    @State private var tasks: [TodoTask] = [
        TodoTask(id: 1, name: "Buy groceries", isDone: false),
        TodoTask(id: 2, name: "Walk the dog", isDone: true),
        TodoTask(id: 3, name: "Read a book", isDone: false)
    ]
    
    @State private var medications: [Medication] = [
        Medication(id: 1, name: "Vitamin C", isDone: true),
        Medication(id: 2, name: "Ibuprofen", isDone: false),
        Medication(id: 3, name: "Antibiotic", isDone: false)
    ]
    
    @State private var showAddTask: Bool = false
    @State private var newTaskName: String = ""
    @State private var newTaskDone: Bool = false
    // Controls the initial detent of the Add Task sheet
    @State private var addSheetDetent: PresentationDetent = .large
    
    private func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    private func deleteMedications(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
    }
    
    var iconColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Tasks")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button {
                    addSheetDetent = .large
                    showAddTask = true
                } label: {
                    Label("Add a new task", systemImage: "plus.circle.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.primary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            List {
                Section(header: Text("Tasks").foregroundStyle(AppTheme.textPrimary)) {
                    ForEach(tasks) { task in
                        Button {
                            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[idx].isDone.toggle()
                            }
                        } label: {
                            eventRow(task)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteTasks)
                }
                
                Section(header: Text("Medications").foregroundStyle(AppTheme.textPrimary)) {
                    ForEach($medications) { $med in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: med.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(med.isDone ? AppTheme.success : AppTheme.primaryMuted)
                                Text(med.name)
                                    .strikethrough(med.isDone, pattern: .solid, color: AppTheme.primaryMuted)
                                    .foregroundStyle(med.isDone ? AppTheme.primaryMuted : AppTheme.textPrimary)
                                Spacer()
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppTheme.stroke, lineWidth: 1))
                            .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 6)

                            HStack(spacing: 10) {
                                Button {
                                    med.isDone = false
                                } label: {
                                    Text("Not taken")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .background(AppTheme.warning)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                Button {
                                    med.isDone = true
                                } label: {
                                    Text("Taken")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .background(AppTheme.primary)
                                        .foregroundStyle(AppTheme.textOnSurfacePrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .onDelete(perform: deleteMedications)
                    
                    Button {
                        let newId = (medications.map { $0.id }.max() ?? 0) + 1
                        medications.append(Medication(id: newId, name: "New medication", isDone: false))
                    } label: {
                        HStack(spacing: 6) {
                            Text("Add medication")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(AppTheme.primary)
                            Image(systemName: "plus")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(AppTheme.primary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(AppTheme.surface2)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppTheme.stroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 6)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $showAddTask) {
            NavigationStack {
                Form {
                    Section("New Task") {
                        TextField("Task name", text: $newTaskName)
                        Toggle("Done", isOn: $newTaskDone)
                    }
                }
                .navigationTitle("Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            resetNewTaskForm()
                            showAddTask = false
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            let trimmed = newTaskName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            let newId = (tasks.map { $0.id }.max() ?? 0) + 1
                            tasks.append(TodoTask(id: newId, name: trimmed, isDone: newTaskDone))
                            resetNewTaskForm()
                            showAddTask = false
                        }
                        .disabled(newTaskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            // ✅ Apre full screen (large), ma poi puoi trascinare giù (medium) e chiudere
            .presentationDetents([.large, .medium], selection: $addSheetDetent)
            .presentationDragIndicator(.visible)
        }
    }
    
    private func resetNewTaskForm() {
        newTaskName = ""
        newTaskDone = false
    }
    
    func eventRow(_ task: TodoTask) -> some View {
        HStack {
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isDone ? AppTheme.success : AppTheme.primaryMuted)
            Text(task.name)
                .strikethrough(task.isDone, pattern: .solid, color: AppTheme.primaryMuted)
                .foregroundStyle(task.isDone ? AppTheme.primaryMuted : AppTheme.textPrimary)
            Spacer()
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppTheme.stroke, lineWidth: 1))
        .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 6)
    }
}

struct TodoTask: Identifiable {
    let id: Int
    let name: String
    var isDone: Bool
}

struct Medication: Identifiable {
    let id: Int
    let name: String
    var isDone: Bool
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}

