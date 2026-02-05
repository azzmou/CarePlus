//
//  TaskRow.swift
//  Care+
//

import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onPlay: () -> Void

    var body: some View {
        CardDark {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(task.isDone ? AppTheme.success : .white.opacity(0.7))
                }
                .buttonStyle(.plain)

                if let data = task.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundStyle(task.isDone ? .white.opacity(0.7) : .white)
                        .strikethrough(task.isDone, color: .white.opacity(0.6))

                    Text(task.createdAt.formatted(.dateTime.day().month().hour().minute()))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    if task.audioURL != nil { MiniChip(icon: "mic.fill", text: "Audio") }
                    if task.imageData != nil { MiniChip(icon: "photo", text: "Photo") }
                    if let p = task.phone, !p.isEmpty { MiniChip(icon: "phone.fill", text: p) }
                }

                Spacer()

                if task.audioURL != nil {
                    Button(action: onPlay) {
                        Image(systemName: "play.fill")
                            .font(.headline)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.white.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
