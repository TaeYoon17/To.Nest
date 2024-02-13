import Foundation

func msgDataConverter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.locale = Locale(identifier: "ko_KR")
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

    if let currentDate = calendar.date(from: components) {
        let now = Date()
        
        if calendar.isDate(currentDate, inSameDayAs: now) {
            // 같은 날짜일 경우
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: date)
        } else {
            // 다른 날짜일 경우
            dateFormatter.dateFormat = "M/d hh:mm a"
            return dateFormatter.string(from: date)
        }
    }

    return ""
}

// 예제 사용법
let dateA = Date()
let dateB = Date().addingTimeInterval(86400) // 1 day later

let formattedDateA = formattedDate(date: dateA)
let formattedDateB = formattedDate(date: dateB)

print("Date A: \(formattedDateA)")
print("Date B: \(formattedDateB)")
