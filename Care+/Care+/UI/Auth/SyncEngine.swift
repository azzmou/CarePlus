import Foundation
import Supabase

enum SyncEngine {
    private static var pushTask: Task<Void, Never>?

    // ✅ allineate con AppState
    private static let tasksKey = "tasks_v1"
    private static let diaryKey = "diary_v1"

    static func fullSync(state: AppState) async {
        guard let uid = state.sessionUserId else { return }

        // Local scoped
        let localTasks = Persistence.load([TaskItem].self, key: tasksKey, userId: uid, defaultValue: [])
        let localDiary = Persistence.load([DiaryEntry].self, key: diaryKey, userId: uid, defaultValue: [])

        // Remote best-effort
        let client = SupabaseClientProvider.shared.client
        var remoteTasks: [TaskItem] = []
        var remoteDiary: [DiaryEntry] = []

        do {
            remoteTasks = try await client.database
                .from("tasks")
                .select()
                .eq("user_id", value: uid)
                .execute()
                .value
        } catch { }

        do {
            remoteDiary = try await client.database
                .from("diary_entries")
                .select()
                .eq("user_id", value: uid)
                .execute()
                .value
        } catch { }

        // Merge
        let mergedTasks = mergeByUpdatedAt(local: localTasks, remote: remoteTasks, id: { $0.id }, updatedAt: { $0.updatedAt })
        let mergedDiary = mergeByUpdatedAt(local: localDiary, remote: remoteDiary, id: { $0.id }, updatedAt: { $0.updatedAt })

        // Save local
        Persistence.save(mergedTasks, key: tasksKey, userId: uid)
        Persistence.save(mergedDiary, key: diaryKey, userId: uid)

        // Update memory
        state.tasks = mergedTasks
        state.diary = mergedDiary

        // Push deltas (debounced)
        schedulePush(state: state)
    }

    static func schedulePush(state: AppState) {
        pushTask?.cancel()
        pushTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await pushNow(state: state)
        }
    }

    private static func pushNow(state: AppState) async {
        guard let uid = state.sessionUserId else { return }
        let client = SupabaseClientProvider.shared.client

        let tasks = state.tasks
        let diary = state.diary

        struct TaskRow: Encodable {
            let user_id: String
            let item_id: String
            let payload: Data
            let updated_at: Date
            let created_at: Date
        }

        struct DiaryRow: Encodable {
            let user_id: String
            let item_id: String
            let date: Date
            let text: String
            let mood: String?
            let updated_at: Date
            let created_at: Date
        }

        let taskRows: [TaskRow] = tasks.map { t in
            let payload = (try? JSONEncoder().encode(t)) ?? Data()
            return TaskRow(
                user_id: uid,
                item_id: t.id.uuidString,
                payload: payload,
                updated_at: t.updatedAt,
                created_at: t.createdAt
            )
        }

        let diaryRows: [DiaryRow] = diary.map { e in
            DiaryRow(
                user_id: uid,
                item_id: e.id.uuidString,
                date: e.date,
                text: e.text,
                mood: e.mood?.rawValue,
                updated_at: e.updatedAt,
                created_at: e.createdAt
            )
        }

        do { try? await client.database.from("tasks").upsert(taskRows).execute() } catch { }
        do { try? await client.database.from("diary_entries").upsert(diaryRows).execute() } catch { }
    }

    // MARK: - Generic merge (robusto, no Mirror/KVC)
    private static func mergeByUpdatedAt<T: Codable, Key: Hashable>(
        local: [T],
        remote: [T],
        id: (T) -> Key,
        updatedAt: (T) -> Date
    ) -> [T] {
        var dict: [Key: T] = [:]
        for l in local { dict[id(l)] = l }
        for r in remote {
            let k = id(r)
            if let existing = dict[k] {
                if updatedAt(r) > updatedAt(existing) { dict[k] = r }
            } else {
                dict[k] = r
            }
        }
        return Array(dict.values)
    }
}
