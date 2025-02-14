import SwiftUI

//MARK: - task model
struct Task: Identifiable {
    let id = UUID()             //unique identifier for each task
    var title: String           //the task description
    var isCompleted: Bool       //boolean to track if the task is completed
    var dueDate: Date?          //optional due date
}

struct ContentView: View {
    //MARK: - state variables
    @State private var tasks: [Task] = []               //array to hold the list of tasks
    @State private var newTaskTitle: String = ""        //input field value for adding a new task
    @State private var selectedDueDate: Date = Date()   //store due date
    @State private var selectedTaskID: UUID? = nil      //store ID or nil
    @State private var selectedTask: Task? = nil        //stores the currently tapped task
    @State private var filterOption: FilterOption = .all //default filter
    @State private var sortAscending: Bool = true        //sort: true = Due First, false = Due Last
    @State private var showFilterMenu: Bool = false
    
    //MARK: - enum for filter
    enum FilterOption {
        case all
        case completed
        case incomplete
        case dueToday
        case overdue
        case upcoming
    }
    
    //MARK: - filtering and sorting
    var filteredAndSortedTasks: [Task] {
        var result = tasks

        // Filtering based on selected option
        switch filterOption {
        case .all:
            break // Show all
        case .completed:
            result = result.filter { $0.isCompleted }
        case .incomplete:
            result = result.filter { !$0.isCompleted }
        case .dueToday:
            result = result.filter {
                $0.dueDate != nil && Calendar.current.isDateInToday($0.dueDate!)
            }
        case .overdue:
            result = result.filter {
                $0.dueDate != nil && $0.dueDate! < Date()
            }
        case .upcoming:
            result = result.filter {
                $0.dueDate != nil && $0.dueDate! > Date()
            }
        }

        // Sort tasks based on due date
        result.sort { (task1, task2) -> Bool in
            guard let date1 = task1.dueDate, let date2 = task2.dueDate else {
                return sortAscending // Put tasks without due dates at the end
            }
            return sortAscending ? (date1 < date2) : (date1 > date2)
        }

        return result
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                //MARK: - filter and sort button
                HStack {
                    Spacer()
                    Button(action: { showFilterMenu.toggle() }) {
                        Image(systemName: "slider.horizontal.3") //icon for filter/sort
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                
                //MARK: - add new task section
                HStack {
                    TextField("Enter new task...", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(maxWidth: .infinity)
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(newTaskTitle.isEmpty ? .gray : .blue)
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
                .padding(.horizontal)

               

                // MARK: - filter & Sort Menu
                if showFilterMenu {
                    VStack {
                        // Filter Picker
                        Picker("Filter", selection: $filterOption) {
                            Text("All").tag(FilterOption.all)
                            Text("Completed").tag(FilterOption.completed)
                            Text("Incomplete").tag(FilterOption.incomplete)
                            Text("Due Today").tag(FilterOption.dueToday)
                            Text("Overdue").tag(FilterOption.overdue)
                            Text("Upcoming").tag(FilterOption.upcoming)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        
                        //sorting Button
                        Button(action: {
                            sortAscending.toggle()
                        }) {
                            HStack {
                                Text(sortAscending ? "Due First" : "Due Last")
                                Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                            }
                        }
                        .padding()
                        
                        //close Button
                        Button("Close") {
                            showFilterMenu = false
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                    .shadow(radius: 5)
                    .padding()
                }
                
                //MARK: - due date picker
                if let selectedTaskID = selectedTaskID, let taskIndex = tasks.firstIndex(where: { $0.id == selectedTaskID }) {
                    VStack {
                        Text("Due Date")
                            .font(.headline)
                            .padding()
                        
                        DatePicker("Select Due Date", selection: Binding(
                            get: { tasks[taskIndex].dueDate ?? Date() },
                            set: { newDate in updateDueDate(for: taskIndex, to: newDate) }
                        ), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .opacity(tasks[taskIndex].dueDate == nil ? 0.5 : 1.0)
                        
                        HStack {
                            Button("Clear Due Date") {
                                clearDueDate(for: taskIndex)
                            }
                            .foregroundColor(.red)
                            
                            Button("Close") {
                                if let selectedTask = tasks.first(where: { $0.id == selectedTaskID }) {
                                    selectTask(selectedTask)
                                }
                            }
                            .padding()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                    .shadow(radius: 5)
                    .padding()
                }
                
                //MARK: - task list
                List {
                    ForEach(filteredAndSortedTasks) { task in
                        HStack {
                            Button(action: { toggleTaskCompletion(task) }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .strikethrough(task.isCompleted, color: .gray)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                                    .animation(.easeInOut, value: task.isCompleted)
                                
                                if let dueDate = task.dueDate {
                                    Text(formatDate(dueDate))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture {
                                selectTask(task)
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(PlainListStyle())
            }
            .padding(.top, 10)
            .navigationTitle("Momentum Tasks") // ✅ Now correctly placed
        }
    }
        
    //MARK: - task management functions

    //add new task to list
    func addTask() {
        let newTask = Task(title: newTaskTitle, isCompleted: false)   //create a new task
        tasks.append(newTask)                                        //add it to the tasks array
        newTaskTitle = ""                                            //clear the input field after adding
    }

    //toggles the completion status of a task
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) { //find the index of the task
            tasks[index].isCompleted.toggle()                          //toggle its completion status
        }
    }

    //deletes tasks from the list based on their index
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)                              //remove the task(s) at the specified index
    }
    
    //set due date for tasks
    func selectTask(_ task: Task) {
        if selectedTaskID == task.id {
            selectedTaskID = nil
        }
        else {
            selectedTaskID = task.id
        }
    }
    
    //update due date
    func updateDueDate(for index: Int, to newDate: Date) {
        tasks[index].dueDate = newDate
    }

    //clear due date
    func clearDueDate(for index: Int) {
        tasks[index].dueDate = nil
    }

    //format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy" // Set format
        return formatter.string(from: date) // Convert date to string
    }
}

//MARK: - preview
#Preview {
    ContentView()
}
