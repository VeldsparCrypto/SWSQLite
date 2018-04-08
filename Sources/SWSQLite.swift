#if os(Linux)
    import CSQLiteLinux
#else
    import CSQLiteDarwin
#endif

import Dispatch
import Foundation

private var alphabet = Array("0123456789abcdef".characters)

func bytesToString(bytes: [UInt8]) -> String {
   
    var result = ""
    for byte in bytes {
        let highBits = Int( byte >> 4)
        let lowBits = Int( byte & 0x0F)
        result.append(alphabet[highBits])
        result.append(alphabet[lowBits])
    }
    return result;
    
}

func stringToBytes(string: String) -> [UInt8]? {
    return []
}

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public typealias Record = [String:Value]

public enum DataType {
    case String
    case Blob
    case Null
    case Int
    case Double
}

public enum ActionType {
    case CreateTable
    case CreateIndex
    case AddColumn
}

public enum SWSQLOp {
    case Insert
    case Update
    case Delete
}

public func uuid() -> String {
    return UUID().uuidString.lowercased()
}

public func timeuuid() -> String {
    return timeuuid(offset: 0);
}

var sequence: UInt8 = 0
let lock: DispatchQueue = DispatchQueue(label: "uuid-sync-queue")

private func timeuuid_sync_byte () -> UInt8 {
    
    var value: UInt8 = 0
    lock.sync {
        if sequence == 255 {
            sequence = 0
        } else {
            sequence+=1
        }
        value = sequence
    }
    return value;
}

private func hex(v: Int64) -> String {
    var s = ""
    var i = v
    for _ in 0..<MemoryLayout<Int64>.size*2 {
        s = String(format: "%x", i & 0xF) + s
        i = i >> 4
    }
    return s
}

public func timeuuid(offset: TimeInterval) -> String {
    
    let newUUID = uuid().replacingOccurrences(of: "-", with: "")
    let time = Date.init(timeIntervalSinceNow: offset)
    let timeValue = Int64((time.timeIntervalSince1970)*1000000)
    let encodedTime = hex(v: timeValue)
    let seq = bytesToString(bytes: [timeuuid_sync_byte()])
    
    let concat_value = encodedTime+seq+newUUID
    
    // 8-4-4-4-12
    var start = concat_value.index(concat_value.startIndex, offsetBy: 0)
    var end = concat_value.index(start, offsetBy: 8)
    var range = start..<end
    var timeuid = "\(concat_value.substring(with: range))-"
    start = end
    end = concat_value.index(start, offsetBy: 4)
    range = start..<end
    timeuid = timeuid + "\(concat_value.substring(with: range))-"
    start = end
    end = concat_value.index(start, offsetBy: 4)
    range = start..<end
    timeuid = timeuid + "\(concat_value.substring(with: range))-"
    start = end
    end = concat_value.index(start, offsetBy: 4)
    range = start..<end
    timeuid = timeuid + "\(concat_value.substring(with: range))-"
    start = end
    end = concat_value.index(start, offsetBy: 12)
    range = start..<end
    timeuid = timeuid + "\(concat_value.substring(with: range))"

    return timeuid
    
}

public class Value {
    
    var stringValue: String!
    var blobValue: Data!
    var numericValue: NSNumber!
    var type: DataType
    
    public init(_ value: Any) {
        let mirror = Mirror(reflecting: value)
        if mirror.subjectType == String.self {
            type = .String
            stringValue = value as! String
        } else if (mirror.subjectType == Float.self) {
            type = .Double
            numericValue = NSNumber(value: value as! Float)
        } else if (mirror.subjectType == Double.self) {
            type = .Double
            numericValue = NSNumber(value: value as! Double)
        } else if (mirror.subjectType == Data.self) {
            type = .Blob
            blobValue = value as! Data
        } else if (mirror.subjectType == Int.self) {
            type = .Int
            numericValue = NSNumber(value: value as! Int)
        } else if (mirror.subjectType == Int64.self) {
            type = .Int
            numericValue = NSNumber(value: value as! Int64)
        } else if (mirror.subjectType == UInt64.self) {
            type = .Int
            numericValue = NSNumber(value: value as! UInt64)
        } else if (value is NSNumber) {
            type = .Double
            numericValue = value as! NSNumber
        } else if (value is NSString) {
            type = .String
            stringValue = value as! String
        } else {
            type = .Null
        }
    }
    
    public func asBool() -> Bool {
        if type == .Int {
            return numericValue.boolValue
        }
        return false
    }
    
    public func asAny() -> Any? {
        
        if type == .String {
            return stringValue
        }
        
        if type == .Int {
            return numericValue.intValue
        }
        
        if type == .Double {
            return numericValue.doubleValue
        }
        
        if type == .Blob {
            return blobValue
        }
        
        return nil
    }
    
    public func asString() -> String? {
        if type == .String {
            return stringValue
        }
        return nil
    }
    
    public func asInt() -> Int? {
        
        if type == .Int {
            return numericValue.intValue
        }
        
        return nil
    }
    
    public func asInt64() -> Int64? {
        
        if type == .Int {
            return numericValue.int64Value
        }
        
        return nil
    }
    
    public func asUInt64() -> UInt64? {
        
        if type == .Int {
            return numericValue.uint64Value
        }
        
        return nil
    }
    
    public func asDouble() -> Double? {
        
        if type == .Double {
            return numericValue.doubleValue
        }
        
        return nil
    }
    
    public func getType() -> DataType {
        return type
    }
    
}

public class Action {
    
    var builtStatement: String
    var actionType: ActionType
    
    public init(createTable: String) {
        actionType = .CreateTable
        builtStatement = "CREATE TABLE IF NOT EXISTS \(createTable) (_id_ TEXT PRIMARY KEY, _timestamp_ TEXT); "
    }
    
    public init(createIndexOnTable: String, keyColumnName: String, ascending: Bool) {
        actionType = .CreateIndex
        
        if ascending {
            builtStatement = "CREATE INDEX IF NOT EXISTS idx_\(createIndexOnTable)_\(keyColumnName) ON \(createIndexOnTable) (\(keyColumnName) ASC);"
        } else {
            builtStatement = "CREATE INDEX IF NOT EXISTS idx_\(createIndexOnTable)_\(keyColumnName) ON \(createIndexOnTable) (\(keyColumnName) DESC);"
        }
        
    }
    
    public init(addColumn: String, type: DataType, table: String) {
        
        self.actionType = .AddColumn
        
        switch type {
        case .String:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) TEXT;"
        case .Double:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) NUMERIC;"
        case .Int:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) INTEGER;"
        case .Blob:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) BLOB;"
        default:
            builtStatement = "ALTER TABLE \(table) ADD COLUMN \(addColumn) BLOB;"
        }
        
    }
    
}

public class Result {
    
    public var results: [Record] = []
    public var error: String? = nil
    
    public init() {
        
    }
    
}

public class SWSQLite {
    
    var db: OpaquePointer?
    
    public init(path: String) {
        let _ = sqlite3_open(path, &db);
    }
    
    public func close() {
        sqlite3_close(db)
        db = nil;
    }
    
    public func execute(sql: String, params:[Any], silenceErrors: Bool) -> Result {
        
        let result = Result()
        
        var values: [Value] = []
        for o in params {
            values.append(Value(o))
        }
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, Int32(sql.utf8.count), &stmt, nil) == SQLITE_OK {
            
            bind(stmt: stmt, params: values);
            while sqlite3_step(stmt) != SQLITE_DONE {
                
            }
            
        } else {
            // error in statement
            if !silenceErrors {
                result.error = "\(String(cString: sqlite3_errmsg(db)))"
            }
        }
        
        sqlite3_finalize(stmt)
        
        return result
        
    }
    
    public func execute(compiledAction: SWSQLAction) -> Result {
        return execute(sql: compiledAction.statement, params: compiledAction.parameters)
    }
    
    public func execute(sql: String, params:[Any]) -> Result {
        
        return execute(sql: sql, params: params, silenceErrors: false)
        
    }
    
    public func execute(actions: [Action]) -> Result {
        
        var result = Result()
        
        for action in actions {
            result = execute(sql: action.builtStatement, params: [], silenceErrors: true)
        }
        
        return result
        
    }
    
    public func query(sql: String, params:[Any]) -> Result {
        
        let result = Result()
        var results: [[String:Value]] = []
        
        var values: [Value] = []
        for o in params {
            values.append(Value(o))
        }
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, Int32(sql.utf8.count), &stmt, nil) == SQLITE_OK {
            bind(stmt: stmt, params: values);
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                var rowData: Record = [:]
                let columns = sqlite3_column_count(stmt)
                if columns > 0 {
                    for i in 0...Int(columns-1) {
                        
                        let columnName = String.init(cString: sqlite3_column_name(stmt, Int32(i)))
                        var value: Value
                        
                        switch sqlite3_column_type(stmt, Int32(i)) {
                        case SQLITE_INTEGER:
                            value = Value(Int(sqlite3_column_int64(stmt, Int32(i))))
                        case SQLITE_FLOAT:
                            value = Value(Double(sqlite3_column_double(stmt, Int32(i))))
                        case SQLITE_TEXT:
                            value = Value(String.init(cString:sqlite3_column_text(stmt, Int32(i))))
                        case SQLITE_BLOB:
                            value = Value(NSData(bytes:sqlite3_column_blob(stmt, Int32(i)), length: Int(sqlite3_column_bytes(stmt, Int32(i)))))
                        case SQLITE_NULL:
                            value = Value(NSNull())
                        default:
                            value = Value(NSNull())
                            break;
                        }
                        
                        rowData[columnName] = value
                        
                    }
                }
                results.append(rowData)
                
            }
        } else {
            // error in statement
            result.error = "\(String(cString: sqlite3_errmsg(db)))"
        }
        
        result.results = results
        
        sqlite3_finalize(stmt)
        
        return result
        
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
                var s = v.stringValue!
                // check for special replacement strings
                
                if s == "%uuid%" {
                    s = uuid()
                } else if s == "%clustertime%" {
                    s = timeuuid()
                }
                
                sqlite3_bind_text(stmt, paramCount, s,Int32(s.characters.count) , SQLITE_TRANSIENT)
            case .Null:
                sqlite3_bind_null(stmt, paramCount)
            case .Blob:
                sqlite3_bind_blob(stmt, paramCount, [UInt8](v.blobValue!), Int32(v.blobValue!.count), SQLITE_TRANSIENT)
            case .Double:
                sqlite3_bind_double(stmt, paramCount, v.numericValue.doubleValue)
            case .Int:
                sqlite3_bind_int64(stmt, paramCount, v.numericValue.int64Value)
            }
            
            paramCount += 1
            
        }
        
    }
    
}

public class SWSQLAction {
    
    var statement: String
    var parameters: [Any]
    var op: SWSQLOp
    
    public init (stmt: String, params: [Any], operation: SWSQLOp) {
        self.statement = stmt
        self.parameters = params
        self.op = operation
    }
    
}
