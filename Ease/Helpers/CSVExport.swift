//
//  CSVExport.swift
//  Ease
//
//  Created by Dorcas Shee on 15/9/26.
//
import Foundation

enum CSVExport {
    
    static func export(transactions: [Transaction]) -> URL? {
        //1. CSV string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Header
        var csv = "Date,Type,Description,Section,Category,Payee,Amount,IsRecurring\n"
        
        for trsn in transactions.sorted(by: { $0.date < $1.date }) {
            let fields: [String] = [
                dateFormatter.string(from: trsn.date),
                trsn.category.transactionType.rawValue.capitalized,
                escape(trsn.desc ?? ""),
                escape(trsn.category.parent?.name ?? ""),
                escape(trsn.category.name),
                escape(trsn.payee?.name ?? ""),
                String(format: "%.2f", trsn.amount),
                trsn.isRecurring ? "Recurring" : "One-time"
            ]
            
            csv += fields.joined(separator: ",") + "\n"
        }
        
        do {
            let timestampFormatter = DateFormatter()
            timestampFormatter.dateFormat = "yyyyMMdd_HHmm"
            let timestamp = timestampFormatter.string(from: Date())
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Ease_Transactions_\(timestamp).csv")
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    // Helpers
    private static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else { return field }
        
        let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escapedField)\""
    }
}
