import SwiftUI

//MARK: - task model
struct Task: Identifiable {
    let id = UUID()             //unique identifier for each task
    var title: String           //the task description
    var isCompleted: Bool       //boolean to track if the task is completed
}

struct ContentView: View {
    //MARK: - state variables
    @State private var tasks: [Task] = []               //array to hold the list of tasks
    @State private var newTaskTitle: String = ""        //input field value for adding a new task

    var body: some View {
        NavigationView {
            VStack {
                //MARK: - add new task section
                HStack {
                    TextField("enter new task...", text: $newTaskTitle)
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

                //MARK: - task list
                List {
                    ForEach(tasks) { task in                           //loops through each task in the array
                        HStack {
                            Button(action: {                           //toggle task completion when tapped
                                toggleTaskCompletion(task)
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray) //green if completed
                            }

                            Text(task.title)                          //display the task title with a strikethrough if completed
                                .strikethrough(task.isCompleted, color: .gray)
                                .foregroundColor(task.isCompleted ? .gray : .primary)
                                .animation(.easeInOut, value: task.isCompleted) //smooth animation on completion toggle
                        }
                    }
                    .onDelete(perform: deleteTask)                    //enables swipe-to-delete functionality
                }
                .listStyle(PlainListStyle())                          //plain list style for cleaner look
            }
            .navigationTitle("momentum tasks")                        //title displayed in the navigation bar
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
}

//MARK: - preview
#Preview {
    ContentView()
}
