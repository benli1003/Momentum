import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://127.0.0.1:8000/api/tasks/"

    // MARK: - Shared ISO8601 decoder
    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let isoFormatter = ISO8601DateFormatter()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try with fractional seconds first
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            // Fallback to without fractional seconds
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }

        return decoder
    }

    // MARK: - createTask
    func createTask(title: String, token: String, completion: @escaping (Result<Task, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let newTask = ["title": title]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: newTask)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decoder = self.makeDecoder()
                let task = try decoder.decode(Task.self, from: data)
                completion(.success(task))
            } catch {
                print("Decoding error:", error)
                print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - fetchTasks
    func fetchTasks(token: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decoder = self.makeDecoder()
                let tasks = try decoder.decode([Task].self, from: data)
                completion(.success(tasks))
            } catch {
                print("Decoding error:", error)
                print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - updateTask
    func updateTask(id: Int, title: String?, isCompleted: Bool?, dueDate: Date?, token: String, completion: @escaping (Result<Task, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(id)/") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [:]
        if let title = title { body["title"] = title }
        if let isCompleted = isCompleted { body["is_completed"] = isCompleted }
        if let dueDate = dueDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            body["due_date"] = formatter.string(from: dueDate)
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decoder = self.makeDecoder()
                let updatedTask = try decoder.decode(Task.self, from: data)
                completion(.success(updatedTask))
            } catch {
                print("Decoding error:", error)
                print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }
        }.resume()
    }
    // MARK: - deleteTask
    func deleteTask(id: Int, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(id)/") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }.resume()
    }

    
}

