import Foundation

/**
 Методы для получения времени в том или ином виде и ключей API.
 */
protocol TimeManaging {
    /// Возвращает время в полночь понедельника.
    /// - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
    func getMonday(for weekOffset: Int) -> Date
    
    /**
     Создает ключ API для получения расписания.
     - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
     - returns: строковое представление ключа.
     Ключ представляет собой время в полночь понедельника с миллисекундами в формате Unix epoch.
     */
    func getApiTimeKey(for weekOffset: Int) -> String
    
    /**
     Возвращает дату начала и конца недели.
     - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
     */
    func getWeekBoundaries(for weekOffset: Int) -> String
    
    /// Возвращает номер текущего дня недели.
    func getCurrentWeekDay() -> Int

    /// Возвращает время начала и конца пары.
    /// - parameter lessonNumber: номер пары.
    func getTimeBoundaries(for lessonNumber: Int) -> String
    
    /// Возвращает номер текущей пары.
    func getCurrentLessonNumber() -> Int


}

extension TimeManaging {
    func getTimeBoundaries(for lessonNumber: Int) -> String {
        switch lessonNumber {
        case 1:
            return "8:30-10:00"
        case 2:
            return "10:10-11:40"
        case 3:
            return "12:00-13:30"
        case 4:
            return "13:40-15:10"
        case 5:
            return "15:20-16:50"
        case 6:
            return "17:00-18:30"
        case 7:
            return "18:40-20:10"
        case 8:
            return "20:15-21:45"
        default:
            return ""
        }
    }
}


final class TimeManager: TimeManaging {

    // MARK: - Public Properties

    static let shared = TimeManager()
    
    // MARK: - Private Properties

    private let calendar = Calendar(identifier: .iso8601)

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Methods

    func getMonday(for weekOffset: Int) -> Date {
        let date = Date()
        
        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        let monday = calendar.date(from: components)!
        return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: monday)!
    }

    func getApiTimeKey(for weekOffset: Int) -> String {
        let monday = getMonday(for: weekOffset)
        return String(Int(monday.timeIntervalSince1970) * 1000)
    }

    func getWeekBoundaries(for weekOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"

        let monday = getMonday(for: weekOffset)
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!

        return "\(formatter.string(from: monday))-\(formatter.string(from: sunday))"
    }

    func getCurrentWeekDay() -> Int {
        return calendar.dateComponents([.weekday], from: Date()).weekday! - 1
    }

    func getCurrentLessonNumber() -> Int {
        let lessonsStartTimeInMinutes =
            [10 * 60, 11 * 60 + 40, 13 * 60 + 30,
             15 * 60 + 10, 16 * 60 + 50, 18 * 60 + 30,
             20 * 60 + 10, 24 * 60]
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let timeInMinutes = components.hour! * 60 + components.minute!
        return lessonsStartTimeInMinutes.firstIndex() { timeInMinutes <= $0 }!
    }


}
