import Foundation
/// Отвечает за загрузку данных по сети
protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, responce, error in
            //check for error
            if let error = error {
                handler(.failure(error))
                return
            }
            
            //check for respomce code
            if let responce = responce as? HTTPURLResponse,
               responce.statusCode < 200 || responce.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else {
                return
            }
            handler(.success(data))
        }
        
        task.resume()
    }
}
