
#if os(Linux)
    import CSQLiteLinux
#else
    import CSQLiteDarwin
#endif

import Foundation

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public enum DataType {
    case String
    case Float
    case Integer
    case Blob
    case Null
    case Double
}

public enum ActionType {
    case CreateTable
    case CreateIndex
    case AddColumn
}

public class Value {
    
    var floatValue: Float!
    var intValue: Int!
    var stringValue: String!
    var doubleValue: Double!
    var blobValue: Data!
    var type: DataType
    
    init(_ value: Any) {
        let mirror = Mirror(reflecting: value)
        if mirror.subjectType == String.self {
            type = .String
            stringValue = value as! String
        } else if (mirror.subjectType == Float.self) {
            type = .Float
            floatValue = value as! Float
        } else if (mirror.subjectType == Double.self) {
            type = .Double
            doubleValue = value as! Double
        } else if (mirror.subjectType == Data.self) {
            type = .Blob
            blobValue = value as! Data
        } else if (mirror.subjectType == Int.self) {
            type = .Integer
            intValue = value as! Int
        } else {
            type = .Null
        }
    }
    
}

public class Action {
    
    var builtStatement: String
    var actionType: ActionType
    
    init(createTable: String) {
        actionType = .CreateTable
        builtStatement = "CREATE TABLE IF NOT EXISTS \(createTable) (_Id_ TEXT PRIMARY KEY, _timestamp_ TEXT); "
    }
    
    init(createIndexOnTable: String, keyColumnName: String, ascending: Bool) {
        actionType = .CreateIndex
        
        if ascending {
            builtStatement = "CREATE INDEX IF NOT EXISTS idx_\(createIndexOnTable)_\(keyColumnName) ON \(createIndexOnTable) (\(keyColumnName) ASC);"
        } else {
            builtStatement = "CREATE INDEX IF NOT EXISTS idx_\(createIndexOnTable)_\(keyColumnName) ON \(createIndexOnTable) (\(keyColumnName) DESC);"
        }
        
    }
    
    init(addColumn: String, type: DataType, table: String) {
        
        self.actionType = .AddColumn
        
        switch type {
        case .String:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) TEXT;"
        case .Float:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) NUMERIC;"
        case .Double:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) REAL;"
        case .Integer:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) INTEGER;"
        case .Blob:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) BLOB;"
        default:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) BLOB;"
        }
        
    }
    
}

public class SWSQLite {
    
    var db: OpaquePointer?
    
    public func open(databasePath: String) -> Bool {
        let result = sqlite3_open(databasePath, &db);
        if result != SQLITE_OK {
            return false;
        } else {
            return true;
        }
    }
    
    public func close() {
        sqlite3_close(db)
        db = nil;
    }
    
    public func execute(sql: String, params:[Any]) {
        
        var values: [Value] = []
        for o in params {
            values.append(Value(o))
        }
        
    }
    
    public func execute(actions: [Action]) {
        
    }
    
    public func query(sql: String, params:[Any]) -> [[String:Value]] {
        return [[:]]
    }
    
    private func bind(stmt: OpaquePointer?, params:[Value]) {
        
        var paramCount = sqlite3_bind_parameter_count(stmt)
        let passedIn = params.count
        
        if(Int(paramCount) != passedIn) {
            // error
        }
        
        paramCount = 1;
        
        for v in params {
            
            switch v.type {
            case .String:
                sqlite3_bind_text(stmt, paramCount, v.stringValue,Int32(v.stringValue!.lengthOfBytes(using: .utf8)) , SQLITE_TRANSIENT)
            case .Null:
                sqlite3_bind_null(stmt, paramCount)
            case .Blob:
                sqlite3_bind_blob(stmt, paramCount, [UInt8](v.blobValue!), Int32(v.blobValue!.count), SQLITE_TRANSIENT)
            case .Integer:
                sqlite3_bind_int64(stmt, paramCount, Int64(v.intValue))
            case .Float:
                sqlite3_bind_double(stmt, paramCount, Double(v.floatValue))
            case .Double:
                sqlite3_bind_double(stmt, paramCount, Double(v.doubleValue))
            }
            
            paramCount += 1
            
        }
        
    }
    
}
