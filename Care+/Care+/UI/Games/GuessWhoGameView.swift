//
//  GuessWhoGameView.swift
//  Care+
//

import SwiftUI

struct GuessWhoGameView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    // Game config
    private let totalRounds = 10
    private let optionsCount = 4

    // Runtime
    @State private var startedAt: Date?
    @State private var elapsedSeconds: Int = 0

    @State private var roundIndex: Int = 0
    @State private var currentTarget: ContactItem?
    @State private var currentOptions: [ContactItem] = []

    @State private var selectedKey: String? = nil
    @State private var revealState: RevealState = .idle

    @State private var attemptsThisRound: Int = 0
    @State private var correctCount: Int = 0
    @State private var totalAttempts: Int = 0

    @State private var roundResults: [GuessWhoRoundResult] = []

    @State private var showFinish = false
    @State private var lastMessage: String = ""

    enum RevealState { case idle, correct, wrong }

    private var eligibleContacts: [ContactItem] {
        state.contacts.filter {
            Validators.nonEmpty($0.name)
            && Validators.nonEmpty($0.relation ?? "")
            && $0.photoData != nil
        }
    }

    private var canStart: Bool { eligibleContacts.count >= 5 }

    var body: some View {
        Screen {
            CardDark {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Guess Who")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(textPrimary)

                        Text("Round \(min(roundIndex + 1, totalRounds))/\(totalRounds)")
                            .font(.caption)
                            .foregroundStyle(textSecondary)
                    }
                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        MiniChip(icon: "timer", text: "\(elapsedSeconds)s")
                        MiniChip(icon: "checkmark.circle", text: "\(correctCount)/\(totalRounds)")
                    }
                }

                if !canStart {
                    Text("To start, add at least 5 contacts with: Name + Role + Photo.")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 6)
                }
            }

            if startedAt == nil {
                CardDark {
                    Text("Ready?")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(textPrimary)

                    Button {
                        startGame()
                    } label: {
                        Text("START (10 rounds)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .opacity(canStart ? 1 : 0.45)
                    }
                    .disabled(!canStart)

                    Button {
                        dismiss()
                    } label: {
                        Text("Back")
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.top, 6)
                    }
                }
            } else {
                if let target = currentTarget {
                    CardDark {
                        Text("Who is this?")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(textPrimary)

                        if let data = target.photoData, let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.10))
                                .frame(height: 220)
                                .overlay(Text("Missing photo").foregroundStyle(textSecondary))
                        }

                        if !lastMessage.isEmpty {
                            Text(lastMessage)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(revealState == .correct ? .green : (revealState == .wrong ? .red : textSecondary))
                                .padding(.top, 6)
                        }
                    }

                    // Options
                    CardDark {
                        VStack(spacing: 10) {
                            ForEach(currentOptions, id: \.uniqueKey) { c in
                                optionButton(contact: c, target: target)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    nextRound()
                                } label: {
                                    Text(roundIndex == totalRounds - 1 ? "FINISH" : "NEXT")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, minHeight: 52)
                                        .background(Color.white)
                                        .foregroundStyle(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                .disabled(revealState == .idle) // must attempt at least once

                                Button {
                                    retryRound()
                                } label: {
                                    Text("RETRY")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, minHeight: 52)
                                        .background(Color.white.opacity(0.18))
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                        )
                                }
                                .disabled(revealState != .wrong)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            // timer loop
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                guard let startedAt else { return }
                let diff = Int(Date().timeIntervalSince(startedAt))
                DispatchQueue.main.async { elapsedSeconds = max(0, diff) }
            }
        }
        .fullScreenCover(isPresented: $showFinish) {
            GuessWhoFinishView(
                state: state,
                durationSeconds: elapsedSeconds,
                correctCount: correctCount,
                totalRounds: totalRounds,
                totalAttempts: totalAttempts,
                roundResults: roundResults,
                onRetry: {
                    resetAndStartAgain()
                },
                onClose: {
                    dismiss()
                }
            )
        }
    }

    // MARK: - UI helpers

    @ViewBuilder
    private func optionButton(contact: ContactItem, target: ContactItem) -> some View {
        let isSelected = (selectedKey == contact.uniqueKey)
        let isCorrectOption = (contact.uniqueKey == target.uniqueKey)

        let borderColor: Color = {
            switch revealState {
            case .idle:
                return isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.18)
            case .correct:
                return isCorrectOption ? .green : Color.white.opacity(0.10)
            case .wrong:
                if isCorrectOption { return .green }
                if isSelected { return .red }
                return Color.white.opacity(0.10)
            }
        }()

        Button {
            choose(contact: contact, target: target)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundStyle(textPrimary)
                    if let r = contact.relation, !r.isEmpty {
                        Text(r)
                            .font(.caption)
                            .foregroundStyle(textSecondary)
                    }
                }
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(revealState == .correct) // after correct, lock options
    }

    // MARK: - Game flow

    private func startGame() {
        guard canStart else { return }
        startedAt = Date()
        elapsedSeconds = 0
        roundIndex = 0
        correctCount = 0
        totalAttempts = 0
        roundResults = []
        prepareRound()
    }

    private func resetAndStartAgain() {
        startedAt = nil
        selectedKey = nil
        revealState = .idle
        attemptsThisRound = 0
        lastMessage = ""
        currentTarget = nil
        currentOptions = []
        showFinish = false
        startGame()
    }

    private func prepareRound() {
        guard canStart else { return }

        selectedKey = nil
        revealState = .idle
        attemptsThisRound = 0
        lastMessage = ""

        // target random (can repeat across rounds)
        let target = eligibleContacts.randomElement()
        currentTarget = target

        guard let target else { return }

        // pick 3 other random different contacts
        var pool = eligibleContacts.filter { $0.uniqueKey != target.uniqueKey }
        pool.shuffle()
        let others = Array(pool.prefix(optionsCount - 1))

        var options = others + [target]
        options.shuffle()
        currentOptions = options
    }

    private func choose(contact: ContactItem, target: ContactItem) {
        // ignore if already correct
        if revealState == .correct { return }

        attemptsThisRound += 1
        totalAttempts += 1

        selectedKey = contact.uniqueKey

        if contact.uniqueKey == target.uniqueKey {
            revealState = .correct
            correctCount += 1
            lastMessage = "Great! +1 ✅"
        } else {
            revealState = .wrong
            lastMessage = "Almost! Want to retry or go next?"
        }
    }

    private func retryRound() {
        // keep same target+options, just let user try again (attempts count continues)
        revealState = .idle
        selectedKey = nil
        lastMessage = "Try again 💜"
    }

    private func nextRound() {
        guard let target = currentTarget else { return }
        guard revealState != .idle else { return } // must have attempted

        let isCorrect = (revealState == .correct)
        roundResults.append(
            GuessWhoRoundResult(
                roundIndex: roundIndex,
                contactKey: target.uniqueKey,
                isCorrect: isCorrect,
                attempts: max(1, attemptsThisRound)
            )
        )

        if roundIndex >= totalRounds - 1 {
            finishGame()
        } else {
            roundIndex += 1
            prepareRound()
        }
    }

    private func finishGame() {
        showFinish = true

        let started = startedAt ?? Date()
        let finished = Date()

        let result = GameSessionResult(
            type: .guessWho,
            startedAt: started,
            finishedAt: finished,
            durationSeconds: elapsedSeconds,
            totalRounds: totalRounds,
            correctCount: correctCount,
            totalAttempts: totalAttempts,
            roundResults: roundResults
        )

        state.addGameResult(result)
    }
}

