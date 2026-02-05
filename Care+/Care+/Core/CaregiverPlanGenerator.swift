import Foundation

struct CaregiverSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let priority: Int // 1=low, 2=medium, 3=high
}

enum MedicalReportType: String {
    case cardiology
    case hematology
    case generic
}

struct CaregiverPlanGenerator {
    static func inferReportType(from fileName: String) -> MedicalReportType {
        let lower = fileName.lowercased()
        if lower.contains("cardio") || lower.contains("ecg") || lower.contains("cuore") {
            return .cardiology
        }
        if lower.contains("emato") || lower.contains("sangue") || lower.contains("emocromo") {
            return .hematology
        }
        return .generic
    }

    static func generateSuggestions(from fileName: String) -> [CaregiverSuggestion] {
        let type = inferReportType(from: fileName)
        switch type {
        case .cardiology:
            return [
                CaregiverSuggestion(title: "Monitorare la pressione", detail: "Misurare la pressione 2 volte al giorno per 7 giorni.", priority: 2),
                CaregiverSuggestion(title: "Ridurre sforzi intensi", detail: "Evitare attività fisiche intense fino al prossimo controllo.", priority: 1),
                CaregiverSuggestion(title: "Programmare visita cardiologica", detail: "Prenotare una visita di controllo entro 2 settimane.", priority: 3)
            ]
        case .hematology:
            return [
                CaregiverSuggestion(title: "Controllo emocromo", detail: "Ripetere analisi del sangue tra 10-14 giorni.", priority: 2),
                CaregiverSuggestion(title: "Idratazione", detail: "Assicurare una buona idratazione giornaliera.", priority: 1)
            ]
        case .generic:
            return [
                CaregiverSuggestion(title: "Organizzare documenti", detail: "Conservare il referto e annotare sintomi/variazioni.", priority: 1)
            ]
        }
    }
}
