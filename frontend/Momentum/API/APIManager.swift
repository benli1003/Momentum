import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://127.0.0.1:8000/api/tasks/"  //endpoint

    //MARK: - createTask
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
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                let task = try decoder.decode(Task.self, from: data)
                completion(.success(task))
            } catch {
                print("Decoding error:", error)
                print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }

        }.resume()
    }
    //MARK: - fetchTask
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
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    let tasks = try decoder.decode([Task].self, from: data)
                    completion(.success(tasks))
                } catch {
                    print("Decoding error:", error)
                    print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                    completion(.failure(error))
                }

            }.resume()
        }
    
}
