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

    var body: some View {
        NavigationView {
            VStack {
                //MARK: - add new task section
                HStack {
                    TextField("Enter new task...", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())  //adds rounded border style to text field
                        .padding(.leading, 10)

                    Button(action: addTask) {                           //button to add a new task
                        Image(systemName: "plus.circle.fill")          //plus icon
                            .font(.title)
                            .foregroundColor(newTaskTitle.isEmpty ? .gray : .blue) //button color changes based on input
                    }
                    .disabled(newTaskTitle.isEmpty)                    //disables button if text field is empty
                }
                .padding()
                
                //MARK: - due date
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
                        .opacity(tasks[taskIndex].dueDate == nil ? 0.5 : 1.0) // Dim if no due date is set

                        HStack {
                            Button("Clear Due Date") {
                                clearDueDate(for: taskIndex)  // Function to remove the due date
                            }
                            .foregroundColor(.red)

                            Button("Close") {
                                if let selectedTask = tasks.first(where: { $0.id == selectedTaskID }) {
                                        selectTask(selectedTask)  // Call the function to toggle selection
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
                    ForEach(tasks) { task in                           //loops through each task in the array
                        HStack {
                            Button(action: {                           //toggle task completion when tapped
                                toggleTaskCompletion(task) //marks task as complete/incomplete
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray) //green if completed
                            }
                            .buttonStyle(PlainButtonStyle()) // Removes button highlight effect
                            
                            VStack(alignment: .leading) {
                                Text(task.title)                          //display the task title with a strikethrough if completed
                                    .strikethrough(task.isCompleted, color: .gray)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                                    .animation(.easeInOut, value: task.isCompleted)         //smooth animation on completion toggle
                                
                                if let dueDate = task.dueDate {
                                    Text(formatDate(dueDate))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture {
                                selectTask(task) //opens the date picker
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)                    //enables swipe-to-delete functionality

                }
                .listStyle(PlainListStyle())                          //plain list style for cleaner look
            }
            .navigationTitle("Momentum Tasks")                        //title displayed in the navigation bar
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
