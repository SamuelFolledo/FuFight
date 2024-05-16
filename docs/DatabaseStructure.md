# Firebase Firestore Database Structure

## Game

- Lobbies = will contain a list of players looking for an opponent
    - lobbyId/p1Id, p1FighterType, p1Moves, p1Rating
- Games = will contain a list of games currently happening between 2 players
    - /lobbyId
        - /Rounds
            - /roundNumber
                - createdAt, p1SelectedMoves, p2SelectedMoves
        - p1Id, p2Id
        - p1Moves, p2Moves
        - p1FighterType, p2FighterType
- Histories = will contain a list of game history results
    - /userId/History/lobbyIds
        - enemyId, username, winnerId (or didWin boolean), winnerHpLeft, roundNumber, experienceGained, createDate,
